# Qwen3.8-27B vs Qwen3.6 comparison

**Session ID:** ses_fd5d2e821ffemldlQtcOW7bHA3
**Created:** 8/22/2026, 5:53:13 PM
**Updated:** 8/22/2026, 6:32:41 PM

---

## User

examine this model https://huggingface.co/Qwen/Qwen3.8-27B

how does it compare to qwen3.6? is this available with a larger context size?

---

## Assistant (Build · Claude Sonnet 5 · 5.6s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3.8-27B"
}
```

**Output:**
```
                

  Qwen/Qwen3.8-27B · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

](/Qwen)

[Qwen](/Qwen)

/

[Qwen3.8-27B](/Qwen/Qwen3.8-27B)

like 12.1k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg) Qwen 99.4k

[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

qwen3\_5

](/models?other=qwen3_5)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)

License: apache-2.0

[Model card](/Qwen/Qwen3.8-27B) [Files Files and versions

xet

](/Qwen/Qwen3.8-27B/tree/main)[Community

159

](/Qwen/Qwen3.8-27B/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Qwen/Qwen3.8-27B with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Qwen/Qwen3.8-27B?library=transformers)
    
    How to use Qwen/Qwen3.8-27B with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("image-text-to-text", model="Qwen/Qwen3.8-27B")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    pipe(text=messages)
    
    \# Load model directly
    from transformers import AutoProcessor, AutoModelForMultimodalLM
    
    processor = AutoProcessor.from\_pretrained("Qwen/Qwen3.8-27B")
    model = AutoModelForMultimodalLM.from\_pretrained("Qwen/Qwen3.8-27B", device\_map="auto")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    inputs = processor.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(processor.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Inference
-   Inference Providers
-   Notebooks
-   [Google Colab](/Qwen/Qwen3.8-27B/colab)
-   [Kaggle](/Qwen/Qwen3.8-27B/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Qwen/Qwen3.8-27B?local-app=vllm)
    
    How to use Qwen/Qwen3.8-27B with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Qwen/Qwen3.8-27B"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Qwen/Qwen3.8-27B
    
-   [SGLang](/Qwen/Qwen3.8-27B?local-app=sglang)
    
    How to use Qwen/Qwen3.8-27B with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Qwen/Qwen3.8-27B" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Qwen/Qwen3.8-27B" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Qwen/Qwen3.8-27B?local-app=docker-model-runner)
    
    How to use Qwen/Qwen3.8-27B with Docker Model Runner:
    
    docker model run hf.co/Qwen/Qwen3.8-27B
    
