# Running GLM-5.2 On-Prem on Blackwell GPUs: How We Sidestepped vLLM's SM120 Sparse-Attention Bug

*Draft — based on `feat-2-glm-5.2-onprem-deployment`, status as of 2026-08-20.*

## 1. Overview

We wanted a second, quality-first coding model running on our own hardware — a
Dell 7960T with four RTX Pro 6000 Blackwell Max-Q GPUs (96 GB VRAM each, 384 GB
total) and 512 GB of system RAM — served behind an OpenAI-compatible API for
OpenCode and OpenWebUI. GLM-5.2 (`zai-org/GLM-5.2`, MIT-licensed, 744B
parameters with 40B active per token, MoE architecture with DeepSeek Sparse
Attention) was the candidate: strong coding/agentic benchmarks, a 1M-token
advertised context, and flexible reasoning-effort modes.

This is a sister effort to an earlier feature (`feat-1`) that deployed
DeepSeek-V4 on the same box. GLM-5.2 was originally deferred out of that
feature as a fallback option — and it inherited one specific, unresolved risk
from it: `feat-1`'s vLLM deployment of DeepSeek-V4-Flash was blocked by a
sparse-attention decode bug on these same SM120 GPUs. GLM-5.2 uses the same
*class* of sparse-attention kernel (DeepSeek Sparse Attention / IndexShare),
so nothing guaranteed a different model on the same hardware would fare any
better under the same engine.

