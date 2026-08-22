# Serving GLM-5.2 On-Prem on 4x RTX PRO 6000 Blackwell (and why vLLM did not work)

In this post I show you how I got [GLM-5.2](https://huggingface.co/zai-org/GLM-5.2) (`zai-org/GLM-5.2`, MIT license, 744B parameters/40B active MoE, official Z.ai announcement at [z.ai/blog/glm-5.2](https://z.ai/blog/glm-5.2)) running on our on-prem hardware behind an OpenAI-compatible endpoint, for use with our coding framwork [`OpenCode`](https://opencode.ai/). 

Note: Originally I tried to install DeepSeek-V4 on our system, which did not succeed due to an unresolved vLLM bug on our sm120 GPUs. GLM-5.2 uses a similar sparse-attention mechanism, so at first, I could not assume that it would just work where DeepSeek-V4 did not.

# Overview

The hardware is a Dell Precision 7960T with 4x [NVIDIA RTX PRO 6000 Blackwell Max-Q](https://www.nvidia.com/en-us/products/workstations/professional-desktop-gpus/rtx-pro-6000-max-q/) (96 GB VRAM each, 384 GB total) and 512 GB system RAM - a nominal 896 GB combined (minus the usual "overhead") - and no NVLink.

The official GLM-5.2 weights are BF16, which is about 1.5 TB in size. That obviously does not fit in 384 GB VRAM, and it does not fit in the 896 GB combined pool either. There is no native sub-BF16 checkpoint for this model, so - unlike the DeepSeek-V4 deployment, where I wanted to use native weights only - I went for a GGUF requantization here. [unsloth](https://huggingface.co/unsloth) provides a Dynamic GGUFs at [unsloth/GLM-5.2-GGUF](https://huggingface.co/unsloth/GLM-5.2-GGUF). The memory table looks like this:

- 1-bit `UD-IQ1_S`: 223 GB
- 2-bit `UD-IQ2_M`: 245 GB
- 4-bit `UD-Q4_K_XL`: 372–475 GB
- 5-bit `UD-Q5_K_XL`: 570 GB
- 8-bit `UD-Q8_K_XL`: 810 GB.

The unsloth reference config runs the 2-bit quant on a single 24 GB GPU + 256 GB RAM. Our system is much bigger than that, so I did not need to drop to a lossy quant at all - the near-lossless 5-bit `UD-Q5_K_XL` (~99.9% KLD-preserving per the unsloth numbers) fits comfortably. That is the opposite situation to DeepSeek-V4-Pro, which did force a precision compromise.

# Step by step

## Why I did not start with vLLM

On the DeepSeek-V4 deployment, the vLLM `FLASHINFER_MLA_SPARSE_DSV4` sparse-attention decode kernel produces broken output on our `sm_120` (Blackwell) GPUs. At `temperature=0` every single decode position returns the exact same token with the exact same log-probability, no matter the prompt:

```
<|begin▁of▁sentence|>   logprob: -11.7697...
<|begin▁of▁sentence|>   logprob: -11.7697...
<|begin▁of▁sentence|>   logprob: -11.7697...
```

My robot told me: "That is not a sampling issue, it is a forward pass returning garbage." I ruled out:

- CUDA graphs (`--enforce-eager`)
- quantization fallback
- FP8 KV-cache

An we even rebuilt vLLM in a clean venv to rule out a broken local install - but still the same byte-for-byte output every time. It is filed upstream as [vllm-project/vllm#52938](https://github.com/vllm-project/vllm/issues/52938) and, at the time of this deployment, still unresolved.

GLM-5.2 uses the same class of kernel (DeepSeek Sparse Attention, tagged `glm_moe_dsa` on Hugging Face). So before touching a single gigabyte of download, I ran a correctness spike first, not environment prep.

## Picking an engine with a genuinely different code path

According to the unsloth model card, several frameworks are supported. These three framworks seemed most promosing:

1. **vLLM**

    my default, but it shares the exact kernel family already broken on this hardware for DeepSeek-V4

2. **SGLang**

    a distinct SM120 code path, unknown quantity

3. **llama.cpp / `llama-server`**

    its GGUF CUDA kernels are a completely separate codebase from the vLLM FlashInfer path, so it cannot inherit the same bug, and it eats the unsloth GGUFs directly

I decided for llama.cpp because it had the lowest chance of hitting the same error. Thus, we built a dedicated checkout with CUDA/SM120 support:

```
git clone https://github.com/ggml-org/llama.cpp /data/llama.cpp-dsa
cd /data/llama.cpp-dsa
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release -j
```

We confirmed the build actually targets Blackwell (`CMAKE_CUDA_ARCHITECTURES` includes `120a-real`), then ran a greedy, `temperature=0` smoke test on the small 1-bit spike quant (`UD-IQ1_S`), across all 4 GPUs:

```
llama-server -m UD-IQ1_S/GLM-5.2-UD-IQ1_S.gguf --ctx-size 4096 ...
```

Result: coherent, grammatical chain-of-thought text with naturally varying log-probabilities (`-0.0000649` to `-1.126`) - nothing like the frozen `-11.77` signature above. I pushed further with a few more prompts (chit-chat, factual, code) and `enable_thinking:false` to actually get finished answers, run twice each for determinism:

- "Say hello" - > `"Hello!"` (byte-identical both runs)
- "Capital of France?" - > `"Paris"` (correct, byte-identical both runs)
- "Write a recursive factorial function" - > a correct Python implementation (byte-identical both runs)

No frozen tokens, no repeats-forever pattern. **The llama.cpp GLM-5.2 DSA decode path works correctly on our SM120 GPUs.** Because the first engine I tried already worked, I never had to test vLLM against GLM-5.2 at all - which, as a side effect, gives the bug filed as [vllm-project/vllm#52938](https://github.com/vllm-project/vllm/issues/52938) a second data point: it looks engine-specific (vLLM/FlashInfer), not fundamentally broken on this hardware.

## MoE placement across four GPUs is not automatic

GLM-5.2 is 744B total / 40B active - nearly all of that is MoE expert weight. We hit two unsafe configurations before landing on a working one, both while measuring real KV-cache cost per context size:

**Attempt 1** - `--cpu-moe` (push all experts to CPU RAM). Reasoning: keep VRAM free for the KV cache under test. Actual result: this pushes ~500 GiB of the 562 GiB `UD-Q5_K_XL` quant onto a 512 GiB RAM pool. Swap climbed from 0 to ~1.4 GiB in under a minute. Killed it as a precaution.

**Attempt 2** - `--n-cpu-moe 41` alone, no explicit tensor split. Assumption: llama.cpp spreads GPU-offloaded MoE blocks evenly. It does not - blocks are assigned to GPUs in contiguous chunks before the CPU cutoff is applied. One GPU ended up with a full, undiminished chunk of expert weight:

```
cudaMalloc failed: out of memory
  ... buffer of size 138774596736
```

`~129 GiB` on a `96 GiB` device - not good.

**Fix** - explicit tensor split, calibrated from the GGUF metadata itself (`block_count=79`, ~6.6 GiB per MoE block):

```
llama-server \
  --n-cpu-moe 54 \
  --tensor-split 54,9,8,8 \
  --ctx-size <n> \
  ...
```

This concentrates the cheap CPU-side blocks on device 0 and caps the GPU-offloaded share of devices 1–3 at 53–59 GiB each. First probe (`ctx=4096`) came back clean: ~186 GiB total across 4 GPUs, ~11.7 GiB system RAM used.

## Confirming the quant and the context size, per GPU, not per pool

Running the same `--n-cpu-moe 54 --tensor-split 54,9,8,8` config across a ramp of context sizes (4K - > 32K - > 128K - > 256K - > 512K tokens) all succeeded, up to 524,288 tokens - well past my initial 350–370K requirement. The aggregate number (~233–235 GiB at 350–370K vs the 896 GB pool) looked fine, but we found out, that this was not the real gate: the tensor split leaves each GPU capped at 97,288 MiB individually, and uneven. So we pulled the per-GPU numbers instead. Worst case is found at the 512K context size:

- CUDA0: 38,717 MiB free (39.8%)
- CUDA1 (worst): 26,153 MiB free (26.9%)
- CUDA2: 33,686 MiB free (34.6%)
- CUDA3: 45,727 MiB free (47.0%)

Since KV-cache memory use only grows with context size, that 512K measurement is a guaranteed floor for the actual 350–370K target. All well above our own safety-margin rule of >=15% free per GPU or >=10 GiB, whichever is larger. **`UD-Q5_K_XL` confirmed as the production quant** - no need for the 4-bit fallback.

We also checked whether the full 1M-token context GLM-5.2 advertises was realistic before burning a load cycle on it. Extrapolating the same per-GPU numbers to 1M tokens puts the tightest GPU at ~4% free - clearly not safe. Two in-between sizes got us to the closest the system would be able to support:

- 768,000 tokens: worst GPU 22,569 MiB free (23.2%) - passes comfortably
- 896,000 tokens: worst GPU 14,079 MiB free (14.5%) - misses my 15% rule by about 500 MiB (still clears the flat >=10 GiB leg)

**Production `--ctx-size` == 768000.** Still more than double my 350–370K requirement. 896K stays on the list as something to revisit if I ever rebalance the tensor split (GPU0/GPU2 sit on PCIe 5.0, GPU1/GPU3 on PCIe 4.0 - there is a plausible angle there, just not explored yet).

## Cold-load time is a recurring cost

This system often gets power-cycled (at this time, it is not a 24/7 system), so a slow cold load is more than just a nuisance. I benchmarked the llama.cpp default `mmap` loading against `--load-mode none` (direct read) for the ~560 GB quant:

- `mmap` (default): 1842 s (~30.7 min)
- `--load-mode none`: 1694 s (~28.2 min)

This made startup about 8% faster. The per-GPU memory footprint was identical between the two, as expected - this setting only changes how tensors are staged on the CPU side, not where they end up on the GPU.

One thing that slowed us down here: a background `mdadm` RAID10 consistency check on the array holding the model file was competing for disk I/O during the benchmark, dropping read throughput from ~120 MB/s to ~53 MB/s. llama.cpp gives zero progress output during the multi-hundred-GB tensor-copy phase, so a slow load and a stuck load look identical from the outside.

## The systemd service

I run the model as a `systemctl --user` unit, so that I (and my trusty agent) do not need `sudo` for routine start/stop/restart during testing:

```
mkdir -p ~/.config/systemd/user
cp bin/08-llama-glm-5.2.service ~/.config/systemd/user/llama-glm-5.2.service
systemctl --user daemon-reload
```

I wanted the service to survive a logout without auto-starting at boot. That needs two separate mechanisms, and I initially only set up one of them:

```
loginctl enable-linger user
```

I also tuned `vm.swappiness` down to `1` (not `0` - I still want swap as an emergency net, just not the kernel proactively swapping during normal operation):

```
sudo tee /etc/sysctl.d/99-glm-swappiness.conf <<EOF
vm.swappiness = 1
EOF
sudo sysctl --system
```

## GLM-5.2_Q5-K-XL vs GLM-5.2_Q4-K-XL

I also tested the performance of the Q4 against the Q5 model: in my benchmarks the Q4 model is between 11.5 % and 13.1 % faster than the Q5 model with reasoning. Decoding also faster: 12.13 %. 

# Summary and results

What I set out to answer - can the GLM-5.2 sparse-attention decode path run correctly on our Blackwell GPUs at all - is answered: yes, with llama.cpp, but at this time, not with vLLM. The same class of bug that is still blocking the DeepSeek-V4 deployment under vLLM ([vllm-project/vllm#52938](https://github.com/vllm-project/vllm/issues/52938)) did not reappear here, because I deliberately picked an engine with a separate CUDA implementation instead of assuming vLLM would work a second time.

Where things stand right now:

- Engine: `llama.cpp` / `llama-server`, custom CUDA build, confirmed correct and deterministic on the GLM-5.2 DSA decode path.
- Quant: `UD-Q5_K_XL`, near-lossless 5-bit GGUF (~570 GB) - the hardware headroom meant no quality compromise was needed.
- Placement: `--n-cpu-moe 54 --tensor-split 54,9,8,8`.
- Context: 768,000 tokens in production, more than double my initial 350–370K requirement, with measured per-GPU margin.

All the scripts that we used to implement the service are in [this repository](https://github.com/dfch/biz.dfch.LlmOps) in [feat-2](https://github.com/dfch/biz.dfch.LlmOps/blob/dev/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md).

I use "Anthropic Claude Sonnet 5" via API from Opencode for all LLM coding tasks.

And as a side note: throughout the planning and implementation, I used [specngr](https://github.com/dfch/biz.dfch.SpecMgr). With `specmgr` I drive my agent from a specification to an actual implementation. This involves the planning, setting out requirements, recording decisions and updating progress. It is always nice to see that "waterfall" (read: incremental design and implementation) becomes more and more useful again these days ...