-   [Browse Quantizations](/models?other=base_model:quantized:Qwen/Qwen3.8-27B) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [Qwen3.8-27B](#qwen38-27b "Qwen3.8-27B")
    -   [Qwen3.8 Highlights](#qwen38-highlights "Qwen3.8 Highlights")
        
    -   [Model Overview](#model-overview "Model Overview")
        
    -   [Benchmark Results](#benchmark-results "Benchmark Results")
        -   [Text Performance](#text-performance "Text Performance")
        -   [VL Performance](#vl-performance "VL Performance")
    -   [Quickstart](#quickstart "Quickstart")
        -   [Serving Qwen3.8](#serving-qwen38 "Serving Qwen3.8")
        -   [API Usage](#api-usage "API Usage")
    -   [Best Practices](#best-practices "Best Practices")
        
    -   [Citation](#citation "Citation")
        

# [](#qwen38-27b)Qwen3.8-27B

> This repository contains model weights and configuration files for the post-trained model in the Hugging Face Transformers format.
> 
> These artifacts are compatible with Hugging Face Transformers, vLLM, SGLang, TokenSpeed, etc.

> For users seeking managed, scalable inference without infrastructure maintenance, the official Qwen API service is provided by [Qwen Cloud](https://www.qwencloud.com). In particular, **Qwen3.8-27B** will be available as a hosted version with more production features, e.g., 1M context length by default, official built-in tools. For more information, please refer to the [Qwen3.8-27B Overview](https://www.qwencloud.com/models/qwen3.8-27b). The service is coming soon. Stay tuned for updates.

Following the widespread community adoption of the Qwen3.5 and Qwen3.6 series, we are pleased to introduce Qwen3.8, the most capable generation in the Qwen open-model family to date.

Built on the architectural foundation of Qwen3.5, Qwen3.8 delivers substantial gains across coding, professional work, research, and long-horizon agentic tasks. Qwen3.8-27B brings these advances to a compact, deployment-friendly dense model: a native vision-language model that understands images and videos, with flexible thinking control, designed to carry complex, multi-step tasks through to completion with greater reliability.

## [](#qwen38-highlights)Qwen3.8 Highlights

Qwen3.8-27B features the following enhancements:

-   **Core Capabilities**: Comprehensive improvements across coding, professional work, research, and long-horizon agentic tasks.
-   **Agent Execution**: Stronger autonomous planning and better handling of environment feedback, leading to more reliable end-to-end task completion.
-   **Downstream Compatibility**: Broader support for popular harnesses and development tools, making it easier to integrate into your existing stack.
-   **Flexible Thinking Control**: Thinking mode is on by default and can be disabled per request; reasoning depth can be tuned with `reasoning_effort`, and reasoning context from historical messages is retained via `preserve_thinking`.
-   **Vision-Language Understanding**: Native support for image and video understanding, from STEM diagrams and documents to hour-scale videos.

## [](#model-overview)Model Overview

-   Type: Causal Language Model with Vision Encoder
-   Training Stage: Pre-training & Post-training
-   Language Model
    -   Number of Parameters: 27B
    -   Hidden Dimension: 5120
    -   Token Embedding: 248,320 (Padded)
    -   Number of Layers: 64
    -   Hidden Layout: 16 × (3 × (Gated DeltaNet → FFN) → 1 × (Gated Attention → FFN))
    -   Gated DeltaNet:
        -   Number of Linear Attention Heads: 48 for V and 16 for QK
        -   Head Dimension: 128
    -   Gated Attention:
        -   Number of Attention Heads: 24 for Q and 4 for KV
        -   Head Dimension: 256
        -   Rotary Position Embedding Dimension: 64
    -   Feed Forward Network:
        -   Intermediate Dimension: 17,408
    -   LM Output: 248,320 (Padded)
    -   MTP (Multi-Token Prediction): trained with multiple steps
-   Context Length: 262,144 natively and extensible up to 1,000,000 tokens.

## [](#benchmark-results)Benchmark Results

### [](#text-performance)Text Performance

Qwen3.8-27B

Qwen3.6-27B

Qwen3.7-Plus

Muse Glimmer-30B

Opus4.6 Max

Coding

Agentic terminal coding

Terminal Bench 2.1 (Terminus)

73.0

63.4

64.0

51.7

**78.2**

Agentic coding

SWE-bench Pro

**61.7**

53.5

57.6

51.2

53.4

Repo-level code generation

NL2Repo-Bench

42.3

36.2

41.1

\--

**47.6**

Agentic coding

DeepSWE 1.1

**42.2**

13.3

14.2

\--

\--

Software engineering

QwenSWEBench

**79.0**

49.3

59.2

\--

63.8

Agent

Long-horizon office work

CoWorkBench

**70.7**

61.0

65.1

\--

68.2

Professional job tasks

JobBench

**33.4**

21.8

27.6

\--

\--

Frontier agentic tasks

Agents' Last Exam

Pass@1

**20.4**

Score

**42.9**

Pass@1

10.6

Score

27.3

Pass@1

13.2

Score

33.6

\--

\--

General

Instruction following

IFBench

**79.5**

69.1

79.1

77.0

62.5

Scientific reasoning

GPQA Diamond

89.2

87.8

90.3

83.5

**91.3**

Multidisciplinary reasoning

HLE

30.8

24.0

34.7

22.0

**40.0**

Competitive coding

LiveCodeBench v6

**90.3**

83.9

89.6

\--

88.8

1.  SWE-bench Pro: Except for Opus4.6 Max, which uses the officially reported score, all models are evaluated with the Claude Code harness at temp=1.0, top\_p=0.95, and a 256K context window. Problematic tasks were corrected, and all baseline models were re-evaluated on the refined benchmark.
2.  NL2Repo-Bench: Evaluated with the Claude Code harness. To prevent reward hacking, we disable Bash commands that attempt to access the specific repository, such as pip download, pip install, and git clone.
3.  DeepSWE 1.1: Evaluated with the Claude Code harness at temp=1.0, top\_p=0.95, and a 256K context window.
4.  QwenSWEBench: In-house coding benchmark for evaluating models' software engineering capabilities. Evaluated with the Claude Code harness. Reporting avg@3 with an 8-hour timeout, max\_tokens=32,768, temperature=1.0, and a 256K context window.
5.  CoWorkBench: In-house cowork benchmark for evaluating long-horizon tasks across computer science, finance, law, medical, and other productivity domains.
6.  HLE: Judged by GPT-4o.
7.  The best result in each row is shown in bold.
8.  Empty cells (--) indicate that results are not yet available or not applicable.

### [](#vl-performance)VL Performance

Qwen3.8-27B

Qwen3.6-27B

Qwen3.7-Plus

Muse Glimmer-30B

Opus4.6 Max

Agentic Multimodal Intelligence

Computer use

OSWorld-Verified

**84.3**

63.9

73.3

65.9

72.7

Browser use

WebArena-Verified

**64.8**

48.8

55.3

\--

\--

Mobile use

AndroidWorld

**81.9**

70.3

81.0

\--

62.0

Application recreation

RecreationBench

**47.1**

29.8

30.2

\--

\--

Multimodal tool use

ClawEval-MM

Pass@3

**57.4**

Average

56.9

Pass@3

42.6

Average

50.4

Pass@3

**57.4**

Average

**60.1**

\--

Pass@3

52.5

Average

54.7

Multimodal software engineering

SWE-MM

**38.6**

25.7

30.0

\--

27.1

Visual web development

Vision2Web

**62.9**

45.0

42.1

\--

\--

General Multimodal Intelligence

Visual math problem solving

MathVision

Without CI

90.0

With CI

**94.6**

Without CI

85.1

Without CI

**90.3**

\--

Without CI

65.5

General visual reasoning

BabyVision

Without CI

**65.7**

With CI

**85.6**

Without CI

28.9

Without CI

64.7

With CI

70.4

\--

Without CI

12.6

Scientific chart analysis

CharXiv (RQ)

Without CI

83.7

With CI

**90.2**

Without CI

78.4

Without CI

**85.8**

With CI

85.9

78.8

Without CI

66.0

Document intelligence

OmniDocBench 1.5

91.1

89.4

**91.4**

75.8

86.6

Real-world perception

RealWorldQA

85.9

84.1

**86.9**

\--

73.9

Embodied intelligence

ERQA

65.5

62.5

**69.8**

\--

40.8

1.  MathVision, BabyVision, and CharXiv (RQ): Where both settings are available, cells report “Without CI” and “With CI” separately; otherwise, only the available setting is shown. A small number of incorrect ground-truth annotations in MathVision and CharXiv (RQ) were corrected following manual verification, and all reported scores on those benchmarks were computed using the corrected annotations.
2.  MathVision: Qwen3.8-27B is evaluated using the fixed prompt: “Please reason step by step, and put your final answer within `\boxed{}`.” For the remaining models, we report the higher score from two prompt variants—one with and one without the `\boxed{}` formatting requirement.
3.  WebArena-Verified: Scores are computed with the official WebArena-Verified grader under the OSWorld scaffold.
4.  RecreationBench: An in-house, long-horizon application-recreation benchmark designed to evaluate hybrid-agent capabilities across five platforms: desktop (Ubuntu, macOS, and Windows), mobile (Android), and the web.
5.  ClawEval-MM: Scores are reported as “Pass@3 / average score.” Pass@3 is the percentage of tasks passed in at least one of three trials; the average score is the mean benchmark score across the three trials.
6.  Vision2Web: Scores are averaged across the frontend, webpage, and website categories. Evaluations use the Claude Code harness and are judged by `gpt-5.4-2026-03-05`.
7.  SWE-MM: Scores are evaluated on the Claude Code harness using the public dev split of SWE-bench Multimodal, with the modifications described in Appendix 8.3 of the Claude Opus 4.7 system card.
8.  Empty cells (--) indicate that results are not yet available or not applicable.

## [](#quickstart)Quickstart

For streamlined integration, we recommend using Qwen3.8 via APIs.

### [](#serving-qwen38)Serving Qwen3.8

> Inference efficiency and throughput vary significantly across frameworks. We recommend using the latest framework versions to ensure optimal performance and compatibility. For production workloads or high-throughput scenarios, dedicated serving engines such as SGLang, vLLM, or TokenSpeed are recommended.

Qwen3.8 can be deployed with popular inference frameworks, e.g.:

-   [SGLang](https://www.sglang.io/): [Qwen3.8 Cookbook](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B)
-   [vLLM](https://vllm.ai/): [Qwen3.8 Recipe](https://recipes.vllm.ai/Qwen/Qwen3.8-27B)
-   [TokenSpeed](https://lightseek.org/tokenspeed/): [Qwen3.8 Recipe](https://lightseek.org/tokenspeed/recipes/models#qwen3-8)

### [](#api-usage)API Usage

> Qwen3.8 models operate in thinking mode by default, generating thinking content signified by `<think>\n...</think>\n\n` before producing the final response. To disable thinking content and obtain a direct response, refer to the examples [here](#instruct-or-non-thinking-mode).

> We recommend using the following sets of sampling parameters for generation:
> 
> -   Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`
> -   Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`
> 
> Please note that the support for sampling parameters varies according to inference frameworks.

Qwen3.8 comes with official support for `reasoning_effort`, which can be used to adjust reasoning depth and control cost:

-   `xhigh` (default): for complex tasks demanding thorough analysis
-   `medium`: balancing accuracy and speed
-   `low`: efficient reasoning optimizing for speed and cost

In addition, `preserve_thinking` is enabled by default for all workloads for the best out-of-the-box experience. To disable preserved thinking, refer to the examples [here](#disable-preserved-thinking).

> In multi-turn agentic tasks, lower reasoning effort does not always reduce overall task completion time. Although it may produce faster per-turn responses, it can also lead to insufficient analysis, more failures, and repeated retries, which may increase total latency and token consumption.

#### [](#chat-completions-api)Chat Completions API

The Chat Completions API can be used with most inference frameworks, as well as [Qwen Cloud](https://www.qwencloud.com/). Before starting, make sure the OpenAI Python SDK is installed and the API key and the API base URL are configured, e.g.:

```shell
pip install -U openai

# Set the following accordingly
export OPENAI_BASE_URL='your-base-url'
export OPENAI_API_KEY='your-api-key'
```

##### [](#text-only-input)Text-Only Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [{"role": "user", "content": "Write a Python function to merge two sorted linked lists."}]

completion = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
    extra_body={
        "chat_template_kwargs": {
            "enable_thinking": True,  # on by default
            "preserve_thinking": True, # on by default
        },
    },
    reasoning_effort="xhigh",  # xhigh by default; supported levels are xhigh, medium, and low
    stream=True,
    stream_options={"include_usage": True},
)

reasoning_content = ""
answer_content = ""
is_answering = False
print("\n" + "=" * 20 + "Reasoning" + "=" * 20 + "\n")

for chunk in completion:
    if not chunk.choices:
        print("\nUsage:")
        print(chunk.usage)
        continue

    delta = chunk.choices[0].delta

    if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:
        if not is_answering:
            print(delta.reasoning_content, end="", flush=True)
        reasoning_content += delta.reasoning_content
    elif hasattr(delta, "reasoning") and delta.reasoning is not None:
        if not is_answering:
            print(delta.reasoning, end="", flush=True)
        reasoning_content += delta.reasoning

    if hasattr(delta, "content") and delta.content:
        if not is_answering:
            print("\n" + "=" * 20 + "Answer" + "=" * 20 + "\n")
            is_answering = True
        print(delta.content, end="", flush=True)
        answer_content += delta.content

messages.append({
    "role": "assistant",
    "content": answer_content,
    "reasoning_content": reasoning_content,
    "reasoning": reasoning_content,
})
```

##### [](#image-input)Image Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/CI_Demo/mathv-1327.jpg"
                }
            },
            {
                "type": "text",
                "text": "The centres of the four illustrated circles are in the corners of the square. The two big circles touch each other and also the two little circles. With which factor do you have to multiply the radii of the little circles to obtain the radius of the big circles?\nChoices:\n(A) $\\frac{2}{9}$\n(B) $\\sqrt{5}$\n(C) $0.8 \\cdot \\pi$\n(D) 2.5\n(E) $1+\\sqrt{2}$"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
)
print("Chat response:", chat_response)
```

##### [](#video-input)Video Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "video_url",
                "video_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/video/N1cdUjctpG8.mp4"
                }
            },
            {
                "type": "text",
                "text": "How many porcelain jars were discovered in the niches located in the primary chamber of the tomb?"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
)

# When vLLM is launched with `--media-io-kwargs '{"video": {"num_frames": -1}}'`,
# video frame sampling can be configured via `extra_body` (e.g., by setting `fps`).
# This feature is currently supported only in vLLM.
#
# By default, `fps=2` and `do_sample_frames=True`.
# With `do_sample_frames=True`, you can customize the `fps` value to set your desired video sampling rate.
# chat_response = client.chat.completions.create(
#     model="Qwen/Qwen3.8-27B",
#     messages=messages,
#     extra_body={
#         "mm_processor_kwargs": {"fps": 2, "do_sample_frames": True},
#     }, 
# )

print("Chat response:", chat_response)
```

##### [](#instruct-or-non-thinking-mode)Instruct (or Non-Thinking) Mode

Qwen3.8-27B will think by default before responding. You can obtain a direct response from the model without thinking by configuring the API parameters. For example,

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/RealWorld/RealWorld-04.png"
                }
            },
            {
                "type": "text",
                "text": "Where is this?"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
    temperature=0.7,
    top_p=0.8,
    presence_penalty=1.5,
    extra_body={
        "top_k": 20,
        "chat_template_kwargs": {"enable_thinking": False},
    }, 
)
print("Chat response:", chat_response)
```

> If you are using APIs from Qwen Cloud, in addition to changing `model`, please use `"enable_thinking": False` instead of `"chat_template_kwargs": {"enable_thinking": False}`.

##### [](#disable-preserved-thinking)Disable Preserved Thinking

By default, Qwen3.8 retains thinking blocks from all historical messages, maintaining a complete reasoning trace across the conversation. This behavior, known as preserved thinking, ensures full context continuity and is especially beneficial for agent scenarios where decision consistency and reduced redundant reasoning are critical. It also improves KV cache utilization, optimizing inference efficiency in both thinking and non-thinking modes.

If you prefer to retain only the thinking blocks from the latest user message, you can disable this behavior by setting `preserve_thinking` to `False`:

```python
from openai import OpenAI

# Configured by environment variables
client = OpenAI()
messages = [...]
chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
    extra_body={
        "chat_template_kwargs": {"preserve_thinking": False},
    },
)
print("Chat response:", chat_response)
```

> If you are using APIs from Qwen Cloud, in addition to changing `model`, please use `"preserve_thinking": False` directly instead of wrapping it in `chat_template_kwargs`.

## [](#best-practices)Best Practices

To achieve optimal performance, we recommend the following settings:

1.  **Sampling Parameters**: We suggest using the following sets of sampling parameters:
    
    -   Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`
    -   Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`
    
    For supported frameworks, you can adjust the `presence_penalty` parameter between 0 and 2 to reduce endless repetition. However, using a higher value may occasionally result in language mixing and a slight decrease in model performance.
    
2.  **Adequate Output Length**: To optimize performance on agentic tasks, we recommend allocating sufficient output length to allow the model to generate detailed and comprehensive responses. For frameworks that support separate token limits for internal reasoning and final outputs, we suggest the following configuration within the 1M context length:
    
    -   Reasoning Content: Set the maximum output length to 262,144 tokens.
    -   Final Response: Set the maximum output length to 131,072 tokens.
    
    These settings provide the necessary capacity for complex reasoning while ensuring ample space for high-quality final deliverables.
    
3.  **Processing Ultra-Long Texts**: Qwen3.8-27B natively supports context lengths of up to 262,144 tokens. For long-horizon tasks where the total length (including both input and output) exceeds this limit, we recommend using RoPE scaling techniques to handle long texts effectively, e.g., YaRN.
    
    YaRN is currently supported by several inference frameworks, e.g., vLLM, SGLang, and TokenSpeed. In general, there are two approaches to enabling YaRN for supported frameworks:
    
    -   Modifying the model configuration file:
        
        In the `config.json` file, change the `rope_parameters` fields in `text_config` to:
        
        ```json
        {
            "mrope_interleaved": true,
            "mrope_section": [
                11,
                11,
                10
            ],
            "rope_type": "yarn",
            "rope_theta": 10000000,
            "partial_rotary_factor": 0.25,
            "factor": 4.0,
            "original_max_position_embeddings": 262144,
        }
        ```
        
    -   Passing command line arguments:
        
        For vLLM, you can use
        
        ```shell
        VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 vllm serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1000000  
        ```
        
        For SGLang, you can use
        
        ```shell
        SGLANG_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 python -m sglang.launch_server ... --json-model-override-args '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --context-length 1000000
        ```
        
        For TokenSpeed, you can use
        
        ```shell
        TOKENSPEED_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 tokenspeed serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1000000  
        ```
        
    
    > All the notable open-source frameworks implement static YaRN, which means the scaling factor remains constant regardless of input length, **potentially impacting performance on shorter texts.** We advise modifying the `rope_parameters` configuration only when processing long contexts is required. It is also recommended to modify the `factor` as needed. For example, if the typical context length for your application is 524,288 tokens, it would be better to set `factor` as 2.0.
    
4.  **Long Video Understanding**: To optimize inference efficiency for plain text and images, the `size` parameter in the released `video_preprocessor_config.json` is conservatively configured. It is recommended to set the `longest_edge` parameter in the video\_preprocessor\_config file to 469,762,048 (corresponding to 224k video tokens) to enable higher frame-rate sampling for hour-scale videos and thereby achieve superior performance. For example,
    
    ```json
    {"longest_edge": 469762048, "shortest_edge": 4096}
    ```
    
    Alternatively, override the default values via engine startup parameters. For implementation details, refer to: [vLLM](https://github.com/vllm-project/vllm/pull/34330) / [SGLang](https://github.com/sgl-project/sglang/pull/18467).
    

## [](#citation)Citation

If you find our work helpful, feel free to give us a cite.

```bibtex
@misc{qwen38,
    title = {{Qwen3.8-Max}: A New Bar for Coding and Cowork},
    url = {https://qwen.ai/blog?id=qwen3.8},
    author = {{Qwen Team}},
    month = {August},
    year = {2026}
}
```

Downloads last month

2,090,699

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

28B params

Tensor type

BF16

·

Chat template

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

Featherless AI

[

Image-Text-to-Text

](/tasks/image-text-to-text "Learn more about image-text-to-text")

Examples

Input a message to start chatting with **Qwen/Qwen3.8-27B**.

Send

View Code Snippets

[Compare providers](/inference/models?model=Qwen%2FQwen3.8-27B)

## Model tree for Qwen/Qwen3.8-27B[](/docs/hub/model-cards#specifying-a-base-model)

Adapters

[38 models](/models?other=base_model:adapter:Qwen/Qwen3.8-27B)

Finetunes

[167 models](/models?other=base_model:finetune:Qwen/Qwen3.8-27B)

Merges

[4 models](/models?other=base_model:merge:Qwen/Qwen3.8-27B)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with Ollama")

[728 models](/models?other=base_model:quantized:Qwen/Qwen3.8-27B)

## Spaces using Qwen/Qwen3.8-27B 28

[

🌀

victor/Qwen3.8-27B-free-endpoint

](/spaces/victor/Qwen3.8-27B-free-endpoint)[

💻

apathy-exe/Qwen3.8-27B

](/spaces/apathy-exe/Qwen3.8-27B)[

🔓

JonathanColetti/Qwen3.8-27B-Uncensored-Demo

](/spaces/JonathanColetti/Qwen3.8-27B-Uncensored-Demo)[

⚗️

prithivMLmods/Qwen3.8-27B-Object-Detection

](/spaces/prithivMLmods/Qwen3.8-27B-Object-Detection)[

🚀

llamameta/qwen3.8-27b-benchmaxx

](/spaces/llamameta/qwen3.8-27b-benchmaxx)[

🌀

Lajid/Qwen3.8-27B-free-endpoint

](/spaces/Lajid/Qwen3.8-27B-free-endpoint)[

📊

EuroEval/euroeval\_leaderboard

](/spaces/EuroEval/euroeval_leaderboard)[

⚡

akhaliq/Qwen3.8-27B

](/spaces/akhaliq/Qwen3.8-27B)\+ 23 Spaces \+ 20 Spaces

## Collection including Qwen/Qwen3.8-27B

[

#### Qwen3.8

Collection

4 items • Updated 9 days ago • 400

](/collections/Qwen/qwen38)

## Evaluation results[](https://huggingface.co/docs/hub/eval-results)

-   [Idavidrein/gpqa](/datasets/Idavidrein/gpqa) · Diamond [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22) [leaderboard](/datasets/Idavidrein/gpqa?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=diamond)
    
    [](/datasets/Idavidrein/gpqa?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=diamond&leaderboard_max_params=128B)89.2
    
-   [ScaleAI/SWE-bench\_Pro](/datasets/ScaleAI/SWE-bench_Pro) · SWE Bench Pro [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22) [leaderboard](/datasets/ScaleAI/SWE-bench_Pro?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=SWE_Bench_Pro)
    
    [](/datasets/ScaleAI/SWE-bench_Pro?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=SWE_Bench_Pro&leaderboard_max_params=128B)61.7 \*
    
-   [datacurve/deep-swe](/datasets/datacurve/deep-swe) · Deep Swe [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22) [leaderboard](/datasets/datacurve/deep-swe?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=deep_swe)
    
    [](/datasets/datacurve/deep-swe?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=deep_swe&leaderboard_max_params=128B)42.2
    
-   [internlm/WildClawBench](/datasets/internlm/WildClawBench) [leaderboard](/datasets/internlm/WildClawBench?eval_result=Qwen/Qwen3.8-27B)
-   Overall [View evaluation results](/Qwen/Qwen3.8-27B/discussions/110)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6432683407bad11484a68457/Q3Y0dL79GcsnaBCGRMooZ.png)
    
    source](https://internlm.github.io/WildClawBench)
    
    [](/datasets/internlm/WildClawBench?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=overall&leaderboard_max_params=128B)48.02
    
-   Avg Time [View evaluation results](/Qwen/Qwen3.8-27B/discussions/110)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6432683407bad11484a68457/Q3Y0dL79GcsnaBCGRMooZ.png)
    
    source](https://internlm.github.io/WildClawBench)
    
    [](/datasets/internlm/WildClawBench?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=avg_time&leaderboard_max_params=128B)516
    
-   [cais/hle](/datasets/cais/hle) · Hle [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22)
    
    [](/datasets/cais/hle?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=hle&leaderboard_max_params=32B)30.8 \*
    
-   [claw-eval/Claw-Eval](/datasets/claw-eval/Claw-Eval) · Multimodal [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22) [leaderboard](/datasets/claw-eval/Claw-Eval?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=multimodal)
    
    [](/datasets/claw-eval/Claw-Eval?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=multimodal)57.4 \*
    

Expand 1 benchmark

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Build · Claude Sonnet 5 · 21.8s)

_Thinking:_



## Qwen3.8-27B — Model Summary

**Architecture**
- Causal LM with vision encoder (native image + video understanding), dense (not MoE), Apache 2.0 license
- 27B language-model params (28B total on disk, BF16 safetensors)
- Hidden dim 5120, 64 layers, hybrid layout: 16× (3× Gated DeltaNet→FFN → 1× Gated Attention→FFN)
- MTP (multi-token prediction) trained
- Built on the Qwen3.5 architectural foundation, successor generation after Qwen3.6/3.7

**Context length**
- **Native: 262,144 tokens (256K)**
- **Extensible to 1,000,000 tokens (1M) via YaRN** (supported in vLLM, SGLang, TokenSpeed) — requires editing `rope_parameters` in `config.json` or passing `--hf-overrides`/equivalent CLI flags
- The hosted **Qwen Cloud** version is stated to ship with **1M context by default** (no manual YaRN config needed) — but that service is listed as "coming soon"

**Thinking control**: thinking mode on by default, toggle via `enable_thinking`, reasoning depth tunable via `reasoning_effort` (`xhigh`/`medium`/`low`), and `preserve_thinking` keeps reasoning traces across multi-turn agentic conversations.

## Qwen3.8-27B vs Qwen3.6-27B

Per the model card's own benchmark table, Qwen3.8-27B improves on Qwen3.6-27B across essentially every metric shown — the gains are largest on agentic/coding and agentic-multimodal tasks:

| Benchmark | Qwen3.6-27B | Qwen3.8-27B | Δ |
|---|---|---|---|
| Terminal-Bench 2.1 (Terminus) | 63.4 | 73.0 | +9.6 |
| SWE-bench Pro | 53.5 | 61.7 | +8.2 |
| DeepSWE 1.1 | 13.3 | 42.2 | +28.9 |
| QwenSWEBench | 49.3 | 79.0 | +29.7 |
| JobBench | 21.8 | 33.4 | +11.6 |
| GPQA Diamond | 87.8 | 89.2 | +1.4 |
| HLE | 24.0 | 30.8 | +6.8 |
| LiveCodeBench v6 | 83.9 | 90.3 | +6.4 |
| OSWorld-Verified (computer use) | 63.9 | 84.3 | +20.4 |
| WebArena-Verified (browser use) | 48.8 | 64.8 | +16.0 |
| AndroidWorld (mobile use) | 70.3 | 81.9 | +11.6 |
| SWE-MM (multimodal SWE) | 25.7 | 38.6 | +12.9 |
| Vision2Web | 45.0 | 62.9 | +17.9 |

**Bottom line**: Qwen3.8-27B is a straightforward upgrade over Qwen3.6-27B at the same parameter count/dense architecture — biggest jumps are in long-horizon agentic coding (DeepSWE, QwenSWEBench) and GUI/agentic-multimodal tasks (OSWorld, WebArena, AndroidWorld, Vision2Web), with smaller but still consistent gains on general reasoning (GPQA, HLE). The card doesn't state whether native context length changed vs. 3.6 (both appear to target the same 256K native / 1M extended range via YaRN).

One caution: several of the comparison points on this page (e.g., "Qwen3.7-Plus," "Opus4.6 Max," a GPT‑5.4 judge model, an August 2026 citation date) are outside anything I can independently verify — I'm reporting exactly what the fetched page states, not confirming it against other sources.

---

## User

I want to use this with a larger context size I need ideally 768k context size. How do I do this ? can I do this with Ollama? Or do I have to use a different framework?

---

## Assistant (Build · Claude Sonnet 5 · 48.7s)

_Thinking:_



## Short answer: yes, but via vLLM/SGLang/TokenSpeed with YaRN — not (reliably) via Ollama

The model card only documents the long-context extension (YaRN) for **vLLM, SGLang, and TokenSpeed**. Ollama isn't mentioned anywhere in the card's context-extension instructions.

### Why Ollama is the weaker option here

- Ollama runs on **llama.cpp / GGUF**. HF does show GGUF-compatible quantizations exist for this model (Ollama/llama.cpp/LM Studio/Jan icons appear under "Quantizations"), so basic inference at whatever context the GGUF was built with will likely work.
- But Qwen3.8-27B uses a **non-standard hybrid architecture**: interleaved Gated DeltaNet (linear attention) + Gated Attention blocks, plus a `partial_rotary_factor=0.25` (only 64 of 256 head dims get RoPE) and `mrope_interleaved`/`mrope_section` settings. That's a much more specific rotary setup than plain YaRN.
- The YaRN config the card gives you (`mrope_interleaved`, `mrope_section`, `rope_type: yarn`, `partial_rotary_factor`, `factor`, `original_max_position_embeddings`) is applied via each framework's own `text_config.rope_parameters` override mechanism. llama.cpp/Ollama has its own, separate YaRN implementation (GGUF metadata `rope.scaling.*` + Modelfile `PARAMETER`), and there's no guarantee it correctly reproduces this model's specific mrope/partial-rotary math — hybrid linear-attention architectures like this (similar lineage to Qwen3-Next) typically need dedicated llama.cpp graph work before scaled/extended context behaves correctly, and that support usually lags official releases.
- Net effect: even if Ollama loads the GGUF and runs at native/default context, pushing it out to 768K via `num_ctx` + rope overrides is unofficial, untested by Qwen, and the model's Gated DeltaNet + partial-rotary attention makes silent correctness bugs more likely than with a standard dense-attention model.

**Recommendation for this use case: use vLLM** (the framework the Qwen team actually validated this on, and the one your project already standardizes on for DeepSeek-V4-Flash).

### How to get 768K with vLLM

768K = 786,432 tokens = exactly 3× the native 262,144 context, so `factor: 3.0` (matches the card's own example pattern: 524,288 → factor 2.0).

```bash
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 vllm serve "Qwen/Qwen3.8-27B" \
  --tensor-parallel-size 4 \
  --hf-overrides '{"text_config": {"rope_parameters": {
      "mrope_interleaved": true,
      "mrope_section": [11, 11, 10],
      "rope_type": "yarn",
      "rope_theta": 10000000,
      "partial_rotary_factor": 0.25,
      "factor": 3.0,
      "original_max_position_embeddings": 262144
  }}}' \
  --max-model-len 786432
```

Equivalent for SGLang, swap in `SGLANG_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1` + `--json-model-override-args` + `--context-length 786432` with the same `rope_parameters` block.

### Two things worth flagging before you commit to 768K

1. **Static YaRN caveat from the card**: all these open frameworks implement *static* YaRN — the scaling factor is fixed regardless of actual input length, which can hurt performance on shorter prompts once you set `factor=3.0`. Only set this if 768K is genuinely your typical working context, not just a ceiling.
2. **KV cache memory**: 768K tokens of KV cache on a 27B dense model (24 attention heads, 4 KV heads, head_dim 256, but only the Gated Attention blocks — 1 in 4 layers — carry standard KV cache; the Gated DeltaNet blocks use a much cheaper recurrent state instead) will still be substantial. Worth doing a VRAM budget check across your 4× RTX Pro 6000 (384GB total) before committing to 768K in production — same category of check your feature README already flags for the 350–370K target on DeepSeek-V4-Pro.

If you want, I can help size the KV-cache/VRAM budget for 768K context at TP=4 before you deploy it.

---

## User

I want to create a new feature "Use qwen3.8 with large context size". For this create a feature like you can see in .specmgr/feat/feat-2. There is a template in the .specmgr folder. What do you need to continue?

---

## Assistant (Plan · Claude Sonnet 5 · 5.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "find /home/user/src/biz.dfch.LlmOps/.specmgr -maxdepth 3 -type d | sort"
}
```

**Output:**
```
/home/user/src/biz.dfch.LlmOps/.specmgr
/home/user/src/biz.dfch.LlmOps/.specmgr/feat
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/bin
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin
/home/user/src/biz.dfch.LlmOps/.specmgr/_template
/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1

```

**Tool: glob**

**Input:**
```json
{
  "pattern": ".specmgr/feat/feat-2*/README.md"
}
```

**Output:**
```
No files found
```

---

## Assistant (Plan · Claude Sonnet 5 · 2.5s)

**Tool: bash**

**Input:**
```json
{
  "command": "find /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment -maxdepth 2 -type f | sort; echo \"---TEMPLATE---\"; find /home/user/src/biz.dfch.LlmOps/.specmgr/_template -maxdepth 3 -type f | sort"
}
```

**Output:**
```
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/article-draft.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/article-draft og.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/00-download-glm-quants.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/01-clone-llama-cpp-dsa.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/02-build-llama-cpp-dsa.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/03-spike-glm-dsa.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/04-dl-status.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/05-spike-glm-dsa-strong.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/06-measure-kv-cache.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/07-measure-kv-cache-768-896.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/08-llama-glm-5.2.service
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/09-install-llama-glm-service.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/10-tune-vm-swappiness.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/11-benchmark-load-mode.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/12-setup-user-systemd-groups.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/13-enable-user-lingering.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/14-smoke-test-glm-service.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/15-measure-pcie-vs-throughput.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/16-benchmark-q4-vs-q5.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/17-tune-q4-placement.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/18-tune-q4-kv-cache-768-896.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/19-llama-glm-5.2-q4.service
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/20-install-llama-glm-q4-service.sh
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/followup-comment-draft.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/opencode-provider-snippet-glm-5.2.jsonc
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/session-ses_fe1b-feat-2-04.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/session-ses_fe1b-feat-2-05.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/session-ses_fe27-feat-2-03.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/session-ses_fe46-feat-2-02.md
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/session-ses_fe6b-feat-2-01.md
---TEMPLATE---
/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md

```

---

## Assistant (Plan · Claude Sonnet 5 · 2.8s)

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md</path>
<type>file</type>
<content>
1: ---
2: id: feat-NNN-slug
3: version: 1.0.0
4: status: planning
5: created: YYYY-MM-DD
6: updated: YYYY-MM-DD
7: ---
8: 
9: # Feature: [Feature Title]
10: 
11: ## Plan
12: 
13: ### Overview
14: 
15: Brief description of what this feature does and why it matters.
16: 
17: ### Requirements
18: 
19: - REQ-001: [Functional requirement]
20: - REQ-002: [Non-functional requirement]
21: - REQ-003: [Constraint or dependency]
22: 
23: ### Acceptance Criteria
24: 
25: - [ ] ACC-001: Verifies REQ-001 — [testable condition]
26: - [ ] ACC-002: Verifies REQ-002 — [testable condition]
27: - [ ] ACC-003: Verifies REQ-003 — [testable condition]
28: 
29: ### Scope
30: 
31: What is included in this feature:
32: - Item 1
33: - Item 2
34: 
35: What is explicitly out of scope:
36: - Item A
37: - Item B
38: 
39: ### Dependencies
40: 
41: - Depends on: [other feat-NNN-slug, ADR id, or external]
42: - Blocks: [other feat-NNN-slug]
43: 
44: ### Design Notes
45: 
46: Any architectural decisions, patterns, or design rationale relevant to this feature.
47: 
48: ### Related ADRs
49: 
50: - [ADR id]: [Title]
51: - [ADR id]: [Title]
52: 
53: ### Task List
54: 
55: Single, canonical breakdown of work phases and tasks. Status lives on the
56: task itself — there is no separate "planned" vs. "executed" list to keep in
57: sync; a task's line *is* its current status. Update it in place as work
58: progresses (edit, don't duplicate).
59: 
60: #### Phase 1: [Phase name]
61: - [x] Task 1.1: [description] — depends on: none — status: done (2026-08-01)
62: - [ ] Task 1.2: [description] — depends on: Task 1.1 — status: in-progress, ETA 2026-08-10
63: - [ ] Task 1.3: [description] — depends on: Task 1.2 — status: blocked (see Blockers)
64: 
65: #### Phase 2: [Phase name]
66: - [ ] Task 2.1: [description] — depends on: Task 1.3 — status: not-started
67: - [ ] Task 2.2: [description] — depends on: Task 2.1 — status: not-started
68: 
69: **Note:** If a task's scope changes mid-flight, edit its description in place;
70: rely on git history (`git log -p` on this file) to recover what was
71: originally planned, rather than keeping a second copy of the task around.
72: 
73: ## Progress
74: 
75: ### Current Status
76: 
77: **As of [YYYY-MM-DD]**: [Brief status summary]
78: 
79: ### Blockers
80: 
81: - [ ] Blocker 1 — [description, impact, mitigation]
82: - [ ] Blocker 2 — [description, impact, mitigation]
83: 
84: (Remove this section if no blockers.)
85: 
86: ### Recent Updates
87: 
88: If this section grows too long, move older entries to `history.md` in this
89: same folder and leave a pointer here, e.g.:
90: `See history.md for updates before YYYY-MM-DD.`
91: 
92: #### [YYYY-MM-DD]
93: - Completed: [what was done]
94: - Next: [what comes next]
95: - Notes: [any relevant context]
96: 
97: #### [YYYY-MM-DD]
98: - Completed: [what was done]
99: - Next: [what comes next]
100: - Notes: [any relevant context]
101: 
102: ### Decisions Made
103: 
104: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
105: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
106: 
107: ### Related PRs / Commits
108: 
109: - [PR #NNN](link): [description]
110: - [Commit hash](link): [description]

(End of file - total 110 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-19
3: id: feat-2-glm-5.2-onprem-deployment
4: status: planning
5: updated: 2026-08-20
6: version: 1.0.0
7: ---
8: 
9: # Feature: On-prem GLM-5.2 serving for OpenCode + OpenWebUI
10: 
11: ## Plan
12: 
13: ### Overview
14: 
15: Deploy GLM-5.2 (`zai-org/GLM-5.2`, MIT) on the existing on-prem Dell 7960T
16: behind an OpenAI-compatible API, for use as a coding model via OpenCode and
17: OpenWebUI. This is the alternative/fallback model deferred from `feat-1`
18: (DeepSeek-V4). Quality is the priority over speed. GLM-5.2 is a 744B-param
19: MoE (40B active), 1M context; official Z.ai weights are BF16 (~1.5 TB),
20: which does NOT fit in the box's 384 GB VRAM nor in the 896 GB VRAM+RAM pool
21: at native precision — so a quantized build is required. Because no native
22: sub-BF16 checkpoint exists, GGUF requantization is explicitly accepted for
23: this model (the `feat-1` "no requant" rule is DeepSeek-only and does not
24: apply here); unsloth ships day-zero Dynamic GGUFs at `unsloth/GLM-5.2-GGUF`.
25: 
26: Crucially, this box is heavily over-provisioned relative to unsloth's stated
27: minimums (their reference config runs the 2-bit quant on a single 24 GB GPU
28: 
29: - 256 GB RAM). With 896 GB total (384 VRAM + 512 RAM), the **near-lossless
30:   4-bit (`UD-Q4_K_XL`, 372-475 GB) and 5-bit (`UD-Q5_K_XL`, 570 GB)** quants
31:   both fit comfortably — so, unlike DeepSeek-V4-Pro, GLM-5.2 does NOT force a
32:   lossy precision compromise. The model repo and the chosen quant are both
33:   pinned to a specific revision for reproducibility.
34: 
35: ### Requirements
36: 
37: - REQ-001: Serve GLM-5.2 via an OpenAI-compatible API
38:   (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
39:   Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
40: - REQ-002: Serve GLM-5.2 without adding new hardware and without networking
41:   in the DGX Spark
42: - REQ-003: The endpoint must support real coding workloads reaching at
43:   least 350-370K tokens of context (GLM-5.2 advertises a solid 1M-token
44:   context; 350-370K is the minimum bar for parity with `feat-1`)
45: - REQ-004: The endpoint must support tool-calling (required for OpenCode
46:   agentic use) and expose GLM-5.2's flexible thinking-effort/reasoning
47:   modes correctly. GLM-5.2 has 3 modes — non-thinking, thinking-high,
48:   thinking-max — toggled via `--chat-template-kwargs`:
49:   `'{"reasoning_effort":"max"}'`, `'{"reasoning_effort":"high"}'`, or
50:   `'{"enable_thinking":false}'` to disable
51: - REQ-005: Maximize model quality within the hardware envelope; inference
52:   speed is explicitly secondary. Because this box fits the near-lossless
53:   4-bit/5-bit quants (see Design Notes), the target is `UD-Q5_K_XL`
54:   (preferred) or `UD-Q4_K_XL` (fallback) — NOT the lossy 1-2 bit levels
55: - REQ-006: GGUF requantization is ACCEPTED for GLM-5.2 (carried over from
56:   the 2026-08-19 `feat-1` decision, scoped to this model only). GLM-5.2 has
57:   no native sub-BF16 checkpoint that fits this hardware, so a quantized
58:   build (GGUF, e.g. unsloth Dynamic GGUF, or an equivalent FP8/FP4
59:   checkpoint) is required, not merely tolerated. Prefer the highest-quality
60:   quant that fits the context target — the box's memory allows near-lossless
61:   4-bit/5-bit, so there is no need to drop to a lossy level.
62: - REQ-007: Pin GLM-5.2 (and any quantized derivative) to a specific
63:   Hugging Face revision/commit (not "latest") for reproducibility across
64:   redeploys
65: - REQ-008: The endpoint runs unauthenticated (anonymous, no API-key/auth
66:   layer) — accepted risk, internal network only (same posture as `feat-1`)
67: - REQ-009: The engine runs as a managed service (systemd unit or
68:   equivalent), started/stopped via the service manager — no ad-hoc
69:   foreground processes, including during testing
70: - REQ-010: Establish whether GLM-5.2's DSA (DeepSeek Sparse Attention /
71:   IndexShare) decode path produces correct output on this box's SM120
72:   (RTX Pro 6000 Blackwell) GPUs before committing to a full deployment —
73:   this is the same *class* of sparse-attention kernel that blocks
74:   `feat-1` Task 1.4, so it must be de-risked early, not assumed working
75: - REQ-011: If llama.cpp/`llama-server` is chosen as the engine (its GGUF
76:   CUDA path is separate from vLLM's broken SM120 sparse-attention kernels,
77:   making it a strong Plan B), its OpenAI-compatible tool-calling must be
78:   explicitly verified against OpenCode's agentic use before commit —
79:   llama.cpp tool-calling is historically weaker than vLLM/SGLang and is a
80:   known risk against REQ-004
81: 
82: ### Acceptance Criteria
83: 
84: - [ ] ACC-001: Verifies REQ-001/REQ-002 — GLM-5.2 running on the Dell 7960T,
85:   reachable via `/v1/chat/completions`, no new hardware, DGX Spark unused
86: - [x] ACC-002: Verifies REQ-010 — a short smoke test at temperature=0
87:   produces coherent, non-degenerate output on SM120 (explicitly checked
88:   against the `feat-1` Task 1.4 failure signature: NOT a single frozen
89:   token repeated at every decode position) — PASS 2026-08-19
90:   (`bin/05-spike-glm-dsa-strong.sh`, `llama.cpp`/`UD-IQ1_S`): 3 of 4 cases
91:   (`enable_thinking:false`) reached a finished, non-truncated answer —
92:   `"Hello!"`, `"Paris"` (factually correct), and a correct recursive
93:   Python `factorial()` — each run TWICE at temperature=0 and byte-identical
94:   both times (rules out flaky/intermittent failure, not just a lucky single
95:   run). The 4th case (default thinking mode, 600 tokens) produced a
96:   coherent, structured reasoning trace with no frozen-token pattern, just
97:   still truncated (GLM-5.2 defaults to `reasoning_effort: max`, needs an
98:   even larger budget or an explicit lower effort level to finish — separate
99:   from REQ-010 correctness). `OVERALL: no degenerate/suspicious/ non-deterministic results found`
100: - [ ] ACC-003: Verifies REQ-003 — empirical test confirms the endpoint
101:   handles a 350-370K-token coding prompt without OOM
102: - [ ] ACC-004: Verifies REQ-004/REQ-011 — tool-call verified via curl smoke
103:   test then a real OpenCode agentic session; all 3 reasoning modes
104:   (`reasoning_effort` max/high and `enable_thinking:false`) confirmed to
105:   toggle correctly. If the engine is llama.cpp, tool-calling is explicitly
106:   re-verified (REQ-011 risk) — **curl smoke-test half PASSED 2026-08-20**
107:   (Task 2.4, `bin/14-smoke-test-glm-service.sh`): all 3 reasoning modes
108:   produced coherent, non-degenerate, non-truncated (`finish_reason: stop`)
109:   output, and the tool-calling case emitted a well-formed
110:   `tool_calls[].function` block (`get_weather`, `arguments: {"location":"Paris"}`) — REQ-011's llama.cpp risk did NOT materialize on this
111:   smoke test. **Still open: the real OpenCode agentic session** (deferred
112:   to Task 2.6/2.7 once OpenCode is wired up) — this checkbox stays
113:   unchecked until that half also passes
114: - [x] ACC-005: Verifies REQ-005/REQ-006 — the chosen quant is recorded
115:   (target `UD-Q5_K_XL`, else `UD-Q4_K_XL`), with a one-line rationale for
116:   why it is the highest-quality option that still meets REQ-003's context
117:   target on this hardware (both are near-lossless per unsloth's KLD data)
118:   — PASS 2026-08-20 (Task 2.2): **`UD-Q5_K_XL` confirmed as the production
119:   quant.** Rationale: under the validated `--n-cpu-moe 54 --tensor-split 54,9,8,8` placement, Task 2.1 directly measured `ctx=524,288` (512K
120:   tokens, > REQ-003's 370K upper bound) succeeding with ≥25.5 GiB (≥26.9%
121:   of 97,288 MiB) free on the worst-margined GPU (CUDA1) — a measured floor
122:   that, by monotonicity of context-size memory use, guarantees at least
123:   as much headroom at the actual 350-370K target (a linear-fit projection
124:   puts it slightly higher, ~27.7 GiB/~28%, consistent with this floor).
125:   Both comfortably clear a ≥15%-or-≥10 GiB per-GPU safety-margin policy —
126:   so the highest-quality near-lossless
127:   option fits with room to spare and there is no need to drop to the
128:   lossier `UD-Q4_K_XL` fallback. See Task 2.2 for the full per-GPU
129:   extrapolation.
130: - [ ] ACC-006: Verifies REQ-007 — deployment config records the exact HF
131:   revision/commit hash used for the base model and for the quant used
132: - [ ] ACC-007: Verifies REQ-008 — endpoint reachable without credentials
133:   from the internal network, confirmed intentional (not an oversight)
134: - [ ] ACC-008: Verifies REQ-009 — engine installed as a systemd service;
135:   started/stopped/restarted exclusively via `systemctl` throughout testing
136:   and production use
137: - [ ] ACC-009: User runs the SAME coding-task examples used for `feat-1`
138:   (see `feat-1` ACC-010 / Task 1.7) against this endpoint, to compare
139:   GLM-5.2 quality directly against DeepSeek-V4 on identical inputs
140: 
141: ### Scope
142: 
143: What is included in this feature:
144: 
145: - An SM120 correctness spike for GLM-5.2's DSA decode path BEFORE full
146:   deployment (REQ-010) — reusing `feat-1`'s hard-won SM120 diagnostics
147: - Deployment of GLM-5.2 on the Dell 7960T as a systemd service, using a
148:   quantized + GPU/CPU-RAM-hybrid configuration
149: - Choosing and pinning a specific quant (GGUF or FP8/FP4 checkpoint) at a
150:   fixed HF revision
151: - OpenWebUI and OpenCode configured against the endpoint
152: - Empirical KV-cache/context validation at 350-370K tokens
153: - Direct quality comparison against `feat-1`'s DeepSeek-V4 using the same
154:   coding-task examples
155: 
156: What is explicitly out of scope:
157: 
158: - Any use of the DGX Spark for this deployment (excluded per the same
159:   user decision as `feat-1`)
160: - Acquiring additional hardware
161: - Authentication/access-control layer (explicitly accepted as anonymous)
162: - Fine-tuning or training GLM-5.2 (serving only)
163: - Retiring or changing the `feat-1` DeepSeek-V4 deployment — the two
164:   coexist; this feature does not depend on `feat-1` succeeding
165: 
166: ### Dependencies
167: 
168: - Depends on: a serving engine with confirmed GLM-5.2 (`glm_moe_dsa`)
169:   support AND a working SM120 code path for its DSA sparse-attention
170:   decode — candidates per the vendor card: vLLM v0.23.0+, SGLang
171:   v0.5.13.post1+, KTransformers v0.5.12+; GPU driver/CUDA compatibility for
172:   RTX Pro 6000 Blackwell (already validated in `feat-1` Task 0.2: driver
173:   610.57.04, CUDA 13.3); sufficient local disk on the Dell 7960T for the
174:   weight set + quant (`feat-1` Task 0.1: /data has 9.3 TB free)
175: - Related (not a hard dependency): `feat-1`'s in-flight SM120
176:   sparse-attention-decode diagnostic (Task 1.4). If `feat-1` establishes
177:   that the SM120 sparse-attention problem is engine-specific (e.g. vLLM
178:   fails but SGLang works), that finding directly informs REQ-010 here and
179:   may let this feature skip its own spike. UPDATE 2026-08-19: `feat-1`
180:   confirmed its bug is vLLM/FlashInfer's `FLASHINFER_MLA_SPARSE_DSV4`
181:   specifically (all local hypotheses ruled out, filed upstream as
182:   vllm-project/vllm#52938), and this feature's own Task 1.2 spike (run
183:   independently, not skipped) found `llama.cpp` producing coherent output
184:   on the same SM120 GPUs — the two findings corroborate each other toward
185:   "engine-specific," not "SM120-fundamental."
186: - Blocks: none
187: 
188: ### Design Notes
189: 
190: - **Model facts (verified from HF + unsloth docs 2026-08-19)**:
191:   `zai-org/GLM-5.2`, MIT license, **744B params / 40B active** (MoE),
192:   tensor type BF16/F32, architecture tag `glm_moe_dsa` (MoE with DeepSeek
193:   Sparse Attention). Advertises a "solid 1M-token context" (max
194:   `1,048,576`), flexible coding thinking-effort levels, and IndexShare
195:   (reuses one indexer across every four sparse-attention layers, ~2.9x
196:   fewer per-token FLOPs at 1M context) plus an improved MTP layer for
197:   speculative decoding. `unsloth/GLM-5.2` is a repackage of the same base
198:   (`base_model: zai-org/GLM-5.2`), BF16; `unsloth/GLM-5.2-GGUF` holds the
199:   Dynamic GGUF quants.
200: - **Quant memory table (unsloth, total = VRAM + RAM or unified)**:
201:   1-bit `UD-IQ1_S` 223 GB · 2-bit `UD-IQ2_M` 245 GB · 3-bit 290-360 GB ·
202:   4-bit `UD-Q4_K_XL` 372-475 GB · 5-bit `UD-Q5_K_XL` 570 GB · 8-bit
203:   `UD-Q8_K_XL` 810 GB. Full BF16 is ~1.5 TB.
204: - **Quant quality (unsloth KLD / top-1 analysis)**: 4-bit and 5-bit are
205:   "mostly lossless" (99.9% KLD); 2-bit ≈ 82% top-1, 1-bit ≈ 76% top-1
206:   (and explicitly NOT "24% gibberish" — mostly filler/stop-word
207:   distribution shift). Larger quality uplift kicks in from 4-bit onward.
208: - **Why quantization is required (but NOT a painful compromise here)**:
209:   744B BF16 (~1.5 TB) exceeds both 384 GB VRAM and the 896 GB VRAM+RAM
210:   pool, so a quant is mandatory. BUT this box is far larger than unsloth's
211:   reference (single 24 GB GPU + 256 GB RAM runs 2-bit). At 896 GB total the
212:   near-lossless **5-bit `UD-Q5_K_XL` (570 GB)** fits with a VRAM+RAM hybrid
213:   split, and **4-bit `UD-Q4_K_XL` (372-475 GB)** fits even more comfortably
214:   (low end may fit VRAM-mostly). Target `UD-Q5_K_XL`, fall back to
215:   `UD-Q4_K_XL`; only drop lower if the 350-370K KV cache forces it. This is
216:   the opposite of DeepSeek-V4-Pro, which could not avoid a lossy trim.
217: - **Engine left open until the REQ-010 spike — now THREE candidates**:
218:   (1) **vLLM** — default (matches `feat-1` runbook), but `feat-1` has an
219:   OPEN SM120 sparse-attention decode bug (Task 1.4) and GLM-5.2's DSA path
220:   is the same kernel class, so NOT assumed to work; needs an FP8/FP4
221:   checkpoint, not GGUF. (2) **SGLang** — distinct SM120 code path, primary
222:   vLLM alternative. (3) **llama.cpp / `llama-server`** — the strongest
223:   SM120 Plan B: its GGUF CUDA kernels are a **completely separate codebase**
224:   from vLLM's FlashInfer sparse-MLA path, so it does not inherit the
225:   `feat-1` bug at all, and it directly consumes the unsloth Dynamic GGUFs.
226:   Its risk is weaker OpenAI-compatible tool-calling (REQ-011). KTransformers
227:   remains a hybrid-size option but is lower priority now that llama.cpp
228:   covers the GGUF-hybrid case with a simpler path.
229: - **This is a Pro-class deployment, not a Flash-class one** (quantized +
230:   VRAM/RAM hybrid), but — unlike `feat-1` Pro — the hardware headroom keeps
231:   it near-lossless. Reuse Phase 2 thinking from `feat-1`, not Phase 1.
232: - **Sampling settings (unsloth)**: default `temperature=1.0, top_p=0.95, min_p=0.01`; SWE-Bench-style `temperature=1.0, top_p=1.0`. Note the
233:   temp=0 greedy smoke test for ACC-002 is a diagnostic for the degenerate
234:   signature, not the production sampling config.
235: - **Reuse `feat-1` environment prep.** Disk (Task 0.1), GPU/driver/CUDA
236:   (Task 0.2), and HF tooling/token (Task 0.3) are already validated on this
237:   same box; do not repeat them, just reference them.
238: - **Same non-negotiables as `feat-1`**: pinned HF revision (REQ-007),
239:   anonymous internal-only endpoint (REQ-008), systemd-only operation
240:   (REQ-009).
241: - **Comparison is the point.** ACC-009 reuses the exact `feat-1`
242:   coding-task examples so GLM-5.2 vs DeepSeek-V4 is an apples-to-apples
243:   quality call on the user's real workloads.
244: 
245: ### Related ADRs
246: 
247: - None (infrastructure/deployment work, tracked in this repo using the
248:   feature-folder convention, same as `feat-1`)
249: 
250: ### Task List
251: 
252: #### Phase 0: Environment prep (mostly inherited from feat-1)
253: 
254: - [ ] Task 0.1: Confirm disk headroom for GLM-5.2 weights + quant on /data (feat-1 Task 0.1 already showed 9.3 TB free; re-check remaining after feat-1's DeepSeek downloads) — depends on: none — status: not-started
255: - [ ] Task 0.2: Reuse feat-1's validated GPU/driver/CUDA (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) — no new work unless a different engine needs a different toolchain — depends on: none — status: not-started
256: - [ ] Task 0.3: Reuse feat-1's HF access/token + download tooling (hf CLI, hf_transfer) — depends on: none — status: not-started
257: - [x] Task 0.4: Choose and record pinned HF revision/commit for `zai-org/GLM-5.2` (base) — depends on: Task 0.3 — status: done — pinned revision `b4734de4facf877f85769a911abafc5283eab3d9` (recorded 2026-08-19; not downloaded, base BF16 not needed for the GGUF path)
258: - [x] Task 0.5: Select the quant strategy + source and record its pinned revision. Default: unsloth Dynamic GGUF `UD-Q5_K_XL` (target) / `UD-Q4_K_XL` (fallback) from `unsloth/GLM-5.2-GGUF` for a llama.cpp/SGLang path; or an FP8/FP4 checkpoint if vLLM is chosen (vLLM does not consume GGUF) — depends on: Task 0.4 — status: done — pinned revision `abc55e72527792c6e77069c99b4cb7de16fa9f23` (recorded 2026-08-19); download kicked off out of order via `bin/00-download-glm-quants.sh` (see Decisions Made)
259: 
260: #### Phase 1: SM120 correctness spike (de-risk REQ-010 BEFORE full deploy)
261: 
262: - [ ] Task 1.1: Pick the engine(s) to spike and their GLM-5.2-supporting versions. Candidates in order of SM120-risk: llama.cpp/llama-server (separate GGUF CUDA path, does NOT inherit feat-1's vLLM sparse-attention bug — strongest Plan B), SGLang (distinct SM120 path), vLLM (default runbook but same broken kernel class as feat-1) — depends on: Task 0.4 — status: in-progress — llama.cpp picked as the lead spike candidate; dedicated checkout cloned+built at `/data/llama.cpp-dsa` (commit `ee4c505a4fb37be8ea37a78af272e74dad2835c1`, 2026-08-19) via `bin/01-clone-llama-cpp-dsa.sh` + `bin/02-build-llama-cpp-dsa.sh`, CUDA/SM120 confirmed linked (`CMAKE_CUDA_ARCHITECTURES` includes `120a-real`); done in parallel with the quant download while GPUs are still occupied by `feat-1`'s service, so Task 1.2 bring-up itself has not started yet
263: - [x] Task 1.2: Minimal short-context bring-up of GLM-5.2 on ONE engine at a small quant, temperature=0 greedy smoke test — check specifically for the feat-1 Task 1.4 degenerate signature (single frozen token at every decode position) — depends on: Task 1.1, Task 0.5 — status: done — 2026-08-19, `bin/03-spike-glm-dsa.sh`: `llama-server` (commit `ee4c505a4`) on `UD-IQ1_S`, all 4 GPUs (~50-53 GB VRAM each), `-c 4096`. Temp=0 greedy request produced coherent, grammatical chain-of-thought reasoning tokens (`The user wants me to say hello...`) with naturally varying logprobs (`-0.0000649` to `-1.126`) — NOT the feat-1 flat `-11.77`-at-every-position frozen-token signature. `finish_reason: length` with empty `message.content` is expected (GLM-5.2 defaults to thinking mode; 20-token budget was spent entirely on `reasoning_content`), not a failure. Decode ran at ~39 tok/s. Strengthened same-day via `bin/05-spike-glm-dsa-strong.sh`: multiple prompts (chit-chat/factual/code), `enable_thinking:false` to reach finished answers, each run twice for determinism — see ACC-002 for the full result. **REQ-010: llama.cpp's DSA decode path is correct on this box's SM120 GPUs.** Cross-reference: `feat-1` independently hit the same *class* of bug (vLLM's `FLASHINFER_MLA_SPARSE_DSV4` sparse-MLA decode produces the exact degenerate signature on these same SM120 GPUs, all local hypotheses ruled out, filed as upstream https://github.com/vllm-project/vllm/issues/52938) — this result is a second, independent data point supporting "vLLM/FlashInfer-specific bug," not "SM120 fundamentally broken for this kernel class"
264: - [x] Task 1.3: If output is degenerate on the first engine, repeat Task 1.2 on the next engine (llama.cpp vs SGLang vs vLLM is the SM120 sparse-attention discriminator that also informs feat-1) — depends on: Task 1.2 — status: not applicable — the first engine tried (llama.cpp) did NOT produce degenerate output (see Task 1.2/ACC-002), so the "repeat on next engine" condition never triggers. SGLang/vLLM not tested for GLM-5.2 — not needed since Phase 1's goal (find ONE working engine) is already met
265: - [x] Task 1.4: Record the outcome: which engine(s) produce coherent GLM-5.2 output on SM120, and whether the sparse-attention problem is engine-specific or SM120-fundamental (feed this back into feat-1 Task 1.4) — depends on: Task 1.2, Task 1.3 — status: done — **llama.cpp produces coherent GLM-5.2 DSA-decode output on this box's SM120 GPUs** (Task 1.2/ACC-002, strengthened via `bin/05-spike-glm-dsa-strong.sh`: deterministic, factually-correct, finished answers across chit-chat/factual/code prompts). Combined with `feat-1`'s finding that vLLM's `FLASHINFER_MLA_SPARSE_DSV4` produces the degenerate signature on the SAME GPUs for a different model (DeepSeek-V4-Flash, upstream vllm-project/vllm#52938), this is consistent with the sparse-attention problem being **engine-specific (vLLM/FlashInfer), not SM120-fundamental** — though this is corroborating evidence from a different model/engine pairing, not a direct reproduction of feat-1's exact bug. Fed back into `feat-1`'s README (cross-reference note under Task 1.4/Blockers)
266: 
267: #### Phase 2: Full deployment (only if Phase 1 yields a working engine)
268: 
269: - [x] Task 2.1: Measure actual KV-cache memory per 1K tokens at real context shapes on the chosen engine/quant — depends on: Task 1.4 — status: done — `bin/06-measure-kv-cache.sh` (adaptive ramp 4K→32K→128K→256K→512K). Two unsafe-config incidents hit and fixed before a run succeeded (see Decisions Made 2026-08-19 "KV-cache measurement MoE placement"): (1) `--cpu-moe` alone pushed ~500 GiB onto the 512 GiB system RAM, causing real swap growth — killed as a precaution (sweep attempt `2026-08-19T203936Z`, crashed at `ctx=4096`, no explicit error in the log — consistent with an external kill); (2) `--n-cpu-moe 41` alone let one GPU (CUDA2) get assigned a full ~132 GiB chunk of MoE weight before the CPU cutoff was applied, causing `cudaMalloc failed: out of memory ... buffer of size 138774596736` (sweep attempt `2026-08-19T212601Z`, crashed at `ctx=4096`). **Fixed run (`2026-08-19T220559Z`) succeeded on ALL 5 ramp sizes** with `--n-cpu-moe 54 --tensor-split 54,9,8,8`, no bisection needed:
270: 
271:   | ctx (tokens) | status | GPU mem (4 GPUs) | RAM used | load time |
272:   |---|---|---|---|---|
273:   | 4,096 | ok | 190,512 MiB (~186.1 GiB) | ~11.68 GiB | 1302 s |
274:   | 32,768 | ok | 193,520 MiB (~189.0 GiB) | ~11.66 GiB | 1212 s |
275:   | 131,072 | ok | 203,768 MiB (~199.0 GiB) | ~11.75 GiB | 1112 s |
276:   | 262,144 | ok | 217,462 MiB (~212.4 GiB) | ~11.58 GiB | 1322 s |
277:   | 524,288 | ok | 244,864 MiB (~239.1 GiB) | ~11.63 GiB | 1462 s |
278: 
279:   All 5 succeeded up to 524,288 tokens (512K) — well past the 350-370K
280:   REQ-003 target — no ceiling found in the tested range (this was a
281:   model-load/VRAM-allocation probe per context size, not a filled-context
282:   generation run; that end-to-end validation is still Task 2.5). Linear
283:   fit across all 5 points: `total_GiB ≈ 197.3 + 0.000102 × ctx_size` →
284:   **~0.104 GiB KV cache per 1K context tokens**, fixed
285:   (weights+runtime) footprint **~197.3 GiB**. Extrapolated: ctx=350,000 ≈
286:   233.0 GiB total, ctx=370,000 ≈ 235.0 GiB total — comfortably inside the
287:   896 GB (384 GB VRAM + 512 GB RAM) pool, and system RAM stayed flat at
288:   ~11.6-11.8 GiB throughout (the `--tensor-split 54,9,8,8` placement keeps
289:   nearly everything on GPU/VRAM). Full data: `bin/logs/2026-08-19T220559Z-kv-cache-sweep.{txt,json}` and per-context server logs `bin/logs/2026-08-19T220559Z-kv-ctx*.log`.
290: 
291: - [x] Task 2.2: Confirm the highest-quality quant that reliably supports 350-370K context with safe margin, based on Task 2.1 (start from UD-Q5_K_XL @ 570 GB in the 896 GB pool; step to UD-Q4_K_XL only if KV headroom demands) — depends on: Task 2.1 — status: done — 2026-08-20. Task 2.1's aggregate numbers (~233-235 GiB @ 350-370K vs the 896 GB pool) are necessary but not sufficient, since `--tensor-split 54,9,8,8` splits model weight AND KV-cache growth unevenly per GPU (each hard-capped at 97,288 MiB) — so the real gate is per-GPU headroom, not the pool sum. Per-GPU `memory breakdown` lines were pulled from all 5 Task 2.1 logs.
292: 
293: **Primary evidence — measured floor, no extrapolation needed:** Task 2.1
294: already directly measured `ctx=524,288` (512K tokens, `status=ok` on all
295: 4 GPUs), and 524,288 > 370,000 (REQ-003's upper bound). Since
296: KV-cache/compute-buffer memory use is monotonically non-decreasing in
297: context size, the *measured* per-GPU margin at 512K is a guaranteed
298: floor for the actual 350-370K target — stronger evidence than a
299: projection past the tested range:
300: 
301: | GPU | free @ ctx=524,288 (measured) | % free |
302: |---|---|---|
303: | CUDA0 | 38,717 MiB (~37.8 GiB) | 39.80% |
304: | **CUDA1 (worst)** | **26,153 MiB (~25.5 GiB)** | **26.89%** |
305: | CUDA2 | 33,686 MiB (~32.9 GiB) | 34.63% |
306: | CUDA3 | 45,727 MiB (~44.7 GiB) | 47.00% |
307: 
308: Worst case CUDA1 (holds the most static MoE weight, 62,690 MiB) still
309: retains ~26.9% (~25.5 GiB) free at a context size *larger* than the
310: target — so the true 370K margin is guaranteed to be at least this good.
311: 
312: **Secondary evidence — linear regression, for color only:** the same 5
313: log points, regressed (free MiB vs ctx) per GPU, project CUDA1's margin
314: at the *actual* 370K target at ~27.7 GiB (~28%) free — consistent with
315: (and, as expected, slightly better than) the measured 512K floor above,
316: confirming monotonicity. CUDA0 (assigned the largest KV-cache growth
317: share) closes its margin fastest as context grows but stays ahead of
318: CUDA1 throughout the tested range.
319: 
320: Both figures comfortably clear an adopted safety-margin policy of
321: **≥15% free VRAM per GPU, or ≥10 GiB absolute, whichever is greater**,
322: at the 350-370K target (covers production extras Task 2.1's load-only
323: probe didn't exercise: larger batch sizes, the prompt cache seen enabled
324: at 8,192 MiB, OpenCode tool-call payloads, OS/driver overhead).
325: **Decision: keep `UD-Q5_K_XL`** (near-lossless, 99.9% KLD) as the
326: production quant under the validated `--n-cpu-moe 54 --tensor-split   54,9,8,8` placement; `UD-Q4_K_XL` fallback is not needed for this
327: hardware/placement combo (see ACC-005 for the recorded rationale, and
328: Decisions Made for the safety-margin policy).
329: 
330: - [x] Task 2.2.1: Benchmark `--load-mode none` (direct/eager read) vs the `mmap` default for `UD-Q5_K_XL` cold-load wall-clock time — run BEFORE Task 2.3's install, via the same kind of ad-hoc probe script used for Task 2.1/2.2 (not the installed systemd service), so the winning mode is baked into `bin/08-llama-glm-5.2.service` from the start instead of requiring an edit-and-reinstall cycle after the fact. Motivated by this box being power-cycled at the start of each ~8.4h working day, where the measured ~45-minute mmap cold load (`bin/logs/2026-08-20T055618Z-kv-ctx768000.log`) already costs ~9% of the day — depends on: Task 2.2 — status: done. **Result (2026-08-20, `bin/11-benchmark-load-mode.sh`, `bin/logs/2026-08-20T081824Z-load-mode-bench.{txt,json}`):** `--load-mode none` loaded in 1694s (~28.2m) vs. `mmap-default`'s 1842s (~30.7m) — **8% faster**, ~2.5 min saved per cold load. Per-GPU memory footprint (`common_memory_breakdown_print`) identical between modes, as expected — `--load-mode` only affects the CPU-side tensor-loading path, not GPU placement. **3 earlier attempts** (`07:23`, `09:40`, `10:12`) were killed within seconds each, before the silent tensor-copy phase even started — not a loader hang, just impatience meeting a loader with zero progress feedback for a multi-hundred-GB copy, compounded by a genuine confound: an `mdadm` RAID10 consistency check on `/data`'s `md126` array was competing for disk I/O (see Current Status/Decisions Made for the full incident); confirmed fully resolved by the time of the successful run (`sync_action: idle`, `mismatch_cnt: 0`) — nothing left to resume. **Caveat carried into the decision, not hidden:** the script doesn't drop the page cache between the two probes, and `mmap-default` ran first — some of the 8% gap could reflect residual cache warmth on the second probe rather than a purely structural effect; judged not worth a further ~1h re-test given the modest, directionally-expected result and the trade this was alwa... (line truncated to 2000 chars)
331: 
332: - [x] Task 2.3: Install the engine + GLM-5.2 as a systemd service with the chosen quant and GPU/CPU-RAM placement — depends on: Task 2.2, Task 2.2.1 — status: done — 2026-08-20: draft artifacts created — `bin/08-llama-glm-5.2.service` (systemd unit, `--ctx-size 768000` / `--n-cpu-moe 54 --tensor-split 54,9,8,8 --load-mode none`, port 8092, `--host 0.0.0.0`, `Restart=on-failure`, etc., mostly following feat-1's `vllm-deepseek-v4-flash.service` conventions where they still apply) and `bin/09-install-llama-glm-service.sh` (installer: copy + `daemon-reload`, deliberately NOT `enable` and NOT `start` — enabling is skipped on purpose, see below; starting is Task 2.4). **DECIDED (2026-08-20): install as a systemd `--user` unit** (`~/.config/systemd/user/llama-glm-5.2.service`, `systemctl --user ...`), NOT a system-wide unit — unlike `feat-1`'s vLLM service, so no `User=`/`Group=` and `sudo` is never needed for day-to-day `start`/`stop`/`restart`. **REVISED same day:** the real requirement is "keep running with no user logged in" (NOT "autostart at boot right now") — those need different, independently-controlled mechanisms: lingering (`loginctl enable-linger`, now **enabled** via `bin/13-enable-user-lingering.sh`) keeps `user`'s systemd --user manager alive without a session, while the unit itself is deliberately left **NOT enabled** so it does not autostart at boot (lingering + an enabled unit together WOULD autostart it — caught and corrected live on the box, see Decisions Made "lingering + no autostart" for the full incident/rationale). Once manually started (Task 2.4), it persists across logout; after a reboot it must be started again by hand. New **Task 2.3.2** (`bin/12-setup-user-systemd-groups.sh`, video/render groups, requires logout/login) and **Task 2.3.3** (`bin/13-enable-user-lingering.sh`, lingering — DONE, confirmed `Linger=yes`) added. **Not yet installed for production use** (loaded via `bin/09` as a dry-run check, but disabled/inactive) — **all three origi... (line truncated to 2000 chars)
333: 
334:   **Why the follow-up probe exists — "go for 1M" checked against the math first:** extending Task 2.2's per-GPU linear regressions to `ctx=1,048,576` (1M, GLM-5.2's advertised max) projects CUDA0 (the GPU with the steepest KV-cache-growth slope, ~66.3 MiB/1K tokens) down to only ~3.89 GiB (~4.1%) free — clearly below the adopted ≥15%/≥10 GiB safety-margin policy, and this is ~2x beyond the largest size Task 2.1 actually measured (524,288), so it's genuine extrapolation risk, not just a policy breach. Extending the same regression to intermediate sizes:
335: 
336:   | ctx (tokens) | CUDA0 free (projected) | vs. ≥15%/≥10 GiB policy |
337:   |---|---|---|
338:   | 768,000 | ~22.0 GiB (~23.2%) | passes comfortably |
339:   | 896,000 | ~13.8 GiB (~14.5%) | borderline — just under 15%, still >10 GiB flat |
340:   | 960,000 | ~9.6 GiB (~10.1%) | fails both thresholds, though still mathematically positive |
341:   | 1,048,576 | ~3.9 GiB (~4.1%) | fails clearly |
342: 
343:   768K and 896K were picked for the follow-up probe as the genuinely informative gray zone (960K/1M were dropped — the math already says "no" clearly enough not to burn a ~20-30 min load cycle on them).
344: 
345:   **DECISION (2026-08-20): production `--ctx-size` = 768,000.** With both probes now measured (not just projected), 768K clears the ≥15%/≥10 GiB safety-margin policy on every GPU with real room to spare (worst case CUDA0 at 23.2% free), while 896K's worst GPU (CUDA0) measures 14,079 MiB free (14.47%) against a 14,593 MiB (15%) requirement — a ~514 MiB shortfall on the primary leg of the policy, even though it still clears the flat ≥10 GiB leg. Rather than ship on a config that already trips one leg of its own adopted safety policy before accounting for batch size, prompt cache, and OpenCode tool-call payloads (the exact production extras the policy was sized to cover, per Task 2.2), 768K is the safer choice, and it still comfortably exceeds REQ-003's 350-370K target by more than 2x. **896K is not discarded — it is flagged as a revisit candidate** (see Decisions Made) once the pending `--tensor-split`/PCIe-topology rebalancing lands, since shifting some of CUDA0's KV-cache share onto its faster PCIe 5.0 bus or onto another GPU could plausibly close that ~514 MiB gap.
346: 
347: - [x] Task 2.3.1: Prepare a script to tune `vm.swappiness` down (target `1`, not `0`) via `/etc/sysctl.d/` (persisted across reboots) on the Dell 7960T — keep swap enabled as a last-resort safety net for genuine memory-pressure emergencies, but stop the kernel from proactively swapping anonymous pages during normal operation (default `swappiness=60` is tuned for general-purpose workloads, not this single dedicated, capacity-planned appliance). Explicitly NOT disabling swap outright — see Decisions Made for the full rationale (mmap'd GGUF weight pages are file-backed/cleanly-reclaimable and don't depend on swap at all; swap only covers anonymous memory, and its gradual growth has already served as a useful early-warning canary during Task 2.1's incidents, which a hard OOM-kill would not) — depends on: none — status: done — 2026-08-20: `bin/10-tune-vm-swappiness.sh` created (idempotent: checks current value + persisted file before writing, writes `/etc/sysctl.d/99-glm-swappiness.conf`, applies immediately via `sudo sysctl --system` so no reboot is required, verifies the resulting value and warns if a conflicting sysctl file wins). Requires sudo on the box. **Run on the actual box 2026-08-20** — succeeded: `vm.swappiness` confirmed `60 -> 1`, persisted at `/etc/sysctl.d/99-glm-swappiness.conf`. Two unrelated `sysctl: setting key ... Invalid argument` warnings appeared for pre-existing `net.ipv4.conf.all.accept_source_route`/`promote_secondaries` keys — harmless, caused by `sudo sysctl --system` re-applying every existing sysctl file on the box, not by `99-glm-swappiness.conf` (confirmed by the final readback showing `vm.swappiness` at the correct target value). Also surfaced an important new finding, logged as Task 3.1: `/swapfile` is only 2 GiB total and already ~1.8 GiB (~90%) used — see Decisions Made and Task 3.1 for why this changes the swap-policy premise
348: 
349: - [x] Task 2.3.2: Add `user` to the `video`/`render` groups as defense-in-depth for GPU device access under the systemd `--user` unit decided for Task 2.3 — not currently required since `/dev/nvidia*` on this box are world-writable (`crw-rw-rw-`), but this should not be relied upon to stay true (a driver update or udev rule change could tighten it) — depends on: none — status: done — `bin/12-setup-user-systemd-groups.sh` created (idempotent, checks current group membership first, requires interactive sudo like `bin/10`). **Bug found and fixed during rollout:** the script originally derived its target user from `$USER`, which resolves to `root` when the script itself is invoked via `sudo` (`sudo bash 12-setup-user-systemd-groups.sh`) — a first run silently added `root` (already a no-op, `root` was already in both groups) instead of `user`. Fixed to take the target user as an optional first argument, defaulting to `user` (`bash 12-setup-user-systemd-groups.sh [target-user]`), and re-run correctly as `sudo bash 12-setup-user-systemd-groups.sh user`. **Done (2026-08-20):** confirmed via `id user` — `video`(44)/`render`(110) both present, groups took effect immediately without a fresh login being required beyond the one already in progress. **Also done manually (per explicit decision, deliberately NOT scripted):** `root` removed from both groups (`sudo delgroup root video`, `sudo delgroup root render`) — `/etc/group` now shows `video:x:44:user` / `render:x:110:user`, `user` only.
350: 
351: - [x] Task 2.3.3: Enable lingering (`loginctl enable-linger`) for `user` so `llama-glm-5.2.service` can keep running with no user logged in, WITHOUT autostarting at boot — the actual requirement turned out to be "survive logout", not "autostart now", and those need lingering-on + unit-NOT-enabled together, not lingering alone (see Decisions Made "lingering + no autostart" for the full incident where this was caught and corrected live on the box) — depends on: none — status: done — 2026-08-20: `bin/13-enable-user-lingering.sh` created (idempotent, no sudo needed — verified `loginctl enable-linger` succeeds for `user` without a password prompt on this box) and run: `Linger=yes` confirmed via `loginctl show-user user -p Linger`. **Incident found and fixed in the same check:** `bin/09-install-llama-glm-service.sh` had already been run once (separately) and had `enable`d the unit — with lingering now on, that combination would have auto-started it at the next boot. Caught immediately (`systemctl --user status llama-glm-5.2` showed `enabled`), fixed via `systemctl --user disable llama-glm-5.2` (confirmed `disabled`/`inactive`), and `bin/09` itself rewritten to never call `enable` (it now also defensively re-disables the unit if it finds it enabled from a prior run, so re-running the installer can't silently reintroduce this).
352: 
353: - [x] Task 2.4: `systemctl --user start` the service (no sudo); curl smoke test against `/v1/chat/completions`, verify tool-calls and all 3 reasoning modes (reasoning_effort max/high, enable_thinking:false). If engine is llama.cpp, explicitly verify OpenAI-compatible tool-calling works for OpenCode (REQ-011 risk) — depends on: Task 2.3, Task 2.3.2, Task 2.3.3 — status: done — 2026-08-20 11:58:20 CEST: `systemctl --user start llama-glm-5.2.service` issued by user. Cold load completed successfully at `12:31:12` (~33 min, matching Task 2.2.1's estimate); confirmed via `systemctl --user status` (`active (running)`), `journalctl` (`model loaded`, `listening on http://0.0.0.0:8092`), `curl http://localhost:8092/health` (`200 {"status":"ok"}`), and `/v1/models` (`glm-5.2:UD-Q5_K_XL`, `n_ctx: 768000`). **`bin/14-smoke-test-glm-service.sh` run 2026-08-20 12:50-12:52 CEST against the live service — ALL 4 CASES PASSED, `OVERALL: no degenerate/suspicious/failed results found`:**
354: 
355:   - `enable_thinking:false`: `finish_reason: stop`, content `"Paris"` (factually correct), 2 completion tokens, ~12.0 tok/s
356:   - `reasoning_effort:high`: `finish_reason: stop` (NOT truncated), a correct recursive `fibonacci()` plus a note on its exponential complexity and a memoized alternative, 477 completion tokens, ~12.9 tok/s, non-empty `reasoning_content`
357:   - `reasoning_effort:max`: `finish_reason: stop` (NOT truncated — earlier ACC-002 attempt at 600 tokens WAS truncated; 4000-token budget here let it finish), a correct recursive `fibonacci()` plus memoized variant, 694 completion tokens, ~12.9 tok/s, non-empty `reasoning_content`
358:   - Tool-calling (REQ-011 risk): `finish_reason: tool_calls`, well-formed `message.tool_calls[0].function` = `{"name":"get_weather","arguments":"{\"location\":\"Paris\"}"}`, valid JSON args with the expected key — llama.cpp's tool-calling did NOT show the historically-weaker failure mode (no plain-text imitation in `content`, which was empty as expected for a pure tool-call turn)
359: 
360:   No degenerate/frozen-token signature in any case. Results:
361:   `bin/logs/2026-08-20T105048Z-smoke-test-glm-service/{nothink,reasoning_high,reasoning_max,toolcall}.json`. **REQ-004 (all 3 reasoning modes) and the curl half of REQ-011/ACC-004 (tool-calling) both confirmed via curl.** ACC-004's remaining half (a real OpenCode agentic session) is deferred to Task 2.6/2.7 once OpenCode is wired up — see ACC-004.
362: 
363: - [ ] Task 2.5: Validate the finalized production context size (**768K**, decided in Task 2.3 — see Track A result; comfortably exceeds REQ-003's 350-370K minimum bar by 2x+. 896K remains a flagged revisit candidate pending the tensor-split rebalancing, see Decisions Made, but is not the current target) works without OOM — depends on: Task 2.4 — status: not-started
364: 
365: - [ ] Task 2.5.1: Measure actual generation throughput (tokens/min in and tokens/min out, or tok/s) for `UD-Q5_K_XL` in the production config (`--n-cpu-moe 54 --tensor-split 54,9,8,8`), at the finalized production context size — Task 2.1/2.2 were model-load/VRAM-allocation probes only, not decode-speed benchmarks; the only speed figure on record (~39 tok/s, Task 1.2) is for the much lighter `UD-IQ1_S` spike quant and is not representative, since `UD-Q5_K_XL` streams the majority of MoE expert weight from CPU RAM per decode step (`--n-cpu-moe 54`), which is structurally slower. Runs against the already-installed service, which already has Task 2.2.1's winning `--load-mode` baked in — no second cold-load-mode comparison needed here — depends on: Task 2.5 — status: not-started — **2026-08-20: prep work done ahead of time**, prompted by a user report that decode felt slow in real use. A live spot-check during this session (`nvidia-smi dmon -s ut`) found GPU0 (the PCIe 5.0 x16 bus, see Task 2.3/3.3's topology finding) sustaining **~46-60 GB/s PCIe RX at 100% SM utilization** during real generation traffic, while GPUs 1-3 sat idle — a strong signal decode may be PCIe-transfer-bound in this `--n-cpu-moe` hybrid config (the CPU-offloaded MoE-expert weight rows being re-streamed to GPU every decode step), not purely compute-bound. Three scripts created (executable, **not yet run**): `bin/15-measure-pcie-vs-throughput.sh` (generic — correlates per-GPU PCIe RX/TX + SM% with measured `tok/s` against any already-running endpoint; doubles as this task's actual measurement tool), `bin/17-tune-q4-placement.sh` (see below — finds a Q4-specific `--n-cpu-moe`/`--tensor-split` placement rather than blindly reusing Q5's, run BEFORE `bin/16`), and `bin/16-benchmark-q4-vs-q5.sh` (orchestrates a full A/B: benchmarks the live Q5 production service via `bin/15` first — satisfying this task — then stops it, cold-loads `UD-Q4_K_XL` ad-hoc on port 8093 with a placement now parameterized via `NC... (line truncated to 2000 chars)
366: 
367: - **2026-08-20 (later): Q4-specific placement tuning added, prompted by a
368:   user question — "shouldn't Q4 get its own block-placement tuning,
369:   like Q5 did?".** Correct catch: blindly reusing Q5's `54,9,8,8` for Q4
370:   is SAFE (every Q4 tensor is \<= its Q5 counterpart) but leaves headroom
371:   unused. Measured directly from GGUF tensor metadata (not estimated):
372:   Q4's average MoE-expert-block size is **5.468 GiB vs Q5's 6.635 GiB
373:   (~82.4% of Q5's size)**, both over the same 76 MoE blocks
374:   (`block_count=79`, `leading_dense_block_count=3`, confirmed via
375:   `gguf-dump`). Reusing Q5's split unchanged would free ~28 GiB combined
376:   headroom across GPU1-3 (not needed for safety at 768K — Q5 already
377:   clears its margin comfortably there — so it's available to push MORE
378:   blocks off CPU-offload onto GPU-resident, which would compound with
379:   Q4's bit-width win under the PCIe-bound hypothesis). Confirmed via
380:   `llama-server --help`: `--n-cpu-moe N` keeps the MoE weights of the
381:   FIRST N layers on CPU (not last N). Also discovered a key efficiency
382:   fact: llama.cpp's own startup fit-check
383:   (`common_params_fit_impl`/`common_fit_params`, confirmed in existing
384:   logs: "fitting params to free memory took 0.60 seconds") completes in
385:   **under a second**, right after reading GGUF metadata — WAY before the
386:   30-45 min tensor-copy phase. This means candidate placements can be
387:   tested in seconds each (start, capture the early diagnostic, kill
388:   before the expensive load), not one full cold-load per candidate.
389:   `bin/17-tune-q4-placement.sh` created to exploit this: stops
390:   production, tries 3 candidates (`54,9,8,8` baseline reuse plus two
391:   progressively more aggressive rebalances, `50,11,9,9` and `46,13,10,10`)
392:   each killed right after its fit-check, prints a comparison table
393:   against Q5's known 768K reference, and restarts production via the
394:   same `trap`-guarded cleanup pattern as `bin/16`. **Not yet run.**
395:   `bin/16` updated to take `NCMOE`/`TENSOR_SPLIT` as overridable env vars
396:   (still defaulting to Q5's values) so the winning candidate from
397:   `bin/17` can feed directly into a fair "best Q4 config vs best Q5
398:   config" throughput comparison. Recommended order:
399:   `bin/17-tune-q4-placement.sh` → pick a winner → re-run `bin/16` with
400:   `NCMOE=... TENSOR_SPLIT=... bash bin/16-benchmark-q4-vs-q5.sh`.
401: 
402: - [ ] Task 2.6: Connect OpenWebUI and OpenCode to the GLM-5.2 endpoint as a separate model entry — depends on: Task 2.5 — status: not-started — OpenCode side drafted ahead of time (2026-08-20): `opencode-provider-snippet-glm-5.2.jsonc` (feature folder root) holds a `provider.llama-cpp-sys0` entry using `@ai-sdk/openai-compatible`, `baseURL: http://<sys0-LAN-IP>:8092/v1`, model key `glm-5.2:UD-Q5_K_XL` with `limit.context: 768000` (matching Task 2.3's decided production context size) — mirrors the box's existing `ollama-sys0` provider entry in shape. Deliberately NOT written into any actual `opencode.jsonc` on this box (that file belongs to a different system) — it's a standalone paste-able fragment for the user to merge into their own config's `provider` object once Task 2.4 confirms the endpoint is actually up. Motivated the `--alias glm-5.2:UD-Q5_K_XL` addition to `bin/08-llama-glm-5.2.service` (see its header comment) so the model id OpenCode/OpenWebUI would show isn't the raw GGUF file path. See Task 3.2 (Phase 3) for the still-open question of driving `--chat-template-kwargs` reasoning-mode toggles from OpenCode itself.
403: 
404: - [ ] Task 2.7: User runs the SAME coding-task examples from feat-1 (Task 1.7 / ACC-010) against this endpoint for a direct quality comparison — depends on: Task 2.6 — status: not-started
405: 
406: #### Phase 3: Optimisations (nice-to-have, non-blocking on Phase 2)
407: 
408: - [ ] Task 3.1: Evaluate/resize the `/swapfile` swap device. Discovered while actually running Task 2.3.1's `bin/10-tune-vm-swappiness.sh` on the box (2026-08-20): the swap device is only **2 GiB total, already ~1.8 GiB (~90%) used** — much smaller than assumed when the swap-policy decision was made. This meaningfully changes that decision's premise: at 2 GiB against a 512 GiB RAM pool, swap cannot absorb anything close to the multi-hundred-GB-scale anonymous-memory incidents already seen in Task 2.1 (Incident #1 alone consumed ~1.4 GiB of this same 2 GiB device in well under a minute — ~70% of its entire capacity from one transient event). At this size swap functions as an early trip-wire signal, not a real capacity cushion — `vm.swappiness=1` (Task 2.3.1) still correctly reduces *proactive* swapping, but does not fix the fact that any genuine pressure event would exhaust this device almost immediately and fall through to the OOM-killer anyway, safety-net or not. Decide whether to enlarge the swapfile (and to what size) to make it a meaningful buffer, or explicitly accept it as trip-wire-only and document that — depends on: Task 2.3.1 — status: not-started
409: 
410: - [ ] Task 3.2: Work out how to drive GLM-5.2's `--chat-template-kwargs` reasoning-mode toggles (`reasoning_effort: max`/`high`, or `enable_thinking: false` — REQ-004) from an OpenCode client session, not just from raw curl smoke tests. Surfaced while drafting the OpenCode `opencode.jsonc` provider snippet for this endpoint (`@ai-sdk/openai-compatible`, pointed at `http://<sys0-host>:8092/v1`): OpenCode's documented config schema for a custom OpenAI-compatible provider (`provider.<id>.models.<id>.{name,limit.context,limit.output}`) has no obvious per-model or per-request hook for injecting arbitrary extra body fields like `chat_template_kwargs` into the request OpenCode sends. Options to evaluate: (a) an OpenCode plugin that injects the field (similar in spirit to `opencode-helicone-session`'s header injection, but for a body field instead of a header); (b) exposing each reasoning mode as a SEPARATE model entry in `opencode.jsonc` pointed at the SAME `baseURL`/model, if the AI SDK's `providerOptions`/`options` surface turns out to support a static extra-body passthrough per model entry (needs verification against the actual `@ai-sdk/openai-compatible` package, not just the opencode.jsonc doc examples seen so far); (c) worst case, accept that OpenCode sessions run GLM-5.2 in its default mode only (`reasoning_effort: max` per unsloth's defaults) and reserve explicit low/no-thinking-mode testing for direct curl/API smoke tests outside OpenCode (Task 2.4/ACC-004 already covers that path). Not a blocker for Task 2.4/ACC-004 (which verifies the modes via curl, per REQ-004's own wording), but does affect how usable the reasoning-mode flexibility actually is day-to-day once OpenCode is wired up (Task 2.6) — depends on: Task 2.6 — status: not-started
411: 
412: - [ ] Task 3.3: Revisit the `--tensor-split`/`--n-cpu-moe` split to see whether 896K context can be reclaimed, informed by the box's PCIe topology (`nvidia-smi --query-gpu=index,pcie.link.gen.max`: GPU0/GPU2 are PCIe 5.0 x16, GPU1/GPU3 are PCIe 4.0 x16). **Moved here from being an embedded Task 2.3 gating item (2026-08-20)** — it never actually blocked shipping at 768K (which already clears the safety-margin policy on every GPU and exceeds REQ-003's 350-370K target by 2x+); it only matters for the 896K stretch goal, which is explicitly "flagged as a revisit candidate, not discarded" rather than required. Context for the revisit: at ctx=896,000 under the current validated split (`--n-cpu-moe 54 --tensor-split 54,9,8,8`), CUDA0 is the binding constraint (14,079 MiB / 14.5% free, ~514 MiB short of the 15% leg) despite holding the *smallest* static model weight of the four GPUs (19,485 MiB) — it appears the layers assigned to CUDA0 by the tensor-split ratio (54/79 ≈ 68%) are the same ones `--n-cpu-moe 54` offloads experts from, so CUDA0 ends up "hollowed out" of static weight but loaded with a proportional (71%) share of the KV-cache instead, which is what makes it tight as context grows. **A real risk, not just an optimization detail:** CUDA0 also happens to sit on the fast PCIe 5.0 bus, which is currently a good pairing (CPU-offloaded experts stream across PCIe every decode step, and that traffic is landing on the faster bus) — shrinking CUDA0's tensor-split ratio to relieve KV-cache pressure could inadvertently shift that expert-streaming traffic onto a Gen4 GPU instead, regressing decode throughput to gain KV-cache margin. **Do not attempt this rebalancing before Task 2.5.1 (decode tok/s baseline) has run** — without a throughput baseline first, a rebalance's downside (slower decode) would be invisible until after the fact. If pursued: re-validate both KV-cache margin (`bin/07-measure-kv-cache-768-896.sh`-style, at ctx=896000) AND decode throughput (Task 2.5.1-style... (line truncated to 2000 chars)
413: 
414: - [x] Task 3.4: Install `UD-Q4_K_XL` as a side-by-side, independently
415:   swappable systemd service (user request, 2026-08-20/2026-08-22) —
416:   depends on: none — status: done. **Investigated and found a hard
417:   capacity ceiling first**: `UD-Q4_K_XL` (~467 GB) + `UD-Q5_K_XL` (~562
418:   GB) combined (~1029 GB) exceed this box's 896 GB total pool (384 GB
419:   VRAM + 512 GB RAM) by ~133 GB, confirmed against live numbers (only
420:   ~116 GiB combined GPU free / ~131 GiB RAM "available" while Q5 alone
421:   ran) — true concurrent residency of both quants is impossible
422:   regardless of placement, a raw capacity limit, not a tuning problem.
423:   **Decided (user): install both as separate, independently
424:   start/stoppable systemd `--user` services, swapped (never run
425:   together).** `bin/19-llama-glm-5.2-q4.service` (port 8093, distinct
426:   `--alias glm-5.2:UD-Q4_K_XL`, otherwise identical
427:   `--n-cpu-moe 54 --tensor-split 54,9,8,8 --ctx-size 768000 --load-mode none` placement to Q5 — deliberately reused unchanged rather than
428:   re-optimized, since every Q4 tensor is ≤ its Q5 counterpart so a split

(Output capped at 50 KB. Showing lines 1-428. Use offset=429 to continue.)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 115.8s)

_Thinking:_



I've reviewed the template (`.specmgr/_template/v1/README.md`) and the most detailed precedent (`feat-2-glm-5.2-onprem-deployment/README.md`, which follows the same REQ/ACC/Scope/Dependencies/Design Notes/Task List structure). Before I draft the plan, I need a few decisions to fill in the requirements, scope, and non-negotiables correctly.

**Tool: question**

**Input:**
```json
{
  "questions": [
    {
      "question": "What's the actual goal of this feature — production serving (wired into OpenCode/OpenWebUI like feat-1/feat-2) or an evaluation/spike to see if Qwen3.8-27B + large context is viable at all?",
      "header": "Feature goal",
      "options": [
        {
          "label": "Production serving (Recommended)",
          "description": "Full deployment: systemd service, OpenCode/OpenWebUI wiring, quality comparison — same bar as feat-1/feat-2"
        },
        {
          "label": "Evaluation/spike only",
          "description": "Just prove 768K context works on this hardware and measure quality/throughput; no OpenCode/OpenWebUI wiring, no long-term service commitment"
        }
      ]
    },
    {
      "question": "Target context size: lock it to exactly 768K (786,432 tokens) as discussed, or treat 768K as a floor and push for more (up to the model's 1M max) if headroom allows?",
      "header": "Context target",
      "options": [
        {
          "label": "Exactly 768K (Recommended)",
          "description": "Matches your stated 'ideally 768K' requirement; simpler acceptance criterion"
        },
        {
          "label": "768K floor, push higher if safe",
          "description": "Mirrors feat-2's approach (measured 512K, could've gone further) — more exploration work, more tasks"
        }
      ]
    },
    {
      "question": "How should this relate to the existing feat-1 (DeepSeek-V4) and feat-2 (GLM-5.2) deployments on the same Dell 7960T box?",
      "header": "Relation to feat-1/feat-2",
      "options": [
        {
          "label": "Independent addition, may coexist (Recommended)",
          "description": "Qwen3.8-27B is much smaller (27B dense, ~54GB BF16) — likely fits on 1-2 GPUs, could run alongside the others rather than needing an exclusive swap"
        },
        {
          "label": "Swappable alternative (like GLM-5.2's Q4/Q5 pair)",
          "description": "Only one model active at a time on the shared GPU pool, started/stopped manually"
        },
        {
          "label": "Not sure yet — investigate as a task",
          "description": "Add a task to determine VRAM footprint and decide coexistence vs. swap before committing"
        }
      ]
    },
    {
      "question": "Engine choice: the HF card only documents the YaRN long-context extension for vLLM, SGLang, and TokenSpeed. Given feat-1 hit an SM120 vLLM sparse-attention bug (different kernel class than Qwen3.8's Gated DeltaNet, so may not apply) — how do you want to handle engine selection?",
      "header": "Engine selection",
      "options": [
        {
          "label": "Start with vLLM directly (Recommended)",
          "description": "It's the primary documented path, matches feat-1's default engine, and Qwen3.8's Gated DeltaNet architecture is a different kernel class from the DSA/sparse-MLA bug that hit feat-1/feat-2 — lower a priori risk"
        },
        {
          "label": "Spike first like feat-2 Phase 1",
          "description": "Add an explicit correctness/smoke-test phase across vLLM/SGLang before committing to full deployment, treating SM120 compatibility as unproven for this new architecture"
        }
      ]
    },
    {
      "question": "Is native/vision-language (image+video) capability actually needed for this feature, or is this purely about text/coding context extension?",
      "header": "Multimodal scope",
      "options": [
        {
          "label": "Text/coding only — VLM capability out of scope (Recommended)",
          "description": "Matches your stated use case (OpenCode coding); vision/video support exists but isn't tested or required"
        },
        {
          "label": "Include vision/video validation",
          "description": "Add acceptance criteria for image/video understanding too"
        }
      ]
    },
    {
      "question": "Quantization/precision: at 27B dense BF16 (~54GB weights), this fits easily on the 384GB VRAM pool even with a large KV cache. Should the feature require full-precision BF16 (matching feat-1's DeepSeek-V4-Flash 'no requant' policy), or is quantization acceptable if it helps context/throughput?",
      "header": "Precision policy",
      "options": [
        {
          "label": "Full BF16, no quantization (Recommended)",
          "description": "Model comfortably fits VRAM at BF16; no need to trade quality for capacity like feat-2's GLM-5.2 had to"
        },
        {
          "label": "Quantization acceptable if beneficial",
          "description": "Leave the door open (e.g., FP8) if it meaningfully improves throughput or frees VRAM for a larger KV cache"
        }
      ]
    }
  ]
}
```

**Output:**
```
User has answered your questions: "What's the actual goal of this feature — production serving (wired into OpenCode/OpenWebUI like feat-1/feat-2) or an evaluation/spike to see if Qwen3.8-27B + large context is viable at all?"="Production serving (Recommended)", "Target context size: lock it to exactly 768K (786,432 tokens) as discussed, or treat 768K as a floor and push for more (up to the model's 1M max) if headroom allows?"="768K floor, push higher if safe", "How should this relate to the existing feat-1 (DeepSeek-V4) and feat-2 (GLM-5.2) deployments on the same Dell 7960T box?"="Independent addition, may coexist (Recommended)", "Engine choice: the HF card only documents the YaRN long-context extension for vLLM, SGLang, and TokenSpeed. Given feat-1 hit an SM120 vLLM sparse-attention bug (different kernel class than Qwen3.8's Gated DeltaNet, so may not apply) — how do you want to handle engine selection?"="Start with vLLM directly (Recommended)", "Is native/vision-language (image+video) capability actually needed for this feature, or is this purely about text/coding context extension?"="Text/coding only — VLM capability out of scope (Recommended)", "Quantization/precision: at 27B dense BF16 (~54GB weights), this fits easily on the 384GB VRAM pool even with a large KV cache. Should the feature require full-precision BF16 (matching feat-1's DeepSeek-V4-Flash 'no requant' policy), or is quantization acceptable if it helps context/throughput?"="Quantization acceptable if beneficial". You can now continue with the user's answers in mind.
```

---

## Assistant (Plan · Claude Sonnet 5 · 35.9s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3.8-27B/commits/main"
}
```

**Output:**
```
                

 Commits · Qwen/Qwen3.8-27B   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

](/Qwen)

[Qwen](/Qwen)

/

[Qwen3.8-27B](/Qwen/Qwen3.8-27B)

like 12.1k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg) Qwen 99.4k

[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

qwen3\_5

](/models?other=qwen3_5)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)

License: apache-2.0

[Model card](/Qwen/Qwen3.8-27B) [Files Files and versions

xet

](/Qwen/Qwen3.8-27B/tree/main)[Community

159

](/Qwen/Qwen3.8-27B/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Qwen/Qwen3.8-27B with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Qwen/Qwen3.8-27B?library=transformers)
    
    How to use Qwen/Qwen3.8-27B with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("image-text-to-text", model="Qwen/Qwen3.8-27B")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    pipe(text=messages)
    
    \# Load model directly
    from transformers import AutoProcessor, AutoModelForMultimodalLM
    
    processor = AutoProcessor.from\_pretrained("Qwen/Qwen3.8-27B")
    model = AutoModelForMultimodalLM.from\_pretrained("Qwen/Qwen3.8-27B", device\_map="auto")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    inputs = processor.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(processor.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Inference
-   Inference Providers
-   Notebooks
-   [Google Colab](/Qwen/Qwen3.8-27B/colab)
-   [Kaggle](/Qwen/Qwen3.8-27B/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Qwen/Qwen3.8-27B?local-app=vllm)
    
    How to use Qwen/Qwen3.8-27B with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Qwen/Qwen3.8-27B"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Qwen/Qwen3.8-27B
    
-   [SGLang](/Qwen/Qwen3.8-27B?local-app=sglang)
    
    How to use Qwen/Qwen3.8-27B with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Qwen/Qwen3.8-27B" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Qwen/Qwen3.8-27B" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Qwen/Qwen3.8-27B?local-app=docker-model-runner)
    
    How to use Qwen/Qwen3.8-27B with Docker Model Runner:
    
    docker model run hf.co/Qwen/Qwen3.8-27B
    

main

[Qwen3.8-27B](/Qwen/Qwen3.8-27B/tree/main)

# Commit History

### 

Update README.md

1d4bf0f

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 8 days ago

### 

Update README.md

ed1e737

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 8 days ago

### 

Update README.md

0044ccc

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 8 days ago

### 

Update README.md (model card)

9206f8d

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 8 days ago

### 

Update README.md

08cb375

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 8 days ago

### 

Update README.md (model card)

99b86b4

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 8 days ago

### 

Add LICENSE

e13a4f0

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 9 days ago

### 

Upload generation\_config.json with huggingface\_hub

dbdc473

verified

![](/avatars/0358ba4ed8393d8b5edbd2d2902db24d.svg) [Iceberg-Yang](/Iceberg-Yang) commited on 9 days ago

### 

Upload chat\_template.jinja with huggingface\_hub

412f8b6

verified

![](/avatars/0358ba4ed8393d8b5edbd2d2902db24d.svg) [Iceberg-Yang](/Iceberg-Yang) commited on 9 days ago

### 

Upload tokenizer\_config.json with huggingface\_hub

452438e

verified

![](/avatars/0358ba4ed8393d8b5edbd2d2902db24d.svg) [Iceberg-Yang](/Iceberg-Yang) commited on 9 days ago

### 

Upload folder using huggingface\_hub

72a217a

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 9 days ago

### 

Update README.md

69b8fb7

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 9 days ago

### 

Update README.md

3bb536d

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 9 days ago

### 

Update README.md

e744676

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 10 days ago

### 

Update README.md

4191656

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 10 days ago

### 

initial commit

6714f56

verified

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66bb6e038515f1f0723180ab/ZdsAJNcYRl7Zt-6lqk-3r.jpeg) [VoyagerXHF](/VoyagerXHF) commited on 17 days ago
```

---

## Assistant (Plan · Claude Sonnet 5 · 19.8s)

_Thinking:_



Good — latest commit on `main` is `1d4bf0f` (8 days ago, README-only changes; the actual weights landed at `72a217a`/initial commit `6714f56`). I'll have the deployment task record the full resolved hash from the box itself.

Now here's the plan I'll write into `.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md` (next available slot after feat-1, feat-2), following the template/feat-2 structure exactly:

## Feature: On-prem Qwen3.8-27B serving with extended context (768K+) for OpenCode + OpenWebUI

**Overview** — Deploy `Qwen/Qwen3.8-27B` (dense VLM, 27B params, Apache-2.0) on the Dell 7960T via vLLM, extended past its native 262,144-token context using the card's documented YaRN `rope_parameters` override. Target is a **768K-token floor**, pushing toward the model's advertised 1M ceiling if per-GPU VRAM safety margin allows (reusing feat-2's ≥15%/≥10 GiB policy). Unlike GLM-5.2, this model is small enough (~54 GB BF16) to fit full-precision with room to spare — no forced quant compromise — though FP8 stays on the table if data shows a throughput/headroom win. Runs independently of feat-1/feat-2; likely small enough to coexist concurrently on a GPU subset rather than needing an exclusive swap. Text/coding only — vision/video capability is present but explicitly untested here.

**Key requirements** (REQ-001…011): OpenAI-compatible API on the 7960T, no new hardware, ≥768K context (stretch to 1M), tool-calling + `reasoning_effort`/`enable_thinking`/`preserve_thinking` all verified, BF16-first with quant only if justified by data, vLLM as primary engine (documented YaRN path; Gated DeltaNet is a different kernel class from the DSA/sparse-MLA bug that hit feat-1/feat-2, so no mandatory pre-spike phase, but an early smoke test is still cheap insurance), pinned HF revision, unauthenticated/internal-only, systemd-managed, and an explicit VRAM/coexistence measurement against the already-running feat-1/feat-2 services.

**Task List phases**:
- **Phase 0 — Env prep**: reuse feat-1's disk/driver/CUDA/HF-token work; new: confirm installed vLLM version actually supports Qwen3.8's architecture tag (`qwen3_5`/hybrid Gated DeltaNet) — this is a brand-new arch, not a given; pin exact HF revision.
- **Phase 1 — Baseline smoke test**: load at native 256K context on vLLM/SM120, verify coherent (non-degenerate) output before touching YaRN.
- **Phase 2 — Context extension + capacity measurement**: apply YaRN config (factor computed as target/262144 — 768K→3.0, 1M→4.0 per the card's own example), measure per-GPU KV-cache headroom at 768K, then step upward (896K, 1M) while margin allows; determine minimum TP/GPU count and whether it fits alongside feat-1/feat-2 concurrently or needs reserved GPUs.
- **Phase 3 — Precision decision**: confirm BF16 as default; evaluate FP8 only if Phase 2 data supports it.
- **Phase 4 — Deployment**: systemd service (`--user` + lingering, following feat-2's pattern), pinned config, start/verify.
- **Phase 5 — Integration**: OpenCode/OpenWebUI wiring, tool-call + reasoning-mode curl verification, then a real OpenCode agentic session, plus a quality comparison using the same coding-task examples from feat-1/feat-2.

One open item I want to flag rather than silently decide: **feature slug**. I'm proposing `feat-3-qwen3.8-27b-large-context` — let me know if you'd prefer different wording (e.g. matching feat-1/feat-2's `-onprem-deployment` suffix style: `feat-3-qwen3.8-27b-onprem-deployment`).

Once you confirm the slug (and anything else you want changed above), I'll switch out of plan mode and write the README.

---

## User

---

## Assistant (Plan · Claude Sonnet 5 · 0.6s)

**Tool: bash**

**Input:**
```json
{
  "command": "git pull"
}
```

**Output:**
```
Updating ae0b59e..0613218
Fast-forward
 .../feat-2-glm-5.2-onprem-deployment/README.md     | 191 ++++++++++-
 .../bin/14-smoke-test-glm-service.sh               |  40 ++-
 .../bin/21-smoke-test-glm-q4-service.sh            |  22 ++
 .../bin/22-measure-pcie-vs-throughput-q4.sh        |  22 ++
 .../bin/23-tune-q4-placement-v2.sh                 | 356 ++++++++++++++++++++
 .../bin/24-benchmark-q4-vs-q5-v2.sh                | 366 +++++++++++++++++++++
 .../nothink.json                                   |   1 +
 .../reasoning_high.json                            |   1 +
 .../reasoning_max.json                             |   1 +
 .../toolcall.json                                  |   1 +
 .../response.json                                  |   1 +
 .../response.json                                  |   1 +
 12 files changed, 982 insertions(+), 21 deletions(-)
 create mode 100755 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/21-smoke-test-glm-q4-service.sh
 create mode 100755 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/22-measure-pcie-vs-throughput-q4.sh
 create mode 100755 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/23-tune-q4-placement-v2.sh
 create mode 100755 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/24-benchmark-q4-vs-q5-v2.sh
 create mode 100644 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/logs/2026-08-22T091818Z-smoke-test-glm-service/nothink.json
 create mode 100644 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/logs/2026-08-22T091818Z-smoke-test-glm-service/reasoning_high.json
 create mode 100644 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/logs/2026-08-22T091818Z-smoke-test-glm-service/reasoning_max.json
 create mode 100644 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/logs/2026-08-22T091818Z-smoke-test-glm-service/toolcall.json
 create mode 100644 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/logs/2026-08-22T122526Z-pcie-vs-throughput/response.json
 create mode 100644 .specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin/logs/2026-08-22T123426Z-pcie-vs-throughput/response.json

```

---

## User

I pulled latest commits from repo. You can use the suggested slug

---

## Assistant (Build · Claude Sonnet 5 · 6.4s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "ls /home/user/src/biz.dfch.LlmOps/.specmgr/feat/"
}
```

**Output:**
```
feat-1-deepseek-v4-onprem-deployment
feat-2-glm-5.2-onprem-deployment

```

---

## Assistant (Build · Claude Sonnet 5 · 5.7s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md",
  "limit": 140
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-18
3: github_issue: 1
4: id: feat-1-deepseek-v4-onprem-deployment
5: status: planning
6: updated: 2026-08-19
7: version: 1.0.0
8: ---
9: 
10: # Feature: On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI
11: 
12: ## Plan
13: 
14: ### Overview
15: 
16: Deploy DeepSeek-V4-Flash and DeepSeek-V4-Pro on existing on-prem hardware,
17: each behind an OpenAI-compatible API, for use as coding models via OpenCode
18: and OpenWebUI. Quality is the priority over speed. Ollama's library-listed
19: `deepseek-v4-flash`/`deepseek-v4-pro` are cloud-proxy tags only (no local
20: weights) and are explicitly not used; official MIT-licensed weights from
21: `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face are loaded directly
22: instead, pinned to a specific revision for reproducibility.
23: 
24: ### Requirements
25: 
26: - REQ-001: Serve DeepSeek-V4-Flash via an OpenAI-compatible API
27:   (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
28:   Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
29: - REQ-002: Serve DeepSeek-V4-Pro via an OpenAI-compatible API on the same
30:   Dell 7960T, without adding new hardware and without networking in the
31:   DGX Spark
32: - REQ-003: Both endpoints must support real coding workloads reaching
33:   350-370K tokens of context
34: - REQ-004: Both endpoints must support tool-calling (required for OpenCode
35:   agentic use) and expose DeepSeek-V4's think/non-think/max-think reasoning
36:   modes correctly
37: - REQ-005: Maximize model quality; inference speed is explicitly secondary
38: - REQ-006: No third-party GGUF requantization — load official weights
39:   directly to avoid an extra, unverified source of quality loss
40: - REQ-007: Pin both models to a specific Hugging Face revision/commit
41:   (not "latest") for reproducibility across redeploys
42: - REQ-008: Both endpoints run unauthenticated (anonymous, no API-key/auth
43:   layer) — accepted risk, internal network only
44: - REQ-009: Both engines run as managed services (systemd units or
45:   equivalent), started/stopped via the service manager — no ad-hoc
46:   foreground processes, including during testing
47: 
48: ### Acceptance Criteria
49: 
50: - [ ] ACC-001: Verifies REQ-001 — `vllm serve deepseek-ai/DeepSeek-V4-Flash`
51:   running with tensor-parallel=4 on the Dell 7960T, reachable via
52:   `/v1/chat/completions`
53: - [ ] ACC-002: Verifies REQ-002 — ktransformers serving
54:   `deepseek-ai/DeepSeek-V4-Pro` on the same box, reachable via its
55:   OpenAI-compatible endpoint
56: - [ ] ACC-003: Verifies REQ-003 — empirical test confirms both endpoints
57:   handle a 350-370K-token coding prompt without OOM
58: - [ ] ACC-004: Verifies REQ-004 — tool-call and reasoning-mode output
59:   verified via curl smoke test, then via a real OpenCode agentic session
60: - [ ] ACC-005: Verifies REQ-005 — Flash runs with FP8 experts (upgraded
61:   from native FP4+FP8 mixed) if vLLM's loader supports the override;
62:   Pro's exact quantization level is chosen empirically to leave headroom
63:   for REQ-003's context requirement
64: - [ ] ACC-006: Verifies REQ-006 — both engines load weights directly from
65:   `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face, no GGUF requant
66: - [ ] ACC-007: Verifies REQ-007 — deployment config records the exact HF
67:   revision/commit hash used for each model
68: - [ ] ACC-008: Verifies REQ-008 — endpoints reachable without credentials
69:   from the internal network, confirmed intentional (not an oversight)
70: - [ ] ACC-009: Verifies REQ-009 — both engines installed as systemd
71:   services; started/stopped/restarted exclusively via `systemctl`
72:   throughout testing and production use
73: - [ ] ACC-010: User runs their own existing coding-task examples against
74:   both endpoints once setup is complete; same examples reused later to
75:   compare quality across future implementations (e.g. GLM-5.2)
76: 
77: ### Scope
78: 
79: What is included in this feature:
80: 
81: - vLLM deployment of DeepSeek-V4-Flash on the Dell 7960T, as a systemd
82:   service
83: - ktransformers deployment of DeepSeek-V4-Pro on the Dell 7960T, as a
84:   systemd service
85: - OpenWebUI and OpenCode configured against both endpoints
86: - Empirical KV-cache/context validation for both models
87: - Pinning both models to a fixed HF revision
88: 
89: What is explicitly out of scope:
90: 
91: - Any use of the DGX Spark for this deployment (explicitly excluded by
92:   user decision)
93: - Any use of Ollama's cloud-tagged library models
94: - Any GGUF/community requantization path
95: - Acquiring additional hardware for DeepSeek-V4-Pro
96: - Authentication/access-control layer (explicitly accepted as anonymous)
97: - GLM-5.2 fallback deployment — tracked as a separate, future feature
98: 
99: ### Dependencies
100: 
101: - Depends on: confirmed vLLM version with merged DeepSeek-V4 tool-call/
102:   reasoning-parser support; confirmed ktransformers version with
103:   DeepSeek-V4 architecture support; GPU driver/CUDA compatibility for RTX
104:   Pro 6000 Blackwell; sufficient local disk space (1TB+) on the Dell
105:   7960T for both model weight sets
106: - Blocks: none
107: - Related (not a dependency, tracked separately):
108:   `feat-2-glm-5.2-onprem-deployment` deploys GLM-5.2 as a fallback/
109:   alternative model — not part of this feature's scope. Its Phase 1 SM120
110:   sparse-attention correctness spike and this feature's Task 1.4 diagnostic
111:   inform each other (both hit the same SM120 sparse-attention-decode kernel
112:   class).
113: 
114: ### Design Notes
115: 
116: - Two independent serving engines by design: vLLM for Flash (fits fully
117:   in VRAM, gets native DeepSeek-V4 tool-call/reasoning-parser support),
118:   ktransformers for Pro (purpose-built GPU+CPU-RAM hybrid MoE inference,
119:   needed because Pro's ~800GB+ native footprint doesn't fit in 384GB VRAM
120:   alone).
121: - Precision tradeoff resolved: for Pro, user explicitly accepted lower
122:   precision (below native FP4+FP8 mixed) in exchange for guaranteed
123:   350-370K context headroom, since both cannot fit simultaneously in the
124:   896GB VRAM+RAM pool at native precision. Exact quant level to be
125:   determined empirically (measure real KV-cache cost per 1K tokens first,
126:   then pick the lightest trim that leaves safe margin — not the tightest
127:   possible fit).
128: - For Flash, FP8-expert override is the target (vs. native FP4 experts)
129:   since the resulting ~284GB footprint still fits comfortably in 384GB
130:   VRAM with headroom for the required context; fallback to native FP4+FP8
131:   mixed if vLLM's loader doesn't expose the override.
132: - DGX Spark intentionally left out of this feature's scope per explicit
133:   user decision (no cross-node networking between DGX Spark and Dell
134:   7960T).
135: - Both models pinned to a specific HF revision at deployment time, not
136:   tracking "latest" — avoids unexpected drift on redeploy, given DeepSeek
137:   appears to ship rolling checkpoint updates (observed `preview` →
138:   `0731`/`0813`-dated snapshots).
139: - No authentication layer: both OpenAI-compatible endpoints are
140:   reachable anonymously on the internal network. Accepted risk, not an

(Showing lines 1-140 of 947. Use offset=141 to continue.)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 6.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "mkdir -p \"/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin\""
}
```

**Output:**
```
(no output)
```

---

## Assistant (Build · Claude Sonnet 5 · 87.2s)

**Tool: write**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "content": "---\ncreated: 2026-08-22\nid: feat-3-qwen3.8-27b-large-context\nstatus: planning\nupdated: 2026-08-22\nversion: 1.0.0\n---\n\n# Feature: On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI\n\n## Plan\n\n### Overview\n\nDeploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,\nApache-2.0) on the existing on-prem Dell 7960T behind an OpenAI-compatible\nAPI, for use as a coding model via OpenCode and OpenWebUI, with its context\nwindow extended well past the 262,144-token native limit via the vendor's\ndocumented YaRN `rope_parameters` override. Target is a **768K-token floor**\n(786,432 tokens = native context x3), pushing toward the model's advertised\n1,048,576-token (1M) ceiling if per-GPU VRAM safety margin allows.\n\nUnlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit this\nbox), Qwen3.8-27B is small enough at full BF16 precision (~54GB weights)\nto fit the 384GB VRAM pool with enormous headroom left over for KV cache —\nso this feature does not start from a quality-vs-capacity compromise.\nQuantization (e.g. FP8) is not required and stays optional, considered only\nif empirical data shows it meaningfully helps context headroom or\nthroughput without a demonstrated quality cost.\n\nThis feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`\n(GLM-5.2) — it does not replace either, and given Qwen3.8-27B's much\nsmaller footprint it may be able to run concurrently alongside them on a\nGPU subset rather than needing an exclusive swap (to be determined\nempirically, see Design Notes).\n\nQwen3.8-27B is a native vision-language model (image + video\nunderstanding), but this feature scopes that capability OUT: only\ntext/coding use via OpenCode is targeted and validated here.\n\n### Requirements\n\n- REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API\n  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell\n  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)\n- REQ-002: No new hardware; DGX Spark explicitly excluded (same posture as\n  `feat-1`/`feat-2`)\n- REQ-003: The endpoint must support a context length of at least\n  **768,000 tokens** (floor). If per-GPU VRAM safety margin allows, push\n  higher in measured steps, up to the model's native ceiling of\n  1,048,576 tokens (1M) — do not stop at 768K if there is safe headroom to\n  go further\n- REQ-004: The endpoint must support tool-calling (required for OpenCode\n  agentic use) and correctly expose Qwen3.8's thinking controls:\n  `enable_thinking` (on by default), `reasoning_effort`\n  (`xhigh`/`medium`/`low`), and `preserve_thinking`\n- REQ-005: Run at full BF16 precision by default (the model fits VRAM\n  comfortably at this precision). Quantization (e.g. FP8) is acceptable\n  ONLY if empirically justified — i.e. it demonstrably improves context\n  headroom or throughput without a documented quality regression; it must\n  not be adopted purely by default the way `feat-2` had to for GLM-5.2\n- REQ-006: Engine = vLLM as the primary/default path — it is the engine\n  the vendor's model card documents the YaRN long-context override for,\n  and it matches `feat-1`'s default engine. Qwen3.8's hybrid Gated\n  DeltaNet + Gated Attention architecture is a different kernel class\n  from the DSA/sparse-MLA path that caused `feat-1`/`feat-2`'s SM120\n  vLLM bug (`vllm-project/vllm#52938`), so no mandatory full spike-phase\n  is required up front — but an early native-context smoke test (Phase 1)\n  is still done as cheap insurance before committing to the YaRN\n  extension work\n- REQ-007: Pin `Qwen/Qwen3.8-27B` to a specific Hugging Face revision/\n  commit (not \"latest\") for reproducibility across redeploys. Latest\n  `main` commit at feature-creation time: `1d4bf0f` (README-only change;\n  weights landed at `72a217a`/initial commit `6714f56`) — to be\n  re-confirmed and pinned from the box itself at download time (Task 0.4)\n- REQ-008: The endpoint runs unauthenticated (anonymous, no API-key/auth\n  layer) — accepted risk, internal network only (same posture as\n  `feat-1`/`feat-2`)\n- REQ-009: The engine runs as a managed service (systemd unit, `--user`\n  + lingering following `feat-2`'s pattern unless a reason emerges to\n  deviate) — no ad-hoc foreground processes, including during testing\n- REQ-010: Determine Qwen3.8-27B's actual VRAM footprint (weights + KV\n  cache at the target context) and record whether it can run\n  CONCURRENTLY alongside `feat-1`/`feat-2`'s existing services on shared\n  GPUs, or needs reserved GPU(s)/a time-sliced swap like GLM-5.2's\n  Q4/Q5 pair\n- REQ-011: YaRN rope scaling must be configured per the vendor's\n  documented `rope_parameters` override (`mrope_interleaved`,\n  `mrope_section`, `rope_type: yarn`, `rope_theta`,\n  `partial_rotary_factor: 0.25`, `factor`, `original_max_position_embeddings: 262144`), with `factor` computed as\n  `target_context / 262144` (e.g. 768K -> 3.0, 1M -> 4.0, matching the\n  vendor's own worked example)\n- REQ-012: Vision/video (image+video understanding) capability is\n  explicitly OUT of scope for testing/validation in this feature — text/\n  coding only\n\n### Acceptance Criteria\n\n- [ ] ACC-001: Verifies REQ-001/REQ-002 — Qwen3.8-27B running via vLLM on\n  the Dell 7960T, reachable via `/v1/chat/completions`, no new hardware,\n  DGX Spark unused\n- [ ] ACC-002: Verifies REQ-003 — empirical per-GPU VRAM/KV-cache\n  measurement confirms the endpoint handles at least a 768K-token prompt\n  without OOM, with the measured safety margin recorded per GPU; if a\n  higher context (896K, 1M) also clears the adopted safety-margin policy\n  (>=15% free VRAM per GPU, or >=10 GiB absolute, whichever is greater —\n  reused from `feat-2`), the highest safely-supported context is chosen\n  as the production value instead of stopping at 768K\n- [ ] ACC-003: Verifies REQ-004 — tool-call and all three thinking-control\n  modes (`enable_thinking: false`, `reasoning_effort: medium`,\n  `reasoning_effort: xhigh`) verified via curl smoke test, then via a\n  real OpenCode agentic session\n- [ ] ACC-004: Verifies REQ-005 — BF16 is confirmed as the production\n  precision, with a one-line rationale recorded; if a quantized variant\n  is adopted instead, the empirical justification (headroom/throughput\n  data, quality-impact check) is recorded alongside it\n- [ ] ACC-005: Verifies REQ-006 — vLLM is confirmed as the deployment\n  engine, with the version used recorded; if vLLM fails the Phase 1\n  native-context smoke test, the fallback engine actually used (SGLang)\n  is recorded instead, along with why\n- [ ] ACC-006: Verifies REQ-007 — deployment config records the exact HF\n  revision/commit hash used\n- [ ] ACC-007: Verifies REQ-008 — endpoint reachable without credentials\n  from the internal network, confirmed intentional (not an oversight)\n- [ ] ACC-008: Verifies REQ-009 — engine installed as a systemd service;\n  started/stopped/restarted exclusively via `systemctl`\n  (`systemctl --user ...` if following `feat-2`'s pattern) throughout\n  testing and production use\n- [ ] ACC-009: Verifies REQ-010 — a recorded decision on whether\n  Qwen3.8-27B runs concurrently with `feat-1`/`feat-2` services or\n  requires exclusive/reserved GPU access, backed by measured VRAM\n  numbers (not assumed)\n- [ ] ACC-010: Verifies REQ-011 — the exact YaRN `rope_parameters` config\n  used for the chosen production context size is recorded in the\n  systemd unit/deployment config\n- [ ] ACC-011: User runs the SAME coding-task examples used for `feat-1`/\n  `feat-2` (see `feat-1` ACC-010, `feat-2` ACC-009) against this\n  endpoint, for a direct three-way quality comparison\n\n### Scope\n\nWhat is included in this feature:\n\n- A lightweight native-context (256K) correctness smoke test on vLLM/\n  SM120 BEFORE attempting the YaRN extension (Phase 1) — not a full\n  multi-engine spike like `feat-2`'s Phase 1, since this model's kernel\n  class differs from the known SM120 bug, but still verified rather than\n  assumed\n- Configuring and validating YaRN-based context extension per the\n  vendor's documented `rope_parameters` override\n- Empirical per-GPU KV-cache/VRAM measurement at 768K and, if headroom\n  allows, at higher context sizes up to 1M\n- A concurrency/coexistence check against `feat-1`/`feat-2`'s existing\n  services on the same box\n- Deployment of Qwen3.8-27B on the Dell 7960T as a systemd service\n- Pinning the model to a fixed HF revision\n- OpenWebUI and OpenCode configured against the endpoint\n- Direct quality comparison against `feat-1`'s DeepSeek-V4 and `feat-2`'s\n  GLM-5.2 using the same coding-task examples\n\nWhat is explicitly out of scope:\n\n- Any use of the DGX Spark for this deployment (excluded per the same\n  user decision as `feat-1`/`feat-2`)\n- Acquiring additional hardware\n- Authentication/access-control layer (explicitly accepted as anonymous)\n- Fine-tuning or training Qwen3.8-27B (serving only)\n- Testing or validating vision-language (image/video) capability (REQ-012)\n- Retiring or changing the `feat-1`/`feat-2` deployments — all three are\n  intended to coexist; this feature does not depend on either succeeding\n- Ollama/llama.cpp/GGUF as the serving path — the vendor's own\n  documentation only covers the YaRN long-context extension for vLLM,\n  SGLang, and TokenSpeed; Qwen3.8's hybrid Gated DeltaNet + partial-\n  rotary/mrope architecture is non-standard enough that an unofficial\n  llama.cpp YaRN override is judged too high-risk for this feature's\n  goals (see the source chat session that preceded this feature for the\n  detailed reasoning)\n\n### Dependencies\n\n- Depends on: a vLLM release with confirmed support for Qwen3.8-27B's\n  architecture (`qwen3_5` tag, hybrid Gated DeltaNet + Gated Attention\n  layout) — this is a brand-new architecture, support is NOT assumed and\n  must be checked (Task 0.2); GPU driver/CUDA compatibility already\n  validated in `feat-1` Task 0.2 (driver 610.57.04, CUDA 13.3); HF\n  access/token/download tooling already validated in `feat-1` Task 0.3;\n  sufficient local disk on the Dell 7960T (`feat-1` Task 0.1: 9.3 TB free\n  at last check, re-verify remaining headroom after `feat-1`/`feat-2`\n  downloads)\n- Related (not a hard dependency): `feat-1`'s and `feat-2`'s SM120\n  sparse-attention-decode findings (`vllm-project/vllm#52938`) — informs\n  Phase 1's risk assessment but does not block it, since Qwen3.8-27B does\n  not use the same DSA/sparse-MLA kernel path\n- Blocks: none\n\n### Design Notes\n\n- **Model facts (verified from HF 2026-08-22)**: `Qwen/Qwen3.8-27B`,\n  Apache-2.0, dense causal LM + vision encoder, 27B language-model params\n  (28B total on disk, BF16 safetensors). Hybrid layout: 16x (3x (Gated\n  DeltaNet -> FFN) -> 1x (Gated Attention -> FFN)), 64 layers total.\n  Gated Attention: 24 Q heads / 4 KV heads, head dim 256, but only a\n  `partial_rotary_factor` of 0.25 (64 of 256 dims) actually gets RoPE.\n  Context: 262,144 native, extensible to 1,048,576 via YaRN per the\n  vendor card. Successor generation after Qwen3.6/3.7.\n- **Why BF16, not a forced quant (contrast with `feat-2`)**: 27B dense at\n  BF16 is ~54GB of weights — comfortably inside the 384GB VRAM pool even\n  before accounting for KV cache, unlike GLM-5.2's 744B MoE which could\n  not fit VRAM+RAM at any near-lossless precision without a quant. There\n  is no a priori reason to trade quality for capacity here; quantization\n  is opportunistic (Task 3.x), not load-bearing.\n- **YaRN factor table** (native = 262,144; vendor's own worked example:\n  524,288 -> factor 2.0):\n\n  | target context | factor |\n  |---|---|\n  | 524,288 (512K) | 2.0 |\n  | 786,432 (768K) | 3.0 |\n  | 917,504 (896K) | 3.5 |\n  | 1,048,576 (1M, native ceiling) | 4.0 |\n\n  Full override block (vendor-documented):\n  `{\"text_config\": {\"rope_parameters\": {\"mrope_interleaved\": true, \"mrope_section\": [11, 11, 10], \"rope_type\": \"yarn\", \"rope_theta\": 10000000, \"partial_rotary_factor\": 0.25, \"factor\": <see table>, \"original_max_position_embeddings\": 262144}}}`\n  passed via `--hf-overrides` (vLLM, needs\n  `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`) or the equivalent SGLang\n  `--json-model-override-args`.\n- **Static YaRN caveat (from the vendor card, carried over verbatim)**:\n  all current open-source frameworks implement static YaRN — the scaling\n  factor is fixed regardless of actual input length, which can hurt\n  short-prompt performance once a large factor is set. Only worth setting\n  if 768K+ is the genuinely typical working context for this deployment,\n  not just a ceiling to have available.\n- **Concurrency/coexistence is a real, not rhetorical, question here**:\n  because Qwen3.8-27B is so much smaller than DeepSeek-V4-Flash/Pro and\n  GLM-5.2, it may be able to run on 1-2 GPUs while `feat-1`/`feat-2`\n  occupy the others, rather than needing the box exclusively or a manual\n  swap. This must be measured (actual free VRAM while `feat-1`/`feat-2`\n  services are live), not assumed from paper VRAM math alone, since KV\n  cache at 768K-1M tokens is non-trivial even for a 27B model.\n- **Reuse `feat-1`/`feat-2` environment prep.** Disk, GPU/driver/CUDA,\n  and HF tooling are already validated on this same box; do not repeat\n  them, just reference them (Phase 0 tasks are mostly confirmation, not\n  new setup work) — EXCEPT the vLLM-version-supports-this-architecture\n  check, which is new and must not be skipped.\n- **Same non-negotiables as `feat-1`/`feat-2`**: pinned HF revision\n  (REQ-007), anonymous internal-only endpoint (REQ-008), systemd-only\n  operation (REQ-009).\n- **Comparison is the point.** ACC-011 reuses the exact `feat-1`/`feat-2`\n  coding-task examples so Qwen3.8-27B's quality (and its much larger\n  context ceiling) can be judged head-to-head against DeepSeek-V4 and\n  GLM-5.2 on the user's real workloads.\n- **Why Ollama/llama.cpp was ruled out for this feature** (from the\n  chat session preceding this feature's creation): the vendor card only\n  documents the YaRN extension for vLLM/SGLang/TokenSpeed. GGUF/Ollama\n  quantizations do exist for this model, but Qwen3.8-27B's hybrid\n  Gated DeltaNet linear-attention blocks plus its unusual\n  `partial_rotary_factor`/`mrope_section` rotary setup make it materially\n  more likely that llama.cpp's independent YaRN implementation would\n  silently diverge from the vendor-validated behavior, versus a standard\n  dense-attention model. This can be revisited later as a separate\n  feature if a specific need for an Ollama-served path emerges.\n\n### Related ADRs\n\n- None (infrastructure/deployment work, tracked in this repo using the\n  feature-folder convention, same as `feat-1`/`feat-2`)\n\n### Task List\n\n#### Phase 0: Environment prep (mostly inherited from feat-1/feat-2)\n\n- [ ] Task 0.1: Confirm remaining disk headroom on `/data` for\n  Qwen3.8-27B weights (~54GB BF16) after `feat-1`/`feat-2` downloads —\n  depends on: none — status: not-started\n- [ ] Task 0.2: Confirm the installed/available vLLM version actually\n  supports Qwen3.8-27B's architecture (`qwen3_5` tag, hybrid Gated\n  DeltaNet + Gated Attention). This is a brand-new architecture as of\n  this feature's creation date (2026-08-22) — do NOT assume support,\n  check the changelog/release notes and, if needed, upgrade vLLM —\n  depends on: none — status: not-started\n- [ ] Task 0.3: Reuse `feat-1`/`feat-2`'s validated GPU/driver/CUDA\n  (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) and HF access/token/\n  download tooling (`hf` CLI, `hf_transfer`) — no new work unless Task\n  0.2 requires a toolchain change — depends on: none — status: not-started\n- [ ] Task 0.4: Choose and record the pinned HF revision/commit for\n  `Qwen/Qwen3.8-27B` (latest `main` as of 2026-08-22 model-card review:\n  `1d4bf0f`; re-confirm and pin the actual full commit hash from the box\n  at download time) — depends on: Task 0.3 — status: not-started\n\n#### Phase 1: Baseline correctness smoke test (native context, before YaRN)\n\n- [ ] Task 1.1: Bring up Qwen3.8-27B on vLLM at native context (262,144 or\n  smaller for a quick check) on the Dell 7960T's SM120 GPUs, no YaRN\n  override yet — depends on: Task 0.2, Task 0.4 — status: not-started\n- [ ] Task 1.2: Temperature=0 smoke test — verify coherent, non-degenerate\n  output (explicitly check against the `feat-1`/`feat-2` degenerate\n  signature: a single frozen token repeated at every decode position),\n  and verify tool-calling + `enable_thinking`/`reasoning_effort` work at\n  native context — depends on: Task 1.1 — status: not-started\n- [ ] Task 1.3: Record the outcome. If vLLM produces degenerate output\n  (unexpected given the different kernel class, but not impossible),\n  fall back to spiking SGLang next, mirroring `feat-2`'s Phase 1\n  approach — depends on: Task 1.2 — status: not-started\n\n#### Phase 2: Context extension + capacity/coexistence measurement\n\n- [ ] Task 2.1: Apply the YaRN `rope_parameters` override (see Design\n  Notes table) targeting 768K context; measure per-GPU VRAM/KV-cache\n  usage and free headroom at that context size — depends on: Task 1.3 —\n  status: not-started\n- [ ] Task 2.2: If Task 2.1's per-GPU margin clears the adopted\n  safety-margin policy (>=15% free VRAM per GPU, or >=10 GiB absolute,\n  whichever is greater) with room to spare, step upward (896K, then 1M)\n  and re-measure at each step until the policy is no longer cleared —\n  choose the highest context size that still clears it as the production\n  target (may be 768K, may be higher) — depends on: Task 2.1 —\n  status: not-started\n- [ ] Task 2.3: Determine minimum GPU/tensor-parallel count needed for\n  the chosen production context size, and measure actual free VRAM\n  WHILE `feat-1`/`feat-2`'s services are concurrently running, to decide\n  REQ-010's coexistence-vs-exclusive question with real numbers —\n  depends on: Task 2.2 — status: not-started\n\n#### Phase 3: Precision decision\n\n- [ ] Task 3.1: Confirm BF16 as the production precision by default\n  (expected outcome given Design Notes) — depends on: Task 2.3 —\n  status: not-started\n- [ ] Task 3.2: (Optional, only if Task 2.2/2.3 data suggests a benefit)\n  Evaluate an FP8 (or similar) variant for throughput or additional\n  context/coexistence headroom, with an explicit quality-impact check\n  before adopting it over BF16 — depends on: Task 3.1 — status: not-started\n\n#### Phase 4: Full deployment\n\n- [ ] Task 4.1: Install vLLM + Qwen3.8-27B as a systemd service (`--user`\n  + lingering, following `feat-2`'s pattern unless Task 2.3 dictates a\n  system-wide unit instead) with the chosen production context, YaRN\n  config, precision, and GPU placement — depends on: Task 3.1 —\n  status: not-started\n- [ ] Task 4.2: Start the service; curl smoke test against\n  `/v1/chat/completions` at the production context size — verify\n  tool-calls and all thinking-control modes — depends on: Task 4.1 —\n  status: not-started\n- [ ] Task 4.3: Validate the finalized production context size end-to-end\n  (a real filled-context request, not just a load-time VRAM probe)\n  works without OOM — depends on: Task 4.2 — status: not-started\n\n#### Phase 5: Integration\n\n- [ ] Task 5.1: Connect OpenWebUI and OpenCode to the Qwen3.8-27B endpoint\n  as a separate model entry — depends on: Task 4.3 — status: not-started\n- [ ] Task 5.2: User runs the same coding-task examples from `feat-1`/\n  `feat-2` against this endpoint for a direct three-way quality\n  comparison — depends on: Task 5.1 — status: not-started\n\n## Progress\n\n### Current Status\n\n**As of 2026-08-22**: Feature created, planning stage. No tasks started\nyet.\n\n### Recent Updates\n\n#### 2026-08-22\n- Completed: Feature scoped and drafted, following the `feat-2` structure\n  and template. Key decisions captured from the preceding chat session\n  (production-serving goal, 768K floor with stretch to 1M, independent/\n  possibly-concurrent relationship to `feat-1`/`feat-2`, vLLM as primary\n  engine, BF16-first precision, vision/video explicitly out of scope).\n- Next: Start Phase 0 (disk headroom check, vLLM version/architecture\n  support check, HF revision pin).\n- Notes: Latest `main` commit on `Qwen/Qwen3.8-27B` at feature-creation\n  time was `1d4bf0f` (README-only); actual weights are unchanged since\n  the initial upload (`72a217a`/`6714f56`).\n\n### Decisions Made\n\n- **2026-08-22**: Feature goal is production serving (systemd service +\n  OpenCode/OpenWebUI wiring + quality comparison), not just an evaluation\n  spike — matching the bar set by `feat-1`/`feat-2`.\n- **2026-08-22**: Context target is a 768K floor, not a hard ceiling —\n  push higher (up to the model's 1M native max) if per-GPU VRAM safety\n  margin allows, rather than stopping at 768K by default.\n- **2026-08-22**: This feature is independent of `feat-1`/`feat-2` and\n  may run concurrently with them on shared GPUs, given Qwen3.8-27B's much\n  smaller footprint — to be confirmed empirically (Task 2.3), not\n  assumed.\n- **2026-08-22**: vLLM is the starting engine (matches the vendor's\n  documented YaRN path and `feat-1`'s default), with only a lightweight\n  native-context smoke test as insurance — no mandatory full multi-engine\n  SM120 spike phase, since Qwen3.8's Gated DeltaNet architecture is a\n  different kernel class from the DSA/sparse-MLA bug that hit\n  `feat-1`/`feat-2` (`vllm-project/vllm#52938`).\n- **2026-08-22**: Vision-language (image/video) capability is explicitly\n  out of scope for this feature — text/coding use only.\n- **2026-08-22**: Full BF16 precision is the default target (the model\n  fits VRAM comfortably); quantization is opportunistic, adopted only if\n  empirically justified — NOT a forced compromise like `feat-2`'s GLM-5.2\n  quant decision.\n- **2026-08-22**: Ollama/llama.cpp (GGUF) was explicitly ruled out as the\n  serving path for this feature — the vendor only documents the YaRN\n  long-context extension for vLLM/SGLang/TokenSpeed, and Qwen3.8-27B's\n  non-standard hybrid/partial-rotary rotary setup makes an unofficial\n  llama.cpp YaRN override judged too high-risk versus the officially\n  validated frameworks.\n\n### Related PRs / Commits\n\n- None yet.\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 4.7s)

_Thinking:_



**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md"
}
```

**Output:**
```
true
```

---

## Assistant (Build · Claude Sonnet 5 · 3.4s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git diff --stat .specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md 2>/dev/null; git status --porcelain .specmgr/feat/feat-3-qwen3.8-27b-large-context/"
}
```

**Output:**
```
?? .specmgr/feat/feat-3-qwen3.8-27b-large-context/

```

---

## Assistant (Build · Claude Sonnet 5 · 2.8s)

Let me do a quick sanity read to confirm the formatted output is clean.

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "limit": 40
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-22
3: id: feat-3-qwen3.8-27b-large-context
4: status: planning
5: updated: 2026-08-22
6: version: 1.0.0
7: ---
8: 
9: # Feature: On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI
10: 
11: ## Plan
12: 
13: ### Overview
14: 
15: Deploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,
16: Apache-2.0) on the existing on-prem Dell 7960T behind an OpenAI-compatible
17: API, for use as a coding model via OpenCode and OpenWebUI, with its context
18: window extended well past the 262,144-token native limit via the vendor's
19: documented YaRN `rope_parameters` override. Target is a **768K-token floor**
20: (786,432 tokens = native context x3), pushing toward the model's advertised
21: 1,048,576-token (1M) ceiling if per-GPU VRAM safety margin allows.
22: 
23: Unlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit this
24: box), Qwen3.8-27B is small enough at full BF16 precision (~54GB weights)
25: to fit the 384GB VRAM pool with enormous headroom left over for KV cache —
26: so this feature does not start from a quality-vs-capacity compromise.
27: Quantization (e.g. FP8) is not required and stays optional, considered only
28: if empirical data shows it meaningfully helps context headroom or
29: throughput without a demonstrated quality cost.
30: 
31: This feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`
32: (GLM-5.2) — it does not replace either, and given Qwen3.8-27B's much
33: smaller footprint it may be able to run concurrently alongside them on a
34: GPU subset rather than needing an exclusive swap (to be determined
35: empirically, see Design Notes).
36: 
37: Qwen3.8-27B is a native vision-language model (image + video
38: understanding), but this feature scopes that capability OUT: only
39: text/coding use via OpenCode is targeted and validated here.
40: 

(Showing lines 1-40 of 420. Use offset=41 to continue.)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 9.6s)

Looks clean. The feature has been created.

## Summary

Created **`.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md`**, following the same structure as `feat-1`/`feat-2` (frontmatter, Overview, Requirements, Acceptance Criteria, Scope, Dependencies, Design Notes, Task List, Progress/Decisions Made).

**Key content:**
- **Goal**: Production serving of `Qwen/Qwen3.8-27B` via vLLM on the Dell 7960T, OpenCode/OpenWebUI-wired, with the same rigor bar as feat-1/feat-2 (12 REQs, 11 ACCs)
- **Context**: 768K floor, explicitly pushed higher (toward the 1M native ceiling) if per-GPU VRAM safety margin allows — reusing feat-2's ≥15%/≥10 GiB policy
- **Precision**: BF16-first (no forced quant, unlike GLM-5.2) — quantization only if empirically justified
- **Engine**: vLLM as primary, with only a lightweight native-context smoke test (Phase 1) as insurance, since Qwen3.8's Gated DeltaNet architecture differs from the DSA/sparse-MLA bug class that hit feat-1/feat-2
- **Relationship to feat-1/feat-2**: independent, likely-concurrent (to be measured, not assumed) given the much smaller footprint
- **Scope exclusions**: vision/video capability untested, Ollama/llama.cpp ruled out (only vLLM/SGLang/TokenSpeed have vendor-documented YaRN support; the hybrid/partial-rotary architecture makes an unofficial llama.cpp override too risky)
- **Task List**: 5 phases (env prep → baseline smoke test → context extension + coexistence measurement → precision decision → deployment → integration/comparison), all currently `not-started`
- All strategic decisions from our discussion are logged under **Decisions Made** with today's date

Ran `specmgr_mdformat` to normalize formatting. The folder also has an empty `bin/` subdirectory ready for scripts, matching feat-1/feat-2's convention.

---

## User

use mdformat on the readme

---

## Assistant (Build · Claude Sonnet 5 · 5.6s)

_Thinking:_



**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md"
}
```

**Output:**
```
false
```

---

## Assistant (Build · Claude Sonnet 5 · 3.2s)

Ran `mdformat` on `.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md` — returned `false`, meaning the file was already formatted (no changes needed; this confirms the formatting I applied earlier already stuck).

---

## User

what is the next step?

---

## Assistant (Build · Claude Sonnet 5 · 8.9s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "hostname; nvidia-smi -L 2>&1 | head -5; df -h /data 2>&1 | head -5; which vllm 2>&1; python3 -c \"import vllm; print(vllm.__version__)\" 2>&1"
}
```

**Output:**
```
nxt
GPU 0: NVIDIA RTX PRO 5000 Blackwell Generation Laptop GPU (UUID: GPU-6873d16d-08da-b646-40c4-307edde6e390)
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv  935G  695G  193G  79% /
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import vllm; print(vllm.__version__)
    ^^^^^^^^^^^
ModuleNotFoundError: No module named 'vllm'

```

---

## Assistant (Build · Claude Sonnet 5 · 10.5s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "ls /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/bin/ 2>&1 | head -20"
}
```

**Output:**
```
00-fix-vllm-flash-service.sh
01-dump-vllm-stacks.sh
02-fix-vllm-flash-offline.sh
03-fallback-native-quant.sh
04-fix-cuda-toolkit-skew.sh
05-fix-missing-venv-path.sh
06-fix-attention-backend-sm120.sh
07-fix-cudart-symlinks.sh
08-diag-enforce-eager.sh
09-diag-dp-ep.sh
10-upgrade-vllm-flashinfer.sh
11-revert-dp-ep-and-retest.sh
12-diag-disable-deepgemm.sh
13-rollback-vllm-flashinfer.sh
14-remove-deepgemm-env-and-retest.sh
15-fix-cuda-toolkit-skew-again.sh
16-snapshot-baseline.sh
17-diag-no-fp8-kvcache.sh
18-build-clean-venv.sh
19-diag-clean-venv-unit.sh

```

---

## Assistant (Build · Claude Sonnet 5 · 25.1s)

_Thinking:_



Quick reality check first: this session's shell isn't the Dell 7960T target box — it's a different machine (`hostname: nxt`, single RTX PRO 5000 Blackwell laptop GPU, no `/data`, no vLLM installed). So I can't directly execute Phase 0 checks here; they need to run on the actual deployment box.

**Next step per the task list: Phase 0 environment prep.** The most useful thing I can do from here is draft the check script for you to run on the Dell 7960T (same pattern as feat-1/feat-2's `bin/` scripts), covering:

- **Task 0.1**: disk headroom on `/data`
- **Task 0.2**: installed vLLM version + whether it supports Qwen3.8-27B's architecture (`qwen3_5` tag / hybrid Gated DeltaNet)
- **Task 0.3**: confirm GPU/driver/CUDA/HF tooling already validated by feat-1/feat-2 is still in place

**Tool: write**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/00-check-env.sh",
  "content": "#!/usr/bin/env bash\n# feat-3-qwen3.8-27b-large-context — Phase 0 environment check\n#\n# Covers Task 0.1 (disk headroom), Task 0.2 (vLLM version / Qwen3.8\n# architecture support), Task 0.3 (confirm GPU/driver/CUDA/HF tooling\n# already validated by feat-1/feat-2 is still in place).\n#\n# Read-only: does not download weights, does not modify anything.\n# Run this ON THE DELL 7960T, not on a dev machine.\n\nset -euo pipefail\n\necho \"=== Task 0.1: disk headroom on /data ===\"\ndf -h /data || echo \"WARNING: /data not found on this host — is this the Dell 7960T?\"\necho\n\necho \"=== Task 0.3: GPUs ===\"\nnvidia-smi -L || echo \"WARNING: nvidia-smi not found or no GPUs visible\"\necho\nnvidia-smi --query-gpu=index,name,driver_version,memory.total,memory.free --format=csv || true\necho\n\necho \"=== Task 0.3: CUDA toolkit ===\"\nnvcc --version 2>/dev/null || echo \"nvcc not on PATH (may still be fine if only the driver/runtime matters)\"\necho\n\necho \"=== Task 0.2: vLLM version ===\"\nVLLM_VERSION=\"$(python3 -c 'import vllm; print(vllm.__version__)' 2>&1)\" || true\necho \"vllm.__version__ = ${VLLM_VERSION}\"\necho\n\necho \"=== Task 0.2: does this vLLM build know about Qwen3.8 / qwen3_5 / Gated DeltaNet? ===\"\npython3 - <<'PYEOF' 2>&1 || true\nimport sys\ntry:\n    from vllm.model_executor.models.registry import ModelRegistry\n    names = sorted(ModelRegistry.get_supported_archs())\n    hits = [n for n in names if \"qwen3\" in n.lower() or \"deltanet\" in n.lower() or \"qwen3_5\" in n.lower()]\n    print(\"Qwen3.x / DeltaNet-related architectures registered:\")\n    for h in hits:\n        print(\" -\", h)\n    if not hits:\n        print(\"NONE FOUND — this vLLM build likely does NOT support Qwen3.8-27B yet.\")\nexcept Exception as e:\n    print(f\"Could not introspect vLLM model registry: {e!r}\")\n    sys.exit(0)\nPYEOF\necho\n\necho \"=== Task 0.3: HF CLI / token ===\"\nhf --version 2>/dev/null || huggingface-cli --version 2>/dev/null || echo \"hf/huggingface-cli not found on PATH\"\nhf auth whoami 2>/dev/null || huggingface-cli whoami 2>/dev/null || echo \"Not logged in to Hugging Face (or CLI subcommand differs by version)\"\necho\n\necho \"=== Task 0.3: hf_transfer ===\"\npython3 -c \"import hf_transfer; print('hf_transfer OK')\" 2>&1 || echo \"hf_transfer not installed\"\necho\n\necho \"=== Task 4.1 preview: feat-1/feat-2 services currently running (for REQ-010 coexistence check later) ===\"\nsystemctl --user list-units --type=service --state=running 2>/dev/null | grep -iE 'vllm|glm|deepseek|llama' || echo \"No matching user services found running (or systemctl --user not available in this shell)\"\nsystemctl list-units --type=service --state=running 2>/dev/null | grep -iE 'vllm|glm|deepseek|llama' || true\necho\n\necho \"=== Done. Paste this whole output back for review. ===\"\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 3.4s)

**Tool: bash**

**Input:**
```json
{
  "command": "chmod +x \"/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin/00-check-env.sh\""
}
```

**Output:**
```
(no output)
```

---

## Assistant (Build · Claude Sonnet 5 · 10.2s)

Now let me mark Task 0.1–0.3 as in-progress in the feature README to reflect that this step has started.

**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "oldString": "- [ ] Task 0.1: Confirm remaining disk headroom on `/data` for\n  Qwen3.8-27B weights (~54GB BF16) after `feat-1`/`feat-2` downloads —\n  depends on: none — status: not-started\n- [ ] Task 0.2: Confirm the installed/available vLLM version actually\n  supports Qwen3.8-27B's architecture (`qwen3_5` tag, hybrid Gated\n  DeltaNet + Gated Attention). This is a brand-new architecture as of\n  this feature's creation date (2026-08-22) — do NOT assume support,\n  check the changelog/release notes and, if needed, upgrade vLLM —\n  depends on: none — status: not-started\n- [ ] Task 0.3: Reuse `feat-1`/`feat-2`'s validated GPU/driver/CUDA\n  (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) and HF access/token/\n  download tooling (`hf` CLI, `hf_transfer`) — no new work unless Task\n  0.2 requires a toolchain change — depends on: none — status: not-started",
  "newString": "- [ ] Task 0.1: Confirm remaining disk headroom on `/data` for\n  Qwen3.8-27B weights (~54GB BF16) after `feat-1`/`feat-2` downloads —\n  depends on: none — status: in-progress — `bin/00-check-env.sh` drafted\n  2026-08-22, to be run on the Dell 7960T (this session's shell is a\n  different machine — hostname `nxt`, single RTX PRO 5000 Blackwell\n  laptop GPU, no `/data` — confirmed NOT the target box)\n- [ ] Task 0.2: Confirm the installed/available vLLM version actually\n  supports Qwen3.8-27B's architecture (`qwen3_5` tag, hybrid Gated\n  DeltaNet + Gated Attention). This is a brand-new architecture as of\n  this feature's creation date (2026-08-22) — do NOT assume support,\n  check the changelog/release notes and, if needed, upgrade vLLM —\n  depends on: none — status: in-progress — `bin/00-check-env.sh`\n  includes a vLLM `ModelRegistry` introspection check, to be run on the\n  box\n- [ ] Task 0.3: Reuse `feat-1`/`feat-2`'s validated GPU/driver/CUDA\n  (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) and HF access/token/\n  download tooling (`hf` CLI, `hf_transfer`) — no new work unless Task\n  0.2 requires a toolchain change — depends on: none — status: in-progress\n  — same `bin/00-check-env.sh` run covers this"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 3.3s)

**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md"
}
```

**Output:**
```
false
```

---

## Assistant (Build · Claude Sonnet 5 · 7.8s)

## Next step

**Run `bin/00-check-env.sh` on the Dell 7960T** (not here — this shell is a different machine, confirmed via `hostname`/`nvidia-smi`/missing `/data`). It's read-only and checks:

1. **Task 0.1** — free space on `/data` (need ~54 GB for Qwen3.8-27B BF16 weights)
2. **Task 0.2** — installed vLLM version, and whether its model registry already recognizes a Qwen3.8/`qwen3_5`/Gated-DeltaNet architecture (this is a brand-new arch — genuinely unknown until checked, not a formality)
3. **Task 0.3** — GPU/driver/CUDA and HF CLI/token/`hf_transfer`, which feat-1/feat-2 already validated on this box, just re-confirming nothing drifted
4. A preview check for **REQ-010** (coexistence) — lists any feat-1/feat-2 services (`vllm`, `glm`, `deepseek`, `llama`) currently running, so we start collecting real data on shared-GPU usage from day one

Paste the script's output back to me and I'll:
- Pin the exact HF revision (Task 0.4)
- If vLLM doesn't yet support the architecture, figure out the upgrade path before touching anything else
- Move into Phase 1 (native-context smoke test) once Phase 0 is confirmed clean

I marked Tasks 0.1–0.3 as `in-progress` in the README to reflect this.

---

## User

create a gh issue and use the "overview" of the README as the description of the issue

---

## Assistant (Build · Claude Sonnet 5 · 10.0s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh auth status 2>&1; echo \"---\"; gh issue list --limit 20 2>&1; echo \"---repo---\"; gh repo view --json nameWithOwner 2>&1"
}
```

**Output:**
```
github.com
  ✓ Logged in to github.com account dfch (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
---
1	OPEN	On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI		2026-08-18T09:42:55Z
---repo---
{"nameWithOwner":"dfch/biz.dfch.LlmOps"}

```

---

## Assistant (Build · Claude Sonnet 5 · 6.7s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "offset": 13,
  "limit": 28
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md</path>
<type>file</type>
<content>
13: ### Overview
14: 
15: Deploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,
16: Apache-2.0) on the existing on-prem Dell 7960T behind an OpenAI-compatible
17: API, for use as a coding model via OpenCode and OpenWebUI, with its context
18: window extended well past the 262,144-token native limit via the vendor's
19: documented YaRN `rope_parameters` override. Target is a **768K-token floor**
20: (786,432 tokens = native context x3), pushing toward the model's advertised
21: 1,048,576-token (1M) ceiling if per-GPU VRAM safety margin allows.
22: 
23: Unlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit this
24: box), Qwen3.8-27B is small enough at full BF16 precision (~54GB weights)
25: to fit the 384GB VRAM pool with enormous headroom left over for KV cache —
26: so this feature does not start from a quality-vs-capacity compromise.
27: Quantization (e.g. FP8) is not required and stays optional, considered only
28: if empirical data shows it meaningfully helps context headroom or
29: throughput without a demonstrated quality cost.
30: 
31: This feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`
32: (GLM-5.2) — it does not replace either, and given Qwen3.8-27B's much
33: smaller footprint it may be able to run concurrently alongside them on a
34: GPU subset rather than needing an exclusive swap (to be determined
35: empirically, see Design Notes).
36: 
37: Qwen3.8-27B is a native vision-language model (image + video
38: understanding), but this feature scopes that capability OUT: only
39: text/coding use via OpenCode is targeted and validated here.
40: 

(Showing lines 13-40 of 426. Use offset=41 to continue.)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 8.6s)

_Thinking:_



**Tool: write**

**Input:**
```json
{
  "filePath": "/tmp/opencode/feat-3-issue-body.md",
  "content": "Deploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,\nApache-2.0) on the existing on-prem Dell 7960T behind an OpenAI-compatible\nAPI, for use as a coding model via OpenCode and OpenWebUI, with its context\nwindow extended well past the 262,144-token native limit via the vendor's\ndocumented YaRN `rope_parameters` override. Target is a **768K-token floor**\n(786,432 tokens = native context x3), pushing toward the model's advertised\n1,048,576-token (1M) ceiling if per-GPU VRAM safety margin allows.\n\nUnlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit this\nbox), Qwen3.8-27B is small enough at full BF16 precision (~54GB weights)\nto fit the 384GB VRAM pool with enormous headroom left over for KV cache —\nso this feature does not start from a quality-vs-capacity compromise.\nQuantization (e.g. FP8) is not required and stays optional, considered only\nif empirical data shows it meaningfully helps context headroom or\nthroughput without a demonstrated quality cost.\n\nThis feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`\n(GLM-5.2) — it does not replace either, and given Qwen3.8-27B's much\nsmaller footprint it may be able to run concurrently alongside them on a\nGPU subset rather than needing an exclusive swap (to be determined\nempirically, see Design Notes).\n\nQwen3.8-27B is a native vision-language model (image + video\nunderstanding), but this feature scopes that capability OUT: only\ntext/coding use via OpenCode is targeted and validated here.\n\n---\nFull spec: `.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md`\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 5.8s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh issue create --title \"On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI\" --body-file /tmp/opencode/feat-3-issue-body.md"
}
```

**Output:**
```
https://github.com/dfch/biz.dfch.LlmOps/issues/2

```

---

## Assistant (Build · Claude Sonnet 5 · 4.6s)

Created **[#2](https://github.com/dfch/biz.dfch.LlmOps/issues/2)** — "On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI", body = the feature's Overview section verbatim (plus a pointer back to the full spec).

Now let me record the issue link in the feature README, mirroring feat-1's `github_issue` frontmatter convention.

**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "oldString": "---\ncreated: 2026-08-22\nid: feat-3-qwen3.8-27b-large-context\nstatus: planning\nupdated: 2026-08-22\nversion: 1.0.0\n---",
  "newString": "---\ncreated: 2026-08-22\ngithub_issue: 2\nid: feat-3-qwen3.8-27b-large-context\nstatus: planning\nupdated: 2026-08-22\nversion: 1.0.0\n---"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 4.1s)

**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "oldString": "### Related PRs / Commits\n\n- None yet.",
  "newString": "### Related PRs / Commits\n\n- [Issue #2](https://github.com/dfch/biz.dfch.LlmOps/issues/2): On-prem\n  Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —\n  description mirrors this README's Overview section"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 2.6s)

**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md"
}
```

**Output:**
```
false
```

---

## Assistant (Build · Claude Sonnet 5 · 5.2s)

Done:

- Created **GitHub issue [#2](https://github.com/dfch/biz.dfch.LlmOps/issues/2)**, description = the feature README's Overview section verbatim.
- Added `github_issue: 2` to the README frontmatter (mirroring feat-1's convention).
- Linked it under **Related PRs / Commits**.

One note worth flagging: `AGENTS.md`'s "Key Conventions" states *"No GitHub issues — features tracked directly in repo (user instruction)"*, yet feat-1 already has issue #1 and now feat-3 has #2 — so that convention line appears stale/inconsistent with actual practice. I went ahead per your explicit instruction, but you may want to update `AGENTS.md` to reflect that GitHub issues are in fact used (at least as a secondary pointer alongside the README).

---

## User

create the issue again, then you should get an "id 3"

---

## Assistant (Build · Claude Sonnet 5 · 8.2s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh issue create --title \"On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI\" --body-file /tmp/opencode/feat-3-issue-body.md"
}
```

**Output:**
```
https://github.com/dfch/biz.dfch.LlmOps/issues/3

```

---

## Assistant (Build · Claude Sonnet 5 · 19.9s)

_Thinking:_



Created **[#3](https://github.com/dfch/biz.dfch.LlmOps/issues/3)** — same title and body (Overview section) as before.

Note: this is now a **duplicate** of issue #2 (which I created in the previous turn and already linked in the README's frontmatter/Related PRs section). Do you want me to:

**Tool: question**

**Input:**
```json
{
  "questions": [
    {
      "question": "Issue #2 and #3 are now duplicates of each other (same title/body). How should I reconcile this?",
      "header": "Duplicate issue cleanup",
      "options": [
        {
          "label": "Close #2, keep #3 as canonical (Recommended)",
          "description": "Close #2 with a 'duplicate, see #3' comment, update the README's github_issue frontmatter and Related PRs link to point to #3"
        },
        {
          "label": "Close #3, keep #2",
          "description": "Close the newly-created #3 as a duplicate, leave the README pointing at #2 (no change needed)"
        },
        {
          "label": "Keep both open",
          "description": "Leave both open as-is; I'll only update the README to note both exist"
        }
      ]
    }
  ]
}
```

**Output:**
```
User has answered your questions: "Issue #2 and #3 are now duplicates of each other (same title/body). How should I reconcile this?"="Close #2, keep #3 as canonical (Recommended)". You can now continue with the user's answers in mind.
```

---

## Assistant (Build · Claude Sonnet 5 · 5.2s)

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh issue close 2 --comment \"Duplicate, superseded by #3 (created immediately after this one for the same feature).\""
}
```

**Output:**
```
✓ Closed issue dfch/biz.dfch.LlmOps#2 (On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI)

```

---

## Assistant (Build · Claude Sonnet 5 · 3.5s)

Now updating the README to point at #3 instead of #2:

**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "oldString": "github_issue: 2",
  "newString": "github_issue: 3"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 5.3s)

**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "oldString": "### Related PRs / Commits\n\n- [Issue #2](https://github.com/dfch/biz.dfch.LlmOps/issues/2): On-prem\n  Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —\n  description mirrors this README's Overview section",
  "newString": "### Related PRs / Commits\n\n- [Issue #3](https://github.com/dfch/biz.dfch.LlmOps/issues/3): On-prem\n  Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —\n  description mirrors this README's Overview section. (Issue #2 was an\n  accidental duplicate, created moments earlier with identical title/\n  body — closed in favor of #3.)"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 3.5s)