The other headline fact shaping this feature: GLM-5.2's official BF16 weights
are ~1.5 TB — too large for this box's 384 GB VRAM or even its combined
896 GB VRAM+RAM pool. Since no native sub-BF16 checkpoint exists for this
model, we explicitly accepted GGUF requantization for GLM-5.2 (a deliberate,
scoped exception to `feat-1`'s "native weights only" rule for DeepSeek).
Because our box is far larger than the reference hardware unsloth's quants
were sized for, this didn't force a quality compromise: the near-lossless
5-bit `UD-Q5_K_XL` quant (570 GB, ~99.9% KLD-preserving) fits comfortably in
a GPU/CPU-RAM hybrid layout.

## 2. Step by step — and why vLLM was never the answer here

**Start with the risk, not the environment prep.** Normally you'd begin with
disk space, drivers, and downloads. We inverted that order deliberately: the
dominant risk wasn't capacity, it was correctness. If GLM-5.2's sparse-decode
path hit the same wall DeepSeek-V4 did, none of the capacity planning would
matter. So Phase 1 was a pure correctness spike, run *before* touching the
multi-hundred-gigabyte downloads.

**Why vLLM was sidelined from the start.** `feat-1` had already spent
significant effort root-causing a vLLM bug: on `sm_120` (Blackwell) GPUs,
vLLM's `FLASHINFER_MLA_SPARSE_DSV4` sparse-MLA decode kernel produced
degenerate output — the exact same frozen token repeated at every decode
position, with the exact same log-probability, regardless of prompt or
position. That's a classic "forward pass returning garbage" signature, not a
sampling quirk. Every local hypothesis was tested and ruled out (CUDA graphs,
KV-cache precision, quantization fallback, a vLLM/FlashInfer version bump,
even a from-scratch clean venv to rule out install contamination) before it
was filed upstream as [`vllm-project/vllm#52938`](https://github.com/vllm-project/vllm/issues/52938).
Since GLM-5.2's DSA decode is the same kernel *class*, we treated "vLLM will
probably work this time" as an assumption to test, not a plan to build on.

**Picking a Plan B with a genuinely different code path.** Instead of
re-running into the same bug with a different model, we looked for an engine
whose CUDA kernels for this attention pattern were a structurally separate
implementation. Three candidates were on the table:

- **vLLM** — the default/familiar choice, but shares the exact kernel family
  already implicated in `feat-1`.
- **SGLang** — a distinct SM120 code path, but still an unknown quantity here.
- **llama.cpp / `llama-server`** — its GGUF CUDA kernels are a *completely
  separate codebase* from vLLM's FlashInfer sparse-MLA path, so it can't
  inherit that specific bug, and it consumes the unsloth Dynamic GGUFs
  natively. The known trade-off: llama.cpp's OpenAI-compatible tool-calling
  is historically weaker than vLLM/SGLang's, which matters for OpenCode's
  agentic use.

We led the correctness spike with llama.cpp precisely because it carried the
lowest SM120 risk. A dedicated build was cloned and compiled with CUDA/SM120
support, then run against a small 1-bit spike quant (`UD-IQ1_S`) with a
greedy, temperature=0 smoke test — the same diagnostic condition that exposed
the vLLM bug in `feat-1`. The result was coherent, grammatically sound
chain-of-thought output with naturally varying log-probabilities — nothing
like the flat, frozen-token signature. We repeated it with more prompts
(chit-chat, factual, code) and forced non-thinking mode to get finished
answers, running each case twice to confirm determinism: byte-identical both
times, including a correct answer to "capital of France" and a working
recursive `factorial()` implementation.

Because the first engine tried already worked, **we never had to actually run
vLLM against GLM-5.2 at all** — the "try the next engine" fallback (Task 1.3)
was moot. That's the payoff of leading with the spike: rather than discover a
second engine-specific failure the hard way, one clean data point (llama.cpp
works; vLLM's bug is model-independent in its signature) was enough to both
unblock this feature and strengthen the case, back in `feat-1`, that the
original bug is FlashInfer/vLLM-specific rather than an SM120-fundamental
limitation.

**What we ran into after the engine was settled.** The correctness spike was
the biggest unknown, but far from the only friction:

- **MoE placement across four GPUs is not automatic.** A naive `--cpu-moe`
  (push all experts to CPU RAM) nearly filled the box's 512 GB RAM pool for a
  model that is almost entirely MoE weight. A naive partial split
  (`--n-cpu-moe` alone, no explicit tensor split) let one GPU get assigned a
  full, undiminished chunk of expert weight before the CPU cutoff applied,
  causing a hard `cudaMalloc` OOM. The fix was an explicit, metadata-derived
  split (`--n-cpu-moe 54 --tensor-split 54,9,8,8`) that caps every GPU's
  share safely.
- **Quant choice needed a per-GPU check, not just a pool-level one.** The
  aggregate "does it fit in 896 GB" math looked fine well before the real
  constraint — an uneven tensor split — was accounted for. Only a per-GPU
  headroom analysis (worst case ~27–28% free at the target context) actually
  confirmed `UD-Q5_K_XL` as safe.
- **"Just use the full 1M context" failed a back-of-envelope check before we
  wasted a load cycle on it.** Extrapolating measured KV-cache growth to 1M
  tokens projected the tightest GPU down to ~4% free — well under our
  adopted safety margin. Two intermediate sizes were tested instead: 768K
  passed with comfortable margin on every GPU; 896K narrowly missed the
  margin on one GPU. We shipped 768K — still more than double the 350–370K
  requirement — and flagged 896K as a revisit candidate pending a possible
  PCIe-aware rebalancing.
- **Cold-load time is a recurring cost, not a one-off, because this box is
  power-cycled daily.** A direct-read load mode (`--load-mode none`) measured
  8% faster than the default `mmap` behavior for this ~560 GB quant — worth
  adopting given the load happens every working day, not just once.
- **An unrelated RAID consistency check masqueraded as a stuck model load.**
  A background `mdadm` array scrub was competing for disk I/O during a load
  benchmark, dropping read throughput and making the (silent, no-progress-
  output) loader look hung. Diagnosing it via `/proc/<pid>/io` read-rate
  samples, rather than assuming a crash, avoided a false "the loader is
  broken" conclusion.
- **Service management needed a deliberate choice, not just "systemd."** We
  installed it as a `systemctl --user` unit (no `sudo` needed for routine
  start/stop) with lingering enabled so it survives logout — but *not*
  enabled for autostart, since lingering plus an enabled unit together would
  have silently started the service on every reboot, which wasn't the actual
  requirement. This combination was caught and corrected live before it
  caused an unwanted autostart.

## 3. Summary and results

The core question this feature needed to answer — *can we run GLM-5.2's
sparse-attention decode path correctly on our SM120 GPUs at all* — is
answered: **yes, via llama.cpp**, not vLLM. vLLM's known SM120
sparse-attention decode bug from the DeepSeek-V4 deployment was treated as a
standing risk rather than assumed away, de-risked with a cheap spike before
any large investment, and resolved by picking an engine with a genuinely
independent CUDA code path instead of chasing the same bug across models.

Where things stand:

- **Engine**: `llama.cpp`/`llama-server`, custom CUDA build with SM120
  support — confirmed correct, deterministic, and factually accurate output
  on GLM-5.2's DSA decode path.
- **Quant**: `UD-Q5_K_XL` (near-lossless 5-bit unsloth Dynamic GGUF, ~570 GB),
  chosen over the lossier fallback because this hardware has enough headroom
  to avoid a quality compromise — the opposite situation from our earlier
  DeepSeek-V4-Pro deployment.
- **Placement**: `--n-cpu-moe 54 --tensor-split 54,9,8,8`, empirically
  calibrated to avoid uneven per-GPU overload.
- **Context**: 768K tokens in production — more than double the 350–370K
  requirement, with real per-GPU margin measured, not just projected.
- **Operations**: systemd `--user` service, no `sudo` for day-to-day
  start/stop, lingering enabled without autostart, `vm.swappiness` tuned down
  as a safety net without disabling swap outright.

What's still open at the time of writing: the service's first full startup
under the production configuration was in progress (cold-loading the ~560 GB
quant), with the tool-calling and reasoning-mode verification, an end-to-end
768K-context validation, a decode-throughput benchmark, and the final
side-by-side quality comparison against DeepSeek-V4 still ahead. The hard,
uncertain part — proving this model's sparse-attention path isn't
categorically broken on our hardware, the way another model's was under a
different engine — is done.
