# Qwen3.8-27B large-context deployment on GB10

**Session ID:** ses_fc75a334effeVp1oRPhEo93aAt
**Created:** 8/25/2026, 1:19:45 PM
**Updated:** 8/25/2026, 1:47:03 PM

---

## User

In @.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md we installed qwen3.8 with a large context on an NVIDIA DGX Spark clone. I need a plan to do this on this machine. What is the best approach?

---

## Assistant (Plan · Claude Sonnet 5 · 4.4s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "offset": 816
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md</path>
<type>file</type>
<content>
816:   NVFP4 data above — depends on: Task 4.3 — status: done 2026-08-23 —
817:   see RESULTS below; BF16 vs. NVFP4 performance is very different,
818:   Task 6.2 is warranted. Apples-to-apples plan:
819: 
820:   1. Reproduce Source A's exact decode benchmark (the Bubblesort
821:      prompt, `temperature=0`, streaming, median of 5 runs after
822:      warmup) against our live BF16 service, thinking on and off.
823:   2. Reproduce Source A's four unique-prefix prefill measurements
824:      (4,566 / 11,988 / 24,015 / 47,857 tokens, distinct prefix per
825:      request — no prefix-cache reuse) against our live BF16 service.
826:   3. Record our own already-measured FP8-KV-cache cost (~33.0 KB/token,
827:      BF16 weights, Task 2.1) next to Source A's 37,169 bytes/token
828:      (FP8 KV, NVFP4 weights) — since the architecture is confirmed
829:      equivalent, any material delta here is attributable to weight
830:      precision/packing, not architecture.
831:   4. Compute the throughput ratio between our BF16 result and Source
832:      A's `num_speculative_tokens=0` NVFP4 baseline specifically (11.4
833:      tok/s) — the only same-engine, no-speculative-decoding data point
834:      in either thread — to isolate the pure BF16-vs-NVFP4 precision
835:      effect from the separate, additive effect of speculative decoding
836:      (MTP/DFlash2).
837:   5. Explicitly record whether most of Source A/B's headline speedup
838:      (24-26 tok/s single-Spark MTP, up to 87 tok/s SGLang+DFlash2) comes
839:      from precision (BF16→NVFP4) or from speculative decoding (none→
840:      MTP/DFlash2) — if the latter dominates, adding MTP-style
841:      speculative decoding to our EXISTING BF16 deployment may be a
842:      lower-risk lever than a full NVFP4 requant, and should be
843:      considered as an alternative outcome of this task, not just
844:      "NVFP4 or nothing."
845: 
846:   **RESULTS (2026-08-23, executed live)** — ran all four planned
847:   measurements with a coordinated maintenance window: stopped the 896K
848:   BF16 production service, ran the NVFP4 checkpoint at native 262144
849:   context (`--gpu-memory-utilization 0.45`, reproducing Source A's exact
850:   recipe) in both `MTP=0` and `MTP=5` configurations, then restarted
851:   the BF16 production service and re-ran the SAME decode benchmark
852:   script against it for a rigorous, identically-methodology BF16
853:   baseline (superseding the rougher ~4.6 tok/s note from Task 1.2). All
854:   three configs passed the same tool-calling/thinking-mode/coherent-
855:   output smoke checks (Task 1.2/4.2 style) before benchmarking.
856: 
857:   | Config | Decode (thinking) | Decode (no-thinking) | Kernel used |
858:   |---|---|---|---|
859:   | Our BF16 production (896K ctx, FP8 KV, no spec decode) | 4.41 tok/s | 4.40 tok/s | n/a (BF16 GEMM) |
860:   | Our NVFP4, `MTP=0` (native 262144 ctx, FP8 KV) | 11.21 tok/s | 11.21 tok/s | `FlashInferCutlassNvFp4LinearKernel` (auto-selected) |
861:   | Our NVFP4, `MTP=5` (native 262144 ctx, FP8 KV) | 31.04 tok/s | 34.03 tok/s | same, + MTP draft head |
862:   | Source A reference, `num_speculative_tokens=0` | — | 11.4 tok/s | (their nightly build) |
863:   | Source A reference, `num_speculative_tokens=5` | 24.0 tok/s | 26.0 tok/s | (their nightly build) |
864: 
865:   Decomposed effects (median of 5 runs each, Bubblesort prompt,
866:   temperature=0, streaming — Source A's exact methodology):
867: 
868:   - **Precision-only effect, isolated (NVFP4 vs BF16, neither using
869:     speculative decoding)**: **2.54x** (11.21 / 4.405 tok/s avg).
870:   - **Speculative-decoding-only effect, isolated (MTP vs no-MTP, both
871:     NVFP4)**: **2.77x** (thinking) / **3.04x** (no-thinking).
872:   - **Combined effect (what a naive before/after would report)**:
873:     **7.05x** (thinking) / **7.73x** (no-thinking).
874:   - Our `MTP=0` result (11.21 tok/s) reproduces Source A's own
875:     no-spec-decode baseline (11.4 tok/s) within ~2% — validates the
876:     reproduction is sound and our stack behaves consistently with
877:     theirs at matched settings.
878:   - Our `MTP=5` result (31.04-34.03 tok/s) BEATS Source A's own
879:     `num_speculative_tokens=5` headline (24.0-26.0 tok/s) by **~29-31%**
880:     — attributed to our newer, stock vLLM 0.27.1 + FlashInfer
881:     0.6.16.post3 release vs. their August nightly dev build
882:     (`0.26.1rc1.dev244+...`), consistent with Task 6.2's kernel-check
883:     finding that our stock release closed real gaps present in their
884:     build.
885:   - **Prefill**: our unique-prefix measurements (2,388 / 2,316 / 2,136 /
886:     1,804 tok/s at 4,578 / 12,000 / 24,027 / 47,869 tokens) are
887:     meaningfully HIGHER than Source A's (1,734 / 1,153 / 1,014 /
888:     853 tok/s at closely-matching lengths) — same newer-stack
889:     explanation likely applies; no chunked-prefill flags were set
890:     explicitly on either side of our A/B, so this isn't a config
891:     artifact on our end.
892:   - **KV-cache efficiency**: our measured 33,571 bytes/token (27.56 GiB
893:     / 881,478 tokens, FP8 KV, native 262144 ctx — the 27.56 GiB figure
894:     matches Source A's exactly) is tighter than Source A's 37,169
895:     bytes/token — only 2.5% overhead above the 32,768-byte naive
896:     calculation vs. their 13.4% — another data point consistent with a
897:     more optimized build.
898:   - Conclusion for Task 6.2's decision criterion (adopt only if
899:     > =1.5-2x and it survives isolating speculative decoding): **BF16
900:     > performance is very different from NVFP4 — both YES independently**
901:     > (2.54x from precision alone clears the bar on its own) **and
902:     > combined with MTP** (7-7.7x). Task 6.2 is warranted and should
903:     > proceed. Still open before a final adoption decision: NVFP4 at our
904:     > actual production context (768K-1M via YaRN, not yet tested — Task
905:     > 6.2 step 4) and the REQ-005-mandated quality-impact check (Task 6.2
906:     > step 6, needs Task 5.2's coding-task examples).
907:   - Housekeeping: benchmark scripts left at `/home/admin/bench_decode.py`
908:     and `/home/admin/bench_prefill.py` for reuse in Task 6.2's
909:     long-context re-test once YaRN is applied to the NVFP4 checkpoint.
910:     Production BF16 service confirmed restored and healthy (896K
911:     context, `qwen3.8:27b-bf16`) at the end of this session — no net
912:     change to the running production state.
913: 
914: - [x] Task 6.2: Set up an NVFP4 deployment if Task 6.1 shows the BF16
915:   installation's performance is very different (materially slower)
916:   from the reference data, once the speculative-decoding contribution
917:   from Task 6.1.5 is accounted for — depends on: Task 6.1 —
918:   status: DONE 2026-08-24. Steps 1-5 done 2026-08-23 (kernel check
919:   passed, checkpoint pinned/downloaded, MTP decision deferred, YaRN
920:   capacity step-up complete — see step 4 RESULTS below: **NVFP4 clears
921:   all of 768K/896K/1M, including the full 1M ceiling BF16 failed at**;
922:   step 5 built/validated a production-candidate NVFP4+YaRN systemd
923:   service at 1M). **Steps 6-7 closed 2026-08-24: user's quality
924:   verdict via OpenCode was "NVFP4 quality is fine, adopt it" (step 6);
925:   final decision (step 7) is to ADOPT NVFP4 as production, replacing
926:   BF16 — but at a chosen production context of 896K, not the 1M
927:   candidate step 5 built**, per a separate user decision that 896K is
928:   "large enough" for real usage after testing (see STEP 6-7 RESULTS /
929:   PRODUCTION CUTOVER below for the full record, including the
930:   resulting deployment change from the 1M candidate to a new 896K
931:   production service). Decision
932:   criterion: only adopt NVFP4 (optionally
933:   with MTP) as production if it clears a large (e.g. >=1.5-2x)
934:   decode/prefill improvement that survives isolating speculative
935:   decoding, AND passes an empirical quality-impact check — per REQ-005,
936:   it must not be adopted by default. Required pre-work, in order:
937: 
938:   1. **Blocking check, do FIRST**: verify our installed vLLM 0.27.1
939:      (stock PyPI wheel, aarch64) actually has NVFP4 GEMM kernels for
940:      GB10/SM121a. Source B's community recipe explicitly warns: "Stock
941:      `vllm/vllm-openai` has NO NVFP4 kernels for Blackwell sm_121a
942:      (GB10). Every stock-vLLM attempt crashed" and required a custom
943:      community-built image
944:      (`ghcr.io/drowzeys/keys-vllm-027-gb10-qwen38` or
945:      `eugr/spark-vllm-b12x`, providing
946:      `FlashInferCutlassNvFp4LinearKernel`). Check this BEFORE any
947:      download/setup work, same discipline as Phase 0/Task 0.2's
948:      platform-support verification. If our stock vLLM build lacks
949:      NVFP4 kernel support, either find/validate an equivalent
950:      GB10-NVFP4-capable build, or treat NVFP4 as blocked and stop at
951:      Task 6.1's findings.
952:   2. Pin and download `unsloth/Qwen3.8-27B-NVFP4` (or an alternative
953:      NVFP4 repo, e.g. RadixArk's, if quality/compatibility differs) to
954:      a specific HF revision (REQ-007 discipline carried forward);
955:      re-verify the pinned revision doesn't have Source A's
956:      since-fixed tokenizer-truncation bug
957:      (`tokenizer.json`'s `truncation` field must be `null`).
958:   3. Decide whether to add MTP speculative decoding
959:      (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`
960:      — the draft head ships inside the NVFP4 checkpoint, no separate
961:      model needed) — stays on our existing engine (vLLM), so REQ-006's
962:      engine decision is unaffected. SGLang+DFlash2 (Source B) is
963:      explicitly out of scope for this task unless MTP alone doesn't
964:      close the gap, since it is a different serving engine and would
965:      reopen the REQ-006 engine decision.
966:   4. Re-run the SAME Task 2.1-2.3 capacity/headroom step-up methodology
967:      (768K → 896K → 1M, >=15% free or >=10 GiB absolute policy) with
968:      NVFP4 weights. Explicitly named goal: NVFP4's much smaller
969:      resident weight footprint (~22.6-23.4 GB vs. BF16's ~55.6 GB)
970:      frees roughly 32 GB of the unified pool, which may be enough to
971:      clear the 1M-context policy floor that BF16 failed at (Task 2.2:
972:      1M measured 12.9% free, below the 15% floor) — re-measuring 1M
973:      with NVFP4 is a specific goal here, not just re-confirming 896K.
974:   5. Re-verify tool-calling and all three thinking-control modes
975:      (mirroring Task 1.2/4.2's exact checks) against the NVFP4(+MTP)
976:      service before calling it production-equivalent.
977:   6. Quality-impact check (REQ-005's bar): at minimum, re-run ACC-011's
978:      coding-task examples (once available from Task 5.2) against both
979:      BF16 and NVFP4 side by side; do not just trust Source A/B's own
980:      NVFP4 quality numbers (HumanEval 97.0%, tool-eval-bench 92/100),
981:      since those measured DIFFERENT NVFP4 checkpoints (unsloth vs.
982:      RadixArk) and a different draft/spec-decode stack (MTP vs.
983:      DFlash2) than whatever ends up deployed here.
984:   7. Record the outcome either way: adopt NVFP4 (± MTP) as the new
985:      production precision (replacing BF16, with the same
986:      one-line-rationale discipline as ACC-004), OR keep BF16 as
987:      production and record NVFP4 as evaluated-but-not-adopted with the
988:      reason (insufficient throughput gain once speculative decoding is
989:      isolated, unacceptable quality regression, or no GB10-compatible
990:      NVFP4 vLLM kernel available). "Not very different" is a valid,
991:      complete answer to this task, not a failure. Supersedes/closes the
992:      still-open Task 3.2 (optional FP8/quant weight eval) either way.
993: 
994:   **Step 4 RESULTS (2026-08-23, executed live, maintenance window)** —
995:   stopped the 896K BF16 production service (`systemctl --user stop qwen3.8-27b-vllm.service`, confirmed 0 GPU processes / clean pool
996:   before starting), created a parameterized YaRN-enabled NVFP4 launch
997:   script (`/home/admin/scripts/qwen3.8-27b-nvfp4-yarn-vllm.sh`, `CTX=768k|896k|1m` toggle, same YaRN `rope_parameters` override shape as
998:   BF16's, same per-context `--kv-cache-memory-bytes` values as the
999:   BF16 `launch-phase2-*-fp8kv.sh` scripts since KV-cache size is a
1000:   function of architecture, not weight precision), then ran the full
1001:   768K → 896K → 1M step-up, one context at a time (stop/measure/stop
1002:   between each — the pool cannot hold two instances at once):
1003: 
1004:   | Context | Factor | `--kv-cache-memory-bytes` | KV cache capacity | Concurrency margin | Available memory | % free | Policy (>=15% or >=10 GiB) |
1005:   |---|---|---|---|---|---|---|---|
1006:   | 768K (786,432) | 3.0 | 30 GiB | 974,864 tokens | 1.24x | 51.61 GiB | 43.1% | **PASS** |
1007:   | 896K (917,504) | 3.5 | 33 GiB | 1,073,277 tokens | 1.17x | 48.00 GiB | 40.1% | **PASS** |
1008:   | 1M (1,048,576) | 4.0 | 37.11 GiB | 1,209,295 tokens | 1.15x | 43.34 GiB | 36.2% | **PASS** |
1009: 
1010:   Key findings:
1011: 
1012:   - **KV-cache token capacity and concurrency margin are IDENTICAL to
1013:     the BF16 measurements at every context size** (974,864 / 1,073,277
1014:     / 1,209,295 tokens at 768K/896K/1M, same 1.24x/1.17x/1.15x
1015:     margins) — confirms KV-cache sizing is driven by model architecture
1016:     (hidden dim, KV heads, layer count), not weight quantization, exactly
1017:     as expected since NVFP4 only quantizes MLP weights (+FP8 attention),
1018:     not the KV-cache-relevant attention shape.
1019:   - **NVFP4 clears ALL THREE context sizes, including the full 1M
1020:     native ceiling that BF16 failed (12.9% free, below the 15%
1021:     floor)** — at 1M, NVFP4 leaves 36.2% of the unified pool free,
1022:     more than double the 15% policy floor and nearly 3x BF16's
1023:     899K-max/12.9%-at-1M result. This directly confirms the Design
1024:     Notes' hypothesis: NVFP4's ~33 GB smaller resident weight footprint
1025:     (21.59 GiB vs. BF16's ~55.99 GiB, measured at load time) is enough
1026:     to fully absorb the difference.
1027:   - Smoke-tested (coherent non-degenerate output, clean
1028:     `get_weather("Paris")` tool-call, all three ACC-003 thinking-control
1029:     modes on the 17×24=408 arithmetic prompt) at all three context
1030:     sizes — all passed at every size: correct answers, correctly-scaled
1031:     reasoning length by effort level (768K: n/a run only for
1032:     correctness/tool-call; 896K: medium=44-char/xhigh=156-char
1033:     reasoning; 1M: medium=124-char/xhigh=175-char reasoning), clean
1034:     tool-calls, no degenerate output at any size.
1035:   - All three test instances shut down cleanly after their
1036:     measurements (0 GPU processes, port 8000 free, ~114 GiB available
1037:     between each step and at the end).
1038:   - **Per your maintenance-window instruction, the BF16 production
1039:     service was intentionally left stopped (not restarted)** at the
1040:     end of this run — `qwen3.8-27b-vllm.service` is `inactive (dead)`.
1041:     Restarting it (`systemctl --user start qwen3.8-27b-vllm.service`)
1042:     is a one-line action whenever normal production serving needs to
1043:     resume; nothing else on the box needs cleanup.
1044:   - **Still open before final adoption (Task 6.2 steps 5-7)**: step 5
1045:     (re-verify tool-calling/thinking at whichever size is chosen as
1046:     NVFP4's production context — informally done above at all three,
1047:     but not yet against a finalized systemd deployment); step 6 (the
1048:     REQ-005-mandated quality-impact check, BF16 vs. NVFP4 side by side
1049:     on Task 5.2's coding-task examples — not yet run); step 7 (the
1050:     final adopt-NVFP4-or-keep-BF16 recorded decision). Given NVFP4 now
1051:     clears the full 1M ceiling (vs. BF16's 896K cap) AND is 2.54x-7.7x
1052:     faster (Task 6.1), 1M is the natural candidate production context
1053:     for NVFP4 if step 6's quality check clears the bar — but that
1054:     decision is explicitly not made yet.
1055: 
1056:   **Prep work done ahead of time (2026-08-23, in parallel with Task
1057:   5.2, no GPU/memory impact on the running BF16 production service)**:
1058: 
1059:   - **Step 1's blocking check is RESOLVED, and the outcome differs from
1060:     the forum's warning**: verified live on this box (no test server
1061:     needed) that our stock vLLM 0.27.1 + FlashInfer 0.6.16.post3
1062:     (aarch64, PyPI release) DOES have working NVFP4 GEMM kernels for
1063:     GB10/SM121a — `cutlass_scaled_mm_supports_fp4(121)` returns `True`,
1064:     and `has_flashinfer_b12x_gemm()` (the exact `Sm120B12xBlockScaledDenseGemmKernel`
1065:     the forum's custom community image added) is also `True`. This
1066:     contradicts Source B's "stock vllm/vllm-openai has NO NVFP4 kernels
1067:     for Blackwell sm_121a" claim — that was true for the August nightly
1068:     dev build (`0.26.1rc1.dev244+...`) the forum posters used; our
1069:     newer stock 0.27.1 release has since closed that gap.
1070:   - One real caveat found in the kernel-selection source itself
1071:     (`vllm/model_executor/kernels/linear/__init__.py`): vLLM's
1072:     auto-selection deliberately EXCLUDES the fastest b12x kernel by
1073:     default — code comment: *"FlashInferB12xNvFp4LinearKernel excluded
1074:     from auto-selection until upstream CUTLASS SM121 MMA op guard is
1075:     resolved; use `--linear-backend flashinfer_b12x` to opt in
1076:     explicitly."* Auto-selection order on this box resolves to
1077:     `FlashInferCutlassNvFp4LinearKernel` (confirmed `is_supported() -> True`) — a solid, supported default, just not the fastest possible
1078:     path. `--linear-backend flashinfer_b12x` is available as an
1079:     explicit, opt-in experiment, not the baseline comparison config.
1080:   - Pinned and downloaded `unsloth/Qwen3.8-27B-NVFP4` to HF revision
1081:     `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108` (2026-08-17, i.e. after
1082:     the 2026-08-15 tokenizer-truncation fix mentioned in Source A) —
1083:     verified `tokenizer.json`'s `truncation` field is `null` BEFORE
1084:     committing to the full 23.4 GB download (fetched that one file
1085:     first), then re-verified after — confirmed fixed both times.
1086:     22.6 GB `model.safetensors` + 0.85 GB `model_mtp.safetensors`
1087:     (1968 tensors total, 15 of them the MTP head, all registered in one
1088:     `model.safetensors.index.json` — matches Source A's finding that no
1089:     separate `--speculative-config "model"` field is needed) landed at
1090:     `/home/admin/models/qwen3.8-27b-nvfp4`. 345 GB still free on
1091:     `/home/admin` afterward — no disk pressure.
1092:   - `config.json` confirms `Qwen3_5ForConditionalGeneration` (same
1093:     registry entry the BF16 checkpoint uses) and a compressed-tensors
1094:     mixed quantization config: NVFP4 for most MLPs, FP8 for
1095:     attention/`lm_head`/the last 8 layers' MLPs — matches Source A's
1096:     "MLP in NVFP4, attention in FP8" description exactly. `rope_type: "default"` (no scaling) with `max_position_embeddings: 262144` in
1097:     `text_config` — same YaRN-override shape (REQ-011) as our BF16
1098:     deployment, just needs applying to this checkpoint when context
1099:     extension is tested.
1100:   - Drafted (not yet run) `/home/admin/scripts/qwen3.8-27b-nvfp4-vllm.sh`
1101:     — two modes via `MTP=0` (default, no speculative decoding — the
1102:     apples-to-apples comparison point for Task 6.1.4 against Source A's
1103:     `num_speculative_tokens=0` baseline) or `MTP=1` (adds
1104:     `--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`,
1105:     matching Source A's headline config), both at native 262144 context
1106:     and `--gpu-memory-utilization 0.45` (reproducing Source A's exact
1107:     recipe). **Deliberately NOT started**: the unified 128 GB pool
1108:     cannot hold both this and the running 896K BF16 production service
1109:     at once (BF16 alone already uses ~111 GiB at 896K) — running it
1110:     requires a coordinated maintenance window (`systemctl --user stop qwen3.8-27b-vllm.service` first, restart after), left for whenever
1111:     Task 6.1's actual benchmark run is scheduled, so as not to disrupt
1112:     Task 5.2's live user testing.
1113: 
1114:   **Step 6-7 RESULTS / PRODUCTION CUTOVER (2026-08-24)**:
1115: 
1116:   1. **Step 6 (quality verdict)**: user ran their coding-task examples
1117:      via OpenCode against the NVFP4 1M candidate service
1118:      (`qwen3.8-27b-nvfp4-1m.service`, left running from step 5) and
1119:      reported: **"NVFP4 quality is fine, adopt it."** This is the
1120:      REQ-005-mandated quality-impact check, satisfied per the same
1121:      "user's own judgment on their own examples" precedent as `feat-1`
1122:      ACC-010 and this feature's own Task 5.2.
1123:   2. **Separate context decision**: in the same follow-up, the user
1124:      concluded from their testing that **896K context is "large
1125:      enough"** for real usage and explicitly chose it over the 1M
1126:      ceiling that step 4/5 had qualified and built a candidate for.
1127:      This is independent of the precision decision — NVFP4 at 896K
1128:      (Task 6.2 step 4's table) has even more headroom (40.1% free) than
1129:      NVFP4 at 1M (36.2% free), so dropping to 896K is a strictly safer
1130:      choice on top of being the user's stated preference.
1131:   3. **Step 7 (final decision, recorded)**: **ADOPT NVFP4 as the
1132:      production precision, replacing BF16, at 896K context (not
1133:      1M).** Rationale (one-line, per ACC-004's precedent): NVFP4 gives
1134:      a 2.54x-7.7x decode speedup over BF16 (Task 6.1) with no quality
1135:      regression per the user's own coding-task judgment (step 6 above),
1136:      clearing REQ-005's bar for adopting a quantized variant over BF16
1137:      ("not adopted by default... only if empirically justified").
1138:      REQ-003/ACC-002's already-chosen 896K production context is
1139:      unaffected by the precision change (KV-cache sizing at 896K is
1140:      architecture-driven and identical for BF16/NVFP4 per Task 6.2 step
1141:      4's table) — only the weight precision changes.
1142:   4. **Deployment cutover performed** (live, this session, directly on
1143:      `dgx`): the 1M NVFP4 candidate no longer matches the chosen
1144:      production context, so it was retired rather than promoted as-is.
1145:      Built a NEW production script/unit at 896K instead:
1146:      - `/home/admin/scripts/qwen3.8-27b-nvfp4-896k.sh` — derived from
1147:        the validated `qwen3.8-27b-nvfp4-1m.sh` (same
1148:        `VLLM_DISABLE_COMPILE_CACHE=1` fix from step 5, deliberately NO
1149:        `--linear-backend` pin per step 5's finding), with 896K params
1150:        (`--max-model-len 917504`, YaRN factor 3.5, `--kv-cache-memory-bytes 35433480192` / 33 GiB — identical KV-cache sizing to the
1151:        BF16 896K script), `--served-model-name qwen3.8:27b-nvfp4-896k`.
1152:      - `/home/admin/.config/systemd/user/qwen3.8-27b-nvfp4-896k.service`
1153:        — mirrors the existing unit pattern (`--user`, disabled/
1154:        no-autostart, `TimeoutStartSec=4200`, `LimitNOFILE=1048576`).
1155:      - Stopped `qwen3.8-27b-nvfp4-1m.service` (confirmed `inactive`,
1156:        port 8000 free, 0 GPU processes) and `qwen3.8-27b-vllm.service`
1157:        (BF16, already stopped from the maintenance window) before
1158:        starting the new unit — both retained on disk, disabled, as
1159:        fallback/reference, not deleted.
1160:   5. **Real environment gap found and fixed during cutover**: the first
1161:      two start attempts of `qwen3.8-27b-nvfp4-896k.service` failed with
1162:      `ValueError: Free memory on device cuda:0 (65.52-65.74/119.63 GiB) on startup is less than desired GPU memory utilization` — NOT a
1163:      script/config bug. Root cause: a **resident Ollama-served model**
1164:      (`qwen3.8:27b-q8_0`, 46 GB, via the `ollama` Docker container,
1165:      `--restart always`) was loaded and holding ~43-46 GiB of the
1166:      unified pool, evidently left over from unrelated testing (possibly
1167:      the same Ollama quant used informally for comparison outside this
1168:      feature). This is the exact contention class the Design Notes
1169:      already warned about for capacity *testing* — new finding here is
1170:      that it also blocks *production service restarts*, not just
1171:      measurement runs. Fixed with `docker exec ollama ollama stop qwen3.8:27b-q8_0` (unloads the model, does NOT stop the
1172:      always-restarting container itself) — pool returned to a clean
1173:      ~114 GiB available baseline immediately. **Operational risk now
1174:      recorded, not just fixed once**: if any Ollama model is loaded
1175:      (via OpenWebUI or the Ollama API directly) while the NVFP4
1176:      production service is running, the shared unified pool has thin
1177:      enough headroom (40.1% / ~48 GiB at 896K) that a large concurrent
1178:      Ollama load could still cause runtime memory pressure even though
1179:      it won't crash an already-started vLLM engine outright (unlike a
1180:      cold start, which re-checks free memory against
1181:      `--gpu-memory-utilization` and fails fast, as observed here). No
1182:      guard/quota is implemented for this coexistence risk — flagged as
1183:      an open operational caveat, not solved by this feature.
1184:   6. **Full re-verification passed** against the new
1185:      `qwen3.8-27b-nvfp4-896k.service` (cold start ~3m45s after the
1186:      Ollama fix): `/v1/models` reports `qwen3.8:27b-nvfp4-896k` /
1187:      `max_model_len: 917504`; memory measured at ~48 GiB available /
1188:      119Gi total (~40.1% free), matching step 4's table exactly;
1189:      coherent non-degenerate output (fib-with-memoization prompt); clean
1190:      `get_weather("Paris")` tool-call (`finish_reason: "tool_calls"`);
1191:      all three ACC-003 thinking-control modes on the 17×24=408 prompt
1192:      (`enable_thinking: false` → 0-length reasoning, direct "408";
1193:      `reasoning_effort: medium` → 44-char reasoning, correct answer;
1194:      `reasoning_effort: xhigh` → 120-char reasoning, correctly more
1195:      elaborate, correct answer). Service left `active (running)` as the
1196:      new production service.
1197:   7. **Not yet re-run**: Task 5.2's exact OpenCode-agentic-session leg
1198:      of ACC-003 (the curl leg above is done, but the full agentic
1199:      session was previously only run against the now-superseded BF16
1200:      production service — see the caveat added to ACC-003 below).
1201:      Also not yet done: updating the user's actual `opencode.jsonc`
1202:      provider entry to the new `qwen3.8:27b-nvfp4-896k` model id (the
1203:      user manages that file, not this repo — an updated snippet is
1204:      provided in Progress below).
1205:   8. Housekeeping: `qwen3.8-27b-nvfp4-1m.service`/`.sh` and
1206:      `qwen3.8-27b-vllm.service`/`.sh` (BF16) are both left on disk,
1207:      `disabled`, `inactive` — kept as documented fallback paths (1M
1208:      NVFP4 if more context is ever needed and headroom allows re-
1209:      confirming it; BF16 if a future finding reverses the NVFP4
1210:      adoption) rather than deleted.
1211: 
1212: - [x] Task 6.3 (follow-up, same day): Test MTP speculative decoding
1213:   combined with YaRN long-context extension at the actual 896K
1214:   production context — depends on: Task 6.2 — status: DONE 2026-08-24.
1215:   Context: Task 6.1's MTP benchmarks were only ever run at NVFP4's
1216:   NATIVE 262144 context; the 896K production cutover (Task 6.2 step 7)
1217:   deliberately left MTP OUT pending this dedicated test, since
1218:   YaRN-long-context + MTP-draft-head behavior together were unvalidated.
1219:   User asked to test and, if it clears the bar, activate it.
1220: 
1221:   **Method**: maintenance window (production service stopped), ran an
1222:   ad-hoc MTP+YaRN-896K instance
1223:   (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`
1224:   added to an otherwise-identical copy of the production 896K script),
1225:   then a same-context non-MTP instance for a true apples-to-apples
1226:   comparison (not just reusing Task 6.1's native-context numbers).
1227: 
1228:   **Results**:
1229: 
1230:   - **Capacity**: KV-cache capacity drops from 1,073,277 to 984,829
1231:     tokens with MTP enabled (margin 1.17x → 1.07x, still clears the
1232:     917,504-token requirement); pool free drops from 40.1% to ~38.5-39.2%
1233:     — still comfortably above the 15%/10 GiB safety-margin policy floor.
1234: 
1235:   - **Correctness**: byte-identical greedy (temperature=0) output vs.
1236:     the non-MTP run on the same prompt — confirms lossless speculative
1237:     decoding at this context (the acceptance/verification step is
1238:     exact, not just "didn't crash"). Tool-calling and all three
1239:     ACC-003 thinking-control modes also verified unaffected.
1240: 
1241:   - **Throughput** (median of 5, `bench_decode.py`, Bubblesort prompt,
1242:     same methodology as Task 6.1), same 896K/YaRN context both runs:
1243: 
1244:     | Config | Decode (thinking) | Decode (no-thinking) |
1245:     |---|---|---|
1246:     | NVFP4, 896K/YaRN, no MTP | 11.27 tok/s | 11.27 tok/s |
1247:     | NVFP4, 896K/YaRN, MTP (num_speculative_tokens=5) | 29.93 tok/s | 35.17 tok/s |
1248: 
1249:     **Speedup: 2.66x (thinking) / 3.12x (no-thinking)** — closely
1250:     matches Task 6.1's native-context MTP-alone finding (2.77x/3.04x),
1251:     confirming the gain carries over cleanly to YaRN-extended context.
1252: 
1253:   - **Decision: MTP clears the bar (capacity, correctness, and
1254:     throughput all pass) — adopted into production.** Promoted directly
1255:     into `qwen3.8-27b-nvfp4-896k.sh` (same served-model-name
1256:     `qwen3.8:27b-nvfp4-896k`, no OpenCode config change needed) rather
1257:     than a separate model id, since it's a strict throughput
1258:     improvement over the same-day 896K cutover with no observed
1259:     downside. The pre-MTP version is preserved as
1260:     `qwen3.8-27b-nvfp4-896k-no-mtp.sh`, a documented rollback path if
1261:     MTP ever misbehaves in real extended usage despite passing these
1262:     checks. Production systemd service restarted with the new script
1263:     and fully re-verified (coherent output, tool-call, correct
1264:     `/v1/models`, 984,829-token KV capacity, ~39% pool free).
1265: 
1266: ## Progress
1267: 
1268: ### Current Status
1269: 
1270: **As of 2026-08-23**: Phase 0 and Phase 1 COMPLETE. The prior session's
1271: Ollama-contention blocker was already cleared by the time this session
1272: started (Ollama no longer resident; GB10 GPU/unified-pool fully free)
1273: — no unload step was needed. vLLM 0.27.1 was brought up successfully
1274: at native context (32768 max-model-len, no YaRN), producing coherent
1275: non-degenerate output, with tool-calling and all three thinking-control
1276: modes (`enable_thinking: false`, `reasoning_effort: low/medium/xhigh`)
1277: verified via curl. Two new non-root-fixable environment gaps were found
1278: and fixed without sudo (missing `Python.h` via `uv python install` +
1279: `CPATH`; `ninja` unreachable via `PATH`) — see Task 1.1 for the full
1280: fix. vLLM is confirmed as the deployment engine (REQ-006/ACC-005); no
1281: SGLang fallback needed. The test server was shut down cleanly after
1282: Phase 1 so the GB10 is back to a clean, fully-free baseline.
1283: 
1284: **As of 2026-08-23 (later this date)**: Phase 2 COMPLETE (Tasks 2.1-2.3).
1285: Two real findings, not just confirmations: (1) the default
1286: `VLLM_ENGINE_READY_TIMEOUT_S=600` is too short for this box at large
1287: `--max-model-len` and had to be raised to 3600; (2) the default
1288: `--gpu-memory-utilization`-driven KV cache sizing leaves the GB10's OS
1289: with almost no memory at 768K+ (measured ~1.7-3.5 GiB free, vs. a
1290: ~17.9 GiB policy floor) — fixed by switching to `--kv-cache-dtype fp8`
1291: with an explicit, right-sized `--kv-cache-memory-bytes` instead (KV
1292: cache precision only, BF16 weights unaffected). With that fix, stepped
1293: 768K -> 896K -> 1M: 768K passed comfortably (19.8% free), 896K passed
1294: narrowly (16.1% free), 1M failed (12.9% free, below the 15% policy
1295: floor). **896K (YaRN factor 3.5) is the chosen production context**,
1296: with 19.28 GiB (16.1%) of the pool remaining free — the GB10
1297: effectively owns its pool at this context; no meaningful coexistence
1298: headroom remains (REQ-010/Task 2.3).
1299: 
1300: **Phase 3 Task 3.1 COMPLETE** (2026-08-23, same session as this update):
1301: BF16 confirmed as the production model *weight* precision via a live
1302: shell on the GB10 — no `--dtype`/`--quantization` flag in the 896K
1303: launch script, no `quantization_config` in `config.json`, safetensors
1304: total (55.56 GB) matches BF16 for ~27B params. REQ-005/ACC-004 closed.
1305: 
1306: **Phase 4 Task 4.1 COMPLETE** (2026-08-23, same session): vLLM +
1307: Qwen3.8-27B installed as a systemd `--user` service on the GB10
1308: (`qwen3.8-27b-vllm.service`, `ExecStart=/home/admin/scripts/qwen3.8-27b-vllm-896k.sh`
1309: — a byte-for-byte-flags production copy of the tested 896K Phase 2
1310: script). Lingering enabled (`Linger=yes`, no sudo needed); unit
1311: deliberately left `disabled` (won't autostart at boot), `inactive`
1312: (not started yet — Task 4.2 does that). GB10 confirmed clean after
1313: install (port 8000 free, 0 GPU processes).
1314: 
1315: **Phase 4 Task 4.2 COMPLETE** (2026-08-23, same session): started
1316: `qwen3.8-27b-vllm.service` — cold load ~7m43s, matching Phase 2's
1317: timing. Curl smoke tests against the live production service (896K,
1318: confirmed via `/v1/models`) all passed: coherent non-degenerate
1319: output, clean tool-call, and ACC-003's exact 3 thinking-control modes
1320: (`enable_thinking: false`, `reasoning_effort: medium`,
1321: `reasoning_effort: xhigh`) all returned the correct 17×24=408 answer
1322: with correctly-scaled reasoning length. Service left running (not
1323: stopped) for Task 4.3 to reuse.
1324: 
1325: **Phase 4 Task 4.3 COMPLETE** (2026-08-23, same session) — **Phase 4 is
1326: now fully COMPLETE.** Built a real 899,067-token prompt (model's own
1327: tokenizer) and POSTed it to the live, already-running production
1328: service from Task 4.2: HTTP 200, no OOM, `usage.total_tokens: 899,117`
1329: (within the 917,504 max-model-len, ~18.4K headroom to spare), 3582s
1330: (~59.7 min) wall time. Service confirmed still healthy afterward
1331: (active, no errors, ~18 GiB available — matching Task 2.3's measured
1332: headroom). One caveat honestly flagged: the test payload's top-level
1333: `enable_thinking: false` field didn't actually suppress thinking here
1334: (a payload-shape artifact from reusing Task 2.1's older format, not a
1335: service defect — Task 4.2 already separately confirmed the correct
1336: `chat_template_kwargs` form works) — response hit `finish_reason: "length"` with truncated reasoning and null content, but this does not
1337: affect Task 4.3's actual pass/fail bar (completes without OOM).
1338: 
1339: **Phase 5 Task 5.1 COMPLETE** (2026-08-23, later session): OpenCode
1340: wired to the production endpoint. Added `--served-model-name qwen3.8:27b-bf16` to the launch script (mirrors `feat-2`'s `--alias`
1341: fix; `/v1/models` previously leaked the raw checkpoint path), restarted
1342: the service, and re-verified health + a thinking-disabled chat
1343: completion post-rename. Produced a standalone OpenCode provider
1344: snippet (`baseURL: http://192.168.1.46:8000/v1`, `limit.context: 917504` matching the real 896K deployment) for the user to paste into
1345: their own `opencode.jsonc` — not written into any config on this box,
1346: same precedent as `feat-2`. OpenWebUI wiring explicitly deferred/out of
1347: scope per user decision (no OpenWebUI deployment details were
1348: available). Remaining: Task 5.2 (user runs the comparison coding-task
1349: examples via OpenCode).
1350: 
1351: **Phase 6 ADDED** (2026-08-23): "Compare with Qwen3.8-27B-NVFP4" —
1352: cross-checks our BF16 production install against two NVIDIA DGX
1353: Spark/GB10 forum threads with real NVFP4+MTP/DFlash2 throughput and
1354: quality numbers on matching hardware/architecture (Task 6.1), then
1355: conditionally sets up an NVFP4 deployment only if the gap is large and
1356: survives isolating the separate speculative-decoding effect, with an
1357: explicit quality-impact check before adoption (Task 6.2, subsumes the
1358: still-open Task 3.2). Not started — depends on Task 4.3, so it can run
1359: independently of/in parallel with Phase 5.
1360: 
1361: **Phase 6 prep work COMPLETE** (2026-08-23, run in parallel with the
1362: user's Task 5.2 session — no GPU/memory impact on the live BF16
1363: service): Task 6.2's blocking kernel check resolved (our stock vLLM
1364: 0.27.1 + FlashInfer 0.6.16.post3 DOES support NVFP4 GEMM on
1365: GB10/SM121a, contrary to the forum's stock-vLLM warning — see Task 6.2
1366: notes for the exact `is_supported()` evidence and the one real caveat,
1367: an upstream SM121 guard that excludes the fastest b12x kernel from
1368: auto-selection). `unsloth/Qwen3.8-27B-NVFP4` downloaded and pinned
1369: (revision `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`, tokenizer fix
1370: verified before AND after download), `/home/admin/scripts/qwen3.8-27b-nvfp4-vllm.sh`
1371: drafted (native 262144 context, `MTP=0`/`MTP=1` toggle) but
1372: deliberately not started — running it needs a maintenance window
1373: (BF16 production service stopped first), left for Task 6.1's actual
1374: benchmark run.
1375: 
1376: **Task 5.2 COMPLETE** (user confirmed, 2026-08-23) — user ran their
1377: coding-task comparison via OpenCode against the production BF16
1378: endpoint.
1379: 
1380: **Phase 6 Task 6.1 COMPLETE** (2026-08-23, same session): with a
1381: coordinated maintenance window (user's go-ahead after finishing Task
1382: 5.2), stopped the 896K BF16 production service, benchmarked the
1383: downloaded NVFP4 checkpoint at native 262144 context in both `MTP=0`
1384: and `MTP=5` configs (tool-calling/thinking-mode/coherent-output smoke
1385: checks all passed on both), then restarted BF16 production and
1386: re-ran the identical decode-benchmark script against it for a rigorous
1387: same-methodology baseline. Headline results: **precision alone (NVFP4
1388: vs. BF16, no spec decode either side) is 2.54x**; **speculative
1389: decoding alone (MTP vs. no-MTP, both NVFP4) is 2.77-3.04x**; combined,
1390: NVFP4+MTP is **7.05-7.73x** faster decode than our BF16 production
1391: service. Our `MTP=0`/`MTP=5` numbers reproduce Source A's own
1392: reference points closely (within ~2% for the no-spec baseline) and
1393: BEAT their MTP=5 headline by ~29-31%, plus meaningfully better prefill
1394: throughput and KV-cache byte/token efficiency — both attributed to our
1395: newer stock vLLM/FlashInfer release vs. their nightly dev build.
1396: **Conclusion: BF16 vs. NVFP4 performance is very different by Task
1397: 6.2's own decision criterion (>=1.5-2x) — proceeding to Task 6.2 is
1398: warranted.** Production BF16 service confirmed restored and healthy
1399: (896K context) at the end of this run — net state unchanged.
1400: 
1401: **Task 6.2 steps 6-7 COMPLETE, PRODUCTION CUTOVER DONE** (2026-08-24) —
1402: **Phase 6 (Task 6.2) is now fully COMPLETE.** User's quality verdict
1403: (step 6, via OpenCode against the NVFP4 1M candidate): "NVFP4 quality
1404: is fine, adopt it." Separate user decision: production context is
1405: **896K, not 1M** — "the ctx is large enough with that size." Final
1406: adoption (step 7): **NVFP4 replaces BF16 as the production precision,
1407: served at 896K context.** Executed the cutover live on `dgx`: retired
1408: `qwen3.8-27b-nvfp4-1m.service` and `qwen3.8-27b-vllm.service` (both
1409: stopped, left disabled/on-disk as fallbacks), built and started
1410: `qwen3.8-27b-nvfp4-896k.service` (new script derived from the
1411: validated 1M one, same context/KV-cache sizing as the existing 896K
1412: BF16 script). Found and fixed a real environment gap during the
1413: cutover: a resident Ollama-served model (`qwen3.8:27b-q8_0`, 46 GB, via
1414: the always-restarting `ollama` Docker container) was holding enough of
1415: the unified pool that the new service failed its startup free-memory
1416: check twice before the Ollama model was unloaded (`docker exec ollama ollama stop qwen3.8:27b-q8_0`) — a genuine coexistence risk beyond
1417: what earlier capacity-testing sessions accounted for, now flagged as an
1418: open operational caveat (no guard/quota exists to prevent it recurring
1419: during normal operation). After the fix, full re-verification passed:
1420: `/v1/models` confirms `qwen3.8:27b-nvfp4-896k` / `max_model_len: 917504`, ~40.1% pool free (matching Task 6.2 step 4's table), coherent
1421: output, clean tool-call, all three thinking-control modes correct.
1422: Updated ACC-004 (superseded — NVFP4 now the empirically-justified
1423: quantized production precision, satisfying REQ-005's bar). Full record
1424: in Task 6.2's "Step 6-7 RESULTS / PRODUCTION CUTOVER" block in the Task
1425: List. Remaining open items: the OpenCode-agentic-session leg of ACC-003
1426: has not been re-run against the new NVFP4 896K service (only against
1427: the superseded BF16 one, Task 5.2); the user's own `opencode.jsonc`
1428: needs updating to the new `qwen3.8:27b-nvfp4-896k`
1429: model id (snippet provided above, in the resolved SESSION HANDOFF
1430: section).
1431: 
1432: **Task 6.3 COMPLETE, MTP ACTIVATED IN PRODUCTION** (2026-08-24, same
1433: session, follow-up requested by user): tested MTP speculative decoding
1434: combined with YaRN long-context extension at the real 896K production
1435: context (previously untested — Task 6.1's MTP numbers were all at
1436: NVFP4's native 262144 context). Capacity still clears the policy
1437: (KV-cache capacity 1,073,277 → 984,829 tokens, margin 1.17x → 1.07x,
1438: pool free 40.1% → ~39%), correctness is lossless (byte-identical greedy
1439: output vs. non-MTP at the same prompt), and throughput at the actual
1440: 896K/YaRN context improves **2.66x (thinking) / 3.12x (no-thinking)** —
1441: closely matching Task 6.1's native-context finding. **Promoted directly
1442: into the production script** (`qwen3.8-27b-nvfp4-896k.sh`, same served
1443: model id, no OpenCode config change needed); the pre-MTP version is
1444: preserved as `qwen3.8-27b-nvfp4-896k-no-mtp.sh` for rollback. Production
1445: systemd service restarted and fully re-verified. Full record in Task
1446: 6.3 in the Task List.
1447: 
1448: **Task 6.2 step 4 COMPLETE** (2026-08-23, same session, maintenance
1449: window): stopped the BF16 production service and ran the full
1450: 768K→896K→1M YaRN capacity step-up against NVFP4 using a new
1451: parameterized script (`/home/admin/scripts/qwen3.8-27b-nvfp4-yarn-vllm.sh`).
1452: **All three context sizes PASS the safety-margin policy, including the
1453: full 1M native ceiling that BF16 failed at** (BF16: 12.9% free at 1M,
1454: below the 15% floor; NVFP4: 36.2% free at 1M, well above it). KV-cache
1455: token capacity/concurrency margins are identical to BF16's at every
1456: size (confirms KV-cache sizing is architecture-driven, not
1457: precision-driven). Tool-calling and all three thinking-control modes
1458: verified at every size. Full results in Task 6.2's step-4 notes above.
1459: **Per your maintenance-window instruction, the BF16 production service
1460: was intentionally left stopped, not restarted.**
1461: 
1462: **Task 6.2 step 5 COMPLETE** (2026-08-23, same session, maintenance
1463: window continued): built a production-candidate NVFP4+YaRN systemd
1464: service at the 1M native ceiling (`qwen3.8-27b-nvfp4-1m.service`,
1465: `ExecStart=/home/admin/scripts/qwen3.8-27b-nvfp4-1m.sh`, mirroring the
1466: BF16 `qwen3.8-27b-vllm.service` pattern -- `--user` unit, lingering
1467: already enabled from Task 4.1, left `disabled` so it won't autostart).
1468: 1M chosen over 768K/896K as the candidate context since it clears the
1469: safety-margin policy with the most headroom of the three AND is the
1470: model's full native ceiling (Task 6.2 step 4).
1471: 
1472: Hit and fixed a real environment gap while bringing this up as a
1473: systemd service (not present in step 4's ad-hoc `nohup` runs): vLLM's
1474: NVFP4/FP8 kernel auto-selection is **not stable run-to-run** on this
1475: box -- observed switching between `CutlassNvFp4LinearKernel` and
1476: `FlashInferCutlassNvFp4LinearKernel` across otherwise-identical
1477: launches, and the on-disk `torch.compile` AOT cache under
1478: `~/.cache/vllm/torch_compile_cache/` does not key on which kernel was
1479: selected. A run that auto-selects a different kernel than a prior run
1480: against the same model directory can load a stale, incompatible
1481: cached graph and crash-loop
1482: (`AttributeError: '_OpNamespace' 'vllm' object has no attribute 'flashinfer_mm_fp4'`). Explicitly pinning `--linear-backend flashinfer_cutlass` was tried first but broke a DIFFERENT kernel
1483: choice (the FP8 W8A8 scaled-mm kernel for attention/lm_head/last-8-
1484: layers-MLP then failed with `FlashInferFP8ScaledMMLinearKernel requires FlashInfer to be installed`) -- `--linear-backend` applies
1485: too broadly across this checkpoint's mixed NVFP4+FP8 quantization
1486: scheme. **Fix: `VLLM_DISABLE_COMPILE_CACHE=1`**, forcing a fresh
1487: compile every launch against whichever kernel gets auto-selected that
1488: run, at the cost of a slightly longer cold start (no AOT-artifact
1489: reuse) -- this is now baked into `qwen3.8-27b-nvfp4-1m.sh` and should
1490: be carried into any future NVFP4 production script derived from it.
1491: 
1492: With that fix, the service started cleanly (`CutlassNvFp4LinearKernel`
1493: auto-selected this run) and passed the full re-verification: KV cache
1494: 1,209,295 tokens (1.15x margin, matching step 4's measurement exactly),
1495: 39.0% pool free, `/v1/models` reports `qwen3.8:27b-nvfp4-1m` /
1496: `max_model_len: 1048576`. Coherent non-degenerate output, clean
1497: `get_weather("Paris")` tool-call, and all three thinking-control modes
1498: (`enable_thinking: false` -> null reasoning; `reasoning_effort: medium`
1499: -> 71-char reasoning; `reasoning_effort: xhigh` -> 95-char reasoning,
1500: correctly more elaborate) all passed, correct 17x24=408 answer
1501: throughout. **Service left running** (not stopped) so you can point
1502: OpenCode at it directly for Task 6.2 step 6.
1503: 
1504: **RESOLVED 2026-08-24 — Task 6.2 steps 6-7 are CLOSED and the production
1505: cutover is DONE.** (This section previously handed off an in-progress
1506: quality test; kept below, struck through in spirit but left as history,
1507: followed by what actually happened.)
1508: 
1509: **Final outcome**: user's quality verdict (step 6) was "NVFP4 quality is
1510: fine, adopt it." Separately, the user decided **896K context is "large
1511: enough"**, not the 1M candidate this handoff was originally about — so
1512: step 7's adoption applied NVFP4 at **896K**, not 1M. The production
1513: cutover was executed live this session:
1514: 
1515: - Retired `qwen3.8-27b-nvfp4-1m.service` (stopped, left disabled/on-disk
1516:   as a documented fallback if 1M is ever wanted again).
1517: - Retired `qwen3.8-27b-vllm.service` (BF16, stopped, left disabled/
1518:   on-disk as a documented fallback if BF16 is ever needed again).
1519: - Built and started the new production service:
1520:   `qwen3.8-27b-nvfp4-896k.service` -> `qwen3.8-27b-nvfp4-896k.sh`
1521:   (896K/917,504 context, YaRN factor 3.5, NVFP4 weights, FP8 KV cache,
1522:   `--served-model-name qwen3.8:27b-nvfp4-896k`). Full re-verification
1523:   passed (coherent output, tool-call, all 3 thinking-control modes,
1524:   ~40.1% pool free matching Task 6.2 step 4's table). See Task 6.2's
1525:   "Step 6-7 RESULTS / PRODUCTION CUTOVER" block in the Task List above
1526:   for the complete record, including a real environment gap found and
1527:   fixed during the cutover (a resident Ollama-served model was
1528:   competing for the unified pool and had to be unloaded first).
1529: 
1530: **Current production OpenCode provider snippet** (supersedes the
1531: 1M-context one originally in this handoff, and Task 5.1's original
1532: BF16 one — update your `opencode.jsonc` accordingly):
1533: 
1534: ```jsonc
1535: "vllm-dgx": {
1536:     "npm": "@ai-sdk/openai-compatible",
1537:     "name": "vllm (DGX, NVFP4 896K)",
1538:     "options": { "baseURL": "http://192.168.1.46:8000/v1" },
1539:     "models": {
1540:         "qwen3.8:27b-nvfp4-896k": {
1541:             "name": "qwen3.8:27b-nvfp4-896k",
1542:             "limit": { "context": 917504, "output": 65536 }
1543:         }
1544:     }
1545: }
1546: ```
1547: 
1548: Same unauthenticated-endpoint caveat as before: add
1549: `"apiKey": "not-needed"` under `"options"` if the provider errors on a
1550: missing key.
1551: 
1552: **What remains (not part of Task 6.2, tracked as open follow-ups)**:
1553: 
1554: 1. The OpenCode-agentic-session leg of ACC-003 was only run against the
1555:    now-superseded BF16 service (Task 5.2) — not yet re-run against the
1556:    new NVFP4 896K production service. The curl leg of ACC-003 HAS been
1557:    re-verified against NVFP4 896K (this session).
1558: 2. MTP-at-long-context (YaRN + speculative decoding together) was the
1559:    OPEN follow-up as of this note -- **RESOLVED 2026-08-24 (Task 6.3):
1560:    tested and adopted into production**, see the session handoff block
1561:    immediately below for the full outcome.
1562: 3. The Ollama-vLLM unified-pool coexistence risk found during the
1563:    cutover (see Task 6.2's step 5 in the results block) has no
1564:    guard/quota — an operational caveat to keep in mind, not a task.
1565: 
1566: **Known non-blocking observation from Phase 1/2**: generation
1567: throughput was only ~4.6 tokens/s in the Phase 1 small-context smoke
1568: test (unquantized BF16, single request, no prefix caching), and the
1569: 768K real-prompt end-to-end requests took ~36 min (BF16 KV cache) /
1570: ~45 min (FP8 KV cache) wall time in Phase 2 — FP8 KV cache appears
1571: slower here, likely un-tuned FlashInfer FP8 dequant on this new
1572: GB10/SM121 platform. Worth a closer look during Phase 4 once serving
1573: flags are closer to final production shape; flagged so it is not
1574: forgotten (may matter for real interactive/agentic use over OpenCode).
1575: 
1576: ______________________________________________________________________
1577: 
1578: **>>> SESSION HANDOFF (2026-08-24, session end) — start here for the
1579: NEXT session. This block supersedes all earlier handoff notes above in
1580: this file (kept for history, but this is the current state):**
1581: 
1582: **Live production state, verified at session end:**
1583: 
1584: - `qwen3.8-27b-nvfp4-896k.service` is `active (running)` —
1585:   `qwen3.8:27b-nvfp4-896k`, `max_model_len: 917504`, port 8000, NVFP4
1586:   weights, YaRN factor 3.5, FP8 KV cache, **MTP speculative decoding
1587:   enabled** (`num_speculative_tokens=5`). ~46 GiB available / ~39% of
1588:   the 119.63 GiB unified pool free.
1589: - `qwen3.8-27b-nvfp4-1m.service` and `qwen3.8-27b-vllm.service` (BF16)
1590:   are both `inactive`/`disabled` — intentionally retained on disk as
1591:   documented rollback paths, not deleted.
1592: - `/home/admin/scripts/qwen3.8-27b-nvfp4-896k-no-mtp.sh` is the
1593:   pre-MTP fallback launch script if MTP ever needs to be backed out.
1594: - No Ollama model is currently loaded (checked — the coexistence issue
1595:   from earlier this session is not currently active, but has no
1596:   permanent guard; see the open caveat above).
1597: 
1598: **What happened this session** (in order): closed out Task 6.2 steps
1599: 6-7 (NVFP4 adopted as production precision, at 896K not 1M per your
1600: own testing/decision); did the production cutover live (retired the 1M
1601: NVFP4 candidate and BF16, stood up `qwen3.8-27b-nvfp4-896k.service`,
1602: hit and fixed a real Ollama-pool-contention bug along the way); you
1603: asked whether MTP was enabled — it wasn't, so Task 6.3 tested it
1604: combined with YaRN-896K (previously never validated together),
1605: confirmed correctness/capacity/a 2.66x-3.12x throughput gain, and
1606: promoted it into production; answered how to control thinking mode
1607: from OpenCode (`chat_template_kwargs.enable_thinking` +
1608: `reasoningEffort`, via model `options`/`variants` in `opencode.jsonc`
1609: — NOT independently verified end-to-end through an actual OpenCode
1610: client on this box, since none runs here); built
1611: `bin/01-build.sh`/`bin/02-install-service.sh` for reproducing this
1612: deployment on a new system, added a `TP` (tensor-parallel-size) env
1613: var defaulting to 1 after you asked about multi-GPU spanning (GB10 only
1614: has 1 GPU; TP>1 is accepted but explicitly flagged as unvalidated by
1615: this feature) — **caught and fixed a real bug in the same edit** (a
1616: doubled `CPATH` path suffix that would have broken a fresh cold start;
1617: the live running process was unaffected since it predated the bug, but
1618: the regenerated file on disk was wrong until fixed); finally, did a
1619: documentation-accuracy pass over the whole Task List/Acceptance
1620: Criteria (found and fixed a stale Task 5.2 checkbox that contradicted
1621: its own Progress notes; closed out ACC-001/006/007/008/009/010, which
1622: were all already factually satisfied but never checked off).
1623: 
1624: **What's actually still open (the real remaining work on this
1625: feature)**:
1626: 
1627: 1. **ACC-003 / ACC-011 (the same underlying gap, twice)**: the OpenCode
1628:    *agentic session* leg was only ever run against the now-superseded
1629:    BF16 production service (Task 5.2, 2026-08-23). It has NOT been
1630:    re-run against the current NVFP4+MTP 896K production service. This
1631:    is the single most concrete "redo this against production" item
1632:    left. Needs you, not automatable (same precedent as `feat-1`
1633:    ACC-010).
1634: 2. **Your own `opencode.jsonc`** needs updating to the current model id
1635:    `qwen3.8:27b-nvfp4-896k` if it isn't already — snippet is earlier in
1636:    this Progress section (search "Current production OpenCode provider
1637:    snippet").
1638: 3. **Thinking-mode control via OpenCode** was explained (this session)
1639:    but not empirically verified end-to-end through an actual OpenCode
1640:    client — worth a quick sanity check the first time you use it
1641:    (confirm the request that hits the server actually carries
1642:    `chat_template_kwargs`/`reasoning_effort` as expected, e.g. via the
1643:    service's journal).
1644: 4. **Task 3.2** (optional FP8/quant weight eval) — explicitly left open
1645:    by earlier user decision; effectively superseded/moot now that NVFP4
1646:    is production, but never formally closed.
1647: 5. **MTP-at-long-context on a DIFFERENT context size or the 1M

(Output capped at 50 KB. Showing lines 816-1647. Use offset=1648 to continue.)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 6.3s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "find /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context -type f | sort"
}
```

**Output:**
```
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/00-check-env.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/01-build.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/02-install-service.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/session-ses_fcf4-feat-3-05.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/session-ses_fcfd-feat-3-04.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/session-ses_fd04-feat-3-03.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/session-ses_fd21-feat-3-02.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/session-ses_fd26-feat-3-01.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/session-ses_fd5d-feat-3-00.md

```

---

## Assistant (Plan · Claude Sonnet 5 · 4.7s)

There are ready-made reproducibility scripts. Let me inspect them, plus check remaining README content and the repo's other feature templates for conventions.

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/00-check-env.sh"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/00-check-env.sh</path>
<type>file</type>
<content>
1: #!/usr/bin/env bash
2: # feat-3-qwen3.8-27b-large-context — Phase 0 environment check
3: #
4: # Covers Task 0.1 (disk headroom), Task 0.2 (GB10/driver/CUDA + vLLM
5: # arm64 build version + Qwen3.8 architecture support), Task 0.3 (HF
6: # tooling).
7: #
8: # Read-only: does not download weights, does not modify anything.
9: # Run this ON THE DELL GB10 (DGX Spark clone), not on any other box.
10: 
11: set -euo pipefail
12: 
13: echo "=== Sanity: is this actually the Dell GB10? ==="
14: uname -m
15: grep -m1 'model name' /proc/cpuinfo || true
16: hostnamectl 2>/dev/null || hostname
17: echo
18: 
19: echo "=== Task 0.1: disk headroom ==="
20: df -h /
21: df -h "$HOME" 2>/dev/null || true
22: echo
23: 
24: echo "=== Task 0.2: GPUs (GB10 = 1x Grace-Blackwell, unified memory) ==="
25: nvidia-smi -L || echo "WARNING: nvidia-smi not found or no GPUs visible — GB10 driver not installed?"
26: echo
27: nvidia-smi --query-gpu=index,name,driver_version,memory.total,memory.free --format=csv || true
28: echo
29: 
30: echo "=== Task 0.2: CUDA toolkit ==="
31: nvcc --version 2>/dev/null || echo "nvcc not on PATH (may still be fine if only the driver/runtime matters)"
32: echo
33: 
34: echo "=== Task 0.2: vLLM version (must be an arm64 build for the GB10) ==="
35: VLLM_VERSION="$(python3 -c 'import vllm; print(vllm.__version__)' 2>&1)" || true
36: echo "vllm.__version__ = ${VLLM_VERSION}"
37: echo
38: 
39: echo "=== Task 0.2: does this vLLM build know about Qwen3.8 / qwen3_5 / Gated DeltaNet? ==="
40: python3 - <<'PYEOF' 2>&1 || true
41: import sys
42: try:
43:     from vllm.model_executor.models.registry import ModelRegistry
44:     names = sorted(ModelRegistry.get_supported_archs())
45:     hits = [n for n in names if "qwen3" in n.lower() or "deltanet" in n.lower() or "qwen3_5" in n.lower()]
46:     print("Qwen3.x / DeltaNet-related architectures registered:")
47:     for h in hits:
48:         print(" -", h)
49:     if not hits:
50:         print("NONE FOUND — this vLLM build likely does NOT support Qwen3.8-27B yet.")
51: except Exception as e:
52:     print(f"Could not introspect vLLM model registry: {e!r}")
53:     sys.exit(0)
54: PYEOF
55: echo
56: 
57: echo "=== Task 0.3: HF CLI / token ==="
58: hf --version 2>/dev/null || huggingface-cli --version 2>/dev/null || echo "hf/huggingface-cli not found on PATH"
59: hf auth whoami 2>/dev/null || huggingface-cli whoami 2>/dev/null || echo "Not logged in to Hugging Face (or CLI subcommand differs by version)"
60: echo
61: 
62: echo "=== Task 0.3: hf_transfer ==="
63: python3 -c "import hf_transfer; print('hf_transfer OK')" 2>&1 || echo "hf_transfer not installed"
64: echo
65: 
66: echo "=== Done. Paste this whole output back for review. ==="

(End of file - total 66 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/01-build.sh"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/01-build.sh</path>
<type>file</type>
<content>
1: #!/usr/bin/env bash
2: # feat-3-qwen3.8-27b-large-context — build/setup script for a NEW system
3: #
4: # Reproduces the environment work behind the CHOSEN PRODUCTION deployment
5: # (NVFP4 weights, 896K context via YaRN factor 3.5, MTP speculative
6: # decoding, FP8 KV cache) on a fresh GB10-class box (arm64,
7: # Grace-Blackwell/SM121, ~120 GB unified CPU+GPU memory pool) or
8: # equivalent hardware with enough VRAM/unified memory for the same
9: # config. See the feature README's Phase 0/1 and Phase 6 (Task 6.2/6.3)
10: # for the full narrative behind every step and fix below.
11: #
12: # Idempotent: safe to re-run; skips steps whose result already exists.
13: # Read/write to $HOME only -- no sudo/root required anywhere (every fix
14: # below was deliberately chosen to avoid needing interactive sudo, since
15: # it was unavailable on the box this was developed on).
16: #
17: # Does NOT install the systemd service -- run 02-install-service.sh
18: # after this succeeds.
19: #
20: # Env vars (all optional, defaults match this feature's own deployment):
21: #   VENV_DIR       venv location for vLLM        (default: $HOME/venvs/vllm)
22: #   MODEL_DIR      NVFP4 checkpoint destination   (default: $HOME/models/qwen3.8-27b-nvfp4)
23: #   VLLM_PIN       pinned vLLM PyPI version       (default: 0.27.1)
24: #   HF_TOKEN       Hugging Face token (only needed if the repo ever
25: #                  becomes gated -- it was NOT gated as of 2026-08-23)
26: set -euo pipefail
27: 
28: MODEL_REPO="unsloth/Qwen3.8-27B-NVFP4"
29: MODEL_REVISION="7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108"
30: VENV_DIR="${VENV_DIR:-$HOME/venvs/vllm}"
31: MODEL_DIR="${MODEL_DIR:-$HOME/models/qwen3.8-27b-nvfp4}"
32: VLLM_PIN="${VLLM_PIN:-0.27.1}"
33: 
34: echo "=== Sanity: platform ==="
35: uname -m
36: nvidia-smi -L || { echo "ERROR: no NVIDIA GPU visible -- install/verify the driver first (see 00-check-env.sh)."; exit 1; }
37: echo
38: 
39: echo "=== Step 1: uv (used for both Python tooling and the vLLM venv) ==="
40: if ! command -v uv >/dev/null 2>&1; then
41:   echo "Installing uv..."
42:   curl -LsSf https://astral.sh/uv/install.sh | sh
43:   export PATH="$HOME/.local/bin:$PATH"
44: fi
45: uv --version
46: echo
47: 
48: echo "=== Step 2: standalone Python 3.12 headers (Python.h) ==="
49: # Why: vLLM's Triton JIT step shells out to gcc to inspect the model
50: # architecture; gcc needs Python.h. python3.12-dev is often not
51: # installed system-wide and apt requires sudo, which may not be
52: # available non-interactively. uv's standalone CPython build ships
53: # headers with no sudo needed. Only the MINOR version (3.12) needs to
54: # match the venv's interpreter to avoid a C-API ABI mismatch -- the
55: # exact patch version does not matter.
56: if ! uv python list 2>/dev/null | grep -q 'cpython-3\.12.*linux'; then
57:   uv python install 3.12
58: fi
59: PYHDR="$(find "$HOME/.local/share/uv/python" -maxdepth 4 -path '*cpython-3.12*/include/python3.12/Python.h' 2>/dev/null | head -1)"
60: if [ -z "${PYHDR}" ]; then
61:   echo "ERROR: could not locate uv-installed CPython 3.12 headers (Python.h)." >&2
62:   exit 1
63: fi
64: export CPATH="$(dirname "${PYHDR}")"
65: echo "Python.h headers: ${CPATH}"
66: echo
67: 
68: echo "=== Step 3: vLLM venv (pinned to ${VLLM_PIN}, aarch64) ==="
69: if [ ! -x "${VENV_DIR}/bin/vllm" ]; then
70:   uv venv "${VENV_DIR}" --python 3.12
71:   uv pip install --python "${VENV_DIR}/bin/python" "vllm==${VLLM_PIN}" hf-transfer
72: else
73:   INSTALLED="$("${VENV_DIR}/bin/python" -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo unknown)"
74:   echo "vLLM already installed at ${VENV_DIR} (version ${INSTALLED})"
75:   if [ "${INSTALLED}" != "${VLLM_PIN}" ]; then
76:     echo "WARNING: installed version (${INSTALLED}) != pinned version (${VLLM_PIN})."
77:     echo "This feature's NVFP4/GB10 (SM121) kernel findings (Task 6.2 step 1) were"
78:     echo "verified specifically on ${VLLM_PIN} -- re-verify the kernel check in Step 5"
79:     echo "below on a different version before trusting the production config as-is."
80:   fi
81: fi
82: # ninja ships as a pip dependency of vllm, but torch.compile only finds
83: # it at RUNTIME if the venv's bin/ is on PATH (baked into the launch
84: # script by 02-install-service.sh, not needed here) -- just confirm it
85: # actually got installed.
86: "${VENV_DIR}/bin/python" -c "import ninja" 2>/dev/null && echo "ninja: OK (inside venv)" || echo "WARNING: ninja not found inside the venv -- torch.compile will fail at launch time."
87: echo
88: 
89: echo "=== Step 4: confirm this vLLM build recognizes Qwen3.8's architecture (qwen3_5) ==="
90: CPATH="${CPATH}" PATH="${VENV_DIR}/bin:$PATH" "${VENV_DIR}/bin/python" - <<'PYEOF'
91: from vllm.model_executor.models.registry import ModelRegistry
92: names = sorted(ModelRegistry.get_supported_archs())
93: hits = [n for n in names if "qwen3_5" in n.lower()]
94: print("qwen3_5 architectures registered:", hits or "NONE FOUND")
95: if not hits:
96:     raise SystemExit("ERROR: this vLLM build does not support Qwen3.8-27B's architecture")
97: PYEOF
98: echo
99: 
100: echo "=== Step 5: confirm NVFP4 GEMM kernel support for this GPU (Task 6.2 step 1 check) ==="
101: # NOTE: a community report (see README Phase 6, Task 6.2 step 1) found
102: # stock vllm/vllm-openai lacking NVFP4 kernels for Blackwell sm_121a on
103: # an older nightly build -- this feature's own stock PyPI 0.27.1 release
104: # DOES have them. Re-verify on whatever vLLM version actually installs
105: # here; if this fails, either pin back to a known-good version or treat
106: # NVFP4 as blocked on this hardware (see README for the fallback
107: # discussion, e.g. a community GB10-specific build).
108: CPATH="${CPATH}" PATH="${VENV_DIR}/bin:$PATH" "${VENV_DIR}/bin/python" - <<'PYEOF' || echo "WARNING: could not confirm NVFP4 kernel support -- inspect manually before trusting the production launch script."
109: try:
110:     from vllm._custom_ops import cutlass_scaled_mm_supports_fp4
111:     import torch
112:     cc = torch.cuda.get_device_capability(0)
113:     cc_int = cc[0] * 10 + cc[1]
114:     print(f"GPU compute capability: {cc} ({cc_int})")
115:     print("cutlass_scaled_mm_supports_fp4:", cutlass_scaled_mm_supports_fp4(cc_int))
116: except Exception as e:
117:     print(f"Could not run the kernel check: {e!r}")
118:     raise
119: PYEOF
120: echo
121: 
122: echo "=== Step 6: HF CLI + hf_transfer (inside the venv) ==="
123: "${VENV_DIR}/bin/hf" --version
124: if ! "${VENV_DIR}/bin/hf" auth whoami >/dev/null 2>&1; then
125:   echo "Not logged in to Hugging Face."
126:   if [ -n "${HF_TOKEN:-}" ]; then
127:     "${VENV_DIR}/bin/hf" auth login --token "${HF_TOKEN}"
128:   else
129:     echo "${MODEL_REPO} is NOT gated as of 2026-08-23, so an anonymous download"
130:     echo "should still work; set HF_TOKEN and re-run if it doesn't."
131:   fi
132: fi
133: echo
134: 
135: echo "=== Step 7: download ${MODEL_REPO} @ ${MODEL_REVISION} ==="
136: if [ -f "${MODEL_DIR}/config.json" ]; then
137:   echo "Model directory already exists at ${MODEL_DIR} -- skipping download."
138:   echo "Delete it first if you need to re-pull a different revision."
139: else
140:   mkdir -p "${MODEL_DIR}"
141:   HF_HUB_ENABLE_HF_TRANSFER=1 "${VENV_DIR}/bin/hf" download "${MODEL_REPO}" \
142:     --revision "${MODEL_REVISION}" \
143:     --local-dir "${MODEL_DIR}"
144: fi
145: echo
146: 
147: echo "=== Step 8: verify the tokenizer-truncation bug (fixed upstream 2026-08-15) is NOT present ==="
148: TRUNC="$("${VENV_DIR}/bin/python" -c "import json; print(json.load(open('${MODEL_DIR}/tokenizer.json'))['truncation'])")"
149: if [ "${TRUNC}" != "None" ]; then
150:   echo "ERROR: tokenizer.json 'truncation' field is '${TRUNC}', expected null/None." >&2
151:   echo "This is the community-reported bug described in the README's Phase 6" >&2
152:   echo "references -- do not use this checkpoint revision as-is if it recurs." >&2
153:   exit 1
154: fi
155: echo "tokenizer.json truncation field is null -- OK"
156: echo
157: 
158: echo "=== BUILD COMPLETE ==="
159: echo "venv:      ${VENV_DIR} (vLLM ${VLLM_PIN})"
160: echo "model:     ${MODEL_DIR} (revision ${MODEL_REVISION})"
161: echo "Next: run 02-install-service.sh to deploy the launch script + systemd service."

(End of file - total 161 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/02-install-service.sh"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/02-install-service.sh</path>
<type>file</type>
<content>
1: #!/usr/bin/env bash
2: # feat-3-qwen3.8-27b-large-context — install the PRODUCTION systemd
3: # service (NVFP4 weights, 896K context via YaRN factor 3.5, MTP
4: # speculative decoding, FP8 KV cache) on a NEW system.
5: #
6: # Run 01-build.sh FIRST (installs vLLM + downloads/pins the NVFP4
7: # checkpoint). This script only deploys the launch script + systemd
8: # --user unit and does NOT start the service by default -- this
9: # matches the feature's "systemd-only, never auto-start at boot"
10: # policy (README REQ-009): the unit is installed `disabled` (no
11: # `systemctl --user enable`), so it survives logout (via lingering)
12: # without launching automatically at boot. Pass --start to start it
13: # immediately after install.
14: #
15: # HARDWARE ASSUMPTION: this deploys the config validated on a GB10-class
16: # box (~120 GB unified CPU+GPU memory pool). If your target box has a
17: # meaningfully different amount of VRAM/unified memory, the
18: # --kv-cache-memory-bytes value below (33 GiB) and/or --max-model-len
19: # (917504) may need re-deriving via the same capacity-step-up
20: # methodology described in the feature README (Task 2.1-2.3/6.2 step 4)
21: # rather than assumed to transfer as-is.
22: #
23: # GPU COUNT: this deploys single-GPU (--tensor-parallel-size 1) by
24: # default, matching the GB10 this feature was validated on (it only has
25: # ONE GPU -- a single Grace-Blackwell SoC with one unified memory pool,
26: # nothing to span). Set TP to a value > 1 ONLY if your target box has
27: # multiple GPUs and you deliberately want to shard across them --
28: # this is UNVALIDATED by this feature: KV-cache capacity/headroom
29: # (Task 2.1-2.3/6.2 step 4) and the MTP throughput measurement
30: # (Task 6.3) were both measured at TP=1 only. Re-run the same
31: # capacity-step-up methodology before trusting the 896K context /
32: # --kv-cache-memory-bytes value at TP>1.
33: #
34: # Env vars (must match what 01-build.sh used, if you overrode them):
35: #   VENV_DIR    (default: $HOME/venvs/vllm)
36: #   MODEL_DIR   (default: $HOME/models/qwen3.8-27b-nvfp4)
37: #   SCRIPTS_DIR (default: $HOME/scripts)
38: #   TP          tensor-parallel-size / GPU count (default: 1)
39: set -euo pipefail
40: 
41: VENV_DIR="${VENV_DIR:-$HOME/venvs/vllm}"
42: MODEL_DIR="${MODEL_DIR:-$HOME/models/qwen3.8-27b-nvfp4}"
43: SCRIPTS_DIR="${SCRIPTS_DIR:-$HOME/scripts}"
44: SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
45: SERVICE_NAME="qwen3.8-27b-nvfp4-896k"
46: TP="${TP:-1}"
47: START_NOW=0
48: 
49: for arg in "$@"; do
50:   case "$arg" in
51:     --start) START_NOW=1 ;;
52:     *) echo "Unknown argument: $arg (only --start is supported)" >&2; exit 1 ;;
53:   esac
54: done
55: 
56: echo "=== Pre-flight checks ==="
57: if [ ! -x "${VENV_DIR}/bin/vllm" ]; then
58:   echo "ERROR: ${VENV_DIR}/bin/vllm not found -- run 01-build.sh first." >&2
59:   exit 1
60: fi
61: if [ ! -f "${MODEL_DIR}/config.json" ]; then
62:   echo "ERROR: ${MODEL_DIR}/config.json not found -- run 01-build.sh first." >&2
63:   exit 1
64: fi
65: if ! [[ "${TP}" =~ ^[0-9]+$ ]] || [ "${TP}" -lt 1 ]; then
66:   echo "ERROR: TP must be a positive integer (got '${TP}')." >&2
67:   exit 1
68: fi
69: GPU_COUNT="$(nvidia-smi -L 2>/dev/null | wc -l)"
70: if [ "${TP}" -gt 1 ]; then
71:   echo "WARNING: TP=${TP} requested -- sharding across multiple GPUs is UNVALIDATED"
72:   echo "by this feature (896K context / --kv-cache-memory-bytes were only measured"
73:   echo "at TP=1 on a single-GPU GB10). Re-run the capacity-step-up methodology"
74:   echo "(README Task 2.1-2.3/6.2 step 4) at this TP before trusting the result."
75:   if [ -n "${GPU_COUNT}" ] && [ "${GPU_COUNT}" -lt "${TP}" ]; then
76:     echo "ERROR: TP=${TP} but only ${GPU_COUNT} GPU(s) visible via nvidia-smi." >&2
77:     exit 1
78:   fi
79: fi
80: PYHDR="$(find "$HOME/.local/share/uv/python" -maxdepth 4 -path '*cpython-3.12*/include/python3.12/Python.h' 2>/dev/null | head -1)"
81: if [ -z "${PYHDR}" ]; then
82:   echo "ERROR: could not find the uv-installed CPython 3.12 headers -- run 01-build.sh first." >&2
83:   exit 1
84: fi
85: CPATH_DIR="$(dirname "${PYHDR}")"
86: echo "vLLM venv:  ${VENV_DIR}"
87: echo "Model dir:  ${MODEL_DIR}"
88: echo "Headers:    ${CPATH_DIR}"
89: echo "GPU count:  ${GPU_COUNT:-unknown} visible, TP=${TP} requested"
90: echo
91: 
92: mkdir -p "${SCRIPTS_DIR}" "${SYSTEMD_USER_DIR}"
93: 
94: echo "=== Writing launch script: ${SCRIPTS_DIR}/${SERVICE_NAME}.sh ==="
95: cat > "${SCRIPTS_DIR}/${SERVICE_NAME}.sh" <<SCRIPT_EOF
96: #!/usr/bin/env bash
97: # Production launch script for Qwen3.8-27B-NVFP4 + YaRN at 896K
98: # (917,504-token) context, YaRN factor 3.5, NVFP4 weights, FP8 KV cache,
99: # WITH MTP speculative decoding.
100: #
101: # Generated by .specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/02-install-service.sh
102: # (TP=${TP}) -- see that feature's README (Phase 6, Tasks 6.2/6.3) for
103: # the full validation record (capacity/headroom measurements,
104: # correctness checks, and the 2.66x/3.12x MTP throughput measurement)
105: # behind every flag below. Re-run the install script to regenerate this
106: # file if the feature's chosen production config ever changes; do not
107: # hand-edit without re-running the same validation methodology.
108: #
109: # NOTE: --tensor-parallel-size ${TP} was requested at install time.$([ "${TP}" -gt 1 ] && echo " This is
110: # UNVALIDATED by this feature -- 896K context / --kv-cache-memory-bytes
111: # were only measured at TP=1 on a single-GPU GB10 (see README Task
112: # 2.1-2.3/6.2 step 4). Re-run that capacity-step-up methodology at this
113: # TP before trusting this config in production.")
114: set -euo pipefail
115: 
116: export CPATH="${CPATH_DIR}"
117: export PATH="${VENV_DIR}/bin:\$PATH"
118: export VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
119: export VLLM_ENGINE_READY_TIMEOUT_S=3600
120: export VLLM_DISABLE_COMPILE_CACHE=1
121: 
122: # factor = 917504 / 262144 = 3.5
123: HF_OVERRIDES='{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 3.5, "original_max_position_embeddings": 262144}}}'
124: 
125: exec "${VENV_DIR}/bin/vllm" serve "${MODEL_DIR}" \\
126:   --port 8000 --trust-remote-code --no-enable-prefix-caching \\
127:   --tensor-parallel-size ${TP} \\
128:   --max-model-len 917504 \\
129:   --served-model-name qwen3.8:27b-nvfp4-896k \\
130:   --kv-cache-dtype fp8 \\
131:   --kv-cache-memory-bytes 35433480192 \\
132:   --hf-overrides "\${HF_OVERRIDES}" \\
133:   --speculative-config '{"method":"mtp","num_speculative_tokens":5}' \\
134:   --enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3
135: SCRIPT_EOF
136: chmod +x "${SCRIPTS_DIR}/${SERVICE_NAME}.sh"
137: 
138: echo "=== Writing systemd unit: ${SYSTEMD_USER_DIR}/${SERVICE_NAME}.service ==="
139: cat > "${SYSTEMD_USER_DIR}/${SERVICE_NAME}.service" <<UNIT_EOF
140: [Unit]
141: Description=vLLM - Qwen3.8-27B-NVFP4 (896K context, YaRN factor 3.5, NVFP4 weights, FP8 KV cache, MTP speculative decoding) -- feat-3-qwen3.8-27b-large-context production
142: After=network-online.target
143: Wants=network-online.target
144: 
145: [Service]
146: Type=simple
147: WorkingDirectory=%h
148: ExecStart=${SCRIPTS_DIR}/${SERVICE_NAME}.sh
149: Restart=on-failure
150: RestartSec=10
151: # Weight load + KV-cache profiling/compile at long max-model-len is
152: # slow; give systemd a longer leash than the launch script's own
153: # internal VLLM_ENGINE_READY_TIMEOUT_S=3600 so systemd never kills the
154: # unit mid-startup.
155: TimeoutStartSec=4200
156: LimitNOFILE=1048576
157: 
158: [Install]
159: WantedBy=default.target
160: UNIT_EOF
161: 
162: echo "=== Enabling lingering (survive logout without autostart at boot) ==="
163: if loginctl show-user "$(whoami)" 2>/dev/null | grep -q '^Linger=yes'; then
164:   echo "Lingering already enabled for $(whoami)."
165: else
166:   loginctl enable-linger "$(whoami)" \
167:     || echo "WARNING: could not enable lingering (may need polkit permission for your own user, or root) -- the service will still work while you stay logged in."
168: fi
169: 
170: echo "=== systemctl --user daemon-reload ==="
171: systemctl --user daemon-reload
172: 
173: echo
174: echo "Installed: ${SERVICE_NAME}.service"
175: echo "Deliberately left 'disabled' (will NOT autostart at boot, per REQ-009's policy)."
176: systemctl --user status "${SERVICE_NAME}.service" --no-pager || true
177: 
178: if [ "${START_NOW}" -eq 1 ]; then
179:   echo
180:   echo "=== --start given: starting the service now ==="
181:   systemctl --user start "${SERVICE_NAME}.service"
182:   echo "Started. Cold load typically takes ~4-9 minutes on GB10-class hardware"
183:   echo "(weight load without page-cache prefetch + KV-cache profiling/compile)."
184:   echo "Check readiness with: curl http://localhost:8000/health"
185: else
186:   echo
187:   echo "Not started (default). Start it explicitly with:"
188:   echo "  systemctl --user start ${SERVICE_NAME}.service"
189:   echo "Then verify with:"
190:   echo "  curl http://localhost:8000/v1/models"
191:   echo "  curl http://localhost:8000/v1/chat/completions -H 'Content-Type: application/json' -d '{\"model\":\"qwen3.8:27b-nvfp4-896k\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"max_tokens\":10}'"
192: fi

(End of file - total 192 lines)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 13.6s)

_Thinking:_



Let me check what machine this session is actually running on, since prior feat-3 sessions ran shell commands directly on the target box.

**Tool: bash**

**Input:**
```json
{
  "command": "echo \"== host ==\" ; hostname; uname -m; echo \"== cpu ==\" ; grep -m1 'model name' /proc/cpuinfo 2>/dev/null || lscpu | head -20; echo \"== mem ==\" ; free -h; echo \"== gpu ==\" ; nvidia-smi -L 2>&1 || echo \"no nvidia-smi\"; echo \"== disk ==\" ; df -h / 2>/dev/null"
}
```

**Output:**
```
== host ==
sys0
x86_64
== cpu ==
model name	: Intel(R) Xeon(R) w9-3595X
== mem ==
               total        used        free      shared  buff/cache   available
Mem:           502Gi       3,9Gi       497Gi       3,0Mi       1,7Gi       496Gi
Swap:          2,0Gi          0B       2,0Gi
== gpu ==
GPU 0: NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (UUID: GPU-5200c9f6-a6bc-e388-2bfc-0e6ddce48ad4)
GPU 1: NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (UUID: GPU-a9939c99-8f16-8d51-fbda-27deb46f0c63)
GPU 2: NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (UUID: GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea)
GPU 3: NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (UUID: GPU-780fe0cd-17a5-153d-bd3c-766d6c1c120e)
== disk ==
Filesystem      Size  Used Avail Use% Mounted on
/dev/md124p3    1,9T  390G  1,4T  22% /

```

---

## Assistant (Plan · Claude Sonnet 5 · 12.4s)

_Thinking:_



This machine is the **Dell 7960T** (x86_64, 4× RTX PRO 6000 Blackwell Max-Q, 96GB VRAM each = 384GB, 512GB system RAM) — a completely different architecture than feat-3's target (arm64 GB10 DGX Spark clone with a single 128GB *unified* CPU+GPU pool). Let me check the existing feat-1/feat-2 setups on this box and current GPU state before planning.

**Tool: bash**

**Input:**
```json
{
  "command": "echo \"== nvidia-smi processes ==\" ; nvidia-smi --query-gpu=index,name,memory.total,memory.used,memory.free --format=csv; echo; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv 2>&1; echo; echo \"== driver/cuda ==\" ; nvidia-smi | head -5; nvcc --version 2>&1 | tail -5; echo; echo \"== systemd user services (any llm/vllm/ktransformers) ==\" ; systemctl --user list-units --all 2>&1 | grep -Ei 'vllm|ktransformers|glm|deepseek|qwen|ollama' ; systemctl list-units --all 2>&1 | grep -Ei 'vllm|ktransformers|glm|deepseek|qwen|ollama'"
}
```

**Output:**
```
== nvidia-smi processes ==
index, name, memory.total [MiB], memory.used [MiB], memory.free [MiB]
0, NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition, 97887 MiB, 2 MiB, 97288 MiB
1, NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition, 97887 MiB, 2 MiB, 97288 MiB
2, NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition, 97887 MiB, 2 MiB, 97279 MiB
3, NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition, 97887 MiB, 10 MiB, 97280 MiB

pid, process_name, used_gpu_memory [MiB]

== driver/cuda ==
Tue Aug 25 13:20:26 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 610.57.04              KMD Version: 610.57.04     CUDA UMD Version: 13.3     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
/bin/bash: line 1: nvcc: command not found

== systemd user services (any llm/vllm/ktransformers) ==

```

---

## Assistant (Plan · Claude Sonnet 5 · 7.4s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "systemctl --user list-unit-files 2>&1 | grep -Ei 'vllm|ktransformers|glm|deepseek|qwen|ollama'; echo \"---\"; systemctl list-unit-files 2>&1 | grep -Ei 'vllm|ktransformers|glm|deepseek|qwen|ollama'; echo \"---venvs---\"; ls -la ~/venvs 2>&1; ls -la ~/models 2>&1; ls -la /data 2>&1 | head -20; echo \"---scripts---\"; ls -la ~/scripts 2>&1"
}
```

**Output:**
```
llama-glm-5.2-q4.service                                          disabled  enabled
llama-glm-5.2.service                                             disabled  enabled
---
vllm-deepseek-v4-flash-clean.service           disabled        enabled
vllm-deepseek-v4-flash.service                 disabled        enabled
---venvs---
ls: cannot access '/home/user/venvs': No such file or directory
ls: cannot access '/home/user/models': No such file or directory
total 12
drwxr-xr-x  9 user user  154 Aug 19 11:53 .
drwxr-xr-x 22 root root 4096 Mai 20 17:09 ..
drwxr-xr-x  3 user user   33 Jun  2 00:50 automodel
drwxrwxr-x  3 user user   25 Aug 18 12:15 .cache
drwxrwxr-x  3 user user   20 Aug 19 11:14 llama_cpp
drwxrwxr-x 31 user user 4096 Aug 19 12:05 llama.cpp-dsa
drwxr-xr-x  7 user user  108 Mai 29 14:50 nvidia
drwxr-xr-x  6 user user   89 Aug  7 07:43 ollama-models
drwxrwxr-x  5 user user 4096 Aug 19 11:58 vllm
---scripts---
ls: cannot access '/home/user/scripts': No such file or directory

```

---

## Assistant (Plan · Claude Sonnet 5 · 6.6s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "ls -la /data/vllm 2>&1 | head -20; echo \"---\"; find /data -maxdepth 2 -iname \"*deepseek*\" -o -iname \"*glm*\" -o -iname \"*qwen*\" 2>/dev/null; echo \"---vllm venv version---\"; /data/vllm/*/bin/python -c \"import vllm; print(vllm.__version__)\" 2>&1 | head -5; find /data/vllm -maxdepth 3 -iname \"bin\" 2>/dev/null; echo \"---disk---\"; df -h /data 2>&1"
}
```

**Output:**
```
total 44
drwxrwxr-x 5 user user 4096 Aug 19 11:58 .
drwxr-xr-x 9 user user  154 Aug 19 11:53 ..
-rw-rw-r-- 1 user user  758 Aug 18 14:26 download_flash.py
-rw-rw-r-- 1 user user  748 Aug 18 14:27 download_pro.py
drwxrwxr-x 7 user user  155 Aug  7 09:55 .git
-rw-rw-r-- 1 user user  109 Aug  7 09:55 .gitignore
-rw-rw-r-- 1 user user   82 Aug  7 09:55 main.py
-rw-rw-r-- 1 user user  150 Aug  7 09:55 pyproject.toml
-rw-rw-r-- 1 user user    5 Aug  7 09:55 .python-version
-rw-rw-r-- 1 user user    0 Aug  7 09:55 README.md
-rwxrwxr-x 1 user user  168 Aug  7 10:04 start_reap50_q3_k_m.sh
-rwxrwxr-x 1 user user  174 Aug  7 10:02 start_unsloth_q3_k_m.sh
-rw-rw-r-- 1 user user  124 Aug  7 09:55 uv.lock
drwxrwxr-x 6 user user  179 Aug  7 10:06 .venv
drwxrwxr-x 6 user user  162 Aug 19 12:28 .venv-clean
-rw-rw-r-- 1 user user  941 Aug 18 16:20 vllm-deepseek-v4-flash.service
---
/data/ollama-models/glm-5.2-gguf
/data/vllm/vllm-deepseek-v4-flash.service
---vllm venv version---
/bin/bash: line 1: /data/vllm/*/bin/python: No such file or directory
/data/vllm/.venv/bin
/data/vllm/.venv-clean/bin
---disk---
Filesystem      Size  Used Avail Use% Mounted on
/dev/md126       15T  7,7T  7,0T  53% /data

```

---

## Assistant (Plan · Claude Sonnet 5 · 59.6s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "/data/vllm/.venv/bin/python -c \"import vllm; print(vllm.__version__)\" 2>&1; echo \"---clean---\"; /data/vllm/.venv-clean/bin/python -c \"import vllm; print(vllm.__version__)\" 2>&1; echo \"---model dirs---\"; find /data -maxdepth 3 -iname \"*deepseek*\" -o -iname \"*qwen*model*\" 2>/dev/null; find / -maxdepth 4 -iname \"*Qwen3.8*\" 2>/dev/null; echo \"---git remote/log of vllm repo---\"; git -C /data/vllm log --oneline -5 2>&1; git -C /data/vllm remote -v 2>&1"
}
```

**Output:**
```
0.26.0
---clean---
0.26.0
---model dirs---
/data/vllm/vllm-deepseek-v4-flash.service
/data/llama.cpp-dsa/conversion/deepseek.py
/data/llama.cpp-dsa/models/ggml-vocab-deepseek-coder.gguf
/data/llama.cpp-dsa/models/ggml-vocab-deepseek-coder.gguf.inp
/data/llama.cpp-dsa/models/ggml-vocab-deepseek-coder.gguf.out
/data/llama.cpp-dsa/models/ggml-vocab-deepseek-llm.gguf
/data/llama.cpp-dsa/models/ggml-vocab-deepseek-llm.gguf.inp
/data/llama.cpp-dsa/models/ggml-vocab-deepseek-llm.gguf.out
---git remote/log of vllm repo---
fatal: your current branch 'master' does not have any commits yet

```

---

## Assistant (Plan · Claude Sonnet 5 · 31.8s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "/data/vllm/.venv/bin/python -c \"\nfrom vllm.model_executor.models.registry import ModelRegistry\nnames = sorted(ModelRegistry.get_supported_archs())\nhits = [n for n in names if 'qwen3' in n.lower() or 'deltanet' in n.lower()]\nprint('hits:', hits)\n\" 2>&1 | tail -20"
}
```

**Output:**
```
hits: ['ColQwen3', 'ColQwen3_5', 'Eagle3Qwen3ForCausalLM', 'Eagle3Qwen3vlForCausalLM', 'OpsColQwen3Model', 'PeagleQwen3ForCausalLM', 'Qwen3ASRForConditionalGeneration', 'Qwen3ASRForcedAlignerForTokenClassification', 'Qwen3ASRRealtimeGeneration', 'Qwen3DSparkModel', 'Qwen3ForCausalLM', 'Qwen3MoeForCausalLM', 'Qwen3NextForCausalLM', 'Qwen3NextMTP', 'Qwen3OmniMoeForConditionalGeneration', 'Qwen3VLForConditionalGeneration', 'Qwen3VLMoeForConditionalGeneration', 'Qwen3VLNemotronEmbedModel', 'Qwen3_5ForConditionalGeneration', 'Qwen3_5MTP', 'Qwen3_5MoeForConditionalGeneration', 'Qwen3_5MoeMTP', 'VoyageQwen3BidirectionalEmbedModel']

```

---

## Assistant (Plan · Claude Sonnet 5 · 15.1s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "/data/vllm/.venv/bin/python -c \"\nimport torch\nprint('cuda available:', torch.cuda.is_available())\nfor i in range(torch.cuda.device_count()):\n    print(i, torch.cuda.get_device_name(i), torch.cuda.get_device_capability(i))\n\" 2>&1 | tail -20\necho \"---fp4 support---\"\n/data/vllm/.venv/bin/python -c \"\nfrom vllm._custom_ops import cutlass_scaled_mm_supports_fp4\nimport torch\ncc = torch.cuda.get_device_capability(0)\ncc_int = cc[0]*10+cc[1]\nprint('cc', cc, cc_int)\nprint('fp4 supported:', cutlass_scaled_mm_supports_fp4(cc_int))\n\" 2>&1 | tail -20"
}
```

**Output:**
```
cuda available: True
0 NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (12, 0)
1 NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (12, 0)
2 NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (12, 0)
3 NVIDIA RTX PRO 6000 Blackwell Max-Q Workstation Edition (12, 0)
---fp4 support---
cc (12, 0) 120
fp4 supported: True

```

---

## Assistant (Plan · Claude Sonnet 5 · 35.1s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "find /home/user/src/biz.dfch.LlmOps/.specmgr/feat -maxdepth 1 -type d | sort"
}
```

**Output:**
```
/home/user/src/biz.dfch.LlmOps/.specmgr/feat
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context

```

---

## Assistant (Plan · Claude Sonnet 5 · 112.4s)

**Tool: task**

**Input:**
```json
{
  "description": "Summarize feat-1 and feat-2 GPU allocation",
  "prompt": "Read the following two files:\n- /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md\n- /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md\n\nI need a concise research summary (not a full reproduction) answering these questions:\n\n1. feat-1 (DeepSeek-V4-Flash via vLLM, tensor-parallel=4): What is the CURRENT status (frontmatter `status:` field)? Is the service currently meant to be running/active, or was it just validated and left disabled? How much VRAM per GPU / total does the DeepSeek-V4-Flash deployment actually consume once running (look for measured numbers)? Does it use all 4 GPUs simultaneously via TP=4, with no spare GPU/VRAM headroom, or is there documented headroom on any GPU?\n\n2. feat-2 (GLM-5.2 via ktransformers, GPU+CPU-RAM hybrid MoE): What is the CURRENT status? How many/which GPUs does it use (all 4? some subset?) and how much VRAM does it consume? Does it leave any GPU or VRAM completely free, or does it also span/touch all 4 GPUs?\n\n3. Is there any existing statement in either README about whether feat-1 and feat-2 are meant to run CONCURRENTLY on this box (Dell 7960T), or whether they are time-shared (only one active at a time)? Quote or closely paraphrase any relevant \"Decisions Made\"/coexistence notes.\n\n4. What GPU driver version, CUDA version, and vLLM version are recorded as validated/used in feat-1? Any notes on the SM120 sparse-attention-decode bug (`vllm-project/vllm#52938`) and its status/workaround?\n\n5. What systemd service naming/pattern convention do feat-1 and feat-2 use (system-level vs --user, unit names, venv paths, model weight storage paths under /data)?\n\n6. Any noted \"lessons learned\" / environment gotchas from feat-1/feat-2 setup on THIS SPECIFIC box (Dell 7960T) that would be relevant to bringing up a third model (e.g., disk paths, non-standard NVIDIA driver/package pinning per hardware/dell-7960t docs, systemd quirks, coexistence caveats).\n\nPlease return a structured, concise summary organized by these 6 questions. Keep it factual and cite line numbers/file where useful. Do not speculate beyond what the documents say.",
  "subagent_type": "explore"
}
```

**Output:**
```
<task id="ses_fc756fd47ffe931fnmpATW0vfL" state="completed">
<task_result>
Now I have everything needed. Here's the concise research summary.

## Research Summary: feat-1 (DeepSeek-V4-Flash/vLLM) vs feat-2 (GLM-5.2/llama.cpp) on Dell 7960T

### 1. feat-1 status, running state, and VRAM/GPU usage

- **Frontmatter `status:`** = `planning` (line 5), `updated: 2026-08-19`.
- **Not currently running / left disabled**, not just "validated and stopped by design" — it is **blocked**. Task 1.4 (curl smoke test) is unresolved: the service starts and serves HTTP but produces degenerate/garbage output (identical frozen token + identical logprob at every decode position). Both the production `vllm-deepseek-v4-flash.service` and a diagnostic `-clean` variant are explicitly **stopped** ("Left deliberately idle" — README lines 262–272, 216–219). The bug was escalated upstream as `vllm-project/vllm#52938`, still awaiting response as of the last update.
- **Measured VRAM**: When running, Flash (native FP4+FP8 mixed experts, TP=4, fp8 KV-cache) consumed **~90.6 GB per GPU** across all 4 GPUs (line 577: "down from ~90.6 GB used each" when stopped, freeing to ~97.3 GB free). Total ≈ **362 GB across 4×96GB GPUs**.
- **All 4 GPUs used simultaneously, essentially no headroom**: TP=4 shards the model across all 4 GPUs equally; at ~90.6/~97.3 GB used, only **~6–7 GB (~7%) free per GPU** while running — no meaningful spare capacity documented. (Design Notes originally targeted an FP8-expert override for a lighter ~284GB footprint "with headroom," but that override hit a vLLM TP-sharding bug and was abandoned in favor of the heavier native FP4+FP8 mixed fallback — line 128–131, 895–899.)

### 2. feat-2 status, GPU usage, and VRAM/RAM footprint

- **Frontmatter `status:`** = `planning` (line 5), `updated: 2026-08-20`.
- **Actively running / production-usable** — much further along than feat-1. `llama-glm-5.2.service` (Q5, `UD-Q5_K_XL`) was started and cold-loaded successfully (Task 2.4, ~33 min load), passed a full smoke test (all 3 reasoning modes + tool-calling, no degenerate output). As of the latest session (2026-08-22), Q4 (`UD-Q4_K_XL`) was live as the swapped-in service after a benchmarking run, confirmed healthy.
- **Uses all 4 GPUs, in a GPU+CPU-RAM hybrid split**: `--n-cpu-moe 54 --tensor-split 54,9,8,8` — the first 54 MoE layers stay on CPU/RAM, the rest are placed unevenly across all 4 GPUs (CUDA1 heaviest static weight at 62,690 MiB; CUDA0 lightest at 19,485 MiB). At the production **768K context**, measured per-GPU free memory (Q5): CUDA0 22,569 MiB (23.2%), CUDA1 ~33,400 MiB (34.3%), CUDA2 ~40,033 MiB (41.2%), CUDA3 ~51,315 MiB (52.8%) — Q4 is similar/slightly better.
- **No GPU is left completely free** — all 4 GPUs are touched, but with real headroom (roughly **23–53% free depending on GPU** at 768K), unlike feat-1. Total footprint at production config: ~197–245 GB across the 896GB VRAM+RAM pool (GPU memory ~190–245 GB range measured during KV-cache sweeps, plus ~11–12 GiB system RAM — Task 2.1 table, lines 272–290).

### 3. Concurrency / time-sharing statement

- No explicit statement that the two engines are meant to run **simultaneously** at full load. The documented relationship is that they **"coexist" as independent features**, not that they share GPU time concurrently:
  - feat-1, Decisions Made: *"GLM-5.2 fallback explicitly deferred to a separate, future feature — not built here"* (line 872).
  - feat-2, Scope (out of scope): *"Retiring or changing the `feat-1` DeepSeek-V4 deployment — the two coexist; this feature does not depend on `feat-1` succeeding"* (lines 164–165).
  - feat-2, Decisions Made: *"Created as a standalone feature (`feat-2`), separate from `feat-1`'s DeepSeek-V4 work — the GLM-5.2 fallback was explicitly deferred to a future feature in `feat-1`, and the two models coexist rather than one replacing the other"* (lines 1696–1699).
  - "Coexist" here is used in the sense of "both are valid, independently-tracked deployments on the same box," not a claim of simultaneous GPU residency. In fact, feat-2's Task 1.1 note observes GPUs were "still occupied by `feat-1`'s service" during feat-2's early spike work (line 263), implying practical exclusivity in at least that period. No README states an explicit policy of time-sharing/mutual exclusion between feat-1 and feat-2 specifically (unlike feat-3, which explicitly documents Q4/Q5-within-feat-2 and BF16/NVFP4-within-feat-3 as unable to run concurrently due to capacity). Given feat-1 Flash alone consumes ~90.6GB/96GB per GPU when active, and feat-2 also needs real allocation on all 4 GPUs, concurrent full-load residency of both is not shown to be evaluated/possible in either README — this is an inference from the numbers, not a stated conclusion.

### 4. feat-1: driver/CUDA/vLLM versions and the SM120 bug

- **GPU driver**: `610.57.04`; **CUDA**: `13.3` (Task 0.2, line 162) — 4× RTX Pro 6000 Blackwell (SM120), 384 GB VRAM total.
- **vLLM**: pinned/validated at **0.26.0**, with **flashinfer-python 0.6.14** (Decisions Made, line 912–918). A trial upgrade to vLLM 0.27.1 / flashinfer 0.6.17 was attempted and **rolled back** — it hit a hard, unconditional "Unsupported architecture" DeepGEMM/mHC gap for SM120 (lines 380–402, 912–918).
- **SM120 sparse-attention-decode bug / `vllm-project/vllm#52938`**: Filed 2026-08-19 as *"[Bug]: DeepSeek-V4-Flash on RTX PRO 6000 Blackwell (SM120) emits degenerate output — identical argmax token + identical logprob at every decode position, TP and DP+EP alike... (FLASHINFER_MLA_SPARSE_DSV4)"* (lines 796–804, 941–947). Status: **open, awaiting upstream response**, still the active blocker for Task 1.4/Phase 1 completion. All local hypotheses (CUDA-graph capture, TP-vs-DP+EP, torch.compile fusions, fp8-KV-cache tunability, environment/venv contamination) were systematically ruled out. Cross-feature corroborating evidence: feat-2's `llama.cpp` build produced coherent (non-degenerate) output on the **same SM120 GPUs** for GLM-5.2's DSA kernel, supporting a "vLLM/FlashInfer-specific bug," not "SM120-hardware-fundamental" (lines 810–850).

### 5. systemd conventions

| | feat-1 (vLLM/DeepSeek-V4-Flash) | feat-2 (llama.cpp/GLM-5.2) |
|---|---|---|
| Unit scope | **System-level**, `/etc/systemd/system/vllm-deepseek-v4-flash.service`, needs `sudo` | **`systemctl --user`**, `~/.config/systemd/user/llama-glm-5.2.service` (and `...-q4.service`), no `sudo` for start/stop |
| Unit name pattern | `vllm-deepseek-v4-flash.service` (+ `-clean` diagnostic variant) | `llama-glm-5.2.service` (Q5) / `llama-glm-5.2-q4.service` (Q4) — separate, swappable units, never run together |
| Autostart/persistence | `User=`/`Group=user`, `[Install] WantedBy=multi-user.target` | No `User=`/`Group=` (meaningless for `--user` units); persistence via `loginctl enable-linger` for `user`, unit deliberately left **NOT enabled** so it doesn't autostart at boot (must be started manually after reboot) |
| Venv/build path | `/data/vllm/.venv` (+ `.venv-clean`) | `/data/llama.cpp-dsa` (dedicated CUDA build, `build/bin/llama-server`) |
| Model weights path | `/data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Flash` (and `-Pro`), via `HF_HOME=/data/nvidia/hf_cache` | `/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q5_K_XL/...` and `.../UD-Q4_K_XL/...` (GGUF shards) |
| Other conventions | `Type=notify`, `KillMode=control-group`, `TimeoutStartSec=3600`, `Restart=on-failure` | `Type=simple` (llama-server has no sd_notify), `KillMode=control-group`, `Restart=on-failure`, `RestartSec=10`; ports 8092 (Q5)/8093 (Q4) chosen to avoid collision with feat-1's port 8000 |

### 6. Lessons learned / gotchas relevant to a third model

- **CUDA-toolkit wheel-version skew** (recurring ≥4 times in feat-1): pip-installed `nvidia-cuda-nvcc`/`-crt`/`-cccl` vs `-runtime`/`-nvrtc`/`-cupti` can drift onto mismatched CUDA minor lines (e.g. 13.3.x vs 13.0.x) whenever a dependency (torch, quack-kernels) is reinstalled, breaking JIT compiles (TileLang/FlashInfer). Must pin all six `nvidia-cuda-*` wheels to the same line and re-check after any dependency reinstall.
- **systemd `KillMode=process` leaves orphaned GPU-memory-holding workers** after a start-timeout kill — always use `KillMode=control-group`.
- **Missing `PATH`/`ninja`/`libcudart` symlinks** in the systemd unit environment break JIT-compiled CUDA extensions — must explicitly set `PATH` including the venv's `nvidia/cu13/bin`, and a `cu13/lib64 -> lib` symlink for FlashInfer's linker.
- **Silent network hangs**: even with fully-local weights, vLLM startup can hang on an outbound Hugging Face call unless `HF_HUB_OFFLINE=1`/`TRANSFORMERS_OFFLINE=1` are set.
- **`/dev/nvidia*` are world-writable (`crw-rw-rw-`)** on this box currently, so `--user` units work without explicit `video`/`render` group membership — but this was still added defensively (Task 2.3.2) since a driver update could tighten permissions.
- **`/swapfile` is only 2 GiB**, ~90% used — essentially useless as a real capacity cushion, functions only as an early trip-wire; `vm.swappiness` tuned to `1` (not `0`) via `/etc/sysctl.d/`.
- **`/data` sits on an `mdadm` RAID10 (`/dev/md126`)** with a periodic `mdcheck_continue.timer` consistency-check scrub that can silently throttle disk I/O (120→53 MB/s observed) during large model cold-loads — check `/proc/mdstat`/`sync_action` before benchmarking load times.
- **PCIe topology matters for GPU/CPU-hybrid placement**: GPU0/GPU2 are PCIe 5.0 x16, GPU1/GPU3 are PCIe 4.0 x16 — relevant for deciding which GPU absorbs CPU-offloaded MoE-expert streaming traffic.
- **Two engines occupying the same 4 GPUs can't be assumed to coexist at full load** — feat-2 explicitly found that even two *quants of the same model* (Q4+Q5, ~1029 GB combined) can't fit the 896 GB pool simultaneously, requiring separate swappable services rather than true side-by-side residency; the same capacity logic would apply when adding a third model.
- **`hardware/dell-7960t/`** (referenced in AGENTS.md/README but not read in detail here) holds the box's NVIDIA driver config, package pinning, and recovery procedure — should be consulted directly before any driver/CUDA-affecting change for a third model.
- **Long-running/unattended jobs** (multi-hour downloads, cold-loads, tuning sweeps): AGENTS.md explicitly calls out a feat-2 Task 2.1 incident as the reason to delegate polling/monitoring rather than tick-by-tick `nvidia-smi`/log-tail checks in the main session.
</task_result>
</task>
```

---

## Assistant (Plan · Claude Sonnet 5 · 59.8s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "/data/vllm/.venv/bin/vllm serve --help 2>&1 | grep -iE \"kv-cache-dtype|kv-cache-memory-bytes|hf-overrides|speculative-config|tensor-parallel-size|served-model-name|reasoning-parser|tool-call-parser|enable-auto-tool-choice|linear-backend\" "
}
```

**Output:**
```
(no output)
```

---

## Assistant (Plan · Claude Sonnet 5 · 9.9s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "/data/vllm/.venv/bin/vllm serve --help 2>&1 | head -50"
}
```

**Output:**
```
usage: vllm serve [model_tag] [options]

Launch a local OpenAI-compatible API server to serve LLM
completions via HTTP. Defaults to Qwen/Qwen3-0.6B if no model is specified.

Search by using: `--help=<ConfigGroup>` to explore options by section (e.g.,
--help=ModelConfig, --help=Frontend)
  Use `--help=all` to show all available flags at once.

Config Groups:
  positional arguments    
  options                 
  Frontend                Arguments for the OpenAI-compatible frontend server.
  ModelConfig             Configuration for the model.
  LoadConfig              Configuration for loading the model weights.
  AttentionConfig         Configuration for attention mechanisms in vLLM.
  MambaConfig             Configuration for Mamba SSM backends.
  StructuredOutputsConfig Dataclass which contains structured outputs config for the engine.
  ParallelConfig          Configuration for the distributed execution.
  CacheConfig             Configuration for the KV cache.
  OffloadConfig           Configuration for model weight offloading to reduce GPU memory usage.
  MultiModalConfig        Controls the behavior of multimodal models.
  LoRAConfig              Configuration for LoRA.
  ObservabilityConfig     Configuration for observability - metrics and tracing.
  SchedulerConfig         Scheduler configuration.
  CompilationConfig       Configuration for compilation.
  
      You must pass CompilationConfig to VLLMConfig constructor.
      VLLMConfig's post_init does further initialization. If used outside of the
      VLLMConfig, some fields will be left in an improper state.
  
      It contains PassConfig, which controls the custom fusion/transformation passes.
      The rest has three parts:
  
      - Top-level Compilation control:
          - [`mode`][vllm.config.CompilationConfig.mode]
          - [`debug_dump_path`][vllm.config.CompilationConfig.debug_dump_path]
          - [`cache_dir`][vllm.config.CompilationConfig.cache_dir]
          - [`backend`][vllm.config.CompilationConfig.backend]
          - [`custom_ops`][vllm.config.CompilationConfig.custom_ops]
          - [`splitting_ops`][vllm.config.CompilationConfig.splitting_ops]
          - [`compile_mm_encoder`][vllm.config.CompilationConfig.compile_mm_encoder]
      - CudaGraph capture:
          - [`cudagraph_mode`][vllm.config.CompilationConfig.cudagraph_mode]
          - [`cudagraph_capture_sizes`]
          [vllm.config.CompilationConfig.cudagraph_capture_sizes]
          - [`max_cudagraph_capture_size`]
          [vllm.config.CompilationConfig.max_cudagraph_capture_size]
          - [`cudagraph_num_of_warmups`]
          [vllm.config.CompilationConfig.cudagraph_num_of_warmups]

```

---

## Assistant (Plan · Claude Sonnet 5 · 10.1s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "/data/vllm/.venv/bin/vllm serve --help=all 2>&1 | grep -iE \"kv-cache-dtype|kv-cache-memory-bytes|hf-overrides|speculative-config|tensor-parallel-size|served-model-name|reasoning-parser|tool-call-parser|enable-auto-tool-choice|linear-backend|rope\""
}
```

**Output:**
```
  --enable-auto-tool-choice, --no-enable-auto-tool-choice
  --tool-call-parser {apertus,cohere_command3,cohere_command4,deepseek_v3,deepseek_v31,deepseek_v32,deepseek_v4,ernie45,functiongemma,gemma4,gigachat3,glm45,glm47,granite,granite-20b-fc,granite4,hermes,hunyuan_a13b,hy_v3,inkling,internlm,jamba,kimi_k2,lfm2,llama3_json,llama4_json,llama4_pythonic,longcat,mimo,minicpm5,minimax_m2,minimax_m3,mistral,olmo3,openai,phi4_mini_json,poolside_v1,pythonic,qwen3_coder,qwen3_xml,seed_oss,step3,step3p5,xlam} or name registered in --tool-parser-plugin
  --hf-overrides HF_OVERRIDES
  --served-model-name SERVED_MODEL_NAME [SERVED_MODEL_NAME ...]
  --reasoning-parser REASONING_PARSER
  --reasoning-parser-plugin REASONING_PARSER_PLUGIN
  --tensor-parallel-size TENSOR_PARALLEL_SIZE, -tp TENSOR_PARALLEL_SIZE
  --kv-cache-dtype {auto,bfloat16,float16,fp8,fp8_ds_mla,fp8_e4m3,fp8_e5m2,fp8_inc,fp8_per_token_head,int4_per_token_head,int8_per_token_head,nvfp4,turboquant_3bit_nc,turboquant_4bit_nc,turboquant_k3v4_nc,turboquant_k8v4}
  --kv-cache-dtype-skip-layers KV_CACHE_DTYPE_SKIP_LAYERS [KV_CACHE_DTYPE_SKIP_LAYERS ...]
  --kv-cache-memory-bytes KV_CACHE_MEMORY_BYTES
      VLLMConfig, some fields will be left in an improper state.
  --linear-backend {aiter,auto,conch,cutlass,deep_gemm,emulation,exllama,fbgemm,flashinfer_b12x,flashinfer_cudnn,flashinfer_cutedsl,flashinfer_cutlass,flashinfer_trtllm,humming,machete,marlin,torch,triton,xpu,xpu_woq}
  --speculative-config SPECULATIVE_CONFIG, -sc SPECULATIVE_CONFIG
                        disable_additional_properties=False,

```

---

## Assistant (Plan · Claude Sonnet 5 · 9.5s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "ls -la /home/user/src/biz.dfch.LlmOps/hardware/dell-7960t/ 2>&1; echo \"---\"; df -h /data; echo \"---HF cache---\"; du -sh /data/nvidia/hf_cache 2>/dev/null; ls /data/nvidia/hf_cache/hub 2>/dev/null"
}
```

**Output:**
```
total 24
drwxrwxr-x 2 user user 4096 Aug 19 11:00 .
drwxrwxr-x 3 user user 4096 Aug 18 10:56 ..
-rw-rw-r-- 1 user user 3222 Aug 19 11:00 configuration.md
-rw-rw-r-- 1 user user  143 Aug 18 10:56 nvidia-manual-packages.txt
-rw-rw-r-- 1 user user  558 Aug 18 10:56 nvidia-package-selections.txt
-rw-rw-r-- 1 user user 3517 Aug 18 10:56 recovery.md
---
Filesystem      Size  Used Avail Use% Mounted on
/dev/md126       15T  7,7T  7,0T  53% /data
---HF cache---
1,6T	/data/nvidia/hf_cache
CACHEDIR.TAG
datasets--appclusive--asd-ste100
datasets--rajpurkar--squad
models--deepseek-ai--DeepSeek-V4-Flash
models--deepseek-ai--DeepSeek-V4-Pro
models--meta-llama--Llama-3.1-8B
models--meta-llama--Meta-Llama-3-70B
models--nvidia--Llama-3.1-Nemotron-70B-Reward-HF
models--Qwen--Qwen3-8B

```

---

## Assistant (Plan · Claude Sonnet 5 · 5.9s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/hardware/dell-7960t/configuration.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/hardware/dell-7960t/configuration.md</path>
<type>file</type>
<content>
1: NVIDIA WORKING INVENTORY
2: ========================
3: 
4: Host OS:
5: - Ubuntu 22.04 LTS
6: 
7: Kernel:
8: - 6.8.0-117-generic
9: 
10: GPU state (updated 2026-08-19T08:04:27Z to match feat-1 Task 0.2 live check):
11: - nvidia-smi works after reboot
12: - Detected GPUs: 4 (all 4 now detected; the earlier "3 GPUs / 4th needs
13:   power cable fix" state below is historical, resolved 2026-08-18)
14: - Driver Version: 610.57.04
15: - CUDA Version reported by nvidia-smi: 13.3
16: - Total VRAM: 384 GB (4x 96 GB)
17: - Driver type: NVIDIA Open Kernel Module
18: - GRUB + modprobe fixes applied (see feat-1 Task 0.2); GPU 0 may show
19:   ollama residency (~43 GB) when a model is loaded, GPUs 1-3 free.
20: 
21: Historical GPU state (superseded — kept for the driver-source lesson below):
22: - Detected GPUs: 3 (note: 4th GPU required power cable fix)
23: - Driver Version: 595.71.05
24: - CUDA Version reported by nvidia-smi: 13.2
25: 
26: Active NVIDIA package source:
27: - NVIDIA CUDA repository:
28:   https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64
29: 
30: Installed working NVIDIA packages from NVIDIA CUDA repo
31: (versions below reflect the historical 595.71.05 stack; the live driver is
32: now 610.57.04 per the GPU state above — re-capture exact package versions
33: from the Dell box with `dpkg -l | grep nvidia` before relying on them):
34: - nvidia-dkms-open           595.71.05-1ubuntu1
35: - nvidia-firmware            595.71.05-1ubuntu1
36: - nvidia-kernel-common       595.71.05-1ubuntu1
37: - libnvidia-compute          595.71.05-1ubuntu1
38: - libnvidia-cfg1             595.71.05-1ubuntu1
39: - libnvidia-decode           595.71.05-1ubuntu1
40: - libnvidia-gpucomp          595.71.05-1ubuntu1
41: - nvidia-persistenced        595.71.05-1ubuntu1
42: 
43: Related NVIDIA/container packages present:
44: - libnvidia-container-tools  1.19.0-1
45: - libnvidia-container1       1.19.0-1
46: - nvidia-container-toolkit   1.19.0-1
47: - nvidia-container-toolkit-base 1.19.0-1
48: - nvidia-modprobe            595.71.05-1ubuntu1
49: - nvidia-settings            595.71.05-1ubuntu1
50: 
51: DKMS status:
52: - nvidia/595.71.05, 6.8.0-117-generic, x86_64: installed
53: 
54: Kernel modules installed under:
55: - /lib/modules/6.8.0-117-generic/updates/dkms/
56: 
57: Expected NVIDIA module files:
58: - nvidia.ko
59: - nvidia-modeset.ko
60: - nvidia-drm.ko
61: - nvidia-uvm.ko
62: - nvidia-peermem.ko
63: 
64: Secure Boot:
65: - disabled
66: 
67: Important note:
68: - The working configuration uses NVIDIA CUDA repo packages for the active driver stack.
69: - Mixing Ubuntu multiverse NVIDIA packages with NVIDIA CUDA repo packages caused breakage.
70: 
71: Conflicting Ubuntu packages seen earlier and should NOT be mixed into the active stack:
72: - nvidia-utils-595                 595.71.05-0ubuntu0.22.04.1
73: - libnvidia-compute-595           595.71.05-0ubuntu0.22.04.1
74: - nvidia-kernel-common-595        595.71.05-0ubuntu0.22.04.1
75: - nvidia-firmware-595-595.71.05   595.71.05-0ubuntu0.22.04.1
76: 
77: Pinning file used to prefer NVIDIA CUDA repo packages:
78: - /etc/apt/preferences.d/nvidia-cuda-pin
79: 
80: Pin file contents:
81: Package: nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1 libnvidia-decode libnvidia-gpucomp nvidia-persistenced
82: Pin: origin developer.download.nvidia.com
83: Pin-Priority: 1001
84: 
85: Validation commands:
86: - dkms status
87: - lsmod | grep nvidia
88: - modinfo -F version nvidia
89: - nvidia-smi
90: - lspci -nn | grep -i nvidia

(End of file - total 90 lines)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 7.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "systemctl list-units --all 2>&1 | grep -i ollama; systemctl --user list-units --all 2>&1 | grep -i ollama; docker ps -a 2>&1 | grep -i ollama; pgrep -fa ollama 2>&1"
}
```

**Output:**
```
9069 /bin/bash -c systemctl list-units --all 2>&1 | grep -i ollama; systemctl --user list-units --all 2>&1 | grep -i ollama; docker ps -a 2>&1 | grep -i ollama; pgrep -fa ollama 2>&1

```

---

## Assistant (Plan · Claude Sonnet 5 · 63.1s)

_Thinking:_



# Plan: Deploy Qwen3.8-27B with extended context on the Dell 7960T

## What's different from feat-3 (and why that matters)

feat-3 deployed on a **GB10 DGX-Spark clone**: arm64, 1 GPU, one **unified** 128 GB CPU+GPU memory pool. This machine — confirmed live just now — is the **Dell 7960T**: x86_64, **4× RTX PRO 6000 Blackwell Max-Q, 96 GB *discrete* VRAM each (384 GB total)**, plus a fully separate 512 GB system RAM pool. That changes several of feat-3's hard-won conclusions:

- The GB10's core problem (`--gpu-memory-utilization` silently starving the *OS* because VRAM and system RAM are the same pool) **structurally cannot happen here** — VRAM and system RAM are physically separate. Still good practice to size KV cache explicitly, but it's not the load-bearing fix it was on the GB10.
- Qwen3.8-27B (~54 GB BF16 weights) fits **inside a single 96 GB GPU** with a lot of room left for KV cache — no need to spread it across 4 GPUs the way feat-1's DeepSeek-V4-Flash does (TP=4).
- This box already hosts `feat-1` (DeepSeek-V4-Flash) and `feat-2` (GLM-5.2), so GPU allocation/coexistence is a real design question here that didn't exist for feat-3 (which had the whole GB10 to itself).

## Live findings from this box (already de-risks several feat-3-style Phase 0/1 steps)

I checked directly rather than assuming anything carries over:

| Check | Result |
|---|---|
| GPUs | 4× RTX PRO 6000 Blackwell Max-Q, 96 GB each, all idle (0 MiB used) right now |
| Driver / CUDA | 610.57.04 / CUDA 13.3 (matches `hardware/dell-7960t/configuration.md`) |
| Existing vLLM venv | `/data/vllm/.venv`, **vLLM 0.26.0** (not feat-3's 0.27.1) |
| `qwen3_5` architecture registered? | **Yes** — `Qwen3_5ForConditionalGeneration`, `Qwen3_5MTP` both present in this 0.26.0 build's `ModelRegistry` |
| NVFP4 GEMM kernel support (SM120)? | **Yes** — `cutlass_scaled_mm_supports_fp4(120)` → `True` on this exact venv |
| Required CLI flags present? | **Yes** — `--kv-cache-dtype` (incl. `fp8`/`nvfp4`), `--kv-cache-memory-bytes`, `--hf-overrides`, `--speculative-config`, `--tensor-parallel-size`, `--served-model-name`, `--tool-call-parser qwen3_xml`, `--reasoning-parser`, `--linear-backend` (incl. `flashinfer_b12x`) all exist |
| feat-1 status | **Blocked**, not running — degenerate-output bug on SM120 (`vllm-project/vllm#52938`), open upstream, service disabled |
| feat-2 status | GLM-5.2 (llama.cpp, not vLLM/ktransollmagic — AGENTS.md is stale on the engine name) — Q4 variant is the working production config, spans all 4 GPUs with headroom (23–53% free per GPU depending on GPU, at 768K context) |
| **Important precedent** | feat-1 tried upgrading to vLLM 0.27.1 (feat-3's pinned version) and **had to roll it back** — hard "unsupported architecture" DeepGEMM gap on SM120. **Do not adopt feat-3's 0.27.1 pin here; stay on this box's already-working 0.26.0.** |
| **Important local risk** | The SM120 degenerate-output bug feat-1 hit is a live, *open*, hardware-specific bug on this exact GPU family. feat-3's Design Notes assumed this couldn't recur on the GB10 (different GPU) — here it can. Qwen3.8-27B's hybrid Gated DeltaNet + Gated Attention layers are architecturally different from DeepSeek's sparse MLA, but this must be **verified, not assumed safe**, before any long-context work. |

## Proposed phased plan (mirrors feat-3's proven structure, adapted)

**Phase 0 — Environment confirmation (mostly already done above, cheap to formalize)**
Confirm disk headroom under `/data` (7 TB free — trivial), pin the HF revision for `Qwen/Qwen3.8-27B` (and optionally an NVFP4 repo), reuse `/data/vllm/.venv` (0.26.0) rather than building a new venv — already confirmed capable.

**Phase 1 — Native-context smoke test (elevated priority vs. feat-3)**
Bring up Qwen3.8-27B on a **single GPU** (TP=1) at native/short context, no YaRN yet. Explicitly check for feat-1's exact degenerate-output signature (frozen token + identical logprob every step) before proceeding — this is a proven local failure mode on this GPU family, so it's a hard gate, not a formality. Verify tool-calling + thinking-control modes, same as feat-3 Task 1.2.

**Phase 2 — YaRN context extension + capacity step-up**
Same `rope_parameters` override and factor table as feat-3 (REQ-011 is model-specific, transfers as-is: 768K→3.0, 896K→3.5, 1M→4.0). Step 768K → 896K → 1M, measuring real headroom — but on a **dedicated 96 GB GPU** rather than a shared 128 GB unified pool, so I expect materially more headroom than feat-3's "896K only, 1M failed" result. Worth re-measuring rather than assuming, since architecture (qwen3_5 hybrid) is still new even if the capacity math is friendlier here.

**Phase 3 — Precision decision**
Given feat-3 already proved NVFP4 (+MTP) gives 2.5×–7.7× decode speedup with no observed quality regression on the *same model*, I'd propose **short-circuiting straight to evaluating NVFP4 as a fast-follow** rather than re-running the full from-scratch "is it worth it" investigation — open question for you below.

**Phase 4 — Systemd deployment**
Propose following feat-2/feat-3's `systemctl --user` + lingering pattern (no sudo needed) rather than feat-1's system-level unit — disabled by default, matching the repo's non-negotiable "systemd only, never auto-start."

**Phase 5 — Integration** (OpenCode provider snippet, optional OpenWebUI)

**Phase 6 (optional, likely fast) — NVFP4 + MTP evaluation**, reusing feat-3's own benchmark scripts/methodology as a template.

## Open decisions I'd like your input on

1. **GPU allocation / coexistence with feat-1 & feat-2**: single dedicated GPU (TP=1, ~96 GB budget, leaves 3 GPUs completely free) vs. TP=2 (192 GB, extra context margin, still leaves 2 GPUs free) vs. TP=4 (like feat-1, maximum capacity but zero coexistence with anything else). Given the model is small, I'd lean **TP=1**, but want your call, especially since feat-1 is currently non-functional (blocked) and feat-2 already occupies all 4 GPUs with only partial headroom — true 3-way *simultaneous* full-load serving may not be realistic regardless of choice here.
2. **Time-shared vs. always-available**: should Qwen3.8-27B be expected to run *concurrently* with GLM-5.2, or is a "start it when you need it" model (same pattern feat-2 already uses for its Q4/Q5 swap) acceptable?
3. **Precision path**: repeat feat-3's full BF16-first-then-empirically-evaluate-NVFP4 journey, or skip ahead to NVFP4(+MTP) as default given feat-3 already validated it on this exact model with no quality loss?
4. **New feature folder name/number**: I'd create `.specmgr/feat/feat-4-qwen3.8-27b-7960t/` (next available number) as the tracking artifact, following feat-1/2/3's convention — confirm the slug, or suggest another.

---

## User

-- 1 GPU: on DGX Spark the model uses 59.8 GB of shared RAM. If the model will not get faster when we use more than one GPU, then pin it to GPU2. These is the GPU that have 5xPCIe.
-- 2: I want a service that start "on-demand" only. I will manage which service run. And I prefer to have a dedicated service and installation, if that makes sense to you. I do not want side effect, when I change either service (GLM-5.2 or qwen3.8).
-- 3: We should try nvfp4 first and the see what is the speed difference to q8 and bf16.
-- 4: when you create the feature, first create the gh issue. This make sure that you have the correct issue id in the feature path.

any more questions?

---

## Assistant (Plan · Claude Sonnet 5 · 23.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "nvidia-smi topo -m 2>&1; echo \"---lspci pcie gen/width---\"; for bdf in $(nvidia-smi --query-gpu=pci.bus_id --format=csv,noheader); do echo \"== $bdf ==\"; sudo lspci -s \"${bdf#*:}\" -vv 2>/dev/null | grep -iE \"LnkCap|LnkSta\" || lspci -s \"${bdf#*:}\" -vv 2>/dev/null | grep -iE \"LnkCap|LnkSta\"; done"
}
```

**Output:**
```
	[4mGPU0	GPU1	GPU2	GPU3	CPU Affinity	NUMA Affinity	GPU NUMA ID[0m
GPU0	 X 	NODE	NODE	NODE	0-119	0		N/A
GPU1	NODE	 X 	NODE	NODE	0-119	0		N/A
GPU2	NODE	NODE	 X 	NODE	0-119	0		N/A
GPU3	NODE	NODE	NODE	 X 	0-119	0		N/A

Legend:

  X    = Self
  SYS  = Connection traversing PCIe as well as the SMP interconnect between NUMA nodes (e.g., QPI/UPI)
  NODE = Connection traversing PCIe as well as the interconnect between PCIe Host Bridges within a NUMA node
  PHB  = Connection traversing PCIe as well as a PCIe Host Bridge (typically the CPU)
  PXB  = Connection traversing multiple PCIe bridges (without traversing the PCIe Host Bridge)
  PIX  = Connection traversing at most a single PCIe bridge
  NV#  = Connection traversing a bonded set of # NVLinks
---lspci pcie gen/width---
== 00000000:16:00.0 ==
== 00000000:34:00.0 ==
== 00000000:AC:00.0 ==
== 00000000:CA:00.0 ==

```

---

## Assistant (Plan · Claude Sonnet 5 · 8.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "nvidia-smi --query-gpu=index,pci.bus_id,pcie.link.gen.max,pcie.link.gen.current,pcie.link.width.max,pcie.link.width.current --format=csv 2>&1"
}
```

**Output:**
```
index, pci.bus_id, pcie.link.gen.max, pcie.link.gen.current, pcie.link.width.max, pcie.link.width.current
0, 00000000:16:00.0, 5, 1, 16, 16
1, 00000000:34:00.0, 4, 1, 16, 16
2, 00000000:AC:00.0, 5, 1, 16, 16
3, 00000000:CA:00.0, 4, 1, 16, 16

```

---

## Assistant (Plan · Claude Sonnet 5 · 11.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "gh auth status 2>&1; echo \"---\"; gh repo view --json nameWithOwner,url 2>&1; echo \"---existing issues---\"; gh issue list --state all --limit 20 2>&1; echo \"---git remote---\"; git remote -v"
}
```

**Output:**
```
github.com
  ✓ Logged in to github.com as dfch (/home/user/.config/gh/hosts.yml)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: *******************
  
---
{"nameWithOwner":"dfch/biz.dfch.LlmOps","url":"https://github.com/dfch/biz.dfch.LlmOps"}
---existing issues---
3	OPEN	On-prem Qwen3.8-27B serving with extended context for OpenCode		2026-08-25 11:30:09 +0000 UTC
2	OPEN	On-prem GLM-5.2 serving for OpenCode + OpenWebUI		2026-08-22 16:29:54 +0000 UTC
1	OPEN	On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI		2026-08-18 09:42:55 +0000 UTC
---git remote---
origin	https://github.com/dfch/biz.dfch.LlmOps.git (fetch)
origin	https://github.com/dfch/biz.dfch.LlmOps.git (push)

```

---

## Assistant (Plan · Claude Sonnet 5 · 153.5s)

_Thinking:_



Good context — I verified a few things that support your directives:

- **No NVLink between any of the 4 GPUs** (`nvidia-smi topo -m` shows `NODE` for every pair — pure PCIe through the host bridge). This confirms your hypothesis: tensor-parallel across these cards has real inter-GPU communication overhead with no fast interconnect to hide it, so TP>1 is a plausible net loss for a 27B model that already fits on one GPU. I'll still **measure** TP=1 vs TP=2 once, per your "if it's not faster, pin to GPU2" instruction, rather than skip it — but I now expect TP=1 to win.
- **GPU2 = PCI bus `AC:00.0`, PCIe Gen5 x16** (confirmed) — GPU0 is also Gen5 x16, but `hardware/dell-7960t/configuration.md` notes GPU0 occasionally holds ~43 GB from an Ollama model, so GPU2 is the cleaner, uncontended Gen5 choice. I'll pin via GPU **UUID** (`GPU-7eea2a46-...`) rather than index, since indices can theoretically reorder across reboots.
- **GitHub**: authenticated as `dfch`, repo `dfch/biz.dfch.LlmOps`, issues #1/#2/#3 already exist for feat-1/2/3 → next issue will be **#4**, giving `feat-4-...` as the folder name.
- **"Dedicated install, no side effects"**: understood as — do **not** reuse `/data/vllm/.venv` (shared with feat-1). I'll build a fully separate tree, e.g. `/data/qwen3.8-27b/` (own venv, own launch scripts, own systemd unit), so changing/upgrading Qwen's vLLM install can never perturb feat-1 or feat-2.

A few things I need from you before finalizing:

**Tool: question**

**Input:**
```json
{
  "questions": [
    {
      "question": "You said 'try NVFP4 first, then compare speed to Q8 and BF16.' On vLLM, 'Q8' most commonly means an on-the-fly/pre-quantized FP8 (W8A8) weight variant, not a GGUF Q8_0 quant (that's a llama.cpp term). Which did you mean?",
      "header": "Q8 meaning",
      "options": [
        {
          "label": "FP8 (vLLM W8A8, Recommended)",
          "description": "Matches the serving engine (vLLM); either vLLM's built-in on-the-fly FP8 quantization of the BF16 checkpoint, or a pre-quantized FP8 HF repo if one exists for Qwen3.8-27B."
        },
        {
          "label": "GGUF Q8_0 (llama.cpp-style)",
          "description": "Would require a different serving engine/format (llama.cpp), reopening the REQ-006-style 'vLLM only' engine decision feat-3 made — bigger scope change."
        }
      ]
    },
    {
      "question": "Context target for this deployment: feat-3 settled on a 768K floor, up to a 1M ceiling if headroom allows, on a much tighter shared 128GB pool. This box gives Qwen3.8 a full dedicated 96GB GPU (or more, if TP helps). Keep the same 768K floor / 1M ceiling target, or aim differently here?",
      "header": "Context target",
      "options": [
        {
          "label": "Same as feat-3: 768K floor, up to 1M ceiling (Recommended)",
          "description": "Reuses the proven YaRN factor table and REQ-003-style floor/ceiling policy; push to 1M if the dedicated GPU's headroom allows it (likely, given no OS-memory-starvation risk here)."
        },
        {
          "label": "Go straight for the 1M native ceiling as the target",
          "description": "Skip the floor/step-up framing since a dedicated 96GB GPU is expected to clear 1M comfortably; still measure, but don't treat 768K/896K as meaningful intermediate stops."
        },
        {
          "label": "Different target (I'll specify)",
          "description": "Something else entirely."
        }
      ]
    },
    {
      "question": "Proposed feature slug/title for the new gh issue + .specmgr folder: 'feat-4-qwen3.8-27b-dell-7960t' / issue title 'On-prem Qwen3.8-27B serving with extended context on the Dell 7960T'. OK to use, or do you want different wording?",
      "header": "Feature naming",
      "options": [
        {
          "label": "Use as proposed (Recommended)",
          "description": "feat-4-qwen3.8-27b-dell-7960t, matching feat-1/2/3's naming convention."
        },
        {
          "label": "I'll give different wording",
          "description": "You'll specify the exact slug/title."
        }
      ]
    },
    {
      "question": "Should the new dedicated install still share the existing HF download cache (/data/nvidia/hf_cache, used by feat-1's DeepSeek weights) for storing Qwen3.8's weights, or should it get its own fully separate cache directory under /data/qwen3.8-27b/?",
      "header": "HF cache location",
      "options": [
        {
          "label": "Share /data/nvidia/hf_cache (Recommended)",
          "description": "It's a read-only download cache (HF_HOME), not code/packages -- sharing it carries no 'side effect' risk between services, and matches feat-1's existing convention."
        },
        {
          "label": "Fully separate cache under /data/qwen3.8-27b/",
          "description": "Maximum isolation -- every artifact (venv, weights, scripts, cache) lives under one dedicated tree with zero shared state with feat-1/feat-2."
        }
      ]
    }
  ]
}
```

**Output:**
```
User has answered your questions: "You said 'try NVFP4 first, then compare speed to Q8 and BF16.' On vLLM, 'Q8' most commonly means an on-the-fly/pre-quantized FP8 (W8A8) weight variant, not a GGUF Q8_0 quant (that's a llama.cpp term). Which did you mean?"="I only meant bf16. Ignore the q8 remark.", "Context target for this deployment: feat-3 settled on a 768K floor, up to a 1M ceiling if headroom allows, on a much tighter shared 128GB pool. This box gives Qwen3.8 a full dedicated 96GB GPU (or more, if TP helps). Keep the same 768K floor / 1M ceiling target, or aim differently here?"="we only go for 896k, no 768k, no 1M. We tested 896k on dgx and it works. And the context is large enough.", "Proposed feature slug/title for the new gh issue + .specmgr folder: 'feat-4-qwen3.8-27b-dell-7960t' / issue title 'On-prem Qwen3.8-27B serving with extended context on the Dell 7960T'. OK to use, or do you want different wording?"="Use as proposed (Recommended)", "Should the new dedicated install still share the existing HF download cache (/data/nvidia/hf_cache, used by feat-1's DeepSeek weights) for storing Qwen3.8's weights, or should it get its own fully separate cache directory under /data/qwen3.8-27b/?"="Share /data/nvidia/hf_cache (Recommended)". You can now continue with the user's answers in mind.
```

---

## Assistant (Plan · Claude Sonnet 5 · 75.2s)

_Thinking:_



All clarified. Here's the finalized plan.

## Final Plan: feat-4-qwen3.8-27b-dell-7960t

**Locked-in decisions from this thread:**
- **Precision comparison**: NVFP4 vs BF16 only (no FP8/Q8 leg).
- **Context**: fixed at **896K (917,504 tokens, YaRN factor 3.5)** only — no 768K/1M step-up sweep, since 896K is already proven on this exact model architecture (feat-3/DGX).
- **GPU**: pin to **GPU2** (UUID `GPU-7eea2a46-...`, PCIe Gen5 x16, uncontended) unless TP>1 measurably helps — expected not to, since `nvidia-smi topo -m` shows no NVLink between any of the 4 GPUs (pure PCIe/`NODE`).
- **Service model**: **on-demand only**, manually started/stopped by you — no auto-start, no auto-selected "production" default the way feat-3 ended up with one.
- **Isolation**: dedicated venv + scripts + systemd units under `/data/qwen3.8-27b/`, fully independent of `/data/vllm/.venv` (feat-1) — no shared packages, so changing one never perturbs the other. Shared `/data/nvidia/hf_cache` for weight storage only (read-only cache, no coupling risk).
- **vLLM version**: pin the new dedicated venv to **0.26.0** (matching what's already proven on this box's SM120 GPUs), *not* feat-3's 0.27.1 — feat-1 already tried 0.27.1 here and had to roll it back (DeepGEMM/SM120 regression).
- **Naming**: gh issue **"On-prem Qwen3.8-27B serving with extended context on the Dell 7960T"** created first → issue #4 (next available) → folder `feat-4-qwen3.8-27b-dell-7960t`.

### Execution sequence

1. **`gh issue create`** for the feature (gets issue #4).
2. **Create `.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md`**, modeled on feat-3's structure (Requirements/Acceptance/Scope/Dependencies/Design Notes/Task List), with `github_issue: 4`, and Design Notes explicitly recording the hardware delta from feat-3 (discrete 96GB GPU vs. GB10's unified pool, no NVLink, feat-1's SM120 degenerate-output bug precedent, feat-1's 0.27.1 rollback precedent).

**Phase 0 — Dedicated environment setup**
- Create `/data/qwen3.8-27b/.venv`, pinned `vllm==0.26.0`, isolated from `/data/vllm/.venv`.
- Re-verify (fresh, in the *new* venv) the same three checks I already did ad hoc: `qwen3_5` registry support, `cutlass_scaled_mm_supports_fp4(120)`, and the CLI flags needed (`--kv-cache-dtype`, `--hf-overrides`, `--speculative-config`, etc.) — cheap, and confirms the new venv isn't subtly different from the one I inspected.
- Pin HF revisions for `Qwen/Qwen3.8-27B` (BF16) and `unsloth/Qwen3.8-27B-NVFP4` (reuse feat-3's vetted `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`, re-verify still current + tokenizer-truncation fix present). Download both into `/data/nvidia/hf_cache`.

**Phase 1 — Native-context smoke test (hard gate)**
- Bring up the BF16 checkpoint at short/native context, single GPU (GPU2 only, `CUDA_VISIBLE_DEVICES` by UUID, TP=1).
- **Explicitly check for feat-1's exact degenerate-output signature** (frozen token / identical logprob every decode step) before doing anything else — this is a live, open, hardware-specific bug on this GPU family, so it's a correctness gate, not a formality.
- Verify tool-calling + all thinking-control modes (`enable_thinking`, `reasoning_effort`), same shape as feat-3 Task 1.2.

**Phase 2 — TP=1 vs TP=2 throughput check**
- Quick decode-throughput comparison: GPU2 alone (TP=1) vs. GPU2+GPU0 (the two Gen5 x16 cards, TP=2).
- Decide based on measured numbers, per your instruction: if TP=2 isn't measurably faster, pin production to **GPU2 only**.

**Phase 3 — YaRN 896K context: apply + validate (single target, no sweep)**
- Apply the same `rope_parameters` override / factor 3.5 as feat-3 (model-specific, transfers as-is).
- Measure KV-cache capacity and free VRAM headroom on the GPU(s) chosen in Phase 2 at 896K.
- Validate with a real filled-context request (build an actual ~899K-token prompt via the tokenizer, POST it, confirm no OOM) — same rigor as feat-3 Task 4.3, not just a load-time probe.

**Phase 4 — Precision comparison: NVFP4 vs BF16 at 896K/YaRN**
- Same decode/prefill benchmark methodology as feat-3 Task 6.1/6.2 step 4, run directly at 896K (not native context first, since context is fixed here) for both precisions on GPU2.
- Record the measured speedup and decide whether NVFP4 clears a meaningful bar (feat-3 saw 2.5×–7.7× on the identical model, so I'd expect a similar order of magnitude here, but it must be measured, not assumed, since the bottleneck profile differs — discrete GPU/no shared-pool contention, different FlashInfer kernel path on SM120 vs. GB10's SM121a).
- *Optional fast-follow, not mandatory*: MTP speculative decoding eval (feat-3 Task 6.3 got another 2.7–3×) — I'll flag this as a cheap follow-up task rather than build it into the critical path, since you didn't ask for it explicitly this time.

**Phase 5 — Systemd services (on-demand only)**
- Two separate, disabled, `systemctl --user` units (lingering enabled, mirroring feat-2/feat-3's pattern), so *you* choose which precision to run:
  - `qwen3.8-27b-nvfp4-896k.service`
  - `qwen3.8-27b-bf16-896k.service`
- Both live under `/data/qwen3.8-27b/`, both pinned to GPU2 (or GPU2+GPU0 if Phase 2 says TP=2 wins), neither auto-starts at boot or on install — matches "I will manage which service runs."

**Phase 6 — Integration**
- OpenCode provider snippet (`baseURL` pointing at this box, `served-model-name` per variant, `limit.context: 917504`) — for you to paste into your own `opencode.jsonc`, not written into any config here (same precedent as feat-1/2/3).
- OpenWebUI wiring deferred/optional, same as feat-3.

One more open point before I start: do you want the **MTP speculative-decoding eval** (Phase 4's optional item) included in this pass, or left out entirely as a separate future feature/task?

---

## User

activate mtp - it made the dgx system faser

---

## Assistant (Plan · Claude Sonnet 5 · 17.4s)

_Thinking:_



Understood — MTP will be included as a required step, not optional. Updated Phase 4:

**Phase 4 — Precision comparison + MTP (at 896K/YaRN, on GPU2)**
1. Benchmark BF16 vs NVFP4 decode/prefill at 896K (same methodology as feat-3 Task 6.1).
2. Benchmark NVFP4 + MTP (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`, draft head ships inside the `unsloth/Qwen3.8-27B-NVFP4` checkpoint, no extra download) against NVFP4-without-MTP at the same 896K/YaRN context — mirrors feat-3 Task 6.3, which found MTP gave a further 2.66×–3.12× speedup with byte-identical (lossless) greedy output vs. non-MTP.
3. Re-verify capacity/headroom with MTP enabled (feat-3 saw KV-cache capacity drop ~9% with MTP on — still needs to clear the 917,504-token requirement on GPU2's dedicated 96GB, expected to be comfortable here given no shared-pool contention).
4. Re-verify correctness (coherent output, tool-calling, all three thinking-control modes) on the MTP-enabled config before it's eligible to be one of the two on-demand services.
5. Final precision decision recorded with the measured numbers (NVFP4+MTP vs. BF16, vs. NVFP4-without-MTP) — adopted only if it clears a real speedup with no correctness regression, same "measure, don't assume" bar as feat-3.

This means Phase 5's two on-demand services become:
- `qwen3.8-27b-nvfp4-mtp-896k.service` (if MTP clears the bar, which is expected)
- `qwen3.8-27b-bf16-896k.service` (fallback/comparison baseline)

(NVFP4-without-MTP would just be a benchmarking waypoint in Phase 4, not necessarily a third permanent service, unless you want it kept around too — let me know if so.)

Full plan is otherwise unchanged from my last message (gh issue #4 → `feat-4-qwen3.8-27b-dell-7960t` → Phase 0 dedicated venv/env setup → Phase 1 native-context degenerate-output gate → Phase 2 TP=1-vs-TP=2 check, expected to land on GPU2-only → Phase 3 YaRN 896K apply+validate → Phase 4 as above → Phase 5 two on-demand systemd `--user` services → Phase 6 OpenCode integration snippet).

Anything else to adjust, or should I proceed once you exit plan mode?

---

## User

write the feature but do not implement yet.

---

## Assistant (Build · Claude Sonnet 5 · 15.4s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "gh issue create --repo dfch/biz.dfch.LlmOps \\\n  --title \"On-prem Qwen3.8-27B serving with extended context on the Dell 7960T\" \\\n  --body \"Deploy \\`Qwen/Qwen3.8-27B\\` on the Dell 7960T (4x RTX PRO 6000 Blackwell Max-Q, 96GB VRAM each) as a dedicated, on-demand vLLM service at 896K context (YaRN factor 3.5), pinned to a single GPU (GPU2, PCIe Gen5 x16, no NVLink between cards). Compares BF16 vs NVFP4 vs NVFP4+MTP speculative decoding for throughput, following the precedent already established on feat-3's DGX Spark (GB10) deployment of the same model. Fully isolated install (separate venv/scripts/systemd units) from feat-1 (DeepSeek-V4) and feat-2 (GLM-5.2) so changes to one never affect the others.\n\nTracked in \\`.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md\\`.\"\n"
}
```

**Output:**
```
https://github.com/dfch/biz.dfch.LlmOps/issues/4

```

---

## Assistant (Build · Claude Sonnet 5 · 4.6s)

Issue #4 created. Now creating the feature folder.

**Tool: bash**

**Input:**
```json
{
  "command": "mkdir -p \"/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t\"; date -I"
}
```

**Output:**
```
2026-08-25

```

---

## Assistant (Build · Claude Sonnet 5 · 199.3s)

_Thinking:_



**Tool: write**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md",
  "content": "---\ncreated: 2026-08-25\ngithub_issue: 4\nid: feat-4-qwen3.8-27b-dell-7960t\nstatus: planning\nupdated: 2026-08-25\nversion: 1.0.0\n---\n\n# Feature: On-prem Qwen3.8-27B serving with extended context on the Dell 7960T\n\n## Plan\n\n### Overview\n\nDeploy `Qwen/Qwen3.8-27B` (the same model as `feat-3`, dense causal LM + vision\nencoder, 27B params, Apache-2.0) via vLLM on the **Dell 7960T** — the box\nalready hosting `feat-1` (DeepSeek-V4-Flash) and `feat-2` (GLM-5.2) — as a\n**dedicated, on-demand** service pinned to a single GPU, at a **fixed 896K\n(917,504-token) context** via the vendor's documented YaRN `rope_parameters`\noverride.\n\nThis is explicitly a re-deployment of a model `feat-3` already fully\nvalidated on different hardware (a GB10/DGX-Spark-clone with one **unified**\n128GB CPU+GPU memory pool, arm64). The Dell 7960T is a fundamentally\ndifferent shape of box: x86_64, **4x RTX PRO 6000 Blackwell Max-Q, 96GB\n*discrete* VRAM each (384GB total)**, plus a fully separate 512GB system RAM\npool, and **no NVLink between any of the 4 GPUs** (confirmed via\n`nvidia-smi topo -m`: every GPU pair shows `NODE`, i.e. PCIe-through-host-\n-bridge only). That changes which of `feat-3`'s hard-won findings transfer\nand which don't:\n\n- `feat-3`'s core Phase 2 problem — `--gpu-memory-utilization` silently\n  starving the *OS* because VRAM and system RAM share one pool — **cannot\n  happen on this box**: VRAM (per-GPU) and system RAM are physically\n  separate pools here. Still good practice to size KV cache explicitly, but\n  it is not the load-bearing fix it was on the GB10.\n- Qwen3.8-27B (~54GB BF16 weights) fits comfortably inside a **single 96GB\n  GPU**, unlike `feat-1`'s DeepSeek-V4-Flash, which needs `--tensor-parallel-\n  -size 4` to fit at all. There is no a priori need to span multiple GPUs\n  here, and — since none of the 4 GPUs have an NVLink interconnect between\n  them — spanning GPUs via tensor-parallel is expected to *add* PCIe\n  communication overhead for no capacity benefit, not help throughput. This\n  must be measured (Phase 2), not assumed, but the working hypothesis is\n  TP=1 wins.\n- `feat-1` already found and is currently blocked by an **open, unresolved\n  SM120-specific bug** (`vllm-project/vllm#52938`): DeepSeek-V4-Flash on\n  these exact RTX PRO 6000 Blackwell GPUs produces degenerate output\n  (frozen token / identical logprob at every decode position). `feat-3`'s\n  Design Notes assumed this class of bug could not recur on the GB10\n  because it uses different GPUs (SM121a, not SM120) — that assumption does\n  **not** hold here, since this box has the exact GPU family the bug was\n  found on. Qwen3.8-27B's hybrid Gated DeltaNet + Gated Attention layout is\n  architecturally different from DeepSeek's sparse MLA attention, but this\n  must be **verified, not assumed safe**, before any long-context work —\n  hence Phase 1 is a hard gate here, not a formality.\n- `feat-1` also already tried upgrading to vLLM 0.27.1 (the version `feat-3`\n  pinned on the GB10) and had to **roll it back** — a hard \"unsupported\n  architecture\" DeepGEMM gap for SM120. This feature stays on the box's\n  already-working **vLLM 0.26.0** instead of adopting `feat-3`'s 0.27.1 pin.\n  Live checks against the box's existing (feat-1) 0.26.0 venv on\n  2026-08-25 already confirm this version registers `Qwen3_5ForConditional-\n  Generation`/`Qwen3_5MTP` and has working NVFP4 GEMM kernels\n  (`cutlass_scaled_mm_supports_fp4(120)` -> `True`) — see Task 0.2.\n\nUnlike `feat-3`'s BF16-first-then-empirically-evaluate-NVFP4 journey, this\nfeature goes straight to comparing **BF16 vs NVFP4 vs NVFP4+MTP** at the\nfixed 896K context, since `feat-3` already established (on the identical\nmodel) that NVFP4 and MTP both give large, quality-neutral speedups — the\nopen question here is only how large the effect is on *this* hardware's\ndifferent bottleneck profile (dedicated GPU, no shared-pool contention,\ndifferent FlashInfer kernel path on SM120 vs. the GB10's SM121a), not\nwhether to try them at all.\n\n**Isolation is a hard requirement, not a preference**: this feature's\ninstall (venv, launch scripts, systemd units) must be fully independent of\n`feat-1`'s `/data/vllm/.venv` — changing or upgrading anything in this\nfeature's dedicated `/data/qwen3.8-27b/` tree must never have side effects\non `feat-1` or `feat-2`, and vice versa. The only shared state is the\nread-only Hugging Face download cache (`/data/nvidia/hf_cache`), which\ncarries no such coupling risk.\n\nEvery service this feature installs is **on-demand only** — started and\nstopped exclusively by the user via `systemctl --user`, never auto-started\nat boot, and with no single service auto-promoted to \"the\" production\ndefault the way `feat-3` ended up doing after its own precision journey.\nThe user decides which variant (BF16 or NVFP4[+MTP]) runs at any given\ntime.\n\n### Requirements\n\n- REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API\n  (`/v1/chat/completions`) on the Dell 7960T, using vLLM, pinned to a single\n  dedicated GPU (GPU2, by UUID) by default. If TP=2 (GPU2+GPU0, the box's\n  two PCIe Gen5 x16 cards) is empirically shown to be faster (Phase 2),\n  that becomes the pinned config instead — TP=4 (spanning all 4 GPUs, as\n  `feat-1` does) is out of scope, since the model does not need the extra\n  VRAM and doing so would prevent any coexistence with `feat-1`/`feat-2`\n- REQ-002: The endpoint(s) must support a **fixed** context length of\n  917,504 tokens (896K) via the vendor's documented YaRN `rope_parameters`\n  override (factor 3.5) — no 768K-floor/1M-ceiling step-up exploration is\n  in scope; 896K is the sole target, already proven sufficient and working\n  on this exact model architecture by `feat-3`\n- REQ-003: The endpoint(s) must support tool-calling (required for OpenCode\n  agentic use) and correctly expose Qwen3.8's thinking controls:\n  `enable_thinking` (on by default), `reasoning_effort`\n  (`xhigh`/`medium`/`low`), and `preserve_thinking` — identical bar to\n  `feat-3` REQ-004\n- REQ-004: Empirically compare **BF16**, **NVFP4**, and **NVFP4 + MTP\n  speculative decoding** at the fixed 896K/YaRN context, on this hardware.\n  Adopt NVFP4 (optionally +MTP) as an available on-demand option only if it\n  clears a measurable throughput improvement with no observed correctness\n  regression (MTP's acceptance/verification step must be lossless —\n  byte-identical greedy output vs. the non-MTP run at temperature=0, same\n  bar `feat-3` Task 6.3 used) — mirrors `feat-3` REQ-005's \"not adopted by\n  default\" bar, but MTP is explicitly requested up front for this feature\n  (not gated behind a separate \"is it worth it\" decision the way it was\n  for `feat-3`)\n- REQ-005: Engine = vLLM, pinned to **0.26.0** (the version already\n  installed and validated on this box's SM120 GPUs by `feat-1`) — **not**\n  `feat-3`'s 0.27.1 pin, since `feat-1` already found that version regresses\n  on this exact hardware (DeepGEMM/architecture-support gap for SM120).\n  Installed in a **fully separate, dedicated venv**\n  (`/data/qwen3.8-27b/.venv`), isolated from `feat-1`'s `/data/vllm/.venv`\n- REQ-006: Pin `Qwen/Qwen3.8-27B` (BF16) and `unsloth/Qwen3.8-27B-NVFP4` to\n  specific Hugging Face revisions/commits (not \"latest\") for reproducibility\n  — reuse `feat-3`'s already-vetted NVFP4 revision\n  (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) if still current at download\n  time, re-verify the tokenizer-truncation fix is present either way; pin\n  the BF16 revision fresh at download time\n- REQ-007: The endpoint(s) run unauthenticated (anonymous, no API-key/auth\n  layer) — accepted risk, internal network only (same posture as\n  `feat-1`/`feat-2`/`feat-3`)\n- REQ-008: Every engine variant runs exclusively as an **on-demand**\n  systemd `--user` service (lingering enabled) — never auto-started at\n  boot, never run as an ad-hoc foreground process, including during\n  testing. The user starts/stops each variant explicitly via `systemctl\n  --user`; no variant is ever auto-selected as \"production\" by default\n- REQ-009: This feature's deployment must be **fully isolated** from\n  `feat-1` (DeepSeek-V4) and `feat-2` (GLM-5.2): separate venv, separate\n  launch scripts, separate systemd unit files, under a dedicated\n  `/data/qwen3.8-27b/` tree — so that installing, upgrading, restarting, or\n  debugging this feature's services has zero side effects on the other two\n  features' services, and vice versa. The only permitted shared state is\n  the read-only Hugging Face download cache (`/data/nvidia/hf_cache`), by\n  explicit choice (it carries no code/package coupling risk)\n- REQ-010: Before any long-context or precision work, run a native/short-\n  context correctness smoke test that **explicitly checks for the exact\n  degenerate-output signature** (a single frozen token / identical logprob\n  repeated at every decode position) found on this same GPU family by\n  `feat-1`'s open, unresolved bug (`vllm-project/vllm#52938`). This is a\n  **hard gate**, not a formality — unlike `feat-3`'s GB10 (a different GPU\n  family where this specific bug class does not apply), this box has the\n  exact hardware the bug was found on\n- REQ-011: Determine empirically (not assumed) whether GPU2-only (TP=1) or\n  GPU2+GPU0 (TP=2, the box's two PCIe Gen5 x16 cards) gives better decode\n  throughput. Since `nvidia-smi topo -m` confirms **no NVLink between any\n  of the 4 GPUs** (every pair shows `NODE`, PCIe-through-host-bridge only),\n  TP>1 is expected to add communication overhead without a capacity\n  benefit — pin production to **GPU2-only (TP=1)** unless TP=2 is\n  measurably faster\n- REQ-012: YaRN `rope_parameters` override configured exactly per the\n  vendor's documented shape, reused verbatim from `feat-3` REQ-011 (it is\n  model-specific, not hardware-specific): `mrope_interleaved`,\n  `mrope_section`, `rope_type: yarn`, `rope_theta`,\n  `partial_rotary_factor: 0.25`, `factor: 3.5` (fixed, since REQ-002 fixes\n  the target context at 896K), `original_max_position_embeddings: 262144`\n- REQ-013: Vision/video (image+video understanding) capability is\n  explicitly OUT of scope for testing/validation in this feature — text/\n  coding only (same as `feat-3` REQ-012)\n\n### Acceptance Criteria\n\n- [ ] ACC-001: Verifies REQ-001/REQ-011 — Qwen3.8-27B running via vLLM on\n  the Dell 7960T, reachable via `/v1/chat/completions`, pinned to GPU2 (or\n  GPU2+GPU0 if TP=2 is empirically chosen instead), with the GPU-pinning\n  decision backed by measured decode-throughput numbers, not assumed;\n  `feat-1`/`feat-2`'s existing services and GPUs untouched\n- [ ] ACC-002: Verifies REQ-002/REQ-012 — the endpoint serves the fixed\n  917,504-token (896K) context via the exact YaRN `rope_parameters`\n  override (factor 3.5), validated with a real filled-context request\n  (built from the model's own tokenizer, not a synthetic estimate) that\n  completes without OOM\n- [ ] ACC-003: Verifies REQ-003 — tool-calling and all three thinking-\n  control modes (`enable_thinking: false`, `reasoning_effort: medium`,\n  `reasoning_effort: xhigh`) verified via curl smoke test against every\n  on-demand service variant that is ultimately installed (BF16, and\n  NVFP4[+MTP] if adopted)\n- [ ] ACC-004: Verifies REQ-004 — a recorded BF16 vs. NVFP4 vs. NVFP4+MTP\n  throughput comparison at the fixed 896K/YaRN context, with the final\n  precision/MTP decision and its one-line rationale recorded; if MTP is\n  adopted, its output is confirmed byte-identical (lossless) vs. the\n  non-MTP run at temperature=0 on the same prompt\n- [ ] ACC-005: Verifies REQ-005 — vLLM 0.26.0 confirmed as the deployment\n  engine version, installed in the dedicated `/data/qwen3.8-27b/.venv`,\n  with the `qwen3_5` architecture and NVFP4 kernel support re-verified\n  inside that specific venv (not just inferred from `feat-1`'s venv)\n- [ ] ACC-006: Verifies REQ-006 — deployment config records the exact HF\n  revision/commit hash used for both the BF16 and NVFP4 checkpoints\n- [ ] ACC-007: Verifies REQ-007 — endpoint(s) reachable without credentials\n  from the internal network, confirmed intentional (not an oversight)\n- [ ] ACC-008: Verifies REQ-008/REQ-009 — every installed service is a\n  `systemctl --user` unit, left `disabled` (never auto-starts at boot),\n  started/stopped exclusively via `systemctl --user` throughout testing;\n  the dedicated `/data/qwen3.8-27b/` install tree is confirmed independent\n  of `/data/vllm/.venv` (`feat-1`) and `feat-2`'s install tree\n- [ ] ACC-009: Verifies REQ-010 — the native/short-context smoke test\n  explicitly checked for and did not reproduce `feat-1`'s SM120 degenerate-\n  output signature, before any YaRN/precision work began\n- [ ] ACC-010: Verifies REQ-013 — vision/video capability explicitly not\n  tested/validated in this feature (scope confirmation, not a functional\n  check)\n\n### Scope\n\nWhat is included in this feature:\n\n- A dedicated, fully isolated Phase 0 environment build on the Dell\n  7960T (`/data/qwen3.8-27b/.venv`, vLLM 0.26.0) — independent of `feat-1`'s\n  existing `/data/vllm/.venv`\n- A native-context correctness smoke test explicitly checking for\n  `feat-1`'s known SM120 degenerate-output signature, before any long-\n  -context or precision work (hard gate, per REQ-010)\n- An empirical TP=1 (GPU2-only) vs. TP=2 (GPU2+GPU0) decode-throughput\n  comparison, to decide GPU pinning (REQ-011)\n- Applying and validating the YaRN-based 896K context extension (fixed\n  target, no step-up/down sweep) per the vendor's documented\n  `rope_parameters` override\n- An empirical BF16 vs. NVFP4 vs. NVFP4+MTP throughput/correctness\n  comparison at the fixed 896K/YaRN context\n- Two (or more, depending on Phase 4's outcome) on-demand, disabled\n  `systemctl --user` services — one per adopted precision/MTP variant —\n  that the user starts/stops manually\n- Pinning both the BF16 and NVFP4 checkpoints to fixed HF revisions\n- An OpenCode provider snippet per installed service variant\n\nWhat is explicitly out of scope:\n\n- Any modification to `feat-1` (DeepSeek-V4) or `feat-2` (GLM-5.2)'s\n  deployments, venvs, systemd units, or GPU allocation beyond GPU2 (and\n  GPU0, only if TP=2 is chosen) — this feature runs only on GPU2 (+GPU0 if\n  needed) and does not touch the other two features\n- 768K or 1M context sizes — REQ-002 fixes the target at 896K only, no\n  step-up/down exploration (explicit user decision, given 896K is already\n  proven sufficient and working on this model by `feat-3`)\n- A Q8/FP8 weight-quantization comparison leg — explicitly dropped in\n  favor of BF16 vs. NVFP4(+MTP) only (explicit user decision)\n- Any single service being auto-promoted to \"the\" production default —\n  every variant stays on-demand and user-selected (unlike `feat-3`, which\n  ended up cutting BF16 over to a single NVFP4+MTP production service)\n- Testing or validating vision-language (image/video) capability (REQ-013)\n- Fine-tuning or training Qwen3.8-27B (serving only)\n- Authentication/access-control layer (explicitly accepted as anonymous)\n- OpenWebUI wiring (deferred/optional, same precedent as `feat-3`)\n- Ollama/llama.cpp/GGUF as the serving path — same rationale as `feat-3`:\n  the vendor's YaRN long-context documentation only covers vLLM, SGLang,\n  and TokenSpeed, and Qwen3.8-27B's hybrid Gated DeltaNet + partial-rotary/\n  mrope architecture is judged too high-risk for an independent llama.cpp\n  YaRN re-implementation\n\n### Dependencies\n\n- Depends on: the Dell 7960T's existing driver/CUDA stack (already\n  installed and validated by `feat-1`/`feat-2` — driver 610.57.04, CUDA\n  13.3, 4x RTX PRO 6000 Blackwell Max-Q/SM120, confirmed live 2026-08-25,\n  see Task 0.2); a fresh, fully isolated vLLM 0.26.0 venv (Task 0.3) — NOT\n  inherited from `feat-1`'s `/data/vllm/.venv`, built independently to\n  guarantee REQ-009's isolation; HF access/download tooling (already\n  present and working per `feat-1`'s cache under `/data/nvidia/hf_cache`);\n  sufficient disk headroom under `/data` (7TB free confirmed 2026-08-25 —\n  trivial for ~54GB BF16 + ~23GB NVFP4)\n- Related (not a hard dependency): `feat-1`'s **open, unresolved** SM120\n  degenerate-output bug (`vllm-project/vllm#52938`) — directly relevant\n  here (same GPU family), unlike `feat-3`'s GB10 (different GPU, the bug\n  does not apply there) — see REQ-010; `feat-1`'s vLLM 0.27.1 rollback\n  finding (DeepGEMM/SM120 regression) — directly informs REQ-005's version\n  pin; `feat-3`'s already-published YaRN factor-table entry for 896K\n  (factor 3.5), NVFP4 checkpoint pin, and MTP methodology — reused\n  verbatim wherever a finding is architecture-driven rather than hardware-\n  -driven (`feat-3` Task 6.2 step 4 already showed KV-cache token capacity\n  at a given context is architecture-driven, not precision- or hardware-\n  -pool-driven, though it must still be re-measured on this box's discrete-\n  -VRAM GPU rather than assumed identical to the GB10's unified-pool\n  numbers)\n- Blocks: none\n\n### Design Notes\n\n- **Model facts**: identical to `feat-3` — `Qwen/Qwen3.8-27B`, Apache-2.0,\n  dense causal LM + vision encoder, 27B language-model params (28B total on\n  disk, BF16 safetensors). Hybrid layout: 16x (3x (Gated DeltaNet -> FFN)\n  -> 1x (Gated Attention -> FFN)), 64 layers total. Native context 262,144,\n  extensible via YaRN. See `feat-3`'s Design Notes for the full\n  architectural detail — not repeated here.\n\n- **Hardware verified live on this box, 2026-08-25** (all read-only checks,\n  no state changed): 4x RTX PRO 6000 Blackwell Max-Q, 96GB VRAM each, all\n  idle (0 MiB used) at check time; driver 610.57.04, CUDA (nvidia-smi)\n  13.3; `nvidia-smi topo -m` shows `NODE` (PCIe-through-host-bridge, no\n  NVLink) between every one of the 6 GPU pairs; per-GPU PCIe generation:\n  GPU0 and GPU2 are Gen5 x16, GPU1 and GPU3 are Gen4 x16\n  (`pcie.link.gen.max`); GPU2 chosen over GPU0 for the default single-GPU\n  pin because `hardware/dell-7960t/configuration.md` notes GPU0\n  occasionally holds an Ollama-resident model (~43GB) — no Ollama\n  process/service was found running on the box at check time, but GPU2 is\n  the cleaner choice to avoid that class of contention recurring later.\n\n- **Why no NVLink changes the multi-GPU calculus vs. `feat-1`**: `feat-1`'s\n  DeepSeek-V4-Flash *needs* `--tensor-parallel-size 4` just to fit the\n  model at all — TP is load-bearing there regardless of interconnect\n  quality. Qwen3.8-27B does not need the extra VRAM (54GB BF16 fits one\n  96GB GPU with room to spare for a 896K KV cache), so TP here is purely a\n  throughput question, and with no NVLink between any GPU pair, splitting\n  compute across GPUs is expected to add real PCIe communication latency\n  per decode step for no offsetting capacity gain — the working hypothesis\n  going into Phase 2 is that TP=1/GPU2-only wins or ties TP=2, not that\n  TP=2 helps.\n\n- **Why `feat-1`'s open SM120 bug is a real (not theoretical) risk here,\n  unlike for `feat-3`**: `feat-1`'s bug\n  (`vllm-project/vllm#52938`) is specific to SM120 (this box's GPU family)\n  and DeepSeek-V4-Flash's sparse MLA attention kernel\n  (`FLASHINFER_MLA_SPARSE_DSV4`). Qwen3.8-27B's Gated DeltaNet + Gated\n  Attention layout is a different kernel path, so there is no strong\n  reason to expect the *same* bug to recur — but there is also no\n  vLLM/FlashInfer track record yet of this specific architecture running\n  cleanly on SM120 at all (it was only ever validated on `feat-3`'s SM121a\n  GB10). Phase 1's smoke test exists specifically to close this gap before\n  any further investment, mirroring the exact check `feat-3` ran on the\n  GB10 for the same reason (new platform, new architecture, verify before\n  extending).\n\n- **Why staying on vLLM 0.26.0, not `feat-3`'s 0.27.1**: `feat-1`'s\n  Decisions Made record a trial upgrade to 0.27.1 (with flashinfer 0.6.17)\n  that was rolled back after hitting a hard, unconditional \"unsupported\n  architecture\" DeepGEMM gap for SM120. Since this box's GPUs are SM120\n  (not `feat-3`'s SM121a, where 0.27.1 was required for `qwen3_5`/NVFP4\n  support), there is no reason to take on that known regression here — the\n  box's already-installed 0.26.0 was live-checked on 2026-08-25 (against\n  `feat-1`'s existing venv, as a fast proxy) and already registers\n  `Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP`, has working NVFP4 GEMM\n  kernels (`cutlass_scaled_mm_supports_fp4(120)` -> `True`), and exposes\n  every CLI flag this feature needs (`--kv-cache-dtype`,\n  `--kv-cache-memory-bytes`, `--hf-overrides`, `--speculative-config`,\n  `--tensor-parallel-size`, `--served-model-name`, `--tool-call-parser\n  qwen3_xml`, `--reasoning-parser`, `--linear-backend`). Task 0.3 still\n  re-runs these same checks inside the feature's own dedicated venv before\n  trusting them for real (REQ-009 isolation means the existing venv's\n  state is only a proxy, not a substitute).\n\n- **Isolation implementation**: dedicated tree `/data/qwen3.8-27b/`\n  contains its own `.venv`, launch scripts, and (via\n  `~/.config/systemd/user/`) its own systemd unit files — no file or\n  package under this tree is shared with `/data/vllm/.venv` (`feat-1`) or\n  `feat-2`'s `/data/llama.cpp-dsa` tree. The single deliberate exception is\n  the read-only Hugging Face download cache (`HF_HOME=/data/nvidia/hf_cache`,\n  matching `feat-1`'s existing convention) — a cache directory carries no\n  code/package coupling risk, so sharing it does not violate REQ-009.\n\n- **YaRN config (fixed, not a table)**: since REQ-002 fixes the target\n  context at 896K (917,504 tokens), only one factor value is needed —\n  `factor: 3.5` — reused verbatim from `feat-3`'s vendor-documented\n  override shape:\n  `{\"text_config\": {\"rope_parameters\": {\"mrope_interleaved\": true, \"mrope_section\": [11, 11, 10], \"rope_type\": \"yarn\", \"rope_theta\": 10000000, \"partial_rotary_factor\": 0.25, \"factor\": 3.5, \"original_max_position_embeddings\": 262144}}}`\n  passed via `--hf-overrides` (needs `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`).\n\n- **On-demand-only service model (explicit user decision, differs from\n  `feat-3`)**: `feat-3` started with multiple disabled services and ended,\n  after its own precision journey, with exactly one auto-promoted\n  \"production\" service (NVFP4+MTP at 896K) and the rest kept as disabled\n  fallbacks. This feature does **not** converge to a single default —\n  every adopted variant (BF16, and NVFP4[+MTP] if it clears REQ-004's bar)\n  stays installed as its own disabled, on-demand `systemctl --user` unit,\n  and the user decides at any given time which one (if any) is running.\n  This also means, unlike `feat-3`, there is no expectation that this\n  feature's service(s) run continuously — coexistence with `feat-1`/\n  `feat-2` is handled by keeping this feature's GPU footprint to GPU2 (or\n  GPU2+GPU0) only, not by any runtime scheduling logic.\n\n- **NO environment inheritance from `feat-1`/`feat-2`'s venvs/install\n  trees**, by design (REQ-009) — the only things inherited are the box's\n  driver/CUDA stack (already shared infrastructure, not a venv), the\n  shared HF cache directory (deliberate, low-risk exception), and\n  practice/precedent (systemd `--user`-lingering pattern, HF-pin\n  discipline, no-auth internal posture, \"measure don't assume\" capacity\n  methodology) from `feat-1`/`feat-2`/`feat-3`.\n\n- **Model-architecture-driven findings reused verbatim from `feat-3`**\n  (i.e., not hardware-pool-dependent, so no need to re-derive): the YaRN\n  `rope_parameters` override shape and factor-to-context mapping; the\n  `qwen3_xml` tool-call-parser / `qwen3` reasoning-parser choice (derived\n  from the model's own `chat_template.jinja`, not from GB10-specific\n  behavior); the NVFP4 checkpoint's mixed quantization scheme (NVFP4 MLPs,\n  FP8 attention/`lm_head`/last-8-layers, MTP draft head bundled in the\n  same `unsloth/Qwen3.8-27B-NVFP4` repo, no separate `speculative-config\n  \"model\"` field needed); the tokenizer-truncation-bug check (`tokenizer.\n  json`'s `truncation` field must be `null`) before trusting a downloaded\n  NVFP4 revision. **Not** reused as-is, requires fresh measurement on this\n  box: KV-cache byte-per-token/capacity/headroom numbers (different memory\n  pool shape), decode/prefill throughput numbers (different GPU, no shared-\n  -pool contention, possibly different FlashInfer kernel selection on\n  SM120 vs. SM121a), and the TP=1-vs-TP=2 question (`feat-3` never tested\n  multi-GPU at all, since the GB10 only has one GPU).\n\n### Related ADRs\n\n- None (infrastructure/deployment work, tracked in this repo using the\n  feature-folder convention, same as `feat-1`/`feat-2`/`feat-3`)\n\n### Task List\n\n#### Phase 0: Environment prep (dedicated, isolated install)\n\n- [x] Task 0.1: Confirm disk headroom under `/data` for the new dedicated\n  tree plus BF16 (~54GB) and NVFP4 (~23GB) weights — depends on: none —\n  status: done 2026-08-25 — `/data` (`/dev/md126`) has 7.0 TB free of\n  15 TB (53% used) — trivial, no cleanup required\n- [x] Task 0.2: Confirm the Dell 7960T's existing driver/CUDA are installed\n  and working, AND — as a fast read-only proxy check before building the\n  feature's own isolated venv — confirm the box's existing (`feat-1`)\n  vLLM 0.26.0 install already supports Qwen3.8-27B's architecture and\n  NVFP4 kernels on SM120 — depends on: none — status: done 2026-08-25 —\n  driver 610.57.04 / CUDA (nvidia-smi) 13.3 confirmed, matches\n  `hardware/dell-7960t/configuration.md`; `/data/vllm/.venv`'s vLLM 0.26.0\n  registers `Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP` in its\n  `ModelRegistry`; `cutlass_scaled_mm_supports_fp4(120)` returns `True`\n  (compute capability confirmed `(12, 0)` on all 4 GPUs); `vllm serve\n  --help=all` confirms every CLI flag this feature needs is present\n  (`--kv-cache-dtype` incl. `fp8`/`nvfp4`, `--kv-cache-memory-bytes`,\n  `--hf-overrides`, `--speculative-config`, `--tensor-parallel-size`,\n  `--served-model-name`, `--tool-call-parser qwen3_xml`,\n  `--reasoning-parser`, `--enable-auto-tool-choice`, `--linear-backend`\n  incl. `flashinfer_b12x`). **This checked `feat-1`'s existing venv only as\n  a proxy — Task 0.3 re-verifies inside the feature's own dedicated venv\n  before trusting it for real (REQ-009 isolation).**\n- [ ] Task 0.3: Build the fully isolated `/data/qwen3.8-27b/.venv`, pinned\n  `vllm==0.26.0` (NOT 0.27.1 — see Design Notes/`feat-1`'s rollback\n  finding), independent of `/data/vllm/.venv`; re-run the same `qwen3_5`\n  registry / NVFP4 kernel / CLI-flag checks from Task 0.2 inside this new\n  venv — depends on: Task 0.2 — status: not-started\n- [x] Task 0.4: Confirm GPU topology (NVLink presence/absence) and PCIe\n  generation per GPU, to inform REQ-011's GPU-pinning decision — depends\n  on: none — status: done 2026-08-25 — `nvidia-smi topo -m` shows `NODE`\n  (PCIe-through-host-bridge, no NVLink) between all 4 GPUs; per-GPU PCIe\n  link: GPU0 & GPU2 = Gen5 x16 (`pcie.link.gen.max`), GPU1 & GPU3 = Gen4\n  x16; GPU2 selected as the default single-GPU pin (Gen5, and avoids\n  GPU0's documented occasional Ollama residency per\n  `hardware/dell-7960t/configuration.md`); GPU2's UUID is\n  `GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea` (bus `00000000:AC:00.0`) —\n  use this for `CUDA_VISIBLE_DEVICES` pinning (UUID, not index, to be\n  robust against any future PCI re-enumeration)\n- [x] Task 0.5: Confirm `feat-1`/`feat-2`'s current live state, to avoid\n  surprises/contention during this feature's own testing — depends on:\n  none — status: done 2026-08-25 — `feat-1` (DeepSeek-V4-Flash) is\n  blocked/disabled (open SM120 degenerate-output bug,\n  `vllm-project/vllm#52938`, `status: planning` in its README, service\n  stopped); `feat-2` (GLM-5.2, served via `llama.cpp`, not vLLM/\n  ktransformers — a discrepancy from `AGENTS.md`'s description worth\n  flagging but not fixing here) has a working Q4 production config but was\n  not running at check time; all 4 GPUs measured at ~0 MiB used (fully\n  idle) at check time; no Ollama process/service found running\n- [ ] Task 0.6: Pin and download `Qwen/Qwen3.8-27B` (BF16) and\n  `unsloth/Qwen3.8-27B-NVFP4` to specific HF revisions into the shared\n  `/data/nvidia/hf_cache` (`HF_HOME`, matching `feat-1`'s convention) —\n  reuse `feat-3`'s already-vetted NVFP4 revision\n  (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) if still current, re-verify\n  the tokenizer-truncation fix (`tokenizer.json`'s `truncation` field must\n  be `null`) either way; pin the BF16 revision fresh at download time —\n  depends on: Task 0.3 — status: not-started\n\n#### Phase 1: Native-context correctness smoke test (hard gate)\n\n- [ ] Task 1.1: Bring up the BF16 checkpoint on GPU2 (TP=1) at short/native\n  context (no YaRN override yet) — depends on: Task 0.6 — status:\n  not-started\n- [ ] Task 1.2: Temperature=0 smoke test — explicitly check for `feat-1`'s\n  exact degenerate-output signature (a single frozen token / identical\n  logprob repeated at every decode position); verify tool-calling and all\n  three thinking-control modes — depends on: Task 1.1 — status:\n  not-started\n- [ ] Task 1.3: Record the outcome. If the degenerate-output signature IS\n  reproduced, this is a blocking finding (same bug class as `feat-1`'s\n  open, unresolved issue) requiring investigation/escalation before any\n  further work in this feature — depends on: Task 1.2 — status:\n  not-started\n\n#### Phase 2: TP=1 vs. TP=2 throughput check (GPU-pinning decision)\n\n- [ ] Task 2.1: Benchmark decode throughput at matched settings: GPU2-only\n  (TP=1) vs. GPU2+GPU0 (TP=2) — depends on: Task 1.3 — status: not-started\n- [ ] Task 2.2: Decide production GPU pinning based on the measured\n  numbers (working hypothesis, per Design Notes: TP=1/GPU2-only wins or\n  ties, given no NVLink between any GPU pair) — depends on: Task 2.1 —\n  status: not-started\n\n#### Phase 3: YaRN 896K context — apply + validate (fixed target)\n\n- [ ] Task 3.1: Apply the YaRN `rope_parameters` override (factor 3.5)\n  targeting the fixed 917,504-token context, on the GPU(s) chosen in\n  Phase 2 — depends on: Task 2.2 — status: not-started\n- [ ] Task 3.2: Measure KV-cache token capacity and free VRAM headroom at\n  896K — depends on: Task 3.1 — status: not-started\n- [ ] Task 3.3: Validate with a real filled-context request (a real\n  ~899K-token prompt built with the model's own tokenizer, not a synthetic\n  estimate) end-to-end; confirm no OOM — depends on: Task 3.2 — status:\n  not-started\n\n#### Phase 4: Precision + MTP comparison at 896K/YaRN\n\n- [ ] Task 4.1: Benchmark BF16 vs. NVFP4 decode/prefill throughput at\n  896K/YaRN, on the GPU(s) chosen in Phase 2 — depends on: Task 3.3 —\n  status: not-started\n- [ ] Task 4.2: Benchmark NVFP4 + MTP (`--speculative-config\n  '{\"method\":\"mtp\",\"num_speculative_tokens\":5}'`, draft head ships inside\n  the `unsloth/Qwen3.8-27B-NVFP4` checkpoint) vs. NVFP4-without-MTP at the\n  same context; verify byte-identical (lossless) greedy output at\n  temperature=0 vs. the non-MTP run on the same prompt — depends on: Task\n  4.1 — status: not-started\n- [ ] Task 4.3: Re-verify KV-cache token capacity/headroom with MTP\n  enabled still clears the 917,504-token requirement — depends on: Task\n  4.2 — status: not-started\n- [ ] Task 4.4: Re-verify correctness (coherent non-degenerate output,\n  tool-calling, all three thinking-control modes) on the MTP-enabled\n  config — depends on: Task 4.3 — status: not-started\n- [ ] Task 4.5: Record the final precision/MTP decision (BF16 / NVFP4 /\n  NVFP4+MTP), with the measured throughput numbers and a one-line\n  rationale, per REQ-004 — depends on: Task 4.4 — status: not-started\n\n#### Phase 5: On-demand systemd services (no auto-start, ever)\n\n- [ ] Task 5.1: Install `qwen3.8-27b-bf16-896k.service` — `systemctl\n  --user`, lingering enabled, left `disabled` (never auto-starts at boot)\n  — depends on: Task 4.5 — status: not-started\n- [ ] Task 5.2: Install the adopted NVFP4 variant's service (e.g.\n  `qwen3.8-27b-nvfp4-mtp-896k.service` if MTP is adopted per Task 4.5) —\n  same `systemctl --user`/lingering/disabled pattern — depends on: Task\n  4.5 — status: not-started\n- [ ] Task 5.3: Confirm both services start/stop cleanly on demand via\n  `systemctl --user start|stop`, and confirm neither auto-starts at boot\n  or on install — depends on: Task 5.1, Task 5.2 — status: not-started\n\n#### Phase 6: Integration\n\n- [ ] Task 6.1: Produce an OpenCode provider snippet for each installed\n  service variant (distinct `baseURL`/port per variant if run\n  concurrently is ever desired, or a single entry updated by hand when\n  switching variants) — depends on: Task 5.3 — status: not-started\n- [ ] Task 6.2 (optional, deferred): OpenWebUI wiring — same precedent as\n  `feat-3` (out of scope unless requested later) — depends on: Task 6.1 —\n  status: not-started\n\n## Progress\n\n### Current Status\n\n**As of 2026-08-25 (feature written, no implementation performed yet)**:\nthis README was written following a planning conversation that produced\nseveral already-verified (read-only, no state changed) findings, recorded\nabove as done Task entries: disk headroom (Task 0.1), the Dell 7960T's\nexisting driver/CUDA and a proxy check of `feat-1`'s existing vLLM 0.26.0\nvenv for `qwen3_5`/NVFP4 support (Task 0.2), GPU topology/NVLink-absence/\nPCIe-generation-per-GPU and the resulting GPU2 pinning choice (Task 0.4),\nand `feat-1`/`feat-2`'s current live state (Task 0.5). None of these\nrequired any write/deploy action — they were confirmed via `nvidia-smi`,\n`vllm serve --help=all`, a Python import against `feat-1`'s existing venv,\n`systemctl`/`docker ps` checks, and reading\n`hardware/dell-7960t/configuration.md`.\n\n**Nothing has been installed, downloaded, or deployed yet.** The dedicated\n`/data/qwen3.8-27b/` venv (Task 0.3) has not been built, no model weights\nhave been downloaded (Task 0.6), and no systemd services exist. GitHub\nissue [#4](https://github.com/dfch/biz.dfch.LlmOps/issues/4) has been\ncreated for this feature.\n\n**Next step**: Task 0.3 (build the isolated venv) — the first task that\nactually changes anything on the box, and the natural entry point for\nimplementation once approved.\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 8.4s)

_Thinking:_



**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md"
}
```

**Output:**
```
true
```

---

## Assistant (Build · Claude Sonnet 5 · 6.4s)

Formatted (mdformat made changes). Let me verify the final result and check git status.

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git status --short && echo \"---\" && git add -A -n .specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/ && wc -l .specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md"
}
```

**Output:**
```
?? .specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/
---
add '.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md'
568 .specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md

```

---

## Assistant (Build · Claude Sonnet 5 · 7.1s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md",
  "limit": 30
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-25
3: github_issue: 4
4: id: feat-4-qwen3.8-27b-dell-7960t
5: status: planning
6: updated: 2026-08-25
7: version: 1.0.0
8: ---
9: 
10: # Feature: On-prem Qwen3.8-27B serving with extended context on the Dell 7960T
11: 
12: ## Plan
13: 
14: ### Overview
15: 
16: Deploy `Qwen/Qwen3.8-27B` (the same model as `feat-3`, dense causal LM + vision
17: encoder, 27B params, Apache-2.0) via vLLM on the **Dell 7960T** — the box
18: already hosting `feat-1` (DeepSeek-V4-Flash) and `feat-2` (GLM-5.2) — as a
19: **dedicated, on-demand** service pinned to a single GPU, at a **fixed 896K
20: (917,504-token) context** via the vendor's documented YaRN `rope_parameters`
21: override.
22: 
23: This is explicitly a re-deployment of a model `feat-3` already fully
24: validated on different hardware (a GB10/DGX-Spark-clone with one **unified**
25: 128GB CPU+GPU memory pool, arm64). The Dell 7960T is a fundamentally
26: different shape of box: x86_64, **4x RTX PRO 6000 Blackwell Max-Q, 96GB
27: *discrete* VRAM each (384GB total)**, plus a fully separate 512GB system RAM
28: pool, and **no NVLink between any of the 4 GPUs** (confirmed via
29: `nvidia-smi topo -m`: every GPU pair shows `NODE`, i.e. PCIe-through-host-
30: -bridge only). That changes which of `feat-3`'s hard-won findings transfer

(Showing lines 1-30 of 568. Use offset=31 to continue.)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 10.3s)

Feature written and not yet implemented, as requested.

**Summary:**
- Created GitHub issue [#4](https://github.com/dfch/biz.dfch.LlmOps/issues/4).
- Wrote `.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md` (13 requirements, 10 acceptance criteria, 6 phases / 21 tasks), covering:
  - Dedicated, isolated install (`/data/qwen3.8-27b/.venv`, vLLM 0.26.0 — deliberately *not* feat-3's 0.27.1, per feat-1's rollback finding) with zero shared state with feat-1/feat-2 beyond the read-only HF cache
  - GPU2 pinning (TP=1 default, tested against TP=2 empirically) with the PCIe topology/NVLink findings recorded as rationale
  - A hard Phase-1 gate explicitly checking for feat-1's known SM120 degenerate-output bug before any long-context work
  - Fixed 896K/YaRN context only (no 768K/1M sweep)
  - BF16 vs. NVFP4 vs. NVFP4+MTP comparison at 896K
  - Two-plus permanently on-demand `systemctl --user` services (no auto-promoted "production" default, unlike feat-3)
- Marked **Tasks 0.1, 0.2, 0.4, 0.5 as done** — these were genuine read-only verification I performed live on this box during planning (disk headroom, driver/CUDA/vLLM-registry/NVFP4-kernel/CLI-flag checks, GPU topology/PCIe-generation, feat-1/feat-2 live state). Nothing was installed, downloaded, or deployed — **Task 0.3 (build the isolated venv) is the first task that changes anything on the box**, and is the natural next step once you're ready to proceed.

---