**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md"
}
```

**Output:**
```
false
```

---

## Assistant (Build · Claude Sonnet 5 · 3.7s)

Done:

- **#2** closed as duplicate (with a comment pointing to #3)
- **#3** is now the canonical issue: https://github.com/dfch/biz.dfch.LlmOps/issues/3
- README frontmatter (`github_issue: 3`) and the Related PRs / Commits section updated accordingly, noting the #2 duplicate/closure for the record

---

## User

now rename gh issue 2 to reflect the name of feat-2 and use the overview of feat-2 README as the description for gh issue 2. Open the issue afterwards

---

## Assistant (Build · Claude Sonnet 5 · 32.9s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md",
  "offset": 9,
  "limit": 26
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md</path>
<type>file</type>
<content>
9: # Feature: On-prem GLM-5.2 serving for OpenCode + OpenWebUI
10: 
11: ## Plan
12: 
13: ### Overview
14: 
15: Deploy GLM-5.2 (`zai-org/GLM-5.2`, MIT) on the existing on-prem Dell 7960T
16: behind an OpenAI-compatible API, for use as a coding model via OpenCode and
17: OpenWebUI. This is the alternative/fallback model deferred from `feat-1`
18: (DeepSeek-V4). Quality is the priority over speed. GLM-5.2 is a 744B-param
19: MoE (40B active), 1M context; official Z.ai weights are BF16 (~1.5 TB),
20: which does NOT fit in the box's 384 GB VRAM nor in the 896 GB VRAM+RAM pool
21: at native precision — so a quantized build is required. Because no native
22: sub-BF16 checkpoint exists, GGUF requantization is explicitly accepted for
23: this model (the `feat-1` "no requant" rule is DeepSeek-only and does not
24: apply here); unsloth ships day-zero Dynamic GGUFs at `unsloth/GLM-5.2-GGUF`.
25: 
26: Crucially, this box is heavily over-provisioned relative to unsloth's stated
27: minimums (their reference config runs the 2-bit quant on a single 24 GB GPU
28: 
29: - 256 GB RAM). With 896 GB total (384 VRAM + 512 RAM), the **near-lossless
30:   4-bit (`UD-Q4_K_XL`, 372-475 GB) and 5-bit (`UD-Q5_K_XL`, 570 GB)** quants
31:   both fit comfortably — so, unlike DeepSeek-V4-Pro, GLM-5.2 does NOT force a
32:   lossy precision compromise. The model repo and the chosen quant are both
33:   pinned to a specific revision for reproducibility.
34: 

(Showing lines 9-34 of 2131. Use offset=35 to continue.)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 40.5s)

_Thinking:_



**Tool: write**

**Input:**
```json
{
  "filePath": "/tmp/opencode/feat-2-issue-body.md",
  "content": "Deploy GLM-5.2 (`zai-org/GLM-5.2`, MIT) on the existing on-prem Dell 7960T\nbehind an OpenAI-compatible API, for use as a coding model via OpenCode and\nOpenWebUI. This is the alternative/fallback model deferred from `feat-1`\n(DeepSeek-V4). Quality is the priority over speed. GLM-5.2 is a 744B-param\nMoE (40B active), 1M context; official Z.ai weights are BF16 (~1.5 TB),\nwhich does NOT fit in the box's 384 GB VRAM nor in the 896 GB VRAM+RAM pool\nat native precision — so a quantized build is required. Because no native\nsub-BF16 checkpoint exists, GGUF requantization is explicitly accepted for\nthis model (the `feat-1` \"no requant\" rule is DeepSeek-only and does not\napply here); unsloth ships day-zero Dynamic GGUFs at `unsloth/GLM-5.2-GGUF`.\n\nCrucially, this box is heavily over-provisioned relative to unsloth's stated\nminimums (their reference config runs the 2-bit quant on a single 24 GB GPU\n+ 256 GB RAM). With 896 GB total (384 VRAM + 512 RAM), the **near-lossless\n4-bit (`UD-Q4_K_XL`, 372-475 GB) and 5-bit (`UD-Q5_K_XL`, 570 GB)** quants\nboth fit comfortably — so, unlike DeepSeek-V4-Pro, GLM-5.2 does NOT force a\nlossy precision compromise. The model repo and the chosen quant are both\npinned to a specific revision for reproducibility.\n\n---\nFull spec: `.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md`\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 11.6s)

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh issue edit 2 --title \"On-prem GLM-5.2 serving for OpenCode + OpenWebUI\" --body-file /tmp/opencode/feat-2-issue-body.md && gh issue reopen 2"
}
```

**Output:**
```
https://github.com/dfch/biz.dfch.LlmOps/issues/2
✓ Reopened issue dfch/biz.dfch.LlmOps#2 (On-prem GLM-5.2 serving for OpenCode + OpenWebUI)

