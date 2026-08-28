#!/usr/bin/env bash
# Task 2.3a: reproduces the hard CUDA-kernel-launch crash found 2026-08-28
# when llama.cpp-qwen4exp (built from PR #27742) is pushed past its native
# 262144-token context via the --override-kv metadata trick. See the
# feature README's Decisions Made (2026-08-28, "Task 2.3a: context
# extension crashes at the native-context boundary") for full narrative.
#
# Deliberately regenerates the exact prompts here (fixed random seeds)
# rather than shipping the original multi-MB .txt blobs used during
# discovery -- same content, no large binary-ish text files in the repo.
#
# Usage: bin/08-repro-task2.3a-context-crash.sh [base_url] [model_name]
#   e.g. bin/08-repro-task2.3a-context-crash.sh http://localhost:30004 qwen4exp
#
# Prerequisite: llama-server already running against UD-Q4_K_XL (or Q8_0)
# at GPU0+GPU2 with the override-kv context-extension flags, e.g.:
#   CUDA_VISIBLE_DEVICES=0,2 llama-server \
#     -m .../UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00001-of-00004.gguf \
#     -ngl 999 --tensor-split 1,1 --split-mode layer \
#     -c 896000 --rope-scaling yarn --yarn-orig-ctx 262144 \
#     --rope-freq-scale 0.29257142857 --parallel 1 \
#     --override-kv qwen4exp.context_length=int:896000 \
#     --host 0.0.0.0 --port 30004 --jinja --reasoning auto

set -uo pipefail

BASE_URL="${1:-http://localhost:30004}"
MODEL="${2:-qwen4exp}"

gen_prompt() {
  # $1 = random seed, $2 = word count
  python3 -c "
import random
random.seed($1)
words = ('the quick brown fox jumps over lazy dog while system architecture documents describe '
         'various technical concepts including distributed computing memory allocation network '
         'protocols database transactions software engineering principles algorithms data structures').split()
print(' '.join(random.choice(words) for _ in range($2)))
"
}

echo "== Step 1: 45,000-word prompt (~45K tokens, well under native 262144) -- expected to SUCCEED =="
gen_prompt 42 45000 > /tmp/repro_task2.3a_small.txt
curl -s "$BASE_URL/v1/chat/completions" -H 'Content-Type: application/json' \
  -d @<(python3 -c "
import json
text = open('/tmp/repro_task2.3a_small.txt').read()
print(json.dumps({
  'model': '$MODEL',
  'messages': [{'role':'user','content': text + '\n\nIn one sentence, what repeated word appears most in the text above?'}],
  'temperature': 0, 'max_tokens': 60,
  'chat_template_kwargs': {'enable_thinking': False}
}))
") -w "\nHTTP:%{http_code}\n"

echo
echo "== Step 2: 310,000-word prompt (tokenizes to well over native 262144) -- expected to CRASH the server =="
echo "   (reproduced crash 2026-08-28: CUDA error: invalid argument in"
echo "    ggml_cuda_op_rms_norm_fused, at n_tokens ~= 260,096 -- essentially"
echo "    exactly the native 262144-token boundary, regardless of the"
echo "    896000 target passed via --override-kv)"
gen_prompt 7 310000 > /tmp/repro_task2.3a_crash.txt
curl -s "$BASE_URL/v1/chat/completions" -H 'Content-Type: application/json' \
  -d @<(python3 -c "
import json
text = open('/tmp/repro_task2.3a_crash.txt').read()
print(json.dumps({
  'model': '$MODEL',
  'messages': [{'role':'user','content': text + '\n\nIn one sentence, what repeated word appears most in the text above?'}],
  'temperature': 0, 'max_tokens': 60,
  'chat_template_kwargs': {'enable_thinking': False}
}))
") -w "\nHTTP:%{http_code}\n"

echo "If step 2 hung/errored/reset the connection, check the server's own log for"
echo "the CUDA error + backtrace -- the server process itself will have exited."