```

---

## Assistant (Build · Claude Sonnet 5 · 4.1s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh issue list --state all --limit 10"
}
```

**Output:**
```
3	OPEN	On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI		2026-08-22T16:27:05Z
2	OPEN	On-prem GLM-5.2 serving for OpenCode + OpenWebUI		2026-08-22T16:29:54Z
1	OPEN	On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI		2026-08-18T09:42:55Z

```

---

## Assistant (Build · Claude Sonnet 5 · 7.0s)

Done. Issue #2 has been repurposed:

- **Title** → "On-prem GLM-5.2 serving for OpenCode + OpenWebUI"
- **Body** → feat-2's Overview section (fixed one markdown-list artifact from the source README — `24 GB GPU\n\n- 256 GB RAM` was a stray "+"-to-bullet mangling by mdformat's line-wrap, restored to `24 GB GPU + 256 GB RAM`)
- **Reopened**

Current state, all three feature issues aligned 1:1 with their feature folders:

| # | Title | Feature |
|---|---|---|
| [#1](https://github.com/dfch/biz.dfch.LlmOps/issues/1) | On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI | `feat-1` |
| [#2](https://github.com/dfch/biz.dfch.LlmOps/issues/2) | On-prem GLM-5.2 serving for OpenCode + OpenWebUI | `feat-2` |
| [#3](https://github.com/dfch/biz.dfch.LlmOps/issues/3) | On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI | `feat-3` |

Want me to also add a `github_issue: 2` frontmatter field to `feat-2`'s README (feat-1 and feat-3 both have this field, feat-2 currently doesn't)?

---

## User

y

---

## Assistant (Build · Claude Sonnet 5 · 8.0s)

_Thinking:_



**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md",
  "oldString": "---\ncreated: 2026-08-19\nid: feat-2-glm-5.2-onprem-deployment\nstatus: planning\nupdated: 2026-08-20\nversion: 1.0.0\n---",
  "newString": "---\ncreated: 2026-08-19\ngithub_issue: 2\nid: feat-2-glm-5.2-onprem-deployment\nstatus: planning\nupdated: 2026-08-20\nversion: 1.0.0\n---"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 3.9s)

**Tool: specmgr_mdformat**

**Input:**
```json
{
  "path": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md"
}
```

**Output:**
```
false
```

---

## Assistant (Build · Claude Sonnet 5 · 3.4s)

Added `github_issue: 2` to `feat-2`'s frontmatter (no other formatting changes needed). All three feature READMEs now consistently link to their GitHub issue: feat-1 → #1, feat-2 → #2, feat-3 → #3.

---

