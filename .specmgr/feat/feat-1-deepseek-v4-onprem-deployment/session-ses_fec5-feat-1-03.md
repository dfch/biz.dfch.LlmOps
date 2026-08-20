# Running Deepseek v4 models with Ollama

**Session ID:** ses_fec5d7d08ffeq0TI7UgTdUcELC
**Created:** 8/18/2026, 8:50:12 AM
**Updated:** 8/18/2026, 9:56:37 AM

---

## User

I want to use these models with my on-prem install:

https://ollama.com/library/deepseek-v4-flash
https://ollama.com/library/deepseek-v4-pro

At this time, I have Ollama. But I do not know how to run these models with Ollama. 

Exmamine and give options

---

## Assistant (Plan · Claude Sonnet 5 · 5.7s)

_Thinking:_



I'll look into these first before putting together a plan.

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://ollama.com/library/deepseek-v4-flash"
}
```

**Output:**
```
deepseek-v4-flash                                 

[![Ollama](/public/ollama.png)](/)

[Models](/search) [Docs](/docs) [Pricing](/pricing)

[Sign in](/signin) [Download](/download)

[Models](/search) [Download](/download) [Docs](/docs) [Pricing](/pricing) [Sign in](/signin)

[deepseek-v4-flash](/library/deepseek-v4-flash "deepseek-v4-flash")

374.5K  Downloads Updated  2 weeks ago

## DeepSeek-V4-Flash is a preview of the DeepSeek-V4 series, a Mixture-of-Experts model with 284B total parameters and 13B activated, built for efficient reasoning across a 1M-token context window.

DeepSeek-V4-Flash is a preview of the DeepSeek-V4 series, a Mixture-of-Experts model with 284B total parameters and 13B activated, built for efficient reasoning across a 1M-token context window.

Cancel 

tools thinking cloud

Usage

medium

Context

1M tokens

Size

304B parameters

CLI cURL Python JavaScript

[Documentation](https://github.com/ollama/ollama-python) [Documentation](https://github.com/ollama/ollama-js)

ollama run deepseek-v4-flash:cloud

curl http://localhost:11434/api/chat \\
  -d '{
    "model": "deepseek-v4-flash:cloud",
    "messages": \[{"role": "user", "content": "Hello!"}\]
  }'

from ollama import chat

response = chat(
    model='deepseek-v4-flash:cloud',
    messages=\[{'role': 'user', 'content': 'Hello!'}\],
)
print(response.message.content)

import ollama from 'ollama'

const response = await ollama.chat({
  model: 'deepseek-v4-flash:cloud',
  messages: \[{role: 'user', content: 'Hello!'}\],
})
console.log(response.message.content)

## Applications

![Claude Code](/public/claude.png)

Claude Code `ollama launch claude --model deepseek-v4-flash:cloud`

![OpenCode](/public/opencode.png)

OpenCode `ollama launch opencode --model deepseek-v4-flash:cloud`

![Hermes Agent](/public/hermes.png)

Hermes Agent `ollama launch hermes --model deepseek-v4-flash:cloud`

![OpenClaw](/public/openclaw.svg)

OpenClaw `ollama launch openclaw --model deepseek-v4-flash:cloud`

## Models

[View all →](/library/deepseek-v4-flash/tags)

Name

3 models

Size / Usage

Context

Input

[

deepseek-v4-flash:cloud

Medium Usage · 1M context window · Text · 2 weeks ago

](/library/deepseek-v4-flash:cloud)

[deepseek-v4-flash:cloud](/library/deepseek-v4-flash:cloud) 

1M

Text

[

deepseek-v4-flash:0731-cloud

Medium Usage · 1M context window · Text · 2 weeks ago

](/library/deepseek-v4-flash:0731-cloud)

[deepseek-v4-flash:0731-cloud](/library/deepseek-v4-flash:0731-cloud) 

1M

Text

[

deepseek-v4-flash:preview-cloud

Medium Usage · 1M context window · Text · 3 months ago

](/library/deepseek-v4-flash:preview-cloud)

[deepseek-v4-flash:preview-cloud](/library/deepseek-v4-flash:preview-cloud) 

1M

Text

## Readme

![](/assets/library/deepseek-v3/069ccc94-63b0-41e6-b2b3-e8e56068ab1a)

DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence

**DeepSeek-V4-Flash** is a preview of the DeepSeek-V4 series, a Mixture-of-Experts model with 284B total parameters and 13B activated, built for efficient reasoning across a 1M-token context window.

3 Thinking modes:

-   No thinking: used for fast, intuitive answers
-   Thinking: used for careful logical analysis
-   Max thinking: maximum reasoning effort on the hardest problems ![benchmark](/assets/library/deepseek-v4-flash/3252e416-59e1-4e1f-9a8d-4345b58ac28f)

Benchmark (Metric)

V4-Flash Non-Think

V4-Flash High

V4-Flash Max

V4-Pro Non-Think

V4-Pro High

V4-Pro Max

**Knowledge & Reasoning**

MMLU-Pro (EM)

83.0

86.4

86.2

82.9

87.1

**87.5**

SimpleQA-Verified (Pass@1)

23.1

28.9

34.1

45.0

46.2

**57.9**

Chinese-SimpleQA (Pass@1)

71.5

73.2

78.9

75.8

77.7

**84.4**

GPQA Diamond (Pass@1)

71.2

87.4

88.1

72.9

89.1

**90.1**

HLE (Pass@1)

8.1

29.4

34.8

7.7

34.5

**37.7**

LiveCodeBench (Pass@1)

55.2

88.4

91.6

56.8

89.8

**93.5**

Codeforces (Rating)

\-

2816

3052

\-

2919

**3206**

HMMT 2026 Feb (Pass@1)

40.8

91.9

94.8

31.7

94.0

**95.2**

IMOAnswerBench (Pass@1)

41.9

85.1

88.4

35.3

88.0

**89.8**

Apex (Pass@1)

1.0

19.1

33.0

0.4

27.4

**38.3**

Apex Shortlist (Pass@1)

9.3

72.1

85.7

9.2

85.5

**90.2**

**Long Context**

MRCR 1M (MMR)

37.5

76.9

78.7

44.7

83.3

**83.5**

CorpusQA 1M (ACC)

15.5

59.3

60.5

35.6

56.5

**62.0**

**Agentic**

Terminal Bench 2.0 (Acc)

49.1

56.6

56.9

59.1

63.3

**67.9**

SWE Verified (Resolved)

73.7

78.6

79.0

73.6

79.4

**80.6**

SWE Pro (Resolved)

49.1

52.3

52.6

52.1

54.4

**55.4**

SWE Multilingual (Resolved)

69.7

70.2

73.3

69.8

74.1

**76.2**

BrowseComp (Pass@1)

\-

53.5

73.2

\-

80.4

**83.4**

HLE w/ tools (Pass@1)

\-

40.3

45.1

\-

44.7

**48.2**

MCPAtlas (Pass@1)

64.0

67.4

69.0

69.4

**74.2**

73.6

GDPval-AA (Elo)

\-

\-

1395

\-

\-

**1554**

Toolathlon (Pass@1)

40.7

43.5

47.8

46.3

49.0

**51.8**

### Reference

[DeepSeek-V4 technical report](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash/blob/main/DeepSeek_V4.pdf)

Write Preview

<img src="/assets/library/deepseek-v3/069ccc94-63b0-41e6-b2b3-e8e56068ab1a" width="320" /> DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence \*\*DeepSeek-V4-Flash\*\* is a preview of the DeepSeek-V4 series, a Mixture-of-Experts model with 284B total parameters and 13B activated, built for efficient reasoning across a 1M-token context window. 3 Thinking modes: - No thinking: used for fast, intuitive answers - Thinking: used for careful logical analysis - Max thinking: maximum reasoning effort on the hardest problems !\[benchmark\](/assets/library/deepseek-v4-flash/3252e416-59e1-4e1f-9a8d-4345b58ac28f) | Benchmark (Metric) | V4-Flash Non-Think | V4-Flash High | V4-Flash Max | V4-Pro Non-Think | V4-Pro High | V4-Pro Max | | :--- | :---: | :---: | :---: | :---: | :---: | :---: | | \*\*Knowledge & Reasoning\*\* | | | | | | | | MMLU-Pro (EM) | 83.0 | 86.4 | 86.2 | 82.9 | 87.1 | \*\*87.5\*\* | | SimpleQA-Verified (Pass@1) | 23.1 | 28.9 | 34.1 | 45.0 | 46.2 | \*\*57.9\*\* | | Chinese-SimpleQA (Pass@1) | 71.5 | 73.2 | 78.9 | 75.8 | 77.7 | \*\*84.4\*\* | | GPQA Diamond (Pass@1) | 71.2 | 87.4 | 88.1 | 72.9 | 89.1 | \*\*90.1\*\* | | HLE (Pass@1) | 8.1 | 29.4 | 34.8 | 7.7 | 34.5 | \*\*37.7\*\* | | LiveCodeBench (Pass@1) | 55.2 | 88.4 | 91.6 | 56.8 | 89.8 | \*\*93.5\*\* | | Codeforces (Rating) | - | 2816 | 3052 | - | 2919 | \*\*3206\*\* | | HMMT 2026 Feb (Pass@1) | 40.8 | 91.9 | 94.8 | 31.7 | 94.0 | \*\*95.2\*\* | | IMOAnswerBench (Pass@1) | 41.9 | 85.1 | 88.4 | 35.3 | 88.0 | \*\*89.8\*\* | | Apex (Pass@1) | 1.0 | 19.1 | 33.0 | 0.4 | 27.4 | \*\*38.3\*\* | | Apex Shortlist (Pass@1) | 9.3 | 72.1 | 85.7 | 9.2 | 85.5 | \*\*90.2\*\* | | \*\*Long Context\*\* | | | | | | | | MRCR 1M (MMR) | 37.5 | 76.9 | 78.7 | 44.7 | 83.3 | \*\*83.5\*\* | | CorpusQA 1M (ACC) | 15.5 | 59.3 | 60.5 | 35.6 | 56.5 | \*\*62.0\*\* | | \*\*Agentic\*\* | | | | | | | | Terminal Bench 2.0 (Acc) | 49.1 | 56.6 | 56.9 | 59.1 | 63.3 | \*\*67.9\*\* | | SWE Verified (Resolved) | 73.7 | 78.6 | 79.0 | 73.6 | 79.4 | \*\*80.6\*\* | | SWE Pro (Resolved) | 49.1 | 52.3 | 52.6 | 52.1 | 54.4 | \*\*55.4\*\* | | SWE Multilingual (Resolved) | 69.7 | 70.2 | 73.3 | 69.8 | 74.1 | \*\*76.2\*\* | | BrowseComp (Pass@1) | - | 53.5 | 73.2 | - | 80.4 | \*\*83.4\*\* | | HLE w/ tools (Pass@1) | - | 40.3 | 45.1 | - | 44.7 | \*\*48.2\*\* | | MCPAtlas (Pass@1) | 64.0 | 67.4 | 69.0 | 69.4 | \*\*74.2\*\* | 73.6 | | GDPval-AA (Elo) | - | - | 1395 | - | - | \*\*1554\*\* | | Toolathlon (Pass@1) | 40.7 | 43.5 | 47.8 | 46.3 | 49.0 | \*\*51.8\*\* | ### Reference \[DeepSeek-V4 technical report\](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash/blob/main/DeepSeek\_V4.pdf)

Paste, drop or click to upload images (.png, .jpeg, .jpg, .svg, .gif) 

© 2026 Ollama

[Download](/download) [Blog](/blog) [Docs](https://docs.ollama.com) [GitHub](https://github.com/ollama/ollama) [Discord](https://discord.com/invite/ollama) [X (Twitter)](https://twitter.com/ollama) [Contact](mailto:hello@ollama.com) [Careers](https://jobs.ashbyhq.com/ollama) [Privacy](/privacy) [Terms](/terms)

-   [Blog](/blog)
-   [Download](/download)
-   [Docs](https://docs.ollama.com)

-   [GitHub](https://github.com/ollama/ollama)
-   [Discord](https://discord.com/invite/ollama)
-   [X (Twitter)](https://twitter.com/ollama)
-   [Meetups](https://lu.ma/ollama)
-   [Careers](https://jobs.ashbyhq.com/ollama)
-   [Privacy](/privacy)
-   [Terms](/terms)

© 2026 Ollama Inc.
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://ollama.com/library/deepseek-v4-pro"
}
```

**Output:**
```
deepseek-v4-pro                                 

[![Ollama](/public/ollama.png)](/)

[Models](/search) [Docs](/docs) [Pricing](/pricing)

[Sign in](/signin) [Download](/download)

[Models](/search) [Download](/download) [Docs](/docs) [Pricing](/pricing) [Sign in](/signin)

[deepseek-v4-pro](/library/deepseek-v4-pro "deepseek-v4-pro")

339.1K  Downloads Updated  4 days ago

## DeepSeek-V4-Pro is a frontier Mixture-of-Experts model with a large context window and three reasoning modes.

DeepSeek-V4-Pro is a frontier Mixture-of-Experts model with a large context window and three reasoning modes.

Cancel 

tools thinking cloud

Usage

extra high

Context

1M tokens

Size

1.65T parameters

CLI cURL Python JavaScript

[Documentation](https://github.com/ollama/ollama-python) [Documentation](https://github.com/ollama/ollama-js)

ollama run deepseek-v4-pro:cloud

curl http://localhost:11434/api/chat \\
  -d '{
    "model": "deepseek-v4-pro:cloud",
    "messages": \[{"role": "user", "content": "Hello!"}\]
  }'

from ollama import chat

response = chat(
    model='deepseek-v4-pro:cloud',
    messages=\[{'role': 'user', 'content': 'Hello!'}\],
)
print(response.message.content)

import ollama from 'ollama'

const response = await ollama.chat({
  model: 'deepseek-v4-pro:cloud',
  messages: \[{role: 'user', content: 'Hello!'}\],
})
console.log(response.message.content)

## Applications

![Claude Code](/public/claude.png)

Claude Code `ollama launch claude --model deepseek-v4-pro:cloud`

![OpenCode](/public/opencode.png)

OpenCode `ollama launch opencode --model deepseek-v4-pro:cloud`

![Hermes Agent](/public/hermes.png)

Hermes Agent `ollama launch hermes --model deepseek-v4-pro:cloud`

![OpenClaw](/public/openclaw.svg)

OpenClaw `ollama launch openclaw --model deepseek-v4-pro:cloud`

## Models

[View all →](/library/deepseek-v4-pro/tags)

Name

3 models

Size / Usage

Context

Input

[

deepseek-v4-pro:cloud

Extra High Usage · 1M context window · Text · 4 days ago

](/library/deepseek-v4-pro:cloud)

[deepseek-v4-pro:cloud](/library/deepseek-v4-pro:cloud) 

1M

Text

[

deepseek-v4-pro:0813-cloud

Extra High Usage · 1M context window · Text · 4 days ago

](/library/deepseek-v4-pro:0813-cloud)

[deepseek-v4-pro:0813-cloud](/library/deepseek-v4-pro:0813-cloud) 

1M

Text

[

deepseek-v4-pro:preview-cloud

Extra High Usage · 1M context window · Text · 3 months ago

](/library/deepseek-v4-pro:preview-cloud)

[deepseek-v4-pro:preview-cloud](/library/deepseek-v4-pro:preview-cloud) 

1M

Text

## Readme

![](/assets/library/deepseek-v3/069ccc94-63b0-41e6-b2b3-e8e56068ab1a)

**DeepSeek-V4-Pro** is the flagship model in the DeepSeek-V4 series — a Mixture-of-Experts model with 1.6T total parameters and 49B activated, built for frontier-level reasoning across a 1M-token context window.

3 Thinking modes:

-   No thinking: used for fast, intuitive answers
-   Thinking: used for careful logical analysis
-   Max thinking: maximum reasoning effort on the hardest problems

### Reference

[DeepSeek-V4 technical report](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash/blob/main/DeepSeek_V4.pdf)

Write Preview

<img src="/assets/library/deepseek-v3/069ccc94-63b0-41e6-b2b3-e8e56068ab1a" width="320" /> \*\*DeepSeek-V4-Pro\*\* is the flagship model in the DeepSeek-V4 series — a Mixture-of-Experts model with 1.6T total parameters and 49B activated, built for frontier-level reasoning across a 1M-token context window. 3 Thinking modes: - No thinking: used for fast, intuitive answers - Thinking: used for careful logical analysis - Max thinking: maximum reasoning effort on the hardest problems ### Reference \[DeepSeek-V4 technical report\](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash/blob/main/DeepSeek\_V4.pdf)

Paste, drop or click to upload images (.png, .jpeg, .jpg, .svg, .gif) 

© 2026 Ollama

[Download](/download) [Blog](/blog) [Docs](https://docs.ollama.com) [GitHub](https://github.com/ollama/ollama) [Discord](https://discord.com/invite/ollama) [X (Twitter)](https://twitter.com/ollama) [Contact](mailto:hello@ollama.com) [Careers](https://jobs.ashbyhq.com/ollama) [Privacy](/privacy) [Terms](/terms)

-   [Blog](/blog)
-   [Download](/download)
-   [Docs](https://docs.ollama.com)

-   [GitHub](https://github.com/ollama/ollama)
-   [Discord](https://discord.com/invite/ollama)
-   [X (Twitter)](https://twitter.com/ollama)
-   [Meetups](https://lu.ma/ollama)
-   [Careers](https://jobs.ashbyhq.com/ollama)
-   [Privacy](/privacy)
-   [Terms](/terms)

© 2026 Ollama Inc.
```

---

## Assistant (Plan · Claude Sonnet 5 · 20.5s)

_Thinking:_



Findings before I write the plan — these two models are more unusual than they first appear:

**Key facts pulled from the Ollama library pages:**

| | DeepSeek-V4-Flash | DeepSeek-V4-Pro |
|---|---|---|
| Total / active params | 284B / 13B (MoE) | 1.6T / 49B (MoE) |
| Listed size | 304B | 1.65T |
| Context | 1M tokens | 1M tokens |
| **Available tags** | `:cloud`, `:0731-cloud`, `:preview-cloud` | `:cloud`, `:0813-cloud`, `:preview-cloud` |

The critical detail: **every single tag for both models is suffixed `-cloud`**. There is no plain/local GGUF tag (no `:7b`, `:70b`, `:q4_0`, etc.) like you'd see on a normal Ollama library page (e.g. `llama3.1:8b`). That's Ollama's convention for models that only run via **Ollama's hosted cloud inference** — `ollama run deepseek-v4-flash:cloud` downloads nothing; it authenticates your local Ollama client to Ollama's cloud API and proxies the request there. That directly conflicts with an on-prem requirement: your prompts/data would leave your network and go to Ollama's servers, and it requires internet connectivity + an Ollama account/API access at all times.

This also lines up with size: 304B and 1.65T parameter models are not realistic for local self-hosting on typical on-prem hardware (V4-Pro alone needs multiple terabytes... well, hundreds of GB even quantized, across multiple high-memory GPUs) — which is likely *why* Ollama only offers them as cloud tags in the first place. Let me verify there's truly no local variant before I finalize a plan.

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://ollama.com/library/deepseek-v4-flash/tags"
}
```

**Output:**
```
Tags · deepseek-v4-flash                                

[![Ollama](/public/ollama.png)](/)

[Models](/search) [Docs](/docs) [Pricing](/pricing)

[Sign in](/signin) [Download](/download)

[Models](/search) [Download](/download) [Docs](/docs) [Pricing](/pricing) [Sign in](/signin)

[deepseek-v4-flash](/library/deepseek-v4-flash "deepseek-v4-flash")

374.5K  Downloads Updated  2 weeks ago

## DeepSeek-V4-Flash is a preview of the DeepSeek-V4 series, a Mixture-of-Experts model with 284B total parameters and 13B activated, built for efficient reasoning across a 1M-token context window.

DeepSeek-V4-Flash is a preview of the DeepSeek-V4 series, a Mixture-of-Experts model with 284B total parameters and 13B activated, built for efficient reasoning across a 1M-token context window.

Cancel 

tools thinking cloud

Name

3 models

Size / Usage

Context

Input

[

deepseek-v4-flash:cloud

031ce2a95446 • Medium Usage • 1M context window • Text input • 2 weeks ago

Text input • 2 weeks ago



](/library/deepseek-v4-flash:cloud)

[deepseek-v4-flash:cloud](/library/deepseek-v4-flash:cloud) 

1M

Text

031ce2a95446 · 2 weeks ago

[

deepseek-v4-flash:0731-cloud

031ce2a95446 • Medium Usage • 1M context window • Text input • 2 weeks ago

Text input • 2 weeks ago



](/library/deepseek-v4-flash:0731-cloud)

[deepseek-v4-flash:0731-cloud](/library/deepseek-v4-flash:0731-cloud) 

1M

Text

031ce2a95446 · 2 weeks ago

[

deepseek-v4-flash:preview-cloud

dd3d9b94bae4 • Medium Usage • 1M context window • Text input • 3 months ago

Text input • 3 months ago



](/library/deepseek-v4-flash:preview-cloud)

[deepseek-v4-flash:preview-cloud](/library/deepseek-v4-flash:preview-cloud) 

1M

Text

dd3d9b94bae4 · 3 months ago

© 2026 Ollama

[Download](/download) [Blog](/blog) [Docs](https://docs.ollama.com) [GitHub](https://github.com/ollama/ollama) [Discord](https://discord.com/invite/ollama) [X (Twitter)](https://twitter.com/ollama) [Contact](mailto:hello@ollama.com) [Careers](https://jobs.ashbyhq.com/ollama) [Privacy](/privacy) [Terms](/terms)

-   [Blog](/blog)
-   [Download](/download)
-   [Docs](https://docs.ollama.com)

-   [GitHub](https://github.com/ollama/ollama)
-   [Discord](https://discord.com/invite/ollama)
-   [X (Twitter)](https://twitter.com/ollama)
-   [Meetups](https://lu.ma/ollama)
-   [Careers](https://jobs.ashbyhq.com/ollama)
-   [Privacy](/privacy)
-   [Terms](/terms)

© 2026 Ollama Inc.
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://ollama.com/library/deepseek-v4-pro/tags"
}
```

**Output:**
```
Tags · deepseek-v4-pro                                

[![Ollama](/public/ollama.png)](/)

[Models](/search) [Docs](/docs) [Pricing](/pricing)

[Sign in](/signin) [Download](/download)

[Models](/search) [Download](/download) [Docs](/docs) [Pricing](/pricing) [Sign in](/signin)

[deepseek-v4-pro](/library/deepseek-v4-pro "deepseek-v4-pro")

339.1K  Downloads Updated  4 days ago

## DeepSeek-V4-Pro is a frontier Mixture-of-Experts model with a large context window and three reasoning modes.

DeepSeek-V4-Pro is a frontier Mixture-of-Experts model with a large context window and three reasoning modes.

Cancel 

tools thinking cloud

Name

3 models

Size / Usage

Context

Input

[

deepseek-v4-pro:cloud

6ed7420bc3a4 • Extra High Usage • 1M context window • Text input • 4 days ago

Text input • 4 days ago



](/library/deepseek-v4-pro:cloud)

[deepseek-v4-pro:cloud](/library/deepseek-v4-pro:cloud) 

1M

Text

6ed7420bc3a4 · 4 days ago

[

deepseek-v4-pro:0813-cloud

6ed7420bc3a4 • Extra High Usage • 1M context window • Text input • 4 days ago

Text input • 4 days ago



](/library/deepseek-v4-pro:0813-cloud)

[deepseek-v4-pro:0813-cloud](/library/deepseek-v4-pro:0813-cloud) 

1M

Text

6ed7420bc3a4 · 4 days ago

[

deepseek-v4-pro:preview-cloud

22bfd5026abd • Extra High Usage • 1M context window • Text input • 3 months ago

Text input • 3 months ago



](/library/deepseek-v4-pro:preview-cloud)

[deepseek-v4-pro:preview-cloud](/library/deepseek-v4-pro:preview-cloud) 

1M

Text

22bfd5026abd · 3 months ago

© 2026 Ollama

[Download](/download) [Blog](/blog) [Docs](https://docs.ollama.com) [GitHub](https://github.com/ollama/ollama) [Discord](https://discord.com/invite/ollama) [X (Twitter)](https://twitter.com/ollama) [Contact](mailto:hello@ollama.com) [Careers](https://jobs.ashbyhq.com/ollama) [Privacy](/privacy) [Terms](/terms)

-   [Blog](/blog)
-   [Download](/download)
-   [Docs](https://docs.ollama.com)

-   [GitHub](https://github.com/ollama/ollama)
-   [Discord](https://discord.com/invite/ollama)
-   [X (Twitter)](https://twitter.com/ollama)
-   [Meetups](https://lu.ma/ollama)
-   [Careers](https://jobs.ashbyhq.com/ollama)
-   [Privacy](/privacy)
-   [Terms](/terms)

© 2026 Ollama Inc.
```

---

## Assistant (Plan · Claude Sonnet 5 · 5.3s)

_Thinking:_



Confirmed — **only `-cloud` tags exist** for both models; there is no local/quantized tag whatsoever. Let me check the one more lead: the technical-report link points to a `deepseek-ai/DeepSeek-V4-Flash` HuggingFace repo, which would tell us if open weights exist for local conversion.

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash"
}
```

**Output:**
```
                

  deepseek-ai/DeepSeek-V4-Flash · Hugging Face   

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

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6538815d1bdb3c40db94fbfa/xMBly9PUMphrFVMxLX4kq.png)

](/deepseek-ai)

[deepseek-ai](/deepseek-ai)

/

[DeepSeek-V4-Flash](/deepseek-ai/DeepSeek-V4-Flash)

like 2.11k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6538815d1bdb3c40db94fbfa/xMBly9PUMphrFVMxLX4kq.png) DeepSeek 142k

[

Text Generation

](/models?pipeline_tag=text-generation)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

deepseek\_v4

](/models?other=deepseek_v4)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)[

8-bit precision

](/models?other=8-bit)[

fp8

](/models?other=fp8)

arxiv: 2606.19348

License: mit

[Model card](/deepseek-ai/DeepSeek-V4-Flash) [Files Files and versions

xet

](/deepseek-ai/DeepSeek-V4-Flash/tree/main)[Community

54

](/deepseek-ai/DeepSeek-V4-Flash/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use deepseek-ai/DeepSeek-V4-Flash with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/deepseek-ai/DeepSeek-V4-Flash?library=transformers)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("text-generation", model="deepseek-ai/DeepSeek-V4-Flash")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    pipe(messages)
    
    \# Load model directly
    from transformers import AutoTokenizer, AutoModelForCausalLM
    
    tokenizer = AutoTokenizer.from\_pretrained("deepseek-ai/DeepSeek-V4-Flash")
    model = AutoModelForCausalLM.from\_pretrained("deepseek-ai/DeepSeek-V4-Flash", device\_map="auto")
    
-   Inference
-   Inference Providers
-   [HuggingChat](/chat/models/deepseek-ai/DeepSeek-V4-Flash)
-   Notebooks
-   [Google Colab](/deepseek-ai/DeepSeek-V4-Flash/colab)
-   [Kaggle](/deepseek-ai/DeepSeek-V4-Flash/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/deepseek-ai/DeepSeek-V4-Flash?local-app=vllm)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "deepseek-ai/DeepSeek-V4-Flash"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "deepseek-ai/DeepSeek-V4-Flash",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/deepseek-ai/DeepSeek-V4-Flash
    
-   [SGLang](/deepseek-ai/DeepSeek-V4-Flash?local-app=sglang)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "deepseek-ai/DeepSeek-V4-Flash" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "deepseek-ai/DeepSeek-V4-Flash",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
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
            --model-path "deepseek-ai/DeepSeek-V4-Flash" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "deepseek-ai/DeepSeek-V4-Flash",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/deepseek-ai/DeepSeek-V4-Flash?local-app=docker-model-runner)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with Docker Model Runner:
    
    docker model run hf.co/deepseek-ai/DeepSeek-V4-Flash
    
-   [Browse Quantizations](/models?other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence](#deepseek-v4-towards-highly-efficient-million-token-context-intelligence "DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence")
    -   [Introduction](#introduction "Introduction")
        
    -   [Model Downloads](#model-downloads "Model Downloads")
        
    -   [Evaluation Results](#evaluation-results "Evaluation Results")
        -   [Base Model](#base-model "Base Model")
        -   [Instruct Model](#instruct-model "Instruct Model")
    -   [Chat Template](#chat-template "Chat Template")
        
    -   [How to Run Locally](#how-to-run-locally "How to Run Locally")
        
    -   [License](#license "License")
        
    -   [Citation](#citation "Citation")
        
    -   [Contact](#contact "Contact")
        

# [](#deepseek-v4-towards-highly-efficient-million-token-context-intelligence)DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence

![DeepSeek-V4](https://github.com/deepseek-ai/DeepSeek-V2/blob/main/figures/logo.svg?raw=true)

---

 [![Homepage](https://github.com/deepseek-ai/DeepSeek-V2/blob/main/figures/badge.svg?raw=true)](https://www.deepseek.com/)[![Chat](https://img.shields.io/badge/🤖%20Chat-DeepSeek%20V4-536af5?color=536af5&logoColor=white)](https://chat.deepseek.com/)

 [![Hugging Face](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-DeepSeek%20AI-ffc107?color=ffc107&logoColor=white)](https://huggingface.co/deepseek-ai)[![Twitter Follow](https://img.shields.io/badge/Twitter-deepseek_ai-white?logo=x&logoColor=white)](https://twitter.com/deepseek_ai)

[![License](https://img.shields.io/badge/License-MIT-f5de53?&color=f5de53)](LICENSE)

[**Technical Report**👁️](https://arxiv.org/abs/2606.19348)

## [](#introduction)Introduction

We present a preview version of **DeepSeek-V4** series, including two strong Mixture-of-Experts (MoE) language models — **DeepSeek-V4-Pro** with 1.6T parameters (49B activated) and **DeepSeek-V4-Flash** with 284B parameters (13B activated) — both supporting a context length of **one million tokens**.

DeepSeek-V4 series incorporate several key upgrades in architecture and optimization:

1.  **Hybrid Attention Architecture:** We design a hybrid attention mechanism combining Compressed Sparse Attention (CSA) and Heavily Compressed Attention (HCA) to dramatically improve long-context efficiency. In the 1M-token context setting, DeepSeek-V4-Pro requires only **27% of single-token inference FLOPs** and **10% of KV cache** compared with DeepSeek-V3.2.
2.  **Manifold-Constrained Hyper-Connections (mHC):** We incorporate mHC to strengthen conventional residual connections, enhancing stability of signal propagation across layers while preserving model expressivity.
3.  **Muon Optimizer:** We employ the Muon optimizer for faster convergence and greater training stability.

We pre-train both models on more than **32T** diverse and high-quality tokens, followed by a comprehensive post-training pipeline. The post-training features a two-stage paradigm: independent cultivation of domain-specific experts (through SFT and RL with GRPO), followed by unified model consolidation via on-policy distillation, integrating distinct proficiencies across diverse domains into a single model.

**DeepSeek-V4-Pro-Max**, the maximum reasoning effort mode of DeepSeek-V4-Pro, significantly advances the knowledge capabilities of open-source models, firmly establishing itself as the best open-source model available today. It achieves top-tier performance in coding benchmarks and significantly bridges the gap with leading closed-source models on reasoning and agentic tasks. Meanwhile, **DeepSeek-V4-Flash-Max** achieves comparable reasoning performance to the Pro version when given a larger thinking budget, though its smaller parameter scale naturally places it slightly behind on pure knowledge tasks and the most complex agentic workflows.

![](/deepseek-ai/DeepSeek-V4-Flash/resolve/main/assets/dsv4_performance.png)

## [](#model-downloads)Model Downloads

**Model**

**#Total Params**

**#Activated Params**

**Context Length**

**Precision**

**Download**

DeepSeek-V4-Flash-Base

284B

13B

1M

FP8 Mixed

[HuggingFace](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-Base) | [ModelScope](https://modelscope.cn/models/deepseek-ai/DeepSeek-V4-Flash-Base)

DeepSeek-V4-Flash

284B

13B

1M

FP4 + FP8 Mixed\*

[HuggingFace](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash) | [ModelScope](https://modelscope.cn/models/deepseek-ai/DeepSeek-V4-Flash)

DeepSeek-V4-Pro-Base

1.6T

49B

1M

FP8 Mixed

[HuggingFace](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-Base) | [ModelScope](https://modelscope.cn/models/deepseek-ai/DeepSeek-V4-Pro-Base)

DeepSeek-V4-Pro

1.6T

49B

1M

FP4 + FP8 Mixed\*

[HuggingFace](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro) | [ModelScope](https://modelscope.cn/models/deepseek-ai/DeepSeek-V4-Pro)

*\*FP4 + FP8 Mixed: MoE expert parameters use FP4 precision; most other parameters use FP8.*

## [](#evaluation-results)Evaluation Results

### [](#base-model)Base Model

Benchmark (Metric)

\# Shots

DeepSeek-V3.2-Base

DeepSeek-V4-Flash-Base

DeepSeek-V4-Pro-Base

Architecture

\-

MoE

MoE

MoE

\# Activated Params

\-

37B

13B

49B

\# Total Params

\-

671B

284B

1.6T

**World Knowledge**

AGIEval (EM)

0-shot

80.1

82.6

**83.1**

MMLU (EM)

5-shot

87.8

88.7

**90.1**

MMLU-Redux (EM)

5-shot

87.5

89.4

**90.8**

MMLU-Pro (EM)

5-shot

65.5

68.3

**73.5**

MMMLU (EM)

5-shot

87.9

88.8

**90.3**

C-Eval (EM)

5-shot

90.4

92.1

**93.1**

CMMLU (EM)

5-shot

88.9

90.4

**90.8**

MultiLoKo (EM)

5-shot

38.7

42.2

**51.1**

Simple-QA verified (EM)

25-shot

28.3

30.1

**55.2**

SuperGPQA (EM)

5-shot

45.0

46.5

**53.9**

FACTS Parametric (EM)

25-shot

27.1

33.9

**62.6**

TriviaQA (EM)

5-shot

83.3

82.8

**85.6**

**Language & Reasoning**

BBH (EM)

3-shot

**87.6**

86.9

87.5

DROP (F1)

1-shot

88.2

88.6

**88.7**

HellaSwag (EM)

0-shot

86.4

85.7

**88.0**

WinoGrande (EM)

0-shot

78.9

79.5

**81.5**

CLUEWSC (EM)

5-shot

83.5

82.2

**85.2**

**Code & Math**

BigCodeBench (Pass@1)

3-shot

**63.9**

56.8

59.2

HumanEval (Pass@1)

0-shot

62.8

69.5

**76.8**

GSM8K (EM)

8-shot

91.1

90.8

**92.6**

MATH (EM)

4-shot

60.5

57.4

**64.5**

MGSM (EM)

8-shot

81.3

**85.7**

84.4

CMath (EM)

3-shot

92.6

**93.6**

90.9

**Long Context**

LongBench-V2 (EM)

1-shot

40.2

44.7

**51.5**

### [](#instruct-model)Instruct Model

DeepSeek-V4-Pro and DeepSeek-V4-Flash both support three reasoning effort modes:

Reasoning Mode

Characteristics

Typical Use Cases

Response Format

Non-think

Fast, intuitive responses

Routine daily tasks, low-risk decisions

`</think>` summary

Think High

Conscious logical analysis, slower but more accurate

Complex problem-solving, planning

`<think>` thinking `</think>` summary

Think Max

Push reasoning to its fullest extent

Exploring the boundary of model reasoning capability

Special system prompt + `<think>` thinking `</think>` summary

#### [](#deepseek-v4-pro-max-vs-frontier-models)DeepSeek-V4-Pro-Max vs Frontier Models

Benchmark (Metric)

Opus-4.6 Max

GPT-5.4 xHigh

Gemini-3.1-Pro High

K2.6 Thinking

GLM-5.1 Thinking

DS-V4-Pro Max

**Knowledge & Reasoning**

MMLU-Pro (EM)

89.1

87.5

**91.0**

87.1

86.0

87.5

SimpleQA-Verified (Pass@1)

46.2

45.3

**75.6**

36.9

38.1

57.9

Chinese-SimpleQA (Pass@1)

76.4

76.8

**85.9**

75.9

75.0

84.4

GPQA Diamond (Pass@1)

91.3

93.0

**94.3**

90.5

86.2

90.1

HLE (Pass@1)

40.0

39.8

**44.4**

36.4

34.7

37.7

LiveCodeBench (Pass@1)

88.8

\-

91.7

89.6

\-

**93.5**

Codeforces (Rating)

\-

3168

3052

\-

\-

**3206**

HMMT 2026 Feb (Pass@1)

96.2

**97.7**

94.7

92.7

89.4

95.2

IMOAnswerBench (Pass@1)

75.3

**91.4**

81.0

86.0

83.8

89.8

Apex (Pass@1)

34.5

54.1

**60.9**

24.0

11.5

38.3

Apex Shortlist (Pass@1)

85.9

78.1

89.1

75.5

72.4

**90.2**

**Long Context**

MRCR 1M (MMR)

**92.9**

\-

76.3

\-

\-

83.5

CorpusQA 1M (ACC)

**71.7**

\-

53.8

\-

\-

62.0

**Agentic**

Terminal Bench 2.0 (Acc)

65.4

**75.1**

68.5

66.7

63.5

67.9

SWE Verified (Resolved)

**80.8**

\-

80.6

80.2

\-

80.6

SWE Pro (Resolved)

57.3

57.7

54.2

**58.6**

58.4

55.4

SWE Multilingual (Resolved)

**77.5**

\-

\-

76.7

73.3

76.2

BrowseComp (Pass@1)

83.7

82.7

**85.9**

83.2

79.3

83.4

HLE w/ tools (Pass@1)

53.1

52.0

51.6

**54.0**

50.4

48.2

GDPval-AA (Elo)

1619

**1674**

1314

1482

1535

1554

MCPAtlas Public (Pass@1)

**73.8**

67.2

69.2

66.6

71.8

73.6

Toolathlon (Pass@1)

47.2

**54.6**

48.8

50.0

40.7

51.8

#### [](#comparison-across-modes)Comparison across Modes

Benchmark (Metric)

V4-Flash Non-Think

V4-Flash High

V4-Flash Max

V4-Pro Non-Think

V4-Pro High

V4-Pro Max

**Knowledge & Reasoning**

MMLU-Pro (EM)

83.0

86.4

86.2

82.9

87.1

**87.5**

SimpleQA-Verified (Pass@1)

23.1

28.9

34.1

45.0

46.2

**57.9**

Chinese-SimpleQA (Pass@1)

71.5

73.2

78.9

75.8

77.7

**84.4**

GPQA Diamond (Pass@1)

71.2

87.4

88.1

72.9

89.1

**90.1**

HLE (Pass@1)

8.1

29.4

34.8

7.7

34.5

**37.7**

LiveCodeBench (Pass@1)

55.2

88.4

91.6

56.8

89.8

**93.5**

Codeforces (Rating)

\-

2816

3052

\-

2919

**3206**

HMMT 2026 Feb (Pass@1)

40.8

91.9

94.8

31.7

94.0

**95.2**

IMOAnswerBench (Pass@1)

41.9

85.1

88.4

35.3

88.0

**89.8**

Apex (Pass@1)

1.0

19.1

33.0

0.4

27.4

**38.3**

Apex Shortlist (Pass@1)

9.3

72.1

85.7

9.2

85.5

**90.2**

**Long Context**

MRCR 1M (MMR)

37.5

76.9

78.7

44.7

83.3

**83.5**

CorpusQA 1M (ACC)

15.5

59.3

60.5

35.6

56.5

**62.0**

**Agentic**

Terminal Bench 2.0 (Acc)

49.1

56.6

56.9

59.1

63.3

**67.9**

SWE Verified (Resolved)

73.7

78.6

79.0

73.6

79.4

**80.6**

SWE Pro (Resolved)

49.1

52.3

52.6

52.1

54.4

**55.4**

SWE Multilingual (Resolved)

69.7

70.2

73.3

69.8

74.1

**76.2**

BrowseComp (Pass@1)

\-

53.5

73.2

\-

80.4

**83.4**

HLE w/ tools (Pass@1)

\-

40.3

45.1

\-

44.7

**48.2**

MCPAtlas (Pass@1)

64.0

67.4

69.0

69.4

**74.2**

73.6

GDPval-AA (Elo)

\-

\-

1395

\-

\-

**1554**

Toolathlon (Pass@1)

40.7

43.5

47.8

46.3

49.0

**51.8**

## [](#chat-template)Chat Template

This release does not include a Jinja-format chat template. Instead, we provide a dedicated `encoding` folder with Python scripts and test cases demonstrating how to encode messages in OpenAI-compatible format into input strings for the model, and how to parse the model's text output. Please refer to the [`encoding`](/deepseek-ai/DeepSeek-V4-Flash/blob/main/encoding/README.md) folder for full documentation.

A brief example:

```python
from encoding_dsv4 import encode_messages, parse_message_from_completion_text

messages = [
    {"role": "user", "content": "hello"},
    {"role": "assistant", "content": "Hello! I am DeepSeek.", "reasoning_content": "thinking..."},
    {"role": "user", "content": "1+1=?"}
]

# messages -> string
prompt = encode_messages(messages, thinking_mode="thinking")

# string -> tokens
import transformers
tokenizer = transformers.AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-V4-Pro")
tokens = tokenizer.encode(prompt)
```

## [](#how-to-run-locally)How to Run Locally

Please refer to the [inference](/deepseek-ai/DeepSeek-V4-Flash/blob/main/inference/README.md) folder for detailed instructions on running DeepSeek-V4 locally, including model weight conversion and interactive chat demos.

For local deployment, we recommend setting the sampling parameters to `temperature = 1.0, top_p = 1.0`. For the Think Max reasoning mode, we recommend setting the context window to at least **384K** tokens.

## [](#license)License

This repository and the model weights are licensed under the [MIT License](/deepseek-ai/DeepSeek-V4-Flash/tree/main/LICENSE).

## [](#citation)Citation

```
@misc{deepseekai2026deepseekv4,
      title={DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence},
      author={DeepSeek-AI},
      year={2026},
}
```

## [](#contact)Contact

If you have any questions, please raise an issue or contact us at [service@deepseek.com](/deepseek-ai/DeepSeek-V4-Flash/blob/main/service@deepseek.com).

Downloads last month

1,989,734

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

291B params

Tensor type

BF16

·

I64

·

F32

·

F8\_E4M3

·

I8

·

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

Novita

[

Text Generation

](/tasks/text-generation "Learn more about text-generation")

Examples

Input a message to start chatting with **deepseek-ai/DeepSeek-V4-Flash**.

Send

View Code Snippets

[Compare providers](/inference/models?model=deepseek-ai%2FDeepSeek-V4-Flash)

## Model tree for deepseek-ai/DeepSeek-V4-Flash[](/docs/hub/model-cards#specifying-a-base-model)

Adapters

[3 models](/models?other=base_model:adapter:deepseek-ai/DeepSeek-V4-Flash)

Finetunes

[24 models](/models?other=base_model:finetune:deepseek-ai/DeepSeek-V4-Flash)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash "Use with Ollama")

[128 models](/models?other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash)

## Spaces using deepseek-ai/DeepSeek-V4-Flash 100

[

🥇

zoom-ai/hle-leaderboard

](/spaces/zoom-ai/hle-leaderboard)[

⚔️

crusoeai/foundry-model-arena

](/spaces/crusoeai/foundry-model-arena)[

📊

osolmaz/leaderboard

](/spaces/osolmaz/leaderboard)[

🏛️

adesh01/civicsetu

](/spaces/adesh01/civicsetu)[

🎥

shiva0013/YT-AI-Automation

](/spaces/shiva0013/YT-AI-Automation)[

⚡

uziproject/Deepseek-V4-Flash

](/spaces/uziproject/Deepseek-V4-Flash)[

🌖

VaNam56/quantforge-miner

](/spaces/VaNam56/quantforge-miner)[

🎓

StudentCompanion/alu-chatbot

](/spaces/StudentCompanion/alu-chatbot)\+ 95 Spaces \+ 92 Spaces

## Collection including deepseek-ai/DeepSeek-V4-Flash

[

#### DeepSeek-V4

Collection

8 items • Updated 5 days ago • 831

](/collections/deepseek-ai/deepseek-v4)

## Paper for deepseek-ai/DeepSeek-V4-Flash

[

#### DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence

Paper • 2606.19348 • Published Apr 26 • 36

](/papers/2606.19348)

## Evaluation results[](https://huggingface.co/docs/hub/eval-results)

-   [SWE-bench/SWE-bench\_Verified](/datasets/SWE-bench/SWE-bench_Verified) · Swe Bench Resolved [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/11) [leaderboard](/datasets/SWE-bench/SWE-bench_Verified?eval_result=deepseek-ai/DeepSeek-V4-Flash&leaderboard_task_id=swe_bench_%_resolved)
    
    79
    
-   [Idavidrein/gpqa](/datasets/Idavidrein/gpqa) · Diamond [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/11) [leaderboard](/datasets/Idavidrein/gpqa?eval_result=deepseek-ai/DeepSeek-V4-Flash&leaderboard_task_id=diamond)
    
    88.1
    
-   [TIGER-Lab/MMLU-Pro](/datasets/TIGER-Lab/MMLU-Pro) · Mmlu Pro [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/11) [leaderboard](/datasets/TIGER-Lab/MMLU-Pro?eval_result=deepseek-ai/DeepSeek-V4-Flash&leaderboard_task_id=mmlu_pro)
    
    86.4
    
-   [SWE-bench/SWE-bench\_Multilingual](/datasets/SWE-bench/SWE-bench_Multilingual) · Swe Bench Multilingual Resolved [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/54) [leaderboard](/datasets/SWE-bench/SWE-bench_Multilingual?eval_result=deepseek-ai/DeepSeek-V4-Flash&leaderboard_task_id=swe_bench_multilingual_%_resolved)
    
    73.3
    
-   [benchflow/skillsbench](/datasets/benchflow/skillsbench) · Skillsbench V1 1 [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/45)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/663fe2d26304d377fc253322/L6ik2VpL5iizADEXK4W-A.png)
    
    source](https://huggingface.co/datasets/benchflow/skillsbench-leaderboard/raw/main/leaderboard/skillsbench/v1.1/official.json) [leaderboard](/datasets/benchflow/skillsbench?eval_result=deepseek-ai/DeepSeek-V4-Flash&leaderboard_task_id=skillsbench_v1_1)
    
    44.7 \*
    
-   [claw-eval/Claw-Eval](/datasets/claw-eval/Claw-Eval) [leaderboard](/datasets/claw-eval/Claw-Eval?eval_result=deepseek-ai/DeepSeek-V4-Flash)
-   General [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/31)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6038d6d0612f5eef3cc05ea9/ryhvAX5djQpD5OrIlZQ1f.jpeg)
    
    source](https://claw-eval.github.io)
    
    Pass³% | N=3 | 161 tasks
    
    57.8 \*
    
-   Multi Turn [View evaluation results](/deepseek-ai/DeepSeek-V4-Flash/discussions/31)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6038d6d0612f5eef3cc05ea9/ryhvAX5djQpD5OrIlZQ1f.jpeg)
    
    source](https://claw-eval.github.io)
    
    Pass³% | N=3 | 38 tasks
    
    [](/datasets/claw-eval/Claw-Eval?eval_result=deepseek-ai%2FDeepSeek-V4-Flash&leaderboard_task_id=multi_turn&leaderboard_max_params=500B)57.9 \*
    

Expand 2 benchmarks

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 127.5s)

_Thinking:_



## What I found

Both links are for **DeepSeek-V4** (a very recent/large preview release — 284B-param "Flash" and 1.6T-param "Pro", both MoE, 1M-token context).

**Critical issue with the Ollama library pages themselves:** every tag listed there (`:cloud`, `:0731-cloud`, `:preview-cloud` / `:0813-cloud`) is a **cloud-only** tag. `ollama run deepseek-v4-flash:cloud` does not download weights — it authenticates your local `ollama` CLI to Ollama's hosted inference service and proxies your prompts there. That is **not on-prem**: your data leaves your network, you need continuous internet + an Ollama account, and you're billed/rate-limited by Ollama's cloud, not running on your own hardware.

The good news: DeepSeek did publish open, **MIT-licensed** weights on Hugging Face (`deepseek-ai/DeepSeek-V4-Flash` / `-Pro`, plus `-Base` variants), and the community has already produced 128 GGUF/quantized derivatives tagged for llama.cpp/Ollama/LM Studio. So a genuine on-prem path exists — it just isn't the path Ollama's library page pushes you toward.

**The hard constraint is hardware, not licensing:**
- V4-Flash: 284B total params / 13B activated (MoE). Even at 4-bit quantization, resident weights are roughly 140–160GB.
- V4-Pro: 1.6T total params / 49B activated (MoE). At 4-bit, resident weights are roughly 800GB+.

Because both are MoE with a small *activated* fraction, the standard trick used for similarly-sized DeepSeek-V3/R1 (671B) is CPU/NVMe offload of "cold" experts with only active experts computed on GPU (e.g., llama.cpp `--n-gpu-layers` partial offload, or `ktransformers`) — full-GPU deployment at these sizes is normally multi-node/enterprise-cluster territory.

## Before I write the plan, I need to know your hardware

**Tool: question**

**Input:**
```json
{
  "questions": [
    {
      "question": "What hardware do you actually have available for this on-prem install?",
      "header": "Available hardware",
      "options": [
        {
          "label": "Single GPU workstation (<=24GB VRAM)",
          "description": "e.g. one RTX 4090/3090 class card - can't hold either model fully even quantized"
        },
        {
          "label": "Multi-GPU server (e.g. 2-8x 24-80GB GPUs)",
          "description": "A100/H100/4090 class server - could run Flash with heavy quantization, Pro still very tight"
        },
        {
          "label": "High-RAM CPU server + 1-2 GPUs (256GB-1TB+ RAM)",
          "description": "The realistic on-prem path for these sizes: llama.cpp/ktransformers MoE offload, GPU handles active experts, RAM holds the rest"
        },
        {
          "label": "Not sure yet / need guidance first",
          "description": "I'll lay out requirements per option so you can check what you have or need to buy"
        }
      ]
    }
  ]
}
```

**Output:**
```
User has answered your questions: "What hardware do you actually have available for this on-prem install?"="I have 2 system: NVIDIA DGX Spark with 128GB VRAM (NVIDIA GB10 Blackwell). Dell 7960T with 512 GB CPU RAM and 384 GB GPU RAM (4 * NVIDIA RTX Pro 6000 Blackwell Max-Q)". You can now continue with the user's answers in mind.
```

---

## Assistant (Plan · Claude Sonnet 5 · 42.2s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/models?other=base_model:quantized:deepseek-ai/DeepSeek-V4-Flash&apps=ollama"
}
```

**Output:**
```
                

  Models – Hugging Face   

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

### Edit Models filters

-   Main
-   Tasks
-   Libraries
-   Languages
-   Licenses
-   Other 2

Model Tree

Reset

[

![](/api/avatars/deepseek-ai)

deepseek-ai/DeepSeek-V4-Flash](deepseek-ai/DeepSeek-V4-Flash)

[

Adapters

](/models?other=adapter)[

Finetunes

](/models?other=finetune)[

Quantizations

](/models?other=quantized)[

Merges

](/models?other=merge)

Apps

Reset Apps

[

llama.cpp

](/models?other=llama.cpp)[

LM Studio

](/models?other=lmstudio)[

Jan

](/models?other=jan)[

Draw Things

](/models?other=drawthings)[

DiffusionBee

](/models?other=diffusionbee)[

JoyFusion

](/models?other=joyfusion)[

vLLM

](/models?other=vllm)[

Ollama

](/models?other=ollama)[

MLX LM

](/models?other=mlx-lm)[

Docker Model Runner

](/models?other=docker-model-runner)[

Lemonade

](/models?other=lemonade)[

SGLang

](/models?other=sglang)[

Unsloth Studio

](/models?other=unsloth)[

Pi

](/models?other=pi)[

Hermes Agent

](/models?other=hermes-agent)[

Atomic Chat

](/models?other=atomic-chat)[

OpenClaw

](/models?other=openclaw)

Inference Providers

Select all

[

Groq

](/models?inference_provider=groq)[

Novita

](/models?inference_provider=novita)[

Cerebras

](/models?inference_provider=cerebras)[

Nscale

](/models?inference_provider=nscale)[

fal

](/models?inference_provider=fal-ai)[

Together AI

](/models?inference_provider=together)[

Fireworks

](/models?inference_provider=fireworks-ai)[

Featherless AI

](/models?inference_provider=featherless-ai)[

Zai

](/models?inference_provider=zai-org)[

Replicate

](/models?inference_provider=replicate)[

Cohere

](/models?inference_provider=cohere)[

Scaleway

](/models?inference_provider=scaleway)[

Public AI

](/models?inference_provider=publicai)[

Baseten

](/models?inference_provider=baseten)[

OVHcloud AI Endpoints

](/models?inference_provider=ovhcloud)[

HF Inference API

](/models?inference_provider=hf-inference)[

WaveSpeed

](/models?inference_provider=wavespeed)[

DeepInfra

](/models?inference_provider=deepinfra)

One-click Deployment

[

Inference Endpoints

](/models?other=endpoints_compatible)[

Microsoft Foundry

](/models?other=deploy%3Aazure)[

Amazon SageMaker AI

](/models?other=deploy%3Asagemaker)

Misc

[

text-generation-inference

](/models?other=text-generation-inference)[

Eval Results (legacy)

](/models?other=model-index)[

text-embeddings-inference

](/models?other=text-embeddings-inference)[

custom\_code

](/models?other=custom_code)[

4-bit precision

](/models?other=4-bit)[

Merge

](/models?other=merge)[

8-bit precision

](/models?other=8-bit)[

Mixture of Experts

](/models?other=moe)[

Carbon Emissions

](/models?other=co2_eq_emissions)[

Eval Results

](/models?other=eval-results)

Apply filters

# Models

57

Base only Inference Available Inference

Edit filters

Sort:  Trending

**Active filters:** ollama, deepseek-ai/DeepSeek-V4-Flash

Clear all

[

![](/avatars/7379345fed54f2447537068ed1c2e440.svg)

#### antirez/deepseek-v4-gguf

Text Generation • 284B • Updated 2 days ago • 1.41M • 451



](/antirez/deepseek-v4-gguf)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6434643695b8ab0493897a00/0bwCanI1NTQZrykXg2Pjl.png)

#### cyberneurova/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF

Text Generation • 284B • Updated May 6 • 2.55k • 60



](/cyberneurova/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69ca4cc97c367f27fa25bb35/aE7xbtwTA4kavmm84ef5i.jpeg)

#### YTan2000/R2-DeepSeek-V4-Flash-0731-TQ3\_4S

284B • Updated 7 days ago • 238 • 8



](/YTan2000/R2-DeepSeek-V4-Flash-0731-TQ3_4S)

[

![](/avatars/981936c810e68793c10f3626f9998c5d.svg)

#### ayourtch/ARustyCoder93

108B • Updated 1 day ago • 86 • 2



](/ayourtch/ARustyCoder93)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66228dc4c8920ec3513dc81a/9stczijVqp6TgQduzT8kN.png)

#### huihui-ai/Huihui-DeepSeek-V4-Flash-abliterated-ds4-GGUF

284B • Updated Jun 6 • 332k • 126



](/huihui-ai/Huihui-DeepSeek-V4-Flash-abliterated-ds4-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62ecdc18b72a69615d6bd857/E4lkPz1TZNLzIFr_dR273.png)

#### unsloth/DeepSeek-V4-Flash-GGUF

284B • Updated Jul 9 • 97.9k • 244



](/unsloth/DeepSeek-V4-Flash-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/63148d3b996c52bf0142cdbe/HXyNkyB0_nHI5WDNdiKHZ.png)

#### ggml-org/DeepSeek-V4-Flash-GGUF

Text Generation • 284B • Updated 12 days ago • 3.81k • 10



](/ggml-org/DeepSeek-V4-Flash-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64136b5750358a8052036df7/r5KhK4Rbc19NwGfnQM2P8.jpeg)

#### nsparks/DeepSeek-V4-Flash-FP4-FP8-GGUF

284B • Updated Apr 26 • 133k • 15



](/nsparks/DeepSeek-V4-Flash-FP4-FP8-GGUF)

[

![](/avatars/4b73fc246825e254a32402a159977433.svg)

#### lovedheart/DeepSeek-V4-Flash-GGUF

284B • Updated Apr 26 • 77 • 6



](/lovedheart/DeepSeek-V4-Flash-GGUF)

[

![](/avatars/16421c2aed8fe34403868412e79db449.svg)

#### Preyazz/DeepSeek-V4-Flash-Q8\_0-GGUF

284B • Updated Apr 27 • 328 • 2



](/Preyazz/DeepSeek-V4-Flash-Q8_0-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/679d9680de0c0f8370cabcf3/numfzR_Lto_Hkvk-Pj8l8.png)

#### anemll/DeepSeek-V4-Flash-FP4-FP8-SSD

Text Generation • 7B • Updated Apr 29 • 203 • 8



](/anemll/DeepSeek-V4-Flash-FP4-FP8-SSD)

[

![](/avatars/026216a27cf9b50789da50f21a44c4a2.svg)

#### ssweens/DeepSeek-V4-Flash-GGUF-YMMV

Text Generation • 284B • Updated May 12 • 649 • 8



](/ssweens/DeepSeek-V4-Flash-GGUF-YMMV)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/no-auth/cUatmCHvw236gi67lmuK5.png)

#### setar007/DeepSeek-V4-Flash-Q8xQ5-GGUF

284B • Updated May 7 • 145 • 2



](/setar007/DeepSeek-V4-Flash-Q8xQ5-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6491a7b8b565f2881c00b5fd/TcnN0qhIdDmsPfziV-iIX.jpeg)

#### Volko76/DeepSeek-V4-Flash-GGUF

Text Generation • 284B • Updated May 7 • 91 • 1



](/Volko76/DeepSeek-V4-Flash-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/68dea5a029387835ee0efd93/KC-TVZIN5o8G3Kul2X5eA.png)

#### teamblobfish/DeepSeek-V4-Flash-GGUF

Text Generation • 284B • Updated May 19 • 26.8k • 29



](/teamblobfish/DeepSeek-V4-Flash-GGUF)

[

![](/avatars/4cbb0888c689f572545b1352aec69eb7.svg)

#### CCSSNE/cyberneurova-CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF

Text Generation • 284B • Updated May 9 • 95 • 1



](/CCSSNE/cyberneurova-CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/68e61ca705bcf09010bef0ea/Mlcw1bMls7_fmXEyd2srD.jpeg)

#### rbinrs/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF

Text Generation • 284B • Updated May 9 • 80 • 2



](/rbinrs/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF)

[

![](/avatars/34fdfb4f529350e2ddc7c2cb84830384.svg)

#### superdan001019/DeepSeek-V4-Flash-FP4-FP8-SSD

Text Generation • 7B • Updated May 9 • 66



](/superdan001019/DeepSeek-V4-Flash-FP4-FP8-SSD)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6868e75b4427e66732ef0b52/yMMlulTd06QG6WLkIftJI.png)

#### opensota/deepseek-v4-gguf

Text Generation • 284B • Updated May 12 • 260 • 2



](/opensota/deepseek-v4-gguf)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6373a1a92d4eccfa6f909f69/j8ED1yzIYH0nBljHcqELg.jpeg)

#### audreyt/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF

Text Generation • 284B • Updated Jul 3 • 10.9k • 14



](/audreyt/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/63599d677d959cab632c9367/oJKgKBeHGVeTKAVnrKC9z.jpeg)

#### 6ms/DeepSeek-V4-Flash-MXFP4-GGUF

Text Generation • 284B • Updated May 14 • 430 • 1



](/6ms/DeepSeek-V4-Flash-MXFP4-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65d60630933e3da6e7d91085/R0GYlOMW1Ylb7CuXBxWAz.jpeg)

#### jedisct1/DeepSeek-V4-Flash-imatrix-aligned

Text Generation • 284B • Updated May 13 • 341 • 5



](/jedisct1/DeepSeek-V4-Flash-imatrix-aligned)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6518ce70186bc3b69970a209/Z9ugTvkM7v792Wxb2caHn.png)

#### persadian/DeepSeek-V4-Flash-GGUF

Text Generation • 284B • Updated May 22 • 12



](/persadian/DeepSeek-V4-Flash-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6518ce70186bc3b69970a209/Z9ugTvkM7v792Wxb2caHn.png)

#### persadian/DeepSeek-V4-Flash-IQ1\_S-XL

Text Generation • 229B • Updated May 26 • 839 • 3



](/persadian/DeepSeek-V4-Flash-IQ1_S-XL)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/noauth/KUW3KvteAwkUM-aarFegH.png)

#### brentin/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF

Text Generation • 284B • Updated May 19 • 152 • 2



](/brentin/CyberNeurova-DeepSeek-V4-Flash-abliterated-GGUF)

[

![](/avatars/e3da19c80e7ea823a436e7e650fef368.svg)

#### huiyanxinxi/DeepSeek-V4-Flash-Q8\_0-GGUF

284B • Updated May 25 • 41



](/huiyanxinxi/DeepSeek-V4-Flash-Q8_0-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/631599c7915d0b8068300134/p_NgHvuzWZId8cAfBtmGa.png)

#### zenlm/zen5-pro-gguf

Text Generation • 284B • Updated Jul 14 • 254 • 1



](/zenlm/zen5-pro-gguf)

[

![](/avatars/e636dfe0eac900384e17654fa181e2a1.svg)

#### Keepser/Huihui-DeepSeek-V4-Flash-abliterated-ds4-GGUF

284B • Updated May 31 • 164 • 1



](/Keepser/Huihui-DeepSeek-V4-Flash-abliterated-ds4-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6a06508a94822ad3a385a24d/5o-CctD08Hh6ntYoqz0uD.jpeg)

#### pinklily69/DeepSeek-V4-Flash-IQ3\_S-GGUF

284B • Updated Jun 1 • 166 • 2



](/pinklily69/DeepSeek-V4-Flash-IQ3_S-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/679d9680de0c0f8370cabcf3/numfzR_Lto_Hkvk-Pj8l8.png)

#### anemll/DSv4-Flash-MXFP4-native-flash

7B • Updated Jun 12 • 13



](/anemll/DSv4-Flash-MXFP4-native-flash)

-   Previous
-   [1](?apps=ollama&other=base_model:quantized:deepseek-ai%2FDeepSeek-V4-Flash&p=0&sort=trending)
-   [2](?apps=ollama&other=base_model:quantized:deepseek-ai%2FDeepSeek-V4-Flash&p=1&sort=trending)
-   [Next](?apps=ollama&other=base_model:quantized:deepseek-ai%2FDeepSeek-V4-Flash&p=1&sort=trending)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/models?other=base_model:quantized:deepseek-ai/DeepSeek-V4-Pro&apps=ollama"
}
```

**Output:**
```
                

  Models – Hugging Face   

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

### Edit Models filters

-   Main
-   Tasks
-   Libraries
-   Languages
-   Licenses
-   Other 2

Model Tree

Reset

[

![](/api/avatars/deepseek-ai)

deepseek-ai/DeepSeek-V4-Pro](deepseek-ai/DeepSeek-V4-Pro)

[

Adapters

](/models?other=adapter)[

Finetunes

](/models?other=finetune)[

Quantizations

](/models?other=quantized)[

Merges

](/models?other=merge)

Apps

Reset Apps

[

llama.cpp

](/models?other=llama.cpp)[

LM Studio

](/models?other=lmstudio)[

Jan

](/models?other=jan)[

Draw Things

](/models?other=drawthings)[

DiffusionBee

](/models?other=diffusionbee)[

JoyFusion

](/models?other=joyfusion)[

vLLM

](/models?other=vllm)[

Ollama

](/models?other=ollama)[

MLX LM

](/models?other=mlx-lm)[

Docker Model Runner

](/models?other=docker-model-runner)[

Lemonade

](/models?other=lemonade)[

SGLang

](/models?other=sglang)[

Unsloth Studio

](/models?other=unsloth)[

Pi

](/models?other=pi)[

Hermes Agent

](/models?other=hermes-agent)[

Atomic Chat

](/models?other=atomic-chat)[

OpenClaw

](/models?other=openclaw)

Inference Providers

Select all

[

Groq

](/models?inference_provider=groq)[

Novita

](/models?inference_provider=novita)[

Cerebras

](/models?inference_provider=cerebras)[

Nscale

](/models?inference_provider=nscale)[

fal

](/models?inference_provider=fal-ai)[

Together AI

](/models?inference_provider=together)[

Fireworks

](/models?inference_provider=fireworks-ai)[

Featherless AI

](/models?inference_provider=featherless-ai)[

Zai

](/models?inference_provider=zai-org)[

Replicate

](/models?inference_provider=replicate)[

Cohere

](/models?inference_provider=cohere)[

Scaleway

](/models?inference_provider=scaleway)[

Public AI

](/models?inference_provider=publicai)[

Baseten

](/models?inference_provider=baseten)[

OVHcloud AI Endpoints

](/models?inference_provider=ovhcloud)[

HF Inference API

](/models?inference_provider=hf-inference)[

WaveSpeed

](/models?inference_provider=wavespeed)[

DeepInfra

](/models?inference_provider=deepinfra)

One-click Deployment

[

Inference Endpoints

](/models?other=endpoints_compatible)[

Microsoft Foundry

](/models?other=deploy%3Aazure)[

Amazon SageMaker AI

](/models?other=deploy%3Asagemaker)

Misc

[

text-generation-inference

](/models?other=text-generation-inference)[

Eval Results (legacy)

](/models?other=model-index)[

text-embeddings-inference

](/models?other=text-embeddings-inference)[

custom\_code

](/models?other=custom_code)[

4-bit precision

](/models?other=4-bit)[

Merge

](/models?other=merge)[

8-bit precision

](/models?other=8-bit)[

Mixture of Experts

](/models?other=moe)[

Carbon Emissions

](/models?other=co2_eq_emissions)[

Eval Results

](/models?other=eval-results)

Apply filters

# Models

4

Base only Inference Available Inference

Edit filters

Sort:  Trending

**Active filters:** ollama, deepseek-ai/DeepSeek-V4-Pro

Clear all

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/68dea5a029387835ee0efd93/KC-TVZIN5o8G3Kul2X5eA.png)

#### teamblobfish/DeepSeek-V4-Pro-GGUF

Text Generation • 1.6T • Updated May 14 • 46.8k • 15



](/teamblobfish/DeepSeek-V4-Pro-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65ac86caa8f716b32e7eb64e/HV8fpHIHhgzzaKtqOxRN-.png)

#### batiai/DeepSeek-V4-Pro-GGUF

Text Generation • 1.6T • Updated Jun 1 • 186 • 2



](/batiai/DeepSeek-V4-Pro-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/631599c7915d0b8068300134/p_NgHvuzWZId8cAfBtmGa.png)

#### zenlm/zen5-max-gguf

Text Generation • 1.6T • Updated Jul 14 • 299 • 1



](/zenlm/zen5-max-gguf)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64e6d37e02dee9bcb9d9fa18/o_HhUnXb_PgyYlqJ6gfEO.png)

#### DevQuasar/deepseek-ai.DeepSeek-V4-Pro-GGUF

Text Generation • 1.6T • Updated Jul 16 • 374



](/DevQuasar/deepseek-ai.DeepSeek-V4-Pro-GGUF)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 39.8s)

_Thinking:_



## Plan: Deploying DeepSeek‑V4‑Flash / ‑Pro on your on‑prem Ollama setup

### 1. Reframe: don't use the Ollama library pages as-is
Both `deepseek-v4-flash` and `deepseek-v4-pro` in Ollama's library are **cloud-proxy tags only** (`:cloud`, `:0731-cloud`/`:0813-cloud`, `:preview-cloud`) — `ollama run deepseek-v4-flash:cloud` sends your prompts to Ollama's hosted service, not your hardware. Skip these entirely for an on-prem requirement.

The real path: DeepSeek released **MIT-licensed open weights** (`deepseek-ai/DeepSeek-V4-Flash` / `-Pro`, natively FP4+FP8), and the community has already produced GGUF quantizations tagged for llama.cpp/Ollama. We import a GGUF into Ollama via a `Modelfile` (`FROM ./model.gguf`) instead of pulling the library tag.

### 2. Hardware feasibility against your two boxes

| Model | Native/quantized footprint | DGX Spark (128GB unified, GB10 Blackwell, ARM) | Dell 7960T (4×96GB RTX Pro 6000 Max-Q = 384GB VRAM + 512GB RAM) |
|---|---|---|---|
| **V4-Flash** (284B total / 13B active MoE) | ~150–160GB at native FP4+FP8 or Q4-class GGUF; ~100–115GB at Q2/Q3/IQ3 | Tight fit only at aggressive quant (Q2/IQ3), reduced context, low throughput (unified LPDDR5x ≈ 273GB/s bandwidth — this is a dev/eval box, not a throughput box) | **Fits comfortably in VRAM alone** near Q4–Q5, full 1M context feasible with headroom for KV cache. This is the right box for Flash. |
| **V4-Pro** (1.6T total / 49B active MoE) | ~800GB+ at Q4-class; ~550–650GB at Q3/IQ3 | Not feasible — not enough memory even quantized | Doesn't fit in 384GB VRAM alone. Needs **VRAM+RAM hybrid offload** (896GB pool). A Q3/IQ3 quant (~550–650GB) is workable with headroom for KV cache/OS; Q4 (~800GB) leaves almost none. Since only 49B params are "active" per token (MoE), CPU-resident cold experts + GPU-resident hot experts is the same trick used for DeepSeek-V3/R1-671B — throughput will be noticeably lower than a pure-VRAM model but usable. |

**Recommendation:** DGX Spark = dev/test box for Flash at reduced quant/context, or leave idle for this purpose. Dell 7960T = the real deployment box — Flash first (easy, high quality), Pro second (harder, needs offload tuning).

### 3. Concrete GGUF sources found (verified to exist on HF, tagged for Ollama)
- **V4-Flash:** `ggml-org/DeepSeek-V4-Flash-GGUF` (llama.cpp's own org — most trustworthy) or `unsloth/DeepSeek-V4-Flash-GGUF` (well-known quant house, dynamic quants). Avoid the "abliterated"/uncensored personal repos unless you specifically want that behavior change.
- **V4-Pro:** `DevQuasar/deepseek-ai.DeepSeek-V4-Pro-GGUF` or `teamblobfish/DeepSeek-V4-Pro-GGUF`. Fewer reputable options exist than for Flash — worth spot-checking file sizes/quant levels and community discussion before committing 500GB+ of download/disk.

### 4. Execution steps (for when you leave plan mode)
1. Verify Ollama version on both machines supports the GB10 (ARM/Blackwell sm_121) and RTX Pro 6000 Blackwell compute capability — recent Ollama/llama.cpp CUDA builds only.
2. Pick quant levels per box from the table above; download the specific GGUF shard(s) (these are split multi-file GGUFs at this size — need `gguf-split` merge or Ollama's multi-file support).
3. Write a `Modelfile` (`FROM <path-to-gguf>` + params: context length, template using DeepSeek's custom encoding — note the model card says **no Jinja chat template ships**; it uses a custom Python encoding scheme, so the Ollama `TEMPLATE` will need to be hand-built or you serve via llama.cpp/vLLM directly instead of Ollama's templating).
4. `ollama create deepseek-v4-flash-local -f Modelfile`; test on Dell 7960T first (multi-GPU layer-split is automatic in Ollama when a model doesn't fit one GPU).
5. For Pro on the Dell box: use llama.cpp's MoE CPU-offload flags (Ollama exposes some via `num_gpu`/`OLLAMA_NUM_GPU` and newer MoE-offload env vars) to keep active experts on GPU and cold experts in system RAM. If Ollama's offload controls prove too coarse, fall back to running **llama.cpp server directly** or **ktransformers** (purpose-built for this exact MoE CPU+GPU split) and only use Ollama as a thin OpenAI-compatible client.
6. Benchmark tokens/sec and quality at each quant level before committing to one as "production."

### Open questions before I execute anything
- Do you want both models running, or is Flash the priority and Pro a stretch goal?
- Is losing the custom DeepSeek chat-template/reasoning-mode plumbing (thinking/non-thinking/max-thinking) acceptable if Ollama's templating can't express it cleanly, or is that a hard requirement (which would push toward vLLM/SGLang instead of Ollama for serving)?
- Any preference on quant level tradeoff (quality vs. speed vs. context length) once we benchmark?

---

## User

regarding "Open questions"
-- 1: Flash for start, Pro for the long run
-- 2: I am ok to use a different tool than Ollama, but it must provide a openai compatible API. I want to use with OpenCode and OpenWebUI
-- 3: I want to use it for coding tasks where the quality is most important. Speed is secondary.

---

## Assistant (Plan · Claude Sonnet 5 · 31.3s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://github.com/vllm-project/vllm/issues?q=deepseek-v4"
}
```

**Output:**
```
                                                                                                                                                   Issues · vllm-project/vllm · GitHub                                                                                                                                                

[Skip to content](#start-of-content)    

           

## Navigation Menu

[](/)

[Sign in](/login?return_to=https%3A%2F%2Fgithub.com%2Fvllm-project%2Fvllm%2Fissues%3Fq%3Ddeepseek-v4)

Appearance settings

-   Platform
    
    -   AI CODE CREATION
        
        -   [GitHub CopilotWrite better code with AI](https://github.com/features/copilot)
        -   [GitHub Copilot appDirect agents from issue to merge](https://github.com/features/ai/github-app)
        -   [MCP RegistryIntegrate external tools](https://github.com/mcp)
        
    -   DEVELOPER WORKFLOWS
        
        -   [ActionsAutomate any workflow](https://github.com/features/actions)
        -   [CodespacesInstant dev environments](https://github.com/features/codespaces)
        -   [IssuesPlan and track work](https://github.com/features/issues)
        -   [Code ReviewManage code changes](https://github.com/features/code-review)
        -   [Code QualityEnforce quality at merge](https://github.com/features/code-quality)
        
    -   APPLICATION SECURITY
        
        -   [GitHub Advanced SecurityFind and fix vulnerabilities](https://github.com/security/advanced-security)
        -   [Code securitySecure your code as you build](https://github.com/security/advanced-security/code-security)
        -   [Secret protectionStop leaks before they start](https://github.com/security/advanced-security/secret-protection)
        
    -   EXPLORE
        
        -   [Why GitHub](https://github.com/why-github)
        -   [Documentation](https://docs.github.com)
        -   [Blog](https://github.blog)
        -   [Changelog](https://github.blog/changelog)
        -   [Marketplace](https://github.com/marketplace)
        
    
    [View all features](https://github.com/features)
    
-   Solutions
    
    -   BY COMPANY SIZE
        
        -   [Enterprises](https://github.com/enterprise)
        -   [Small and medium teams](https://github.com/team)
        -   [Startups](https://github.com/enterprise/startups)
        -   [Nonprofits](https://github.com/solutions/industry/nonprofits)
        
    -   BY USE CASE
        
        -   [App Modernization](https://github.com/solutions/use-case/app-modernization)
        -   [DevSecOps](https://github.com/solutions/use-case/devsecops)
        -   [DevOps](https://github.com/solutions/use-case/devops)
        -   [CI/CD](https://github.com/solutions/use-case/ci-cd)
        -   [View all use cases](https://github.com/solutions/use-case)
        
    -   BY INDUSTRY
        
        -   [Healthcare](https://github.com/solutions/industry/healthcare)
        -   [Financial services](https://github.com/solutions/industry/financial-services)
        -   [Manufacturing](https://github.com/solutions/industry/manufacturing)
        -   [Government](https://github.com/solutions/industry/government)
        -   [View all industries](https://github.com/solutions/industry)
        
    
    [View all solutions](https://github.com/solutions)
    
-   Resources
    
    -   EXPLORE BY TOPIC
        
        -   [AI](https://github.com/resources/articles?topic=ai)
        -   [Software Development](https://github.com/resources/articles?topic=software-development)
        -   [DevOps](https://github.com/resources/articles?topic=devops)
        -   [Security](https://github.com/resources/articles?topic=security)
        -   [View all topics](https://github.com/resources/articles)
        
    -   EXPLORE BY TYPE
        
        -   [Customer stories](https://github.com/customer-stories)
        -   [Events & webinars](https://github.com/resources/events)
        -   [Ebooks & reports](https://github.com/resources/whitepapers)
        -   [Business insights](https://github.com/solutions/executive-insights)
        -   [GitHub Skills](https://skills.github.com)
        
    -   SUPPORT & SERVICES
        
        -   [Documentation](https://docs.github.com)
        -   [Customer support](https://support.github.com)
        -   [Community forum](https://github.com/orgs/community/discussions)
        -   [Trust center](https://github.com/trust-center)
        -   [Partners](https://github.com/partners)
        
    
    [View all resources](https://github.com/resources)
    
-   Open Source
    
    -   COMMUNITY
        
        -   [GitHub SponsorsFund open source developers](https://github.com/open-source/sponsors)
        
    -   PROGRAMS
        
        -   [Security Lab](https://securitylab.github.com)
        -   [Maintainer Community](https://maintainers.github.com)
        -   [Accelerator](https://github.com/open-source/accelerator)
        -   [GitHub Stars](https://stars.github.com)
        -   [Archive Program](https://archiveprogram.github.com)
        
    -   REPOSITORIES
        
        -   [Topics](https://github.com/topics)
        -   [Trending](https://github.com/trending)
        -   [Collections](https://github.com/collections)
        
    
-   Enterprise
    
    -   ENTERPRISE SOLUTIONS
        
        -   [Enterprise platformAI-powered developer platform](https://github.com/enterprise)
        
    -   AVAILABLE ADD-ONS
        
        -   [GitHub Advanced SecurityEnterprise-grade security features](https://github.com/security/advanced-security)
        -   [Copilot for BusinessEnterprise-grade AI features](https://github.com/features/copilot/copilot-business)
        -   [Premium SupportEnterprise-grade 24/7 support](https://github.com/enterprise/premium-support)
        
    
-   [Pricing](https://github.com/pricing)

Search/

[Sign in](/login?return_to=https%3A%2F%2Fgithub.com%2Fvllm-project%2Fvllm%2Fissues%3Fq%3Ddeepseek-v4)

[Sign up](/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fissues%2Findex&source=header-repo&source_repo=vllm-project%2Fvllm)

Appearance settings

You signed in with another tab or window. Reload to refresh your session. You signed out in another tab or window. Reload to refresh your session. You switched accounts on another tab or window. Reload to refresh your session. Dismiss alert

### Uh oh!

There was an error while loading. Please reload this page.

[vllm-project](/vllm-project) / **[vllm](/vllm-project/vllm)** Public

-   ### Uh oh!
    
    There was an error while loading. Please reload this page.
    
-   [Notifications](/login?return_to=%2Fvllm-project%2Fvllm) You must be signed in to change notification settings
-   [Fork 20.8k](/login?return_to=%2Fvllm-project%2Fvllm)
-   [Star 89.3k](/login?return_to=%2Fvllm-project%2Fvllm)
    

-   [Code](/vllm-project/vllm)
-   [Issues 2.1k](/vllm-project/vllm/issues)
-   [Pull requests 4.6k](/vllm-project/vllm/pulls)
-   [Discussions](/vllm-project/vllm/discussions)
-   [Actions](/vllm-project/vllm/actions)
-   [Projects](/vllm-project/vllm/projects)
-   [Security and quality 62](/vllm-project/vllm/security)
-   [Insights](/vllm-project/vllm/pulse)

Additional navigation options

-   [Code](/vllm-project/vllm)
-   [Issues](/vllm-project/vllm/issues)
-   [Pull requests](/vllm-project/vllm/pulls)
-   [Discussions](/vllm-project/vllm/discussions)
-   [Actions](/vllm-project/vllm/actions)
-   [Projects](/vllm-project/vllm/projects)
-   [Security and quality](/vllm-project/vllm/security)
-   [Insights](/vllm-project/vllm/pulse)

-   [
    
    Issues
    
    ](/vllm-project/vllm/issues?q=is%3Aissue+state%3Aopen)
-   [
    
    Assigned to me
    
    ](/vllm-project/vllm/issues?q=is%3Aissue+state%3Aopen+assignee%3A%40me)
-   [
    
    Created by me
    
    ](/vllm-project/vllm/issues?q=is%3Aissue+state%3Aopen+author%3A%40me)
-   [
    
    Mentioned
    
    ](/vllm-project/vllm/issues?q=is%3Aissue+state%3Aopen+mentions%3A%40me)
-   [
    
    Recent activity
    
    ](/vllm-project/vllm/issues?q=is%3Aissue+updated%3A%3E%40today-1w+sort%3Aupdated-desc)

---

-   [Views](/vllm-project/vllm/issues/views)
-   [Projects](/vllm-project/vllm/projects)
-   [Milestones](/vllm-project/vllm/milestones)
-   [Labels](/vllm-project/vllm/labels)

-   [FeedbackPreview](https://gh.io/issues-sidebar-feedback)

-   Collapse sidebar

# All issues

New issueIssue creation is restricted in this repository

-   [\[RFC\]: Changes in vLLM Model Development](https://github.com/vllm-project/vllm/issues/42770)
    
    #42770 · [WoosukKwon](https://github.com/WoosukKwon) opened on May 15, 2026
    
    21
    
-   [\[Roadmap\] Rust Frontend Feature Parity](https://github.com/vllm-project/vllm/issues/44280)
    
    #44280 · [BugenZhao](https://github.com/BugenZhao) opened on Jun 2, 2026
    
    29
    
-   [\[Model Support\] Kimi K3 Tracking Issue](https://github.com/vllm-project/vllm/issues/50001)
    
    #50001 · [ywang96](https://github.com/ywang96) opened on Jul 27, 2026
    
    9
    

## Issues

Search Issues

deepseek-v4

deepseek-v4

Search

## Search results

Open

Closed

-   ### [\[Bugfix\]\[KV Offload\] Widen eagle lookup query for non-sliding-window groups](/vllm-project/vllm/pull/52669)
    
    [bugSomething isn't working](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Abug)Something isn't working
    
    [kv-connector](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Akv-connector)
    
    Status: Closed (abandoned).
    
    vllm-project/vllmnumber 52669
    
    #52669 In vllm-project/vllm;
    
    · by [yifjiang](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Ayifjiang) was closed on Aug 18, 2026
    

-   ### [\[Rust Frontend\] Add Hunyuan A13B reasoning parser](/vllm-project/vllm/pull/52658)
    
    [rust](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Arust)
    
    Status: Open (in progress).
    
    vllm-project/vllmnumber 52658
    
    #52658 In vllm-project/vllm;
    
    · [LuisPard011](/vllm-project/vllm/issues?q=deepseek-v4%20author%3ALuisPard011) opened on Aug 17, 2026
    

-   ### [\[Bugfix\]\[Parser\] Recover DeepSeek V4 tool calls with malformed DSML wrappers](/vllm-project/vllm/pull/52645)
    
    [bugSomething isn't working](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Abug)Something isn't working
    
    [deepseekRelated to DeepSeek models](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Adeepseek)Related to DeepSeek models
    
    [tool-calling](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Atool-calling)
    
    Status: Open (in progress).
    
    vllm-project/vllmnumber 52645
    
    #52645 In vllm-project/vllm;
    
    · [jinbagi](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Ajinbagi) opened on Aug 17, 2026
    

-   ### [\[Bug\]\[ROCm\]: DeepSeek V4 accuracy drops with MRV2 on MI350/MI355 when FULL\_DECODE\_ONLY graph](/vllm-project/vllm/issues/52644)
    
    [bugSomething isn't working](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Abug)Something isn't working
    
    [rocmRelated to AMD ROCm](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Arocm)Related to AMD ROCm
    
    Status: Open.
    
    #52644 In vllm-project/vllm;
    
    · [qli88](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Aqli88) opened on Aug 17, 2026
    

-   ### [\[Feature\]: Optional content fallback policy for length-truncated reasoning responses](/vllm-project/vllm/issues/52640)
    
    [feature requestNew feature or request](/vllm-project/vllm/issues?q=deepseek-v4%20label%3A%22feature%20request%22)New feature or request
    
    Status: Open.
    
    #52640 In vllm-project/vllm;
    
    · [surajssd](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Asurajssd) opened on Aug 17, 2026
    

-   ### [\[ROCm\] Enable fused AR draft metadata updates for DeepSeek V4](/vllm-project/vllm/pull/52628)
    
    [deepseekRelated to DeepSeek models](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Adeepseek)Related to DeepSeek models
    
    [rocmRelated to AMD ROCm](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Arocm)Related to AMD ROCm
    
    Status: Open (in progress).
    
    vllm-project/vllmnumber 52628
    
    #52628 In vllm-project/vllm;
    
    · [tpopp](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Atpopp) opened on Aug 17, 2026
    

-   ### [\[Bugfix\] Fix DeepSeek V4 mHC broadcast buffer for weight sync](/vllm-project/vllm/pull/52626)
    
    [bugSomething isn't working](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Abug)Something isn't working
    
    [deepseekRelated to DeepSeek models](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Adeepseek)Related to DeepSeek models
    
    [readyONLY add when PR is ready to merge/full CI is needed](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Aready)ONLY add when PR is ready to merge/full CI is needed
    
    Status: Merged (completed).
    
    vllm-project/vllmnumber 52626
    
    #52626 In vllm-project/vllm;
    
    · by [HollowMan6](/vllm-project/vllm/issues?q=deepseek-v4%20author%3AHollowMan6) was closed on Aug 18, 2026
    

-   ### [fix: avoid overlapping stores in XPU KV cache kernel](/vllm-project/vllm/pull/52582)
    
    [deepseekRelated to DeepSeek models](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Adeepseek)Related to DeepSeek models
    
    [intel-gpuRelated to Intel GPU](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Aintel-gpu)Related to Intel GPU
    
    Status: Open (in progress).
    
    vllm-project/vllmnumber 52582
    
    #52582 In vllm-project/vllm;
    
    · [AbarnaaSree](/vllm-project/vllm/issues?q=deepseek-v4%20author%3AAbarnaaSree) opened on Aug 17, 2026
    

-   ### [\[Config\] Unify indexer cache dtype under attention\_config.indexer\_kv\_dtype](/vllm-project/vllm/pull/52550)
    
    [readyONLY add when PR is ready to merge/full CI is needed](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Aready)ONLY add when PR is ready to merge/full CI is needed
    
    Status: Merged (completed).
    
    vllm-project/vllmnumber 52550
    
    #52550 In vllm-project/vllm;
    
    · by [zyongye](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Azyongye) was closed on Aug 17, 2026
    

-   ### [\[Feat\]\[Bench\] Allow random dataset to sample real tokens from --dataset-path](/vllm-project/vllm/pull/52537)
    
    [performancePerformance-related issues](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Aperformance)Performance-related issues
    
    Status: Open (in progress).
    
    vllm-project/vllmnumber 52537
    
    #52537 In vllm-project/vllm;
    
    · [wuhangxian](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Awuhangxian) opened on Aug 16, 2026
    

-   ### [\[Feature\] Allow random dataset to use --dataset-path for realistic token sampling](/vllm-project/vllm/issues/52536)
    
    Status: Open.
    
    #52536 In vllm-project/vllm;
    
    · [wuhangxian](/vllm-project/vllm/issues?q=deepseek-v4%20author%3Awuhangxian) opened on Aug 16, 2026
    

-   ### [\[Bugfix\] Make attention-head / TP divisibility error actionable](/vllm-project/vllm/pull/52535)
    
    [bugSomething isn't working](/vllm-project/vllm/issues?q=deepseek-v4%20label%3Abug)Something isn't working
    
    Status: Open (in progress).
    
    vllm-project/vllmnumber 52535
    
    #52535 In vllm-project/vllm;
    
    · [SayHelloToWorld](/vllm-project/vllm/issues?q=deepseek-v4%20author%3ASayHelloToWorld) opened on Aug 16, 2026
    

## Footer

[](https://github.com)© 2026 GitHub, Inc.

### Footer navigation

-   [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
-   [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
-   [Security](https://github.com/security)
-   [Status](https://www.githubstatus.com/)
-   [Community](https://github.community/)
-   [Docs](https://docs.github.com/)
-   [Contact](https://support.github.com?tags=dotcom-footer)
-   Manage cookies
-   Do not share my personal information

You can’t perform that action at this time.
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash/blob/main/inference/README.md"
}
```

**Output:**
```
                

  inference/README.md · deepseek-ai/DeepSeek-V4-Flash at main   

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

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6538815d1bdb3c40db94fbfa/xMBly9PUMphrFVMxLX4kq.png)

](/deepseek-ai)

[deepseek-ai](/deepseek-ai)

/

[DeepSeek-V4-Flash](/deepseek-ai/DeepSeek-V4-Flash)

like 2.11k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6538815d1bdb3c40db94fbfa/xMBly9PUMphrFVMxLX4kq.png) DeepSeek 142k

[

Text Generation

](/models?pipeline_tag=text-generation)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

deepseek\_v4

](/models?other=deepseek_v4)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)[

8-bit precision

](/models?other=8-bit)[

fp8

](/models?other=fp8)

arxiv: 2606.19348

License: mit

[Model card](/deepseek-ai/DeepSeek-V4-Flash) [Files Files and versions

xet

](/deepseek-ai/DeepSeek-V4-Flash/tree/main)[Community

54

](/deepseek-ai/DeepSeek-V4-Flash/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use deepseek-ai/DeepSeek-V4-Flash with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/deepseek-ai/DeepSeek-V4-Flash?library=transformers)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("text-generation", model="deepseek-ai/DeepSeek-V4-Flash")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    pipe(messages)
    
    \# Load model directly
    from transformers import AutoTokenizer, AutoModelForCausalLM
    
    tokenizer = AutoTokenizer.from\_pretrained("deepseek-ai/DeepSeek-V4-Flash")
    model = AutoModelForCausalLM.from\_pretrained("deepseek-ai/DeepSeek-V4-Flash", device\_map="auto")
    
-   Inference
-   Inference Providers
-   [HuggingChat](/chat/models/deepseek-ai/DeepSeek-V4-Flash)
-   Notebooks
-   [Google Colab](/deepseek-ai/DeepSeek-V4-Flash/colab)
-   [Kaggle](/deepseek-ai/DeepSeek-V4-Flash/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/deepseek-ai/DeepSeek-V4-Flash?local-app=vllm)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "deepseek-ai/DeepSeek-V4-Flash"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "deepseek-ai/DeepSeek-V4-Flash",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/deepseek-ai/DeepSeek-V4-Flash
    
-   [SGLang](/deepseek-ai/DeepSeek-V4-Flash?local-app=sglang)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "deepseek-ai/DeepSeek-V4-Flash" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "deepseek-ai/DeepSeek-V4-Flash",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
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
            --model-path "deepseek-ai/DeepSeek-V4-Flash" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "deepseek-ai/DeepSeek-V4-Flash",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/deepseek-ai/DeepSeek-V4-Flash?local-app=docker-model-runner)
    
    How to use deepseek-ai/DeepSeek-V4-Flash with Docker Model Runner:
    
    docker model run hf.co/deepseek-ai/DeepSeek-V4-Flash
    

main

[DeepSeek-V4-Flash](/deepseek-ai/DeepSeek-V4-Flash/tree/main) / [inference](/deepseek-ai/DeepSeek-V4-Flash/tree/main/inference) /README.md

![GeeeekExplorer's picture](/avatars/92c18f20d6cdbce66cd475706b1a5ceb.svg)

[GeeeekExplorer](/GeeeekExplorer)

add inference code

[2b88d47](/deepseek-ai/DeepSeek-V4-Flash/commit/2b88d470ff9b52df7e87bbe5887ff786b77f676a) verified 4 months ago

[preview](/deepseek-ai/DeepSeek-V4-Flash/blob/main/inference/README.md) [code](/deepseek-ai/DeepSeek-V4-Flash/blob/main/inference/README.md?code=true)

|

[Raw](/deepseek-ai/DeepSeek-V4-Flash/raw/main/inference/README.md)

Download with hf CLI

Copy download link

[History](/deepseek-ai/DeepSeek-V4-Flash/commits/main/inference/README.md) [Blame](/deepseek-ai/DeepSeek-V4-Flash/blame/main/inference/README.md) [Contribute](/deepseek-ai/DeepSeek-V4-Flash/edit/main/inference/README.md) [Delete](/deepseek-ai/DeepSeek-V4-Flash/delete/main/inference/README.md)

951 Bytes

# [](#inference-code-for-deepseek-models)Inference code for DeepSeek models

First convert huggingface model weight files to the format of this project.

```bash
export EXPERTS=256
export MP=4
export CONFIG=config.json
python convert.py --hf-ckpt-path ${HF_CKPT_PATH} --save-path ${SAVE_PATH} --n-experts ${EXPERTS} --model-parallel ${MP}
```

Then chat with DeepSeek model at will!

```bash
torchrun --nproc-per-node ${MP} generate.py --ckpt-path ${SAVE_PATH} --config ${CONFIG} --interactive
```

Or batch inference from file.

```bash
torchrun --nproc-per-node ${MP} generate.py --ckpt-path ${SAVE_PATH} --config ${CONFIG} --input-file ${FILE}
```

Or multi nodes inference.

```bash
torchrun --nnodes ${NODES} --nproc-per-node $((MP / NODES)) --node-rank $RANK --master-addr $ADDR generate.py --ckpt-path ${SAVE_PATH} --config ${CONFIG} --input-file ${FILE}
```

If you want to use fp8, just remove `"expert_dtype": "fp4"` in `config.json` and specify `--expert-dtype fp8` in `convert.py`.
```

---

## Assistant (Plan · Claude Sonnet 5 · 54.9s)

_Thinking:_



## Updated Plan: vLLM-based OpenAI-compatible serving for coding (quality-first)

Your answers change the recommended architecture meaningfully — dropping the Ollama/GGUF path in favor of **native-precision serving via vLLM**, which turns out to be well-supported and to fit your hardware better than expected.

### Key finding: vLLM has active, current DeepSeek-V4-specific support
I checked vLLM's issue/PR tracker — there's a cluster of recent, DeepSeek-V4-specific work already merged or in progress: mHC layer fixes, a **tool-calling parser for DeepSeek-V4's "DSML" format**, and reasoning-parser handling for its think/non-think/max-think modes. This matters directly for you: OpenCode relies on reliable tool-calling, and this is a native vLLM feature (not something GGUF/Ollama would give you as cleanly, since the model ships **no Jinja chat template** — it needs custom encode/decode logic that vLLM's DeepSeek-V4 integration already handles, but Ollama's Modelfile templating would not without you writing that logic yourself).

**Decision: use vLLM (not Ollama, not GGUF quantization) as the serving engine.** It natively exposes an OpenAI-compatible `/v1/chat/completions` API — satisfies your requirement 2 directly, and both OpenWebUI and OpenCode can point straight at it as a custom OpenAI-compatible provider.

### Quality-first precision choice (revised sizing)
Since speed is secondary, don't default to the model's native FP4-expert config — push for the higher-quality option DeepSeek's own inference docs expose: **swap experts from FP4 to FP8** (`--expert-dtype fp8`, removing `expert_dtype: fp4` from config). This roughly doubles expert memory but maximizes quality, which matters for coding correctness.

| | Flash, FP8 everywhere | Pro, native FP4+FP8 mixed | Pro, FP8 everywhere |
|---|---|---|---|
| Approx. resident size | ~284GB | ~800–870GB | ~1.6TB |
| Fits Dell 7960T (384GB VRAM)? | **Yes, entirely in VRAM** across 4×96GB GPUs (tensor-parallel=4) | No — needs VRAM+RAM hybrid (896GB pool), leaves little headroom | No — needs a second node |

**Flash, now:** run at full FP8 quality, 100% in VRAM on the Dell 7960T. This avoids GGUF quantization loss entirely and should be close to the benchmarked numbers in DeepSeek's own report (SWE-bench Verified 78.6–79%, close to Pro's 80.6%).

**Pro, long run — this needs a decision from you:** at native FP4+FP8 mixed (~800-870GB) it barely fits your single node's 896GB combined VRAM+RAM pool, leaving almost no headroom for KV cache and forcing slow CPU-RAM-offloaded experts for anything not GPU-resident — a real quality-vs-usability compromise, and NOT the "quality most important" outcome you want. Two paths:
- **(a) Squeeze it onto current hardware** via CPU offload (accept slower generation, some risk of running out of headroom at longer contexts).
- **(b) Add a second node** (e.g., a matching 4-GPU workstation) and run Pro distributed via vLLM's multi-node tensor/pipeline parallelism — full native precision, real GPU throughput, no RAM-offload bottleneck. This is what I'd recommend given your quality priority, but it's a hardware/budget call only you can make.

### DGX Spark's role
Given the quality-first, OpenAI-API requirement, the DGX Spark (128GB unified memory, ARM/GB10) is now best used as a **secondary/staging box** — e.g., testing new DeepSeek-V4 vLLM builds, running Flash at reduced precision for quick iteration, or hosting a second smaller model — not as a primary coding-quality server. Its unified memory bandwidth (~273GB/s) is well below the Dell box's GDDR7 GPUs, and vLLM support for GB10/sm_121 needs to be verified (likely fine given NVIDIA's push for vLLM on DGX products, but worth confirming the wheel/build you use actually targets that compute capability before relying on it).

### Execution steps (once you leave plan mode)
1. Confirm vLLM version with merged DeepSeek-V4 tool-calling/reasoning parser support (recent — check exact parser names via `vllm serve --help`, e.g. `--tool-call-parser` / `--reasoning-parser` values for deepseek-v4/DSML).
2. Install vLLM on the Dell 7960T; `vllm serve deepseek-ai/DeepSeek-V4-Flash --tensor-parallel-size 4 --expert-dtype fp8 --enable-auto-tool-choice --tool-call-parser <deepseek-v4-parser> --reasoning-parser <deepseek-v4-parser> --host 0.0.0.0 --port 8000`.
3. Smoke-test with curl against `/v1/chat/completions`, verify tool-calls and thinking-mode output render correctly.
4. Point OpenWebUI (Settings → Connections → OpenAI API, base URL `http://<host>:8000/v1`) and OpenCode (custom OpenAI-compatible provider in its config) at the endpoint.
5. Benchmark on real coding tasks (SWE-style, agentic tool use) before treating as default.
6. Separately plan/scope Pro: decide (a) vs (b) above, then repeat steps 2–5 for Pro once hardware/approach is settled.

### Open questions
- For Pro: do you want me to plan for option (a) squeeze-onto-current-hardware, or (b) budget/plan for a second node? Or hold that decision until Flash is validated?
- Do you have a target timeline/budget ceiling for Pro, or is "long run" open-ended for now?
- Any preference on exposing thinking-mode/reasoning content to OpenCode/OpenWebUI (shown separately vs. hidden), since that affects which vLLM reasoning-parser flags we enable?

---

## User

1. not sure if I understood this correctly: "Since speed is secondary, don't default to the model's native FP4-expert config"

Is the DeepSeekV4 FP4 by default and you want to push it up to FP8?

2. I cannot use additional hardware. The hardware cannot be changed.

---

## Assistant (Plan · Claude Sonnet 5 · 73.3s)

_Thinking:_



Good catch to double-check — let me answer directly, then adjust the Pro plan since new hardware is off the table.

### 1. Yes, that's exactly right

DeepSeek ships the **instruct** checkpoints (`DeepSeek-V4-Flash` and `DeepSeek-V4-Pro`, the ones you'd actually use for coding) at **"FP4 + FP8 Mixed"** by default — that's the out-of-the-box precision, not something I'm adding. Per DeepSeek's own inference docs: MoE expert weights (the bulk of the parameters) are stored/run at FP4, while attention and shared layers run at FP8.

Their reference inference code explicitly documents an override: delete `"expert_dtype": "fp4"` from `config.json` and pass `--expert-dtype fp8`, which keeps the experts at FP8 instead of down-compressing them to FP4. Based on the tensor types listed on the HF repo (it includes `F8_E4M3` alongside the 4-bit format), this looks like the checkpoint already carries FP8-precision expert tensors and the default config additionally quantizes them to FP4 for memory savings — meaning disabling that step gets you real extra precision, not a lossy round-trip. Since you said quality > speed, I proposed skipping that down-quantization step. Bigger memory footprint (~284GB vs ~156GB for Flash), but that's fine since it still fits your 384GB-VRAM box.

**Caveat I need to verify before this is a real plan, not just a good idea:** that override is documented for DeepSeek's own reference `convert.py`/`generate.py` stack (which doesn't expose an OpenAI-compatible API by itself). Whether vLLM's loader for the `deepseek_v4` architecture respects/exposes the same `expert_dtype` toggle from `config.json`, or requires a different flag, or doesn't support it at all yet (given how fresh the vLLM integration is), is something I have not confirmed — it needs testing against the actual vLLM version before you rely on it. If vLLM doesn't support it, the fallback is the model's native FP4+FP8 mixed default via vLLM as-is, which is still fully supported and is what the benchmarks in the model card were measured on.

### 2. No new hardware — this rules out my "add a second node" option for Pro

Revised assessment for Pro (1.6T total / 49B active) confined to what you have:

- **Flash plan is unaffected** — full FP8 (or fallback to native FP4+FP8) serving via vLLM, 100% in VRAM on the Dell 7960T (4×96GB), tensor-parallel=4. Stays the near-term deliverable.
- **Pro must fit inside Dell 7960T alone** (384GB VRAM + 512GB RAM = 896GB pool) at native FP4+FP8 mixed (~800–870GB estimated). That's a very tight fit — likely leaves little room for KV cache, especially at anything close to the 1M-token context, and vLLM itself isn't really built for hundreds-of-GB CPU-offload (its `--cpu-offload-gb` flag is meant for small shortfalls, not this scale).
- **Better tool for this specific job: ktransformers**, not vLLM, for Pro. It's purpose-built for exactly this case — DeepSeek-style MoE with GPU-resident "hot" experts and CPU-RAM-resident "cold" experts — and it exposes an **OpenAI-compatible API server** out of the box, satisfying your requirement 2 without needing Ollama. Since only 49B of Pro's 1.6T params are active per token, this hybrid split is architecturally the intended way to run it on a single workstation-class box, and slower generation is an acceptable tradeoff given your stated priority.
- This does mean **two different serving engines** in your stack — vLLM for Flash, ktransformers for Pro — both exposed as separate OpenAI-compatible endpoints/model entries in OpenWebUI and OpenCode. Worth confirming that's acceptable to you operationally (two services to keep running/updated) versus preferring one engine for both, which — given the hardware ceiling — isn't realistically vLLM-only for Pro.
- One more idea worth investigating, not promising it'll pan out: since you already own the DGX Spark (128GB unified memory), it's technically possible to pool both machines together via network-distributed pipeline-parallel inference for Pro, which would give more headroom (more total memory, more room for KV cache/longer context). But mixing an ARM/GB10 box with x86/Blackwell GPU workstation in one distributed inference job is unusual and not something I can confirm works cleanly in either vLLM or ktransformers without testing — and it only helps if there's a fast, low-latency link between the two boxes.

### Questions before I finalize this
- What's the network connection between the DGX Spark and the Dell 7960T (10GbE, 100GbE/InfiniBand, or just standalone boxes on a regular LAN)? This determines whether pooling them for Pro is even worth investigating.
- Are you okay running two different engines (vLLM for Flash, ktransformers for Pro) as separate endpoints, or would you rather I look harder for a single-engine solution even if it's more constrained?
- For Pro specifically, is there a minimum acceptable context length/throughput floor, or truly "any speed is fine as long as it runs" given the tight memory fit?

---

## User

1. I do not want to network-connect the DGX with the Dell
2. ok to run 2 different engines
3. in real coding scenarios I easily reached 350k - 370k in context size.

---

## Assistant (Plan · Claude Sonnet 5 · 39.7s)

_Thinking:_



### Revised assessment given the context requirement (350–370K tokens)

This is the detail that actually stresses the Pro plan the most, and it interacts directly with the "no new hardware" constraint from before.

**Flash — still comfortable.** At full FP8 experts (~284GB) on the Dell 7960T's 384GB VRAM, that leaves ~100GB of VRAM headroom for KV cache + activations. DeepSeek's V4 architecture (Compressed Sparse Attention + Heavily Compressed Attention) specifically claims ~10% the KV-cache footprint of V3.2 at 1M-token context, so 350–370K should fit with room to spare. This remains low-risk.

**Pro — this is where the constraints collide.** Recap of the memory budget on the Dell 7960T alone (384GB VRAM + 512GB RAM = 896GB pool, since we've ruled out pulling in the DGX Spark):

- Native FP4+FP8 mixed weights: ~800–870GB estimated
- That leaves only **~25–95GB** for KV cache, activations, and OS overhead
- Pro is a much bigger/wider model than Flash (1.6T vs 284B total), so its per-token KV-cache cost at 350–370K tokens is very likely higher in absolute terms than Flash's, even with the same compressed-attention architecture

I don't have hard numbers on DeepSeek-V4-Pro's actual per-token KV-cache size (that depends on internal details of CSA/HCA I can't verify without testing), so I can't tell you with confidence today whether "~50GB of headroom" is enough for 350–370K tokens. It's a real open risk, not a solved problem — and it directly conflicts with keeping Pro at max precision, since more precision (more of the 896GB pool consumed by weights) directly means less room for the context length you actually use.

**The honest tradeoff to put in front of you:** on this fixed hardware, Pro likely can't have *both* full native FP4+FP8 quality *and* your full working context of 350–370K simultaneously with real headroom. Realistic options, roughly in order of how much they preserve context length vs. precision:

1. **Trim Pro's precision below native** (e.g., a Q5/Q6-class quantization instead of the FP4+FP8 mixed default) to free up ~150–250GB for KV cache — sacrifices some quality to guarantee your context length works.
2. **Keep native FP4+FP8 mixed precision, accept an empirically-discovered lower max context** than 350–370K for Pro specifically (Flash would still handle your full range).
3. **Split the difference**: use ktransformers' per-layer placement flexibility (it lets you choose which layers/experts sit in VRAM vs. system RAM, and can push KV cache to CPU RAM at a speed cost) to tune a middle ground empirically rather than guessing up front.

Given this can't be resolved analytically with confidence, the responsible next step is an **empirical validation pass**: stand up Pro under ktransformers at native precision, measure actual KV-cache memory per 1K tokens at your real prompt/context shapes, and see where the ceiling actually falls — before deciding whether to trim precision. This should happen early, since it determines whether Pro is usable for your actual coding workflow at all in its default form.

### Question before I finalize
If testing shows Pro genuinely can't do both full precision and ~350–370K context on this hardware, which do you want prioritized: **keep full context length and accept a lower-precision Pro**, or **keep max precision and accept a lower max context for Pro** (with Flash still covering the long-context cases)?

---

## User

for Pro I accept lower precision

---

## Assistant (Plan · Claude Sonnet 5 · 18.2s)

_Thinking:_



### Final consolidated plan

With that decision, here's the complete plan, ready for execution when you give the go-ahead.

---

## Phase 1: DeepSeek-V4-Flash (near-term, Dell 7960T)

- **Engine:** vLLM, OpenAI-compatible `/v1/chat/completions` API
- **Precision:** FP8 experts (upgraded from native FP4+FP8 mixed) — quality-maximizing, since the ~284GB footprint still fits comfortably in the 384GB VRAM pool (4×96GB RTX Pro 6000 Blackwell Max-Q) with room for your 350–370K context
- **Fallback:** if vLLM's `deepseek_v4` loader doesn't expose the `expert_dtype` override, drop to native FP4+FP8 mixed default (still fully supported, still fits with more headroom)
- **Parallelism:** tensor-parallel=4 across the 4 GPUs
- **Tool calling / reasoning:** enable vLLM's DeepSeek-V4-specific tool-call parser and reasoning parser (recently merged upstream) so OpenCode's agentic tool use and thinking-mode output work correctly
- **Validation:** curl smoke test → confirm tool calls and think/non-think modes render → connect OpenWebUI and OpenCode → real coding-task benchmark before treating as default

## Phase 2: DeepSeek-V4-Pro (long run, Dell 7960T only — no DGX Spark networking)

- **Engine:** ktransformers (not vLLM) — purpose-built for GPU+CPU-RAM hybrid MoE inference, exposes an OpenAI-compatible API natively
- **Memory budget:** 384GB VRAM + 512GB system RAM = 896GB pool, all on one box
- **Precision:** lower than native FP4+FP8 mixed, chosen specifically to leave enough headroom for 350–370K-token KV cache (exact quant level — e.g. Q5/Q6-class — to be set empirically, not guessed)
- **Process:**
  1. Deploy at native FP4+FP8 mixed first, empirically measure actual KV-cache memory per 1K tokens at your real context shapes
  2. Use that measurement to pick the lightest precision trim that reliably supports 350–370K context with safe headroom (not the tightest possible fit — leave margin for spikes/variance)
  3. Use ktransformers' per-layer placement config to tune which experts/layers sit in VRAM vs. RAM around that precision choice
  4. Validate tool-calling and reasoning-mode behavior same as Flash (ktransformers' DeepSeek support maturity for this should be checked — likely less battle-tested than vLLM's, given how new V4 is)
- **Endpoint:** separate OpenAI-compatible service/port from the vLLM Flash instance; both registered as distinct model entries in OpenWebUI and OpenCode

## Cross-cutting items
- Two independently running services on the Dell 7960T (vLLM for Flash, ktransformers for Pro) — you've confirmed this is acceptable
- DGX Spark stays standalone — no cross-node work, available for other use (staging/testing, smaller models, etc.) but out of scope for this deployment
- Source models: official `deepseek-ai/DeepSeek-V4-Flash` / `-Pro` from Hugging Face (MIT license) loaded directly by vLLM/ktransformers — no third-party GGUF requantization needed, avoiding an extra source of quality loss and trust/provenance concerns
- Verify software versions before starting: vLLM build with confirmed DeepSeek-V4 tool-call/reasoning-parser support, ktransformers build with DeepSeek-V4 architecture support, and GPU driver/CUDA compatibility for the RTX Pro 6000 Blackwell cards

---

Is there anything else you want to adjust before I move to execution, or should I proceed to build this out (install/config vLLM for Flash first, then ktransformers for Pro)?

---

## User

create a new feature for this . There is an ADR in specmgr that shows you how to create it. Use "feat-0-..." and do not create a gh issue for it. 

---

## Assistant (Plan · Claude Sonnet 5 · 19.4s)

_Thinking:_



I'm in plan mode (read-only), so I can't create anything yet — but let me investigate the ADR you're referring to so I can build an accurate plan for what "creating a feature" actually involves in specmgr.

**Tool: list_mcp_resources**

**Input:**
```json
{
  "server": "specmgr"
}
```

**Output:**
```
{
  "resources": [
    {
      "name": "adr_list",
      "title": "ADR List",
      "uri": "specmgr://adr/list",
      "description": "Ids, titles, statuses, and refs of every ADR in the configured ADR base directory (SPECMGR_ADR_DIR), for context before addressing one by id. 'ref' is an opaque, extensionless identifier -- not a filename to read from disk -- for documents that have no assigned id; use get_adr/specmgr://adr/{id} with it instead.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "iso25010",
      "title": "ISO/IEC 25010:2023 Product Quality Model",
      "uri": "specmgr://iso25010",
      "description": "The nine main characteristics (and their sub-characteristics) of the ISO/IEC 25010:2023 system/software product quality model, each with a description.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "req_example",
      "title": "REQ Example",
      "uri": "specmgr://req/example",
      "description": "A complete, valid sample requirement document as raw markdown -- frontmatter and body -- exercising every section, for use as a learning example.",
      "mimeType": "text/markdown",
      "server": "specmgr"
    },
    {
      "name": "req_list",
      "title": "Requirement List",
      "uri": "specmgr://req/list",
      "description": "Ids, titles, statuses, and refs of every requirement in the configured requirement base directory, for context before addressing one by id. 'ref' is an opaque, extensionless identifier -- not a filename to read from disk -- for documents that have no assigned id; use it with the get_req tool instead.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "req_schema",
      "title": "REQ JSON Schema",
      "uri": "specmgr://req/schema",
      "description": "The generated REQ JSON Schema (2020-12 dialect), generated by `specmgr schema` and kept current by a pre-commit hook/CI step. Includes a `$comment` schema-layout version marker for detecting a shape change without diffing the whole document.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "req_template",
      "title": "REQ Template",
      "uri": "specmgr://req/template",
      "description": "A REQ document template -- frontmatter and every body field present, populated with short placeholder ('blind text') content -- as raw markdown, for use as a starting point when drafting a new requirement.",
      "mimeType": "text/markdown",
      "server": "specmgr"
    },
    {
      "name": "tsk_example",
      "title": "TSK Example",
      "uri": "specmgr://tsk/example",
      "description": "A complete, valid sample task list document as raw markdown -- frontmatter and body -- exercising every section, for use as a learning example.",
      "mimeType": "text/markdown",
      "server": "specmgr"
    },
    {
      "name": "tsk_list",
      "title": "TSK List",
      "uri": "specmgr://tsk/list",
      "description": "Ids, titles, statuses, and refs of every task list in the configured task list base directory, for context before addressing one by id. 'ref' is an opaque, extensionless identifier -- not a filename to read from disk -- for documents that have no assigned id; use it with the get_tsk tool instead.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "tsk_schema",
      "title": "TSK JSON Schema",
      "uri": "specmgr://tsk/schema",
      "description": "The generated TSK JSON Schema (2020-12 dialect), generated by `specmgr schema` and kept current by a pre-commit hook/CI step. Includes a `$comment` schema-layout version marker for detecting a shape change without diffing the whole document.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "tsk_template",
      "title": "TSK Template",
      "uri": "specmgr://tsk/template",
      "description": "A TSK document template -- frontmatter and every body field present, populated with short placeholder ('blind text') content -- as raw markdown, for use as a starting point when drafting a new task list.",
      "mimeType": "text/markdown",
      "server": "specmgr"
    },
    {
      "name": "uc_example",
      "title": "UC Example",
      "uri": "specmgr://uc/example",
      "description": "A complete, valid sample use case document as raw markdown -- frontmatter and body -- exercising every section, for use as a learning example.",
      "mimeType": "text/markdown",
      "server": "specmgr"
    },
    {
      "name": "uc_list",
      "title": "Use Case List",
      "uri": "specmgr://uc/list",
      "description": "Ids, titles, statuses, and refs of every use case in the configured use-case base directory, for context before addressing one by id. 'ref' is an opaque, extensionless identifier -- not a filename to read from disk -- for documents that have no assigned id; use it with the get_uc tool instead.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "uc_schema",
      "title": "UC JSON Schema",
      "uri": "specmgr://uc/schema",
      "description": "The generated UC JSON Schema (2020-12 dialect), generated by `specmgr schema` and kept current by a pre-commit hook/CI step. Includes a `$comment` schema-layout version marker for detecting a shape change without diffing the whole document.",
      "mimeType": "application/json",
      "server": "specmgr"
    },
    {
      "name": "uc_template",
      "title": "UC Template",
      "uri": "specmgr://uc/template",
      "description": "A UC document template -- frontmatter and every body field present, populated with short placeholder ('blind text') content -- as raw markdown, for use as a starting point when drafting a new use case.",
      "mimeType": "text/markdown",
      "server": "specmgr"
    },
    {
      "name": "version",
      "title": "SpecMgr MCP Server Version",
      "uri": "specmgr://version",
      "description": "Installed version number of the biz-dfch-specmgr package that backs this MCP server. Lets a client check compatibility without a tool round-trip.",
      "mimeType": "application/json",
      "server": "specmgr"
    }
  ]
}
```

**Tool: list_mcp_resource_templates**

**Input:**
```json
{
  "server": "specmgr"
}
```

**Output:**
```
{
  "resourceTemplates": [
    {
      "name": "adr_get",
      "title": "Get ADR",
      "uriTemplate": "specmgr://adr/{id}",
      "description": "Full ADR document (frontmatter and body) for the given id, as structured JSON -- a resource-based, read-only counterpart of the get_adr tool for plain context retrieval without a tool round-trip.",
      "mimeType": "application/json",
      "server": "specmgr"
    }
  ]
}
```

---

## Assistant (Plan · Claude Sonnet 5 · 3.8s)

_Thinking:_



**Tool: read_mcp_resource**

**Input:**
```json
{
  "server": "specmgr",
  "uri": "specmgr://adr/list"
}
```

**Output:**
```
Resource: specmgr://adr/list
MIME: application/json
[]
```

---

## Assistant (Plan · Claude Sonnet 5 · 510.2s)

_Thinking:_



The specmgr ADR list is currently empty — there are no ADRs in the connected instance, so I can't find the one you're referencing there. A couple of things are ambiguous to me and I don't want to guess wrong before we get to execution:

**Tool: question**

**Input:**
```json
{
  "questions": [
    {
      "question": "The specmgr ADR list is empty on my end. Where should I look for the ADR that documents how to create a 'feature'?",
      "header": "Locating the ADR",
      "options": [
        {
          "label": "It's a file on disk, not yet in specmgr",
          "description": "Give me a path/repo location to read it directly with Glob/Grep/Read"
        },
        {
          "label": "It should be in specmgr but isn't showing",
          "description": "There may be a configuration issue (wrong base dir) - I should investigate specmgr's config"
        },
        {
          "label": "I misspoke - there is no existing ADR",
          "description": "You want me to draft a new ADR from scratch that establishes how 'features' are created going forward"
        }
      ],
      "multiple": false
    },
    {
      "question": "By 'create a new feature', what artifact do you want produced?",
      "header": "What 'feature' means here",
      "options": [
        {
          "label": "A specmgr document (REQ/TSK/UC) capturing this DeepSeek-V4 deployment work, using create_req/create_tsk/create_uc",
          "description": "Uses specmgr's existing document types; 'feat-0-...' would be a slug/title convention, not a literal type"
        },
        {
          "label": "A git feature branch named feat-0-... for implementation work",
          "description": "Not a specmgr document at all - just source control branching, with GH issue creation explicitly skipped"
        },
        {
          "label": "Something else - I'll clarify",
          "description": "Let me describe what I mean directly"
        }
      ]
    }
  ]
}
```

**Output:**
```
User has answered your questions: "The specmgr ADR list is empty on my end. Where should I look for the ADR that documents how to create a 'feature'?"="/home/user/src/biz.dfch.SpecMgr/docs/adr/e369ee2e-3353-4f92-991c-6367d76d832e-organize-development-artifacts-in-specmgr-with-feature.md", "By 'create a new feature', what artifact do you want produced?"="see the doc I referenced". You can now continue with the user's answers in mind.
```

---

## Assistant (Plan · Claude Sonnet 5 · 5.2s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.SpecMgr/docs/adr/e369ee2e-3353-4f92-991c-6367d76d832e-organize-development-artifacts-in-specmgr-with-feature.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.SpecMgr/docs/adr/e369ee2e-3353-4f92-991c-6367d76d832e-organize-development-artifacts-in-specmgr-with-feature.md</path>
<type>file</type>
<content>
1: ---
2: status: accepted
3: date: '2026-08-05'
4: decision-makers: dfch
5: id: e369ee2e-3353-4f92-991c-6367d76d832e
6: version: 1.0.0
7: ---
8: 
9: # Organize development artifacts in `.specmgr` with feature-driven work units
10: 
11: ## Context and Problem Statement
12: 
13: The project maintains two documentation folders with an unclear split: `docs/` — published, generated documentation (API docs, ADRs, specifications), which reflects the current state of the project — and `doc/` — development progress notes, planning artifacts, research, which has no clear ongoing purpose once this ADR's structure exists. As part of adopting this ADR's outcome, `doc/` is dissolved: its content is migrated (manually, see Consequences) into the new structure below, and the `doc/` folder is retired. Development artifacts (plans, progress tracking, work-unit status) need a structured, agent-friendly location that is: (1) separate from published documentation (`docs/`); (2) organized by feature/work-unit for easy agent reference; (3) generic enough to serve as a template for future projects using specmgr as a toolkit.
14: 
15: ## Decision Drivers
16: 
17: - Agent-friendly reference paths: agents should reference specific feature paths inline (e.g., "See `.specmgr/feat/feat-001-adr-toc/README.md`"), keeping agent instructions lean and focused
18: - Toolkit reusability: structure should be generic enough for future projects adopting specmgr as a toolkit — the folder name itself (`.specmgr/`) is chosen for this reason, following the convention of tool-named dotfolders like `.github/`, `.vscode/`, `.docker/`
19: - Clear separation of concerns: development artifacts must be distinct from published documentation
20: - Version control and auditability: development progress should be tracked in git with full history
21: 
22: ## Considered Options
23: 
24: - Single README.md per feature containing both plan and progress
25: - Separate README.md (plan) and progress.md (status) per feature
26: 
27: ## Decision Outcome
28: 
29: **Chosen option: "Option 1: .specmgr structure"** — a single `README.md` per feature combining plan and progress, with an optional sibling `history.md` for rotating out older `Recent Updates` entries. Every feature `README.md` also carries a minimal YAML frontmatter block (`id`, `version`, `status`, `created`, `updated` — see that option's "Frontmatter" note for details). There is no separate `GitHub Issue` field or body line: the issue number is the `NNN` infix already embedded in `id` (the folder name, `feat-NNN-slug`) itself.
30: 
31: This is preferred over Option 2 (separate `README.md`/`progress.md`) for its simplicity: one file per feature, no cross-file cross-referencing needed to see the full feature story, and the single canonical Task List (status inline per task) removes the Implementation Plan/Execution Plan duplication that Option 2 still carries. See "Pros and Cons of the Options" below for the full tradeoff analysis, and that option's "Open Questions" for points intentionally left open for later decisions.
32: 
33: ### Consequences
34: 
35: **Positive:**
36: - Agents can reference specific feature paths inline, keeping instructions lean and focused
37: - Clear separation: agents only read what's relevant to their task
38: - Structure is reusable for future projects adopting specmgr as a toolkit
39: - Development progress is version-controlled and auditable
40: - The `.specmgr/` folder (and its `feat/` work units) is committed to git like any other tracked path in the repo — no `.gitignore` exclusion — so history and review apply to it the same way they do to `docs/` and source code
41: 
42: **Negative:**
43: - Adds another top-level folder to the repo structure
44: - Requires discipline to keep progress sections updated (hand-maintained, not auto-generated)
45: - Migrating `doc/`'s existing content (e.g. `doc/adr-tool-plan.md`, `doc/refactor-domain.md`) into the new structure is done manually, one file at a time, once this ADR is adopted — no automated migration tooling is planned
46: 
47: **Numbering convention:**
48: - `feat-NNN-slug` — `NNN` is the GitHub issue number for feature work tied to an issue. There is no separate `github_issue` frontmatter field or body line: `id` (the folder name itself) is the single source of truth for the issue number, read by parsing its `NNN` infix.
49: - Work started without a GitHub issue yet uses `feat-0-slug` (issue number `0`) until/unless an issue is later opened for it
50: 
51: **ADR vs. feature-level "Decisions Made" log:**
52: A decision belongs in a full ADR (under `docs/adr/`) if it: (a) is architecture/structure-level and affects more than one feature or the repo as a whole, (b) would be relevant to someone joining the project later trying to understand why something is the way it is, or (c) reverses/supersedes a previous ADR. A decision belongs in the feature's own "Decisions Made" log instead if it: (a) is scoped entirely to that one feature's implementation details, (b) wouldn't need to be found by searching ADRs later, and (c) doesn't constrain future features. Tie-breaker: if in doubt, write the ADR — it is cheap to write and already indexed by `adr-toc`, so overuse is low-cost, while under-use risks losing a decision in a feature folder no one will grep later.
53: 
54: ### Confirmation
55: 
56: For now, confirmation that new `feat-NNN-slug/README.md` files follow the chosen structure/template is done manually via PR review. Automated enforcement (e.g. a `specmgr feat-*` validation tool mirroring `validate_adr`) is deferred to future work, consistent with the other deferred-tooling items noted in the chosen option's Open Questions.
57: 
58: ## Pros and Cons of the Options
59: 
60: ### Option 1: .specmgr structure
61: 
62: ```
63: .specmgr/
64: ├── feat/                          # Feature work units
65: │   └── feat-NNN-slug/             # One folder per GitHub issue
66: │       ├── README.md              # Feature plan + progress (mandatory)
67: │       └── history.md             # Archived older "Recent Updates" entries (optional)
68: └── (other dirs as needed)
69: ```
70: 
71: **File purposes:**
72: - `README.md` — Single file containing both the feature plan (requirements, acceptance criteria, task list, scope, dependencies, design notes) and progress tracking (current state, blockers, decisions made during implementation, links to related ADRs or PRs)
73: - `history.md` — Optional sibling file. Holds older `Recent Updates` entries once `README.md` grows too long; `README.md` keeps only recent entries and links back to this file for anything older.
74: 
75: **Frontmatter:** Every feature `README.md` carries a YAML frontmatter block, mandatory fields `id` (the `feat-NNN-slug` folder name itself, not a generated UUID — unlike ADR frontmatter's server-generated `id`), `version` (semver, starts at `1.0.0`), `status` (`planning` | `in-progress` | `review` | `done`), and `created`/`updated` (`YYYY-MM-DD`, `updated` bumped on every substantive edit). There is no separate `GitHub Issue` field, in frontmatter or body: the issue number is the `NNN` infix already embedded in `id` (i.e. the folder name, `feat-NNN-slug`) — `0` means no issue yet — so it is derived by reading `id`, never duplicated as its own field.
76: 
77: **Template: README.md**
78: 
79: ```markdown
80: ---
81: id: feat-NNN-slug
82: version: 1.0.0
83: status: planning
84: created: YYYY-MM-DD
85: updated: YYYY-MM-DD
86: ---
87: 
88: # Feature: [Feature Title]
89: 
90: ## Plan
91: 
92: ### Overview
93: 
94: Brief description of what this feature does and why it matters.
95: 
96: ### Requirements
97: 
98: - REQ-001: [Functional requirement]
99: - REQ-002: [Non-functional requirement]
100: - REQ-003: [Constraint or dependency]
101: 
102: ### Acceptance Criteria
103: 
104: - [ ] ACC-001: Verifies REQ-001 — [testable condition]
105: - [ ] ACC-002: Verifies REQ-002 — [testable condition]
106: - [ ] ACC-003: Verifies REQ-003 — [testable condition]
107: 
108: ### Scope
109: 
110: What is included in this feature:
111: - Item 1
112: - Item 2
113: 
114: What is explicitly out of scope:
115: - Item A
116: - Item B
117: 
118: ### Dependencies
119: 
120: - Depends on: [other feat-NNN-slug, ADR id, or external]
121: - Blocks: [other feat-NNN-slug]
122: 
123: ### Design Notes
124: 
125: Any architectural decisions, patterns, or design rationale relevant to this feature.
126: 
127: ### Related ADRs
128: 
129: - [ADR id]: [Title]
130: - [ADR id]: [Title]
131: 
132: ### Task List
133: 
134: Single, canonical breakdown of work phases and tasks. Status lives on the
135: task itself — there is no separate "planned" vs. "executed" list to keep in
136: sync; a task's line *is* its current status. Update it in place as work
137: progresses (edit, don't duplicate).
138: 
139: #### Phase 1: [Phase name]
140: - [x] Task 1.1: [description] — depends on: none — status: done (2026-08-01)
141: - [ ] Task 1.2: [description] — depends on: Task 1.1 — status: in-progress, ETA 2026-08-10
142: - [ ] Task 1.3: [description] — depends on: Task 1.2 — status: blocked (see Blockers)
143: 
144: #### Phase 2: [Phase name]
145: - [ ] Task 2.1: [description] — depends on: Task 1.3 — status: not-started
146: - [ ] Task 2.2: [description] — depends on: Task 2.1 — status: not-started
147: 
148: **Note:** If a task's scope changes mid-flight, edit its description in place;
149: rely on git history (`git log -p` on this file) to recover what was
150: originally planned, rather than keeping a second copy of the task around.
151: 
152: ## Progress
153: 
154: ### Current Status
155: 
156: **As of [YYYY-MM-DD]**: [Brief status summary]
157: 
158: ### Blockers
159: 
160: - [ ] Blocker 1 — [description, impact, mitigation]
161: - [ ] Blocker 2 — [description, impact, mitigation]
162: 
163: (Remove this section if no blockers.)
164: 
165: ### Recent Updates
166: 
167: If this section grows too long, move older entries to `history.md` in this
168: same folder and leave a pointer here, e.g.:
169: `See history.md for updates before YYYY-MM-DD.`
170: 
171: #### [YYYY-MM-DD]
172: - Completed: [what was done]
173: - Next: [what comes next]
174: - Notes: [any relevant context]
175: 
176: #### [YYYY-MM-DD]
177: - Completed: [what was done]
178: - Next: [what comes next]
179: - Notes: [any relevant context]
180: 
181: ### Decisions Made
182: 
183: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
184: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
185: 
186: ### Related PRs / Commits
187: 
188: - [PR #NNN](link): [description]
189: - [Commit hash](link): [description]
190: ```
191: 
192: **Pros:**
193: - Single file to maintain
194: - Simpler structure: one file per feature
195: - Plan and progress are always together in one document
196: - Easier to see the full feature story (what was planned vs. what happened) in one place
197: - Requirements and acceptance criteria are co-located with clear traceability
198: - Single Task List: no separate Implementation/Execution Plan pair to keep in sync — status is a property of each task line, not a duplicated list, so there is nothing to drift
199: - Auditability of "what was planned vs. what actually happened" comes from git history on this one file, not from a hand-maintained duplicate
200: - `Recent Updates` growth is bounded by rotating older entries into an optional `history.md`, keeping `README.md` itself lean
201: - Frontmatter `id`/`version`/`status`/`created`/`updated` gives each feature folder a compact, machine-readable header, mirroring the ADR frontmatter's `status` field for consistency across both document types
202: - No `GitHub Issue` duplication: the issue number is already encoded in `id`'s `NNN` infix, so there is nothing to keep in sync between a frontmatter/body field and the folder name itself
203: 
204: **Cons:**
205: - File grows over time as progress updates (Recent Updates, Decisions Made) accumulate, even with rotation available
206: - Plan and progress are intermingled, making it harder to extract just the plan for reference
207: - No clear separation between "contract" (what we committed to) and "journal" (what actually happened) — relies on git history to reconstruct the original plan instead of a preserved, separate copy
208: - Still hand-maintained/free-text: nothing currently enforces that a task's status field, or the frontmatter `status`/`updated` fields, are kept in sync with reality, or that `history.md` rotation actually happens
209: - Deriving the GitHub issue number from `id`'s `NNN` infix requires parsing the folder name rather than reading a dedicated field — acceptable since `feat-NNN-slug` is already a fixed, documented convention
210: 
211: **Open Questions:**
212: - Archival/lifecycle rule for the file once `status: done` (stay in place / archive / prune) — intentionally left undecided here; treated as a separate future project decision, not a gap in this ADR.
213: - Rotation strategy for `Recent Updates`: rotating older entries into `history.md` is documented here as an available option; the exact trigger (manual vs. a fixed entry-count rule) and mechanics are left to the user/agent maintaining the feature folder to decide at the time, not prescribed by this ADR.
214: - Template location: **resolved** — the template now exists at `.specmgr/_template/v1/README.md`, matching the versioned path scheme originally proposed here.
215: - Whether to add further frontmatter fields later (e.g. `decision_makers`, `related_adrs`, `tags`) is left open; the current five-field frontmatter (`id`, `version`, `status`, `created`, `updated`) is a deliberate, minimal starting point, not a ceiling.
216: - Recommendation (not yet built, non-blocking): a dedicated MCP tool (analogous to this project's `update_section`/`option_update` for ADRs) that flips one task's status field, or the frontmatter `status`, atomically, instead of relying on an agent/human to locate and hand-edit the right line.
217: 
218: ### Option 2: .specmgr structure with separate README.md (plan) and progress.md (status)
219: 
220: ```
221: .specmgr/
222: ├── feat/                          # Feature work units
223: │   └── feat-NNN-slug/             # One folder per GitHub issue
224: │       ├── README.md              # Feature plan (mandatory)
225: │       └── progress.md            # Status tracking (mandatory)
226: └── (other dirs as needed)
227: ```
228: 
229: **File purposes:**
230: - `README.md` — Contains the complete feature plan: requirements, acceptance criteria, implementation plan, scope, dependencies, design notes, any pre-implementation research. Treated as immutable once work begins (except Implementation Plan, which may be refined during execution).
231: - `progress.md` — Hand-maintained status log: execution plan (tracking actual progress), current state, blockers, decisions made during implementation, links to related ADRs or PRs. Updated throughout the feature lifecycle.
232: 
233: **Template: README.md**
234: 
235: ```markdown
236: # Feature: [Feature Title]
237: 
238: **GitHub Issue**: #NNN  
239: **Status**: [Planning | In Progress | Review | Done]
240: 
241: ## Overview
242: 
243: Brief description of what this feature does and why it matters.
244: 
245: ## Requirements
246: 
247: - REQ-001: [Functional requirement]
248: - REQ-002: [Non-functional requirement]
249: - REQ-003: [Constraint or dependency]
250: 
251: ## Acceptance Criteria
252: 
253: - [ ] ACC-001: Verifies REQ-001 — [testable condition]
254: - [ ] ACC-002: Verifies REQ-002 — [testable condition]
255: - [ ] ACC-003: Verifies REQ-003 — [testable condition]
256: 
257: ## Scope
258: 
259: What is included in this feature:
260: - Item 1
261: - Item 2
262: 
263: What is explicitly out of scope:
264: - Item A
265: - Item B
266: 
267: ## Dependencies
268: 
269: - Depends on: [other feat-NNN-slug, ADR id, or external]
270: - Blocks: [other feat-NNN-slug]
271: 
272: ## Design Notes
273: 
274: Any architectural decisions, patterns, or design rationale relevant to this feature.
275: 
276: ## Related ADRs
277: 
278: - [ADR id]: [Title]
279: - [ADR id]: [Title]
280: 
281: ## Implementation Plan
282: 
283: High-level breakdown of work phases and tasks:
284: 
285: ### Phase 1: [Phase name]
286: - Task 1.1: [description] — Depends on: [none/other tasks]
287: - Task 1.2: [description] — Depends on: Task 1.1
288: 
289: ### Phase 2: [Phase name]
290: - Task 2.1: [description] — Depends on: Task 1.2
291: - Task 2.2: [description] — Depends on: Task 2.1
292: ```
293: 
294: **Template: progress.md**
295: 
296: ```markdown
297: # Progress: [Feature Title]
298: 
299: ## Current Status
300: 
301: **As of [YYYY-MM-DD]**: [Brief status summary]
302: 
303: ## Execution Plan
304: 
305: Tracks actual progress against the Implementation Plan in README.md. Update task status here as work progresses.
306: 
307: ### Phase 1: [Phase name]
308: - [x] Task 1.1: [description] — Completed [YYYY-MM-DD]
309: - [ ] Task 1.2: [description] — In progress, ETA [YYYY-MM-DD]
310: 
311: ### Phase 2: [Phase name]
312: - [ ] Task 2.1: [description] — Blocked by: [blocker]
313: - [ ] Task 2.2: [description] — Not started
314: 
315: ### Blockers
316: 
317: - [ ] Blocker 1 — [description, impact, mitigation]
318: - [ ] Blocker 2 — [description, impact, mitigation]
319: 
320: (Remove this section if no blockers.)
321: 
322: ## Recent Updates
323: 
324: ### [YYYY-MM-DD]
325: - Completed: [what was done]
326: - Next: [what comes next]
327: - Notes: [any relevant context]
328: 
329: ### [YYYY-MM-DD]
330: - Completed: [what was done]
331: - Next: [what comes next]
332: - Notes: [any relevant context]
333: 
334: ## Decisions Made
335: 
336: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
337: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
338: 
339: ## Related PRs / Commits
340: 
341: - [PR #NNN](link): [description]
342: - [Commit hash](link): [description]
343: ```
344: 
345: **Pros:**
346: - Clear separation of concerns: README.md is the immutable "contract" (what we committed to), progress.md is the mutable "journal" (what actually happened)
347: - Auditability: you can see what was promised vs. what was delivered by comparing the two files
348: - Plan stays clean and focused: not cluttered with progress updates
349: - Easier to reference just the plan without scrolling through progress history
350: - Requirements and acceptance criteria are co-located with clear traceability
351: - Implementation Plan lives in README.md (single source of truth for the plan)
352: - Execution Plan lives in progress.md (single source of truth for actual progress)
353: 
354: **Cons:**
355: - Two files to maintain — requires reading both to get the full picture
356: - More complex structure
357: - Requires discipline to keep progress.md updated (hand-maintained, not auto-generated)
358: - Agents need to read both files to understand plan + current status
359: - Implementation Plan and Execution Plan are in separate files (requires cross-referencing)
360: 
361: **Open Questions:**
362: - Not chosen — this option was not carried forward with the same scrutiny/refinement pass as Option 1, since Option 1 was selected as the Decision Outcome. Retained here for reference only.
363: - Still has the original Implementation Plan / Execution Plan split (across two files, no less), i.e. the sync-burden issue identified and resolved in Option 1 via a single Task List with inline status was never addressed here.
364: - No `history.md`-equivalent or rotation mechanism for `progress.md`'s `Recent Updates` growth.
365: - Template-location ambiguity applies here too — no separate reusable template files, only what's embedded in this ADR.
366: - To be answered later, if this option is ever revisited: same open items as Option 1 (archival/lifecycle rule, template versioning path, potential atomic status-update tooling).
367: 
368: ## More Information
369: 
370: - specmgr repository: https://github.com/anomalyco/biz.dfch.SpecMgr

(End of file - total 370 lines)
</content>

<system-reminder>
Instructions from: /home/user/src/biz.dfch.SpecMgr/AGENTS.md
# AGENTS.md

Quick reference for OpenCode agents working on **biz.dfch.SpecMgr** — an artifact manager for system specifications.

## Status: five domain/cross-cutting packages implemented (ADR, REQ, UC, TSK, general)

Four document-type domains plus one cross-cutting package now exist, each
following the domain-first layout from ADR
ece4554b-725c-4f76-bc04-5d2b760363d2 ("Organize the codebase by
document-type domain: domain-first hierarchy for tools/prompts/resources,
shared versioned models"):

- **`adr/`** (Architecture Decision Records) — the original, most complete
  domain. `adr/tools/` has 11 `@mcp.tool()` wrappers (`get_adr`,
  `create_adr`, `update_frontmatter`, `update_section`, `set_status`,
  `option_list`/`option_create`/`option_read`/`option_update`/
  `option_delete`, `validate_adr`); `adr/resources/` exposes
  `specmgr://adr/list` and `specmgr://adr/{id}`; `adr/prompts/` has
  narrated `create_adr`/`update_adr` prompts plus step-gated
  `create_adr_test`/`update_adr_test` A/B variants (see
  `.specmgr/feat/feat-9-doc-in-specmgr/adr-tool-plan.md` §11). Its Pydantic
  schema uniquely lives under the shared top-level `models/adr/` (not
  `adr/models/`) — see the "models location" note below.
- **`req/`** (Requirements) — `req/tools/` (`create_req`, `update_req`,
  `set_status_req`, `parse_req`, `delete_req` stub, `validate_req`);
  `req/resources/` (`specmgr://req/list`, `specmgr://req/schema`,
  `specmgr://req/example`, `specmgr://req/template`; no `specmgr://req/{id}`
  — id-based reads are `get_req`-only, ADR
  ddfb1109-422d-4507-8dbc-dc5e4bec9614); `req/prompts/`
  (`create_req`/`update_req`). Its schema lives at `req/models/v1/`, inside
  the domain package itself, not under top-level `models/`.
- **`uc/`** (Use Cases) — same tools/resources/prompts shape as `req/` but
  for use cases (`create_uc`, `update_uc`, `set_status_uc`, `parse_uc`,
  `get_uc`, `get_uc_example`, `get_uc_template`, `delete_uc` stub,
  `validate_uc`); no `specmgr://uc/{id}` resource for the same reason as
  REQ. Schema at `uc/models/v1/` (legacy) and `uc/models/v2/` (current),
  inside the domain package, not `models/uc/`.
- **`tsk/`** (Task Lists) — same shape again (`create_tsk`, `update_tsk`,
  `set_status_tsk`, `parse_tsk`, `get_tsk`, `get_tsk_example`,
  `get_tsk_template`, `delete_tsk` stub, `validate_tsk`), plus a distinct
  `implement_task` prompt (reads a task list via `get_tsk`, builds a
  `TodoWrite` list from its items, and uses the `question` tool to resolve
  ambiguity). Schema at `tsk/models/v1/`, inside the domain package.
- **`general/`** — cross-cutting, non-domain-specific package:
  `general/tools/` (`mdformat`, formats a markdown file in place while
  preserving YAML frontmatter blocks) and `general/resources/`
  (`specmgr://version`, `specmgr://iso25010` — the ISO/IEC 25010:2023
  quality model). No `general/prompts/` yet.

**Models location — a real, intentional divergence, not an oversight**:
ADR's schema (`AdrFrontmatter`, `AdrBody`, `AdrOption`, `Adr`, `parse_adr`,
`render_adr`) stays under the shared top-level `models/adr/` package
because it predates the domain-first refactor and has no dependency on
`mcp`/`tools`/`resources`/`prompts`. REQ, UC, and TSK were built *after*
that refactor and each keep their schema inside their own domain package
(`req/models/`, `uc/models/`, `tsk/models/`) instead — fully domain-first,
models included. Top-level `models/` therefore only holds `adr/`,
`iso25010.py`, `md/` (shared cross-domain markdown-section building
blocks), and `version_info.py` — don't assume any other doc type's schema
lives there.

`server.py`'s own module docstring is the single most authoritative,
currently-maintained list of every resource/tool/prompt this MCP server
registers — read it before consulting this file for specifics, and update
it whenever you add/remove/rename a resource, tool, or prompt.
`docs/MCP.md` is the auto-generated (via `specmgr mcp-docs`), user-facing
mirror of that same registration and must never be hand-edited.

Still genuinely missing / not yet done (don't assume otherwise):
- No `validate_adr` (or `validate_req`/`validate_uc`/`validate_tsk`) tool
  runs over the repo's own documents yet via pre-commit or CI. (ADR
  9c687bb1-8ee7-41c8-84ec-07606356bc73: "Enforce doc generation/lint/tests
  locally via pre-commit hook, not just CI")
- `delete_req`/`delete_uc`/`delete_tsk` are stubs, not yet implemented.
- No `ac` (Acceptance Criteria) domain exists yet, despite `server.py`'s
  docstring already reserving a spot for it ("... and later `ac`").
- `req`/`tsk` each register `tools`, `resources`, and `prompts`; `uc`
  registers `tools` and `resources` only — it has no `prompts` sub-package
  yet.

`.specmgr/feat/feat-9-doc-in-specmgr/adr-tool-plan.md` §10 ("Next steps") tracks per-item done/not-done
status for the ADR feature specifically and should be kept in sync with
`src/` as this evolves; treat it as current-state tracking, not just a
historical design doc. Don't assume any other domain package exists beyond
`adr`/`general`/`req`/`tsk`/`uc` (with their respective
`tools`/`prompts`/`resources` sub-packages, per the exceptions noted
above), or anything in `general/resources/` beyond `version`/`iso25010` —
check first.

## Project Shape

- **Type**: Python library + optional CLI + optional MCP server, in one repo
- **Namespace**: `biz.dfch.specmgr` in `src/biz/dfch/specmgr/` — `biz`/`biz/dfch`
  are implicit namespace packages (no `__init__.py` in those two dirs; only the
  leaf `specmgr/` has one)
- **Package manager**: `uv` (not pip) — lockfile is committed, use `--frozen`
- **Python**: `requires-python = ">=3.11"` (3.11–3.13 tested in CI); local dev
  defaults to 3.13 via `.python-version` — two separate settings, keep in
  sync intentionally, not by accident

## Development Artifacts (`.specmgr/`)

Per ADR e369ee2e-3353-4f92-991c-6367d76d832e ("Organize development
artifacts in `.specmgr` with feature-driven work units"), development
planning/progress artifacts live under `.specmgr/`, separate from published
documentation in `docs/`:

```
.specmgr/
├── _template/
│   └── v1/
│       └── README.md              # Versioned feature template (plan + progress)
└── feat/
    └── feat-NNN-slug/              # One folder per GitHub issue
        ├── README.md               # Feature plan + progress (mandatory)
        └── history.md              # Archived older "Recent Updates" entries (optional)
```

- **Naming convention**: `feat-NNN-slug`, where `NNN` is the GitHub issue
  number. Work started without an issue yet uses `feat-0-slug` (issue number
  `0`) until/unless an issue is later opened for it.
- **Single `README.md` per feature** combines the plan (requirements,
  acceptance criteria, scope, dependencies, design notes) and progress
  (current status, blockers, recent updates, decisions made) — there is no
  separate `progress.md`; status lives inline on each task line, edited in
  place rather than duplicated.
- **Template**: `.specmgr/_template/v1/README.md` is the versioned,
  reusable template (copy it when starting a new feature folder). It is
  hand-copied, not scaffolded by any tool — no automation exists for this
  yet, and none is currently planned.
- **Frontmatter**: every feature `README.md` starts with a minimal YAML
  frontmatter block — `id` (the `feat-NNN-slug` folder name itself, not a
  generated UUID), `version` (semver, starts at `1.0.0`), `status`
  (`planning` | `in-progress` | `review` | `done`), and `created`/`updated`
  (`YYYY-MM-DD`, `updated` bumped on every substantive edit). There is no
  separate `GitHub Issue` field/body-line: the issue number is the `NNN`
  infix already embedded in `id`/the folder name (`feat-NNN-slug`) — `0`
  means no issue yet — so it is never duplicated elsewhere in the file. See
  ADR e369ee2e-3353-4f92-991c-6367d76d832e's Option 1 for the full
  rationale.
- **`doc/` has been migrated** into this structure — development planning docs
   now live in `.specmgr/feat/` with their respective feature folders.
- **No CI/pre-commit enforcement** exists for `.specmgr/` content — unlike
  `docs/adr/`, there is no `validate_adr`-equivalent check and no `adr-toc`-
  equivalent generation step wired into hooks or CI for feature folders.
- **ADR vs. feature-level "Decisions Made" log**: a decision belongs in a
  full ADR (`docs/adr/`) if it's architecture/structure-level, affects more
  than one feature or the repo as a whole, or reverses/supersedes a previous
  ADR. It belongs in the feature's own "Decisions Made" log instead if it's
  scoped entirely to that feature's implementation details. When in doubt,
  write the ADR.
- Existing feature folders: `.specmgr/feat/feat-9-doc-in-specmgr/`
   (development artifacts migration), `.specmgr/feat/feat-4-use-cases/` (use-case
   modeling and examples), `.specmgr/feat/feat-5-md-model-parser/` (markdown
   parsing infrastructure).

## Developer Commands

```bash
uv sync --all-extras                                                   # install deps
uv run --frozen pre-commit install                                     # one-time: enable pre-commit hooks
uv run --frozen ruff format --check && uv run --frozen ruff check      # lint (enforced)
uv run --frozen pylint $(git ls-files '*.py')                          # lint (advisory only; CI runs it with `|| true`)
uv run --frozen vulture src/ whitelist.py --min-confidence 60          # dead-code check (enforced)
uv run --frozen python -m unittest discover -v -s tests -t . -p "test_*.py"  # tests
uv run --frozen specmgr docs                                           # regenerate docs/api/ + docs/GENERATED.md
uv run --frozen specmgr adr-toc                                        # regenerate docs/adr/README.md (ADR table of contents)
uv run --frozen specmgr unused-code                                    # report unused code in src/ (same check as the vulture hook)
uv run --frozen specmgr unused-code --test                             # report symbols only referenced from tests/, never src/
uv run --frozen specmgr version                                        # run the CLI
```

### Using a different Python version

The project defaults to Python 3.13 (see `.python-version`). To use a different version (e.g., 3.12), add `--python X.Y` to **both** `uv sync` and `uv run` commands, and include `--all-extras` on the `uv run` call:

```bash
uv sync --all-extras --frozen --python 3.12
uv run --frozen --all-extras --python 3.12 specmgr docs
```

Without `--all-extras` on `uv run`, only base dependencies are installed, causing `ModuleNotFoundError` for CLI/MCP extras like `typer`.

`pylint` only sees files tracked by git (`git ls-files`) — new files must be
`git add`ed before it will lint them, both locally and in CI.

`pre-commit install` is one-time per clone (see `.pre-commit-config.yaml`):
runs `ruff format`/`ruff check`, the full `unittest` suite (scoped to
`src/**/*.py`/`tests/**/*.py` changes), a local `specmgr docs` hook (scoped to
`src/**/*.py` changes), and a local `specmgr adr-toc` hook (scoped to
`docs/adr/**/*.md` changes) before every commit, so a broken test or drift in
`docs/api/`/`docs/GENERATED.md`/`docs/adr/README.md` gets caught locally instead
of failing later in CI. (ADR 9c687bb1-8ee7-41c8-84ec-07606356bc73: "Enforce doc generation/lint/tests locally via pre-commit hook, not just CI")

## Extras split (base library has no CLI/MCP deps)

`dependencies` in `pyproject.toml` is only `pydantic` + `python-dotenv`, so the
library is usable standalone. `typer`/`rich` live in the `cli` extra, `mcp` in
the `mcp` extra. **Never** import `cli.py` or `server.py` from
`src/biz/dfch/specmgr/__init__.py` — that would force those extras onto every
consumer of the base library.

## CLI (`cli.py`)

- Typer app, entry point `specmgr` (`pyproject.toml` `[project.scripts]`);
  `python -m biz.dfch.specmgr` (`__main__.py`) runs the same Typer `app()`.
- **Gotcha**: with only one `@app.command()` registered, Typer collapses to a
  single top-level command and drops subcommand dispatch (`specmgr version`
  would fail with "unexpected extra argument"). An explicit `@app.callback()`
  (see `_callback` in `cli.py`) forces Typer to keep treating it as a command
  group — keep that callback even after a second command is added, don't
  assume it becomes dead code to remove.

## MCP server (`server.py`)

- Builds the `MCPServer` instance (`mcp` object) and a no-op `_lifespan`,
  then imports every domain package (`adr`, `general`, `req`, `tsk`, `uc`)
  as its last line purely for the side effect of running their
  `@mcp.tool()`/`@mcp.resource()`/`@mcp.prompt()` decorators. When adding a
  new domain, add its import to that same last line — forgetting it means
  the new tools/resources/prompts silently never register.
- **`specmgr mcp`** (`commands/mcp.py`) *does* start the server —
  `mcp_server.run(transport="stdio")` by default, or
  `mcp_server.run(transport="sse", host=..., port=...)` via
  `--transport sse`/`-t sse`. `python -m biz.dfch.specmgr mcp` and
  `uvx --from "biz-dfch-specmgr[mcp]" specmgr mcp` both work identically
  (see `README.md`'s "Add to OpenCode" section) — don't assume the server
  has no working entry point.

## CI / Release

- Branches: `dev` (default, feature work) → `main` (stable) → tag.
- `.github/workflows/ci.yml`: ruff + pylint (`|| true`) + vulture + unittest
  run on matrix 3.11/3.12/3.13 via `uv sync --frozen --all-extras`, but
  `specmgr docs` and `specmgr adr-toc` drift checks run **only on Python
  3.13** (pinned, since different Python versions generate different
  docstring formatting in the API docs, and we want consistent ADR TOC
  generation).
- `.github/workflows/publish.yml` exists and has shipped `v0.1.0`, `v0.2.0`,
  `v0.2.1` to PyPI/the MCP Registry, triggered on `v*` tags.
- Version bumps: update `version` in `pyproject.toml` (single source) and
  move `CHANGELOG.md`'s `[Unreleased]` into a dated section, same commit.

## Coding Standards

See `.specmgr/conventions.md` for detailed coding requirements and conventions:
- Python version and type notation
- Assert statement guidelines
- Variable naming (use `result` for return values)
- Comparison constants
- Mandatory type hints
- Documentation requirements for classes, attributes, and functions

- Formatter/linter: `ruff` (enforced, not black), line length 120.
- `pylint` is advisory fallback only (see pylint caveat above).

## Generated Documentation

See [`docs/GENERATED.md`](docs/GENERATED.md), auto-generated by `specmgr
docs` (implemented-domain list, per-module docstrings, and test-file count).
This pointer is permanent and hand-written — it is never regex-spliced or
otherwise auto-edited; only `docs/GENERATED.md` itself is regenerated.

</system-reminder>
```

---

## Assistant (Plan · Claude Sonnet 5 · 16.6s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.SpecMgr/.specmgr/_template/v1/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.SpecMgr/.specmgr/_template/v1/README.md</path>
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

**Tool: bash**

**Input:**
```json
{
  "command": "ls /home/user/src/biz.dfch.SpecMgr/.specmgr/feat/"
}
```

**Output:**
```
feat-10-add-artifact-type-tasklist
feat-4-use-cases
feat-5-md-model-parser
feat-6-requirement-artifact
feat-7-various-improvements
feat-8-coverage-badge
feat-9-doc-in-specmgr

```

---

## Assistant (Plan · Claude Sonnet 5 · 54.2s)

_Thinking:_



I now have the full convention: this project (`biz.dfch.SpecMgr`) tracks its own dev work in `.specmgr/feat/feat-NNN-slug/README.md` — a single file combining plan + progress, with `feat-0-slug` used when there's no GitHub issue (matches your "do not create a gh issue" instruction). I have the exact template and existing naming examples (`feat-10-add-artifact-type-tasklist`, `feat-9-doc-in-specmgr`, etc.).

Since I'm still in plan mode, I can't write the file yet — here's the drafted content for your review before I execute.

**Proposed location:** `/home/user/src/biz.dfch.SpecMgr/.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md`

**Drafted content:**

```markdown
---
id: feat-0-deepseek-v4-onprem-deployment
version: 1.0.0
status: planning
created: 2026-08-18
updated: 2026-08-18
---

# Feature: On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI

## Plan

### Overview

Deploy DeepSeek-V4-Flash and DeepSeek-V4-Pro on existing on-prem hardware,
each behind an OpenAI-compatible API, for use as coding models via OpenCode
and OpenWebUI. Quality is the priority over speed. Ollama's library-listed
`deepseek-v4-flash`/`deepseek-v4-pro` are cloud-proxy tags only (no local
weights) and are explicitly not used; official MIT-licensed weights from
`deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face are loaded directly
instead.

### Requirements

- REQ-001: Serve DeepSeek-V4-Flash via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
- REQ-002: Serve DeepSeek-V4-Pro via an OpenAI-compatible API on the same
  Dell 7960T, without adding new hardware and without networking in the
  DGX Spark
- REQ-003: Both endpoints must support real coding workloads reaching
  350-370K tokens of context
- REQ-004: Both endpoints must support tool-calling (required for OpenCode
  agentic use) and expose DeepSeek-V4's think/non-think/max-think reasoning
  modes correctly
- REQ-005: Maximize model quality; inference speed is explicitly secondary
- REQ-006: No third-party GGUF requantization — load official weights
  directly to avoid an extra, unverified source of quality loss

### Acceptance Criteria

- [ ] ACC-001: Verifies REQ-001 — `vllm serve deepseek-ai/DeepSeek-V4-Flash`
  running with tensor-parallel=4 on the Dell 7960T, reachable via
  `/v1/chat/completions`
- [ ] ACC-002: Verifies REQ-002 — ktransformers serving
  `deepseek-ai/DeepSeek-V4-Pro` on the same box, reachable via its
  OpenAI-compatible endpoint
- [ ] ACC-003: Verifies REQ-003 — empirical test confirms both endpoints
  handle a 350-370K-token coding prompt without OOM
- [ ] ACC-004: Verifies REQ-004 — tool-call and reasoning-mode output
  verified via curl smoke test, then via a real OpenCode agentic session
- [ ] ACC-005: Verifies REQ-005 — Flash runs with FP8 experts (upgraded
  from native FP4+FP8 mixed) if vLLM's loader supports the override;
  Pro's exact quantization level is chosen empirically to leave headroom
  for REQ-003's context requirement
- [ ] ACC-006: Verifies REQ-006 — both engines load weights directly from
  `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face, no GGUF requant

### Scope

What is included in this feature:
- vLLM deployment of DeepSeek-V4-Flash on the Dell 7960T
- ktransformers deployment of DeepSeek-V4-Pro on the Dell 7960T
- OpenWebUI and OpenCode configured against both endpoints
- Empirical KV-cache/context validation for both models

What is explicitly out of scope:
- Any use of the DGX Spark for this deployment (explicitly excluded by
  user decision)
- Any use of Ollama's cloud-tagged library models
- Any GGUF/community requantization path
- Acquiring additional hardware for DeepSeek-V4-Pro

### Dependencies

- Depends on: confirmed vLLM version with merged DeepSeek-V4 tool-call/
  reasoning-parser support; confirmed ktransformers version with
  DeepSeek-V4 architecture support; GPU driver/CUDA compatibility for RTX
  Pro 6000 Blackwell
- Blocks: none

### Design Notes

- Two independent serving engines by design: vLLM for Flash (fits fully
  in VRAM, gets native DeepSeek-V4 tool-call/reasoning-parser support),
  ktransformers for Pro (purpose-built GPU+CPU-RAM hybrid MoE inference,
  needed because Pro's ~800GB+ native footprint doesn't fit in 384GB VRAM
  alone).
- Precision tradeoff resolved: for Pro, user explicitly accepted lower
  precision (below native FP4+FP8 mixed) in exchange for guaranteed
  350-370K context headroom, since both cannot fit simultaneously in the
  896GB VRAM+RAM pool at native precision. Exact quant level to be
  determined empirically (measure real KV-cache cost per 1K tokens first,
  then pick the lightest trim that leaves safe margin — not the tightest
  possible fit).
- For Flash, FP8-expert override is the target (vs. native FP4 experts)
  since the resulting ~284GB footprint still fits comfortably in 384GB
  VRAM with headroom for the required context; fallback to native FP4+FP8
  mixed if vLLM's loader doesn't expose the override.
- DGX Spark intentionally left out of this feature's scope per explicit
  user decision (no cross-node networking between DGX Spark and Dell
  7960T).

### Related ADRs

- None (this is infrastructure/deployment work outside biz.dfch.SpecMgr's
  own architecture, tracked here per this repo's feature-folder convention
  per ADR e369ee2e-3353-4f92-991c-6367d76d832e)

### Task List

#### Phase 1: DeepSeek-V4-Flash (vLLM)
- [ ] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: not-started
- [ ] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Deploy `vllm serve deepseek-ai/DeepSeek-V4-Flash` with tensor-parallel=4 on the Dell 7960T — depends on: Task 1.2 — status: not-started
- [ ] Task 1.4: curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: not-started
- [ ] Task 1.5: Connect OpenWebUI and OpenCode to the Flash endpoint — depends on: Task 1.4 — status: not-started
- [ ] Task 1.6: Validate 350-370K-token context works without OOM — depends on: Task 1.5 — status: not-started
- [ ] Task 1.7: Real coding-task benchmark before treating as default — depends on: Task 1.6 — status: not-started

#### Phase 2: DeepSeek-V4-Pro (ktransformers)
- [ ] Task 2.1: Confirm ktransformers version with DeepSeek-V4 architecture support and OpenAI-compatible API — depends on: none — status: not-started
- [ ] Task 2.2: Deploy Pro at native FP4+FP8 mixed precision on the Dell 7960T, measure actual KV-cache memory per 1K tokens at real context shapes — depends on: Task 2.1 — status: not-started
- [ ] Task 2.3: Choose the lightest precision trim that reliably supports 350-370K context with safe margin, based on Task 2.2 measurements — depends on: Task 2.2 — status: not-started
- [ ] Task 2.4: Tune ktransformers per-layer GPU/RAM placement around the chosen precision — depends on: Task 2.3 — status: not-started
- [ ] Task 2.5: Verify tool-calling and reasoning-mode behavior (maturity unknown, check explicitly) — depends on: Task 2.4 — status: not-started
- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the Pro endpoint as a separate model entry — depends on: Task 2.5 — status: not-started
- [ ] Task 2.7: Real coding-task benchmark — depends on: Task 2.6 — status: not-started

## Progress

### Current Status

**As of 2026-08-18**: Planning complete via discussion; hardware and
engine choices finalized (vLLM/Flash, ktransformers/Pro, both on the Dell
7960T, DGX Spark out of scope, precision tradeoffs decided). No
implementation started yet.

### Blockers

- [ ] vLLM's exact support for the FP8-expert override on DeepSeek-V4 is
  unverified — impact: Flash may have to run at native FP4+FP8 mixed
  instead of full FP8 experts; mitigation: verify early in Task 1.2
- [ ] Pro's actual KV-cache cost at 350-370K tokens is unknown — impact:
  can't confirm precision/context fit without empirical testing;
  mitigation: Task 2.2 measures this directly before committing to a quant
  level

### Recent Updates

#### 2026-08-18
- Completed: Researched Ollama library listings (cloud-only tags),
  confirmed official HF weights + existing GGUF quantizations, evaluated
  hardware fit for both models on the DGX Spark and Dell 7960T, resolved
  engine choice (vLLM/ktransformers) and precision tradeoffs through
  discussion with user
- Next: Verify vLLM/ktransformers DeepSeek-V4 support levels, begin Phase 1
- Notes: Feature created without a GitHub issue (`feat-0-`) per user
  instruction

### Decisions Made

- **2026-08-18**: Rejected Ollama's official `deepseek-v4-flash`/
  `deepseek-v4-pro` library tags — cloud-proxy only, not on-prem
- **2026-08-18**: Use official HF weights directly via vLLM/ktransformers
  instead of community GGUF requantization, to preserve quality
- **2026-08-18**: Flash served via vLLM (fits fully in VRAM, gets native
  tool-call/reasoning-parser support); Pro served via ktransformers
  (purpose-built GPU+CPU-RAM hybrid for MoE, needed since Pro doesn't fit
  in VRAM alone)
- **2026-08-18**: No new hardware for Pro; DGX Spark explicitly excluded
  (no cross-node networking)
- **2026-08-18**: For Pro, user accepted lower precision (below native
  FP4+FP8 mixed) in exchange for guaranteed 350-370K context support

### Related PRs / Commits

- None yet
```

**Open items before I execute this:**
1. Is `/home/user/src/biz.dfch.SpecMgr/` really the right repo for this feature folder, or were you just pointing me at the ADR as a reference for the *convention*, with the actual folder meant to live in a different (e.g., your infra/ops) repo?
2. Is the slug `deepseek-v4-onprem-deployment` good, or do you want something different?

---

## User

do you still need the task list or is everything in the README?

---

## Assistant (Plan · Claude Sonnet 5 · 7.0s)

The Task List is already fully contained within the README's `## Plan` section — per the ADR's Option 1 (the chosen structure), there's deliberately **no separate task-list artifact or file**. The whole point of that design was to avoid the Option 2 problem ("Implementation Plan" in one file, "Execution Plan" in another, requiring sync).

So in the drafted README above:
- The `### Task List` subsection (Phase 1 / Phase 2 with `Task 1.1`, `Task 1.2`, etc.) **is** the task list — status lives inline on each task line (`status: not-started`, etc.)
- When work progresses, that same list gets edited in place (checkbox ticked, `status:` updated) rather than duplicated into a separate tracking file
- `history.md` is the only other file the convention allows, and it's optional — only for rotating out old `Recent Updates` entries once the file gets long, not for tasks

Nothing else is needed — one `README.md` file covers plan + task list + progress, exactly as drafted.

---

## User

anything else that we should add?

---

## Assistant (Plan · Claude Sonnet 5 · 40.5s)

_Thinking:_



A few real gaps I'd flag before finalizing the content (all just proposals — nothing written to disk yet):

1. **Weight acquisition isn't a task yet.** Downloading ~284GB (Flash) and ~600-900GB (Pro, depending on chosen quant) from Hugging Face is itself a nontrivial, possibly multi-day operation. Should add an explicit "Phase 0: Environment prep" with tasks for: disk space validation (need 1TB+ free on the Dell 7960T for both models), HF download (`huggingface-cli`/token setup), and GPU driver/CUDA version checks for the RTX Pro 6000 Blackwell cards.

2. **No security/access-control consideration.** Both endpoints will be reachable over your network for OpenWebUI/OpenCode — nothing in the plan currently addresses API-key auth, binding to internal-only network interfaces, or TLS. Worth an explicit requirement/task before this goes into real use, even internally.

3. **Weight version pinning.** DeepSeek appears to ship rolling checkpoint updates (we saw `preview-cloud` → `0731-cloud`/`0813-cloud` snapshots on Ollama's listing). Should decide whether to pin to a specific HF commit/revision for reproducibility, or track "latest" — currently undecided.

4. **Vague benchmark criteria.** Tasks 1.7/2.7 just say "real coding-task benchmark" with no concrete definition. Worth defining a small fixed set of representative internal coding tasks (or a known benchmark subset) as the actual measurable acceptance check, rather than an open-ended vibe check.

5. **No fallback defined for Pro if the tight fit doesn't work.** Flash has an explicit fallback (native FP4+FP8 mixed if FP8-expert override isn't supported). Pro doesn't — if even a heavily quantized version can't reliably hold 350-370K context, what's the fallback? (e.g., accept a lower max context for Pro specifically and route longer-context coding tasks to Flash instead.) Worth stating explicitly rather than discovering it mid-implementation.

6. **Operational lifecycle not addressed.** Nothing about running these as persistent services (systemd/container with auto-restart) versus ad-hoc foreground processes — matters once this moves from "test" to "daily driver."

Do you want me to fold all of these into the README draft, only some of them, or leave the feature file lean and treat these as follow-up decisions once Phase 1 is underway?

---

## User

-- 1. Is /home/user/src/biz.dfch.SpecMgr/ really the right repo: NO, I will create a separate repo: suggest a name
-- 2. 2. Is the slug deepseek-v4-onprem-deployment: OK

-- 1. Weight acquisition isn't a task yet: yes, add Phase 0
-- 2. No security/access-control consideration: anon, no-auth is OK
-- 3. Weight version pinning: yes, pin
-- 4. Vague benchmark criteria: I will run coding task when the setup is complete. I have examples. Then we will use that same example to compare the quality of different implementations.
-- 5. No fallback defined for Pro if the tight fit doesn't work: we will use GLM-5.2 as a fallback, but this will be a different feature
-- 6. Operational lifecycle not addressed: we will run these tools as services not "ad-hoc". Even while testing, we better stop/start via sys ctrl manager than manually start a process

---

## Assistant (Plan · Claude Sonnet 5 · 63.8s)

_Thinking:_



### Repo name suggestion

Since this will likely host more than just DeepSeek-V4 (you mentioned GLM-5.2 as a future fallback feature in the same vein), I'd name it generically for on-prem LLM serving infra rather than model-specific, matching your `biz.dfch.<Name>` convention (mirroring `biz.dfch.SpecMgr`):

- **`biz.dfch.LlmOps`** (recommended) — short, matches the "Ops"-style naming pattern, generic enough for any model/engine you deploy later
- `biz.dfch.ModelServing`
- `biz.dfch.OnPremLLM`
- `biz.dfch.AiInfra`

Let me know which you want (or a different name), and I'll use it as the target repo in the plan.

### Updated README draft, incorporating all six decisions

```markdown
---
id: feat-0-deepseek-v4-onprem-deployment
version: 1.0.0
status: planning
created: 2026-08-18
updated: 2026-08-18
---

# Feature: On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI

## Plan

### Overview

Deploy DeepSeek-V4-Flash and DeepSeek-V4-Pro on existing on-prem hardware,
each behind an OpenAI-compatible API, for use as coding models via OpenCode
and OpenWebUI. Quality is the priority over speed. Ollama's library-listed
`deepseek-v4-flash`/`deepseek-v4-pro` are cloud-proxy tags only (no local
weights) and are explicitly not used; official MIT-licensed weights from
`deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face are loaded directly
instead, pinned to a specific revision for reproducibility.

### Requirements

- REQ-001: Serve DeepSeek-V4-Flash via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
- REQ-002: Serve DeepSeek-V4-Pro via an OpenAI-compatible API on the same
  Dell 7960T, without adding new hardware and without networking in the
  DGX Spark
- REQ-003: Both endpoints must support real coding workloads reaching
  350-370K tokens of context
- REQ-004: Both endpoints must support tool-calling (required for OpenCode
  agentic use) and expose DeepSeek-V4's think/non-think/max-think reasoning
  modes correctly
- REQ-005: Maximize model quality; inference speed is explicitly secondary
- REQ-006: No third-party GGUF requantization — load official weights
  directly to avoid an extra, unverified source of quality loss
- REQ-007: Pin both models to a specific Hugging Face revision/commit
  (not "latest") for reproducibility across redeploys
- REQ-008: Both endpoints run unauthenticated (anonymous, no API-key/auth
  layer) — accepted risk, internal network only
- REQ-009: Both engines run as managed services (systemd units or
  equivalent), started/stopped via the service manager — no ad-hoc
  foreground processes, including during testing

### Acceptance Criteria

- [ ] ACC-001: Verifies REQ-001 — `vllm serve deepseek-ai/DeepSeek-V4-Flash`
  running with tensor-parallel=4 on the Dell 7960T, reachable via
  `/v1/chat/completions`
- [ ] ACC-002: Verifies REQ-002 — ktransformers serving
  `deepseek-ai/DeepSeek-V4-Pro` on the same box, reachable via its
  OpenAI-compatible endpoint
- [ ] ACC-003: Verifies REQ-003 — empirical test confirms both endpoints
  handle a 350-370K-token coding prompt without OOM
- [ ] ACC-004: Verifies REQ-004 — tool-call and reasoning-mode output
  verified via curl smoke test, then via a real OpenCode agentic session
- [ ] ACC-005: Verifies REQ-005 — Flash runs with FP8 experts (upgraded
  from native FP4+FP8 mixed) if vLLM's loader supports the override;
  Pro's exact quantization level is chosen empirically to leave headroom
  for REQ-003's context requirement
- [ ] ACC-006: Verifies REQ-006 — both engines load weights directly from
  `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face, no GGUF requant
- [ ] ACC-007: Verifies REQ-007 — deployment config records the exact HF
  revision/commit hash used for each model
- [ ] ACC-008: Verifies REQ-008 — endpoints reachable without credentials
  from the internal network, confirmed intentional (not an oversight)
- [ ] ACC-009: Verifies REQ-009 — both engines installed as systemd
  services; started/stopped/restarted exclusively via `systemctl`
  throughout testing and production use
- [ ] ACC-010: User runs their own existing coding-task examples against
  both endpoints once setup is complete; same examples reused later to
  compare quality across future implementations (e.g. GLM-5.2)

### Scope

What is included in this feature:
- vLLM deployment of DeepSeek-V4-Flash on the Dell 7960T, as a systemd
  service
- ktransformers deployment of DeepSeek-V4-Pro on the Dell 7960T, as a
  systemd service
- OpenWebUI and OpenCode configured against both endpoints
- Empirical KV-cache/context validation for both models
- Pinning both models to a fixed HF revision

What is explicitly out of scope:
- Any use of the DGX Spark for this deployment (explicitly excluded by
  user decision)
- Any use of Ollama's cloud-tagged library models
- Any GGUF/community requantization path
- Acquiring additional hardware for DeepSeek-V4-Pro
- Authentication/access-control layer (explicitly accepted as anonymous)
- GLM-5.2 fallback deployment — tracked as a separate, future feature

### Dependencies

- Depends on: confirmed vLLM version with merged DeepSeek-V4 tool-call/
  reasoning-parser support; confirmed ktransformers version with
  DeepSeek-V4 architecture support; GPU driver/CUDA compatibility for RTX
  Pro 6000 Blackwell; sufficient local disk space (1TB+) on the Dell
  7960T for both model weight sets
- Blocks: none
- Related (not a dependency, tracked separately): a future feature will
  deploy GLM-5.2 as a fallback/alternative model — not part of this
  feature's scope

### Design Notes

- Two independent serving engines by design: vLLM for Flash (fits fully
  in VRAM, gets native DeepSeek-V4 tool-call/reasoning-parser support),
  ktransformers for Pro (purpose-built GPU+CPU-RAM hybrid MoE inference,
  needed because Pro's ~800GB+ native footprint doesn't fit in 384GB VRAM
  alone).
- Precision tradeoff resolved: for Pro, user explicitly accepted lower
  precision (below native FP4+FP8 mixed) in exchange for guaranteed
  350-370K context headroom, since both cannot fit simultaneously in the
  896GB VRAM+RAM pool at native precision. Exact quant level to be
  determined empirically (measure real KV-cache cost per 1K tokens first,
  then pick the lightest trim that leaves safe margin — not the tightest
  possible fit).
- For Flash, FP8-expert override is the target (vs. native FP4 experts)
  since the resulting ~284GB footprint still fits comfortably in 384GB
  VRAM with headroom for the required context; fallback to native FP4+FP8
  mixed if vLLM's loader doesn't expose the override.
- DGX Spark intentionally left out of this feature's scope per explicit
  user decision (no cross-node networking between DGX Spark and Dell
  7960T).
- Both models pinned to a specific HF revision at deployment time, not
  tracking "latest" — avoids unexpected drift on redeploy, given DeepSeek
  appears to ship rolling checkpoint updates (observed `preview` →
  `0731`/`0813`-dated snapshots).
- No authentication layer: both OpenAI-compatible endpoints are
  reachable anonymously on the internal network. Accepted risk, not an
  oversight — revisit only if network exposure changes.
- Both engines run exclusively as systemd-managed services (or
  equivalent service manager) — start/stop/restart via `systemctl`, even
  during initial testing, never as manually-launched foreground
  processes.
- Benchmark approach: no synthetic/formal benchmark suite defined here.
  User will run their own existing real coding-task examples once each
  endpoint is live, and reuse the same examples later to compare quality
  across future alternatives (e.g. GLM-5.2).

### Related ADRs

- None (this is infrastructure/deployment work, tracked in its own repo
  using the feature-folder convention documented in biz.dfch.SpecMgr's
  ADR e369ee2e-3353-4f92-991c-6367d76d832e)

### Task List

#### Phase 0: Environment prep
- [ ] Task 0.1: Validate available local disk space on the Dell 7960T (need 1TB+ free for both weight sets combined) — depends on: none — status: not-started
- [ ] Task 0.2: Verify GPU driver/CUDA version compatibility with RTX Pro 6000 Blackwell across all 4 GPUs — depends on: none — status: not-started
- [ ] Task 0.3: Set up Hugging Face access/token and download tooling — depends on: none — status: not-started
- [ ] Task 0.4: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Flash` — depends on: Task 0.3 — status: not-started
- [ ] Task 0.5: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Pro` — depends on: Task 0.3 — status: not-started
- [ ] Task 0.6: Download DeepSeek-V4-Flash weights at the pinned revision — depends on: Task 0.4, Task 0.1 — status: not-started
- [ ] Task 0.7: Download DeepSeek-V4-Pro weights at the pinned revision — depends on: Task 0.5, Task 0.1 — status: not-started

#### Phase 1: DeepSeek-V4-Flash (vLLM)
- [ ] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: not-started
- [ ] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Install vLLM + DeepSeek-V4-Flash as a systemd service (tensor-parallel=4) on the Dell 7960T — depends on: Task 1.2, Task 0.6 — status: not-started
- [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: not-started
- [ ] Task 1.5: Connect OpenWebUI and OpenCode to the Flash endpoint — depends on: Task 1.4 — status: not-started
- [ ] Task 1.6: Validate 350-370K-token context works without OOM — depends on: Task 1.5 — status: not-started
- [ ] Task 1.7: User runs their real coding-task examples against the endpoint — depends on: Task 1.6 — status: not-started

#### Phase 2: DeepSeek-V4-Pro (ktransformers)
- [ ] Task 2.1: Confirm ktransformers version with DeepSeek-V4 architecture support and OpenAI-compatible API — depends on: none — status: not-started
- [ ] Task 2.2: Install ktransformers + DeepSeek-V4-Pro as a systemd service at native FP4+FP8 mixed precision, measure actual KV-cache memory per 1K tokens at real context shapes — depends on: Task 2.1, Task 0.7 — status: not-started
- [ ] Task 2.3: Choose the lightest precision trim that reliably supports 350-370K context with safe margin, based on Task 2.2 measurements — depends on: Task 2.2 — status: not-started
- [ ] Task 2.4: Reconfigure the service with the chosen precision and ktransformers per-layer GPU/RAM placement — depends on: Task 2.3 — status: not-started
- [ ] Task 2.5: `systemctl start`/restart the service; verify tool-calling and reasoning-mode behavior — depends on: Task 2.4 — status: not-started
- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the Pro endpoint as a separate model entry — depends on: Task 2.5 — status: not-started
- [ ] Task 2.7: User runs the same coding-task examples from Task 1.7 against this endpoint for comparison — depends on: Task 2.6 — status: not-started

**Note:** If a task's scope changes mid-flight, edit its description in place;
rely on git history (`git log -p` on this file) to recover what was
originally planned, rather than keeping a second copy of the task around.

## Progress

### Current Status

**As of 2026-08-18**: Planning complete via discussion; hardware, engine,
precision, security, versioning, and operational (systemd) decisions all
finalized. No implementation started yet. Target repo not yet created.

### Blockers

- [ ] vLLM's exact support for the FP8-expert override on DeepSeek-V4 is
  unverified — impact: Flash may have to run at native FP4+FP8 mixed
  instead of full FP8 experts; mitigation: verify early in Task 1.2
- [ ] Pro's actual KV-cache cost at 350-370K tokens is unknown — impact:
  can't confirm precision/context fit without empirical testing;
  mitigation: Task 2.2 measures this directly before committing to a quant
  level

### Recent Updates

#### 2026-08-18
- Completed: Researched Ollama library listings (cloud-only tags),
  confirmed official HF weights + existing GGUF quantizations, evaluated
  hardware fit for both models on the DGX Spark and Dell 7960T, resolved
  engine choice (vLLM/ktransformers), precision tradeoffs, security
  posture (anonymous/no-auth accepted), version pinning, benchmark
  approach, and operational model (systemd services only) through
  discussion with user
- Next: Create the target repo, then begin Phase 0
- Notes: Feature created without a GitHub issue (`feat-0-`) per user
  instruction; will live in a new repo (name TBD), not in
  biz.dfch.SpecMgr itself

### Decisions Made

- **2026-08-18**: Rejected Ollama's official `deepseek-v4-flash`/
  `deepseek-v4-pro` library tags — cloud-proxy only, not on-prem
- **2026-08-18**: Use official HF weights directly via vLLM/ktransformers
  instead of community GGUF requantization, to preserve quality
- **2026-08-18**: Flash served via vLLM (fits fully in VRAM, gets native
  tool-call/reasoning-parser support); Pro served via ktransformers
  (purpose-built GPU+CPU-RAM hybrid for MoE, needed since Pro doesn't fit
  in VRAM alone)
- **2026-08-18**: No new hardware for Pro; DGX Spark explicitly excluded
  (no cross-node networking)
- **2026-08-18**: For Pro, user accepted lower precision (below native
  FP4+FP8 mixed) in exchange for guaranteed 350-370K context support
- **2026-08-18**: Both models pinned to a specific HF revision, not
  "latest"
- **2026-08-18**: No authentication on either endpoint — anonymous access
  accepted as internal-network-only risk
- **2026-08-18**: Both engines run as systemd services exclusively, never
  ad-hoc processes, including during testing
- **2026-08-18**: GLM-5.2 fallback explicitly deferred to a separate,
  future feature — not built here

### Related PRs / Commits

- None yet
```

Once you confirm the repo name, I'll consider this ready to execute (create the repo structure, this feature folder, and the ADR-referenced `.specmgr/` scaffolding) when you leave plan mode.

---

## User

where is the file now? provide full path

---

## Assistant (Plan · Claude Sonnet 5 · 5.6s)

The file doesn't exist anywhere yet — nothing has been written to disk. We're still in plan mode, and I haven't executed any create/write action.

So far only a draft has existed in this conversation as proposed markdown content. No repo has been created, no `feat-0-deepseek-v4-onprem-deployment` folder exists, and no README.md has been written — that's still pending on:

1. Confirming the new repo name (I suggested `biz.dfch.LlmOps` and a few alternatives — you haven't picked one yet)
2. Leaving plan mode so I'm allowed to actually create the repo and write the file

Once both of those happen, the file would land at (assuming `biz.dfch.LlmOps`, adjust if you pick a different name):

```
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md
```

Do you want to confirm the repo name now so it's locked in for when you're ready to execute?

---

## User

we have to change to this dir: ~/src/biz.dfch.LlmOps

I created a repo there

---

## Assistant (Build · Claude Sonnet 5 · 9.4s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "ls -la ~/src/biz.dfch.LlmOps/ 2>&1; echo \"---\"; ls -la ~/src/biz.dfch.LlmOps/.git 2>&1 | head -5"
}
```

**Output:**
```
total 44
drwxrwxr-x  3 user user  4096 Aug 18 09:51 .
drwxrwxr-x 36 user user  4096 Aug 18 09:51 ..
drwxrwxr-x  7 user user  4096 Aug 18 09:51 .git
-rw-rw-r--  1 user user  4628 Aug 18 09:51 .gitignore
-rw-rw-r--  1 user user 18092 Aug 18 09:51 LICENSE
-rw-rw-r--  1 user user    70 Aug 18 09:51 README.md
---
total 52
drwxrwxr-x  7 user user 4096 Aug 18 09:51 .
drwxrwxr-x  3 user user 4096 Aug 18 09:51 ..
-rw-rw-r--  1 user user   20 Aug 18 09:51 HEAD
-rw-rw-r--  1 user user  262 Aug 18 09:51 config

```

---

## Assistant (Build · Claude Sonnet 5 · 3.6s)

Good, the repo exists with a git init, `.gitignore`, `LICENSE`, and a basic `README.md`. Now I'll set up the `.specmgr/` scaffolding (template + feature folder) and populate the feature README.

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/README.md</path>
<type>file</type>
<content>
1: # biz.dfch.LlmOps
2: Describe the setup and tests of our LLM environment

(End of file - total 2 lines)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 4.7s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "mkdir -p ~/src/biz.dfch.LlmOps/.specmgr/_template/v1 ~/src/biz.dfch.LlmOps/.specmgr/feat/feat-0-deepseek-v4-onprem-deployment && echo OK"
}
```

**Output:**
```
OK

```

---

## Assistant (Build · Claude Sonnet 5 · 11.2s)

**Tool: write**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md",
  "content": "---\nid: feat-NNN-slug\nversion: 1.0.0\nstatus: planning\ncreated: YYYY-MM-DD\nupdated: YYYY-MM-DD\n---\n\n# Feature: [Feature Title]\n\n## Plan\n\n### Overview\n\nBrief description of what this feature does and why it matters.\n\n### Requirements\n\n- REQ-001: [Functional requirement]\n- REQ-002: [Non-functional requirement]\n- REQ-003: [Constraint or dependency]\n\n### Acceptance Criteria\n\n- [ ] ACC-001: Verifies REQ-001 — [testable condition]\n- [ ] ACC-002: Verifies REQ-002 — [testable condition]\n- [ ] ACC-003: Verifies REQ-003 — [testable condition]\n\n### Scope\n\nWhat is included in this feature:\n- Item 1\n- Item 2\n\nWhat is explicitly out of scope:\n- Item A\n- Item B\n\n### Dependencies\n\n- Depends on: [other feat-NNN-slug, ADR id, or external]\n- Blocks: [other feat-NNN-slug]\n\n### Design Notes\n\nAny architectural decisions, patterns, or design rationale relevant to this feature.\n\n### Related ADRs\n\n- [ADR id]: [Title]\n- [ADR id]: [Title]\n\n### Task List\n\nSingle, canonical breakdown of work phases and tasks. Status lives on the\ntask itself — there is no separate \"planned\" vs. \"executed\" list to keep in\nsync; a task's line *is* its current status. Update it in place as work\nprogresses (edit, don't duplicate).\n\n#### Phase 1: [Phase name]\n- [x] Task 1.1: [description] — depends on: none — status: done (2026-08-01)\n- [ ] Task 1.2: [description] — depends on: Task 1.1 — status: in-progress, ETA 2026-08-10\n- [ ] Task 1.3: [description] — depends on: Task 1.2 — status: blocked (see Blockers)\n\n#### Phase 2: [Phase name]\n- [ ] Task 2.1: [description] — depends on: Task 1.3 — status: not-started\n- [ ] Task 2.2: [description] — depends on: Task 2.1 — status: not-started\n\n**Note:** If a task's scope changes mid-flight, edit its description in place;\nrely on git history (`git log -p` on this file) to recover what was\noriginally planned, rather than keeping a second copy of the task around.\n\n## Progress\n\n### Current Status\n\n**As of [YYYY-MM-DD]**: [Brief status summary]\n\n### Blockers\n\n- [ ] Blocker 1 — [description, impact, mitigation]\n- [ ] Blocker 2 — [description, impact, mitigation]\n\n(Remove this section if no blockers.)\n\n### Recent Updates\n\nIf this section grows too long, move older entries to `history.md` in this\nsame folder and leave a pointer here, e.g.:\n`See history.md for updates before YYYY-MM-DD.`\n\n#### [YYYY-MM-DD]\n- Completed: [what was done]\n- Next: [what comes next]\n- Notes: [any relevant context]\n\n#### [YYYY-MM-DD]\n- Completed: [what was done]\n- Next: [what comes next]\n- Notes: [any relevant context]\n\n### Decisions Made\n\n- **[YYYY-MM-DD]**: [Decision] — [Rationale]\n- **[YYYY-MM-DD]**: [Decision] — [Rationale]\n\n### Related PRs / Commits\n\n- [PR #NNN](link): [description]\n- [Commit hash](link): [description]\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 44.2s)

Now the actual feature README:

**Tool: write**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md",
  "content": "---\nid: feat-0-deepseek-v4-onprem-deployment\nversion: 1.0.0\nstatus: planning\ncreated: 2026-08-18\nupdated: 2026-08-18\n---\n\n# Feature: On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI\n\n## Plan\n\n### Overview\n\nDeploy DeepSeek-V4-Flash and DeepSeek-V4-Pro on existing on-prem hardware,\neach behind an OpenAI-compatible API, for use as coding models via OpenCode\nand OpenWebUI. Quality is the priority over speed. Ollama's library-listed\n`deepseek-v4-flash`/`deepseek-v4-pro` are cloud-proxy tags only (no local\nweights) and are explicitly not used; official MIT-licensed weights from\n`deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face are loaded directly\ninstead, pinned to a specific revision for reproducibility.\n\n### Requirements\n\n- REQ-001: Serve DeepSeek-V4-Flash via an OpenAI-compatible API\n  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell\n  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)\n- REQ-002: Serve DeepSeek-V4-Pro via an OpenAI-compatible API on the same\n  Dell 7960T, without adding new hardware and without networking in the\n  DGX Spark\n- REQ-003: Both endpoints must support real coding workloads reaching\n  350-370K tokens of context\n- REQ-004: Both endpoints must support tool-calling (required for OpenCode\n  agentic use) and expose DeepSeek-V4's think/non-think/max-think reasoning\n  modes correctly\n- REQ-005: Maximize model quality; inference speed is explicitly secondary\n- REQ-006: No third-party GGUF requantization — load official weights\n  directly to avoid an extra, unverified source of quality loss\n- REQ-007: Pin both models to a specific Hugging Face revision/commit\n  (not \"latest\") for reproducibility across redeploys\n- REQ-008: Both endpoints run unauthenticated (anonymous, no API-key/auth\n  layer) — accepted risk, internal network only\n- REQ-009: Both engines run as managed services (systemd units or\n  equivalent), started/stopped via the service manager — no ad-hoc\n  foreground processes, including during testing\n\n### Acceptance Criteria\n\n- [ ] ACC-001: Verifies REQ-001 — `vllm serve deepseek-ai/DeepSeek-V4-Flash`\n  running with tensor-parallel=4 on the Dell 7960T, reachable via\n  `/v1/chat/completions`\n- [ ] ACC-002: Verifies REQ-002 — ktransformers serving\n  `deepseek-ai/DeepSeek-V4-Pro` on the same box, reachable via its\n  OpenAI-compatible endpoint\n- [ ] ACC-003: Verifies REQ-003 — empirical test confirms both endpoints\n  handle a 350-370K-token coding prompt without OOM\n- [ ] ACC-004: Verifies REQ-004 — tool-call and reasoning-mode output\n  verified via curl smoke test, then via a real OpenCode agentic session\n- [ ] ACC-005: Verifies REQ-005 — Flash runs with FP8 experts (upgraded\n  from native FP4+FP8 mixed) if vLLM's loader supports the override;\n  Pro's exact quantization level is chosen empirically to leave headroom\n  for REQ-003's context requirement\n- [ ] ACC-006: Verifies REQ-006 — both engines load weights directly from\n  `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face, no GGUF requant\n- [ ] ACC-007: Verifies REQ-007 — deployment config records the exact HF\n  revision/commit hash used for each model\n- [ ] ACC-008: Verifies REQ-008 — endpoints reachable without credentials\n  from the internal network, confirmed intentional (not an oversight)\n- [ ] ACC-009: Verifies REQ-009 — both engines installed as systemd\n  services; started/stopped/restarted exclusively via `systemctl`\n  throughout testing and production use\n- [ ] ACC-010: User runs their own existing coding-task examples against\n  both endpoints once setup is complete; same examples reused later to\n  compare quality across future implementations (e.g. GLM-5.2)\n\n### Scope\n\nWhat is included in this feature:\n- vLLM deployment of DeepSeek-V4-Flash on the Dell 7960T, as a systemd\n  service\n- ktransformers deployment of DeepSeek-V4-Pro on the Dell 7960T, as a\n  systemd service\n- OpenWebUI and OpenCode configured against both endpoints\n- Empirical KV-cache/context validation for both models\n- Pinning both models to a fixed HF revision\n\nWhat is explicitly out of scope:\n- Any use of the DGX Spark for this deployment (explicitly excluded by\n  user decision)\n- Any use of Ollama's cloud-tagged library models\n- Any GGUF/community requantization path\n- Acquiring additional hardware for DeepSeek-V4-Pro\n- Authentication/access-control layer (explicitly accepted as anonymous)\n- GLM-5.2 fallback deployment — tracked as a separate, future feature\n\n### Dependencies\n\n- Depends on: confirmed vLLM version with merged DeepSeek-V4 tool-call/\n  reasoning-parser support; confirmed ktransformers version with\n  DeepSeek-V4 architecture support; GPU driver/CUDA compatibility for RTX\n  Pro 6000 Blackwell; sufficient local disk space (1TB+) on the Dell\n  7960T for both model weight sets\n- Blocks: none\n- Related (not a dependency, tracked separately): a future feature will\n  deploy GLM-5.2 as a fallback/alternative model — not part of this\n  feature's scope\n\n### Design Notes\n\n- Two independent serving engines by design: vLLM for Flash (fits fully\n  in VRAM, gets native DeepSeek-V4 tool-call/reasoning-parser support),\n  ktransformers for Pro (purpose-built GPU+CPU-RAM hybrid MoE inference,\n  needed because Pro's ~800GB+ native footprint doesn't fit in 384GB VRAM\n  alone).\n- Precision tradeoff resolved: for Pro, user explicitly accepted lower\n  precision (below native FP4+FP8 mixed) in exchange for guaranteed\n  350-370K context headroom, since both cannot fit simultaneously in the\n  896GB VRAM+RAM pool at native precision. Exact quant level to be\n  determined empirically (measure real KV-cache cost per 1K tokens first,\n  then pick the lightest trim that leaves safe margin — not the tightest\n  possible fit).\n- For Flash, FP8-expert override is the target (vs. native FP4 experts)\n  since the resulting ~284GB footprint still fits comfortably in 384GB\n  VRAM with headroom for the required context; fallback to native FP4+FP8\n  mixed if vLLM's loader doesn't expose the override.\n- DGX Spark intentionally left out of this feature's scope per explicit\n  user decision (no cross-node networking between DGX Spark and Dell\n  7960T).\n- Both models pinned to a specific HF revision at deployment time, not\n  tracking \"latest\" — avoids unexpected drift on redeploy, given DeepSeek\n  appears to ship rolling checkpoint updates (observed `preview` →\n  `0731`/`0813`-dated snapshots).\n- No authentication layer: both OpenAI-compatible endpoints are\n  reachable anonymously on the internal network. Accepted risk, not an\n  oversight — revisit only if network exposure changes.\n- Both engines run exclusively as systemd-managed services (or\n  equivalent service manager) — start/stop/restart via `systemctl`, even\n  during initial testing, never as manually-launched foreground\n  processes.\n- Benchmark approach: no synthetic/formal benchmark suite defined here.\n  User will run their own existing real coding-task examples once each\n  endpoint is live, and reuse the same examples later to compare quality\n  across future alternatives (e.g. GLM-5.2).\n\n### Related ADRs\n\n- None (this is infrastructure/deployment work, tracked in its own repo\n  using the feature-folder convention documented in biz.dfch.SpecMgr's\n  ADR e369ee2e-3353-4f92-991c-6367d76d832e)\n\n### Task List\n\n#### Phase 0: Environment prep\n- [ ] Task 0.1: Validate available local disk space on the Dell 7960T (need 1TB+ free for both weight sets combined) — depends on: none — status: not-started\n- [ ] Task 0.2: Verify GPU driver/CUDA version compatibility with RTX Pro 6000 Blackwell across all 4 GPUs — depends on: none — status: not-started\n- [ ] Task 0.3: Set up Hugging Face access/token and download tooling — depends on: none — status: not-started\n- [ ] Task 0.4: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Flash` — depends on: Task 0.3 — status: not-started\n- [ ] Task 0.5: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Pro` — depends on: Task 0.3 — status: not-started\n- [ ] Task 0.6: Download DeepSeek-V4-Flash weights at the pinned revision — depends on: Task 0.4, Task 0.1 — status: not-started\n- [ ] Task 0.7: Download DeepSeek-V4-Pro weights at the pinned revision — depends on: Task 0.5, Task 0.1 — status: not-started\n\n#### Phase 1: DeepSeek-V4-Flash (vLLM)\n- [ ] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: not-started\n- [ ] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: not-started\n- [ ] Task 1.3: Install vLLM + DeepSeek-V4-Flash as a systemd service (tensor-parallel=4) on the Dell 7960T — depends on: Task 1.2, Task 0.6 — status: not-started\n- [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: not-started\n- [ ] Task 1.5: Connect OpenWebUI and OpenCode to the Flash endpoint — depends on: Task 1.4 — status: not-started\n- [ ] Task 1.6: Validate 350-370K-token context works without OOM — depends on: Task 1.5 — status: not-started\n- [ ] Task 1.7: User runs their real coding-task examples against the endpoint — depends on: Task 1.6 — status: not-started\n\n#### Phase 2: DeepSeek-V4-Pro (ktransformers)\n- [ ] Task 2.1: Confirm ktransformers version with DeepSeek-V4 architecture support and OpenAI-compatible API — depends on: none — status: not-started\n- [ ] Task 2.2: Install ktransformers + DeepSeek-V4-Pro as a systemd service at native FP4+FP8 mixed precision, measure actual KV-cache memory per 1K tokens at real context shapes — depends on: Task 2.1, Task 0.7 — status: not-started\n- [ ] Task 2.3: Choose the lightest precision trim that reliably supports 350-370K context with safe margin, based on Task 2.2 measurements — depends on: Task 2.2 — status: not-started\n- [ ] Task 2.4: Reconfigure the service with the chosen precision and ktransformers per-layer GPU/RAM placement — depends on: Task 2.3 — status: not-started\n- [ ] Task 2.5: `systemctl start`/restart the service; verify tool-calling and reasoning-mode behavior — depends on: Task 2.4 — status: not-started\n- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the Pro endpoint as a separate model entry — depends on: Task 2.5 — status: not-started\n- [ ] Task 2.7: User runs the same coding-task examples from Task 1.7 against this endpoint for comparison — depends on: Task 2.6 — status: not-started\n\n**Note:** If a task's scope changes mid-flight, edit its description in place;\nrely on git history (`git log -p` on this file) to recover what was\noriginally planned, rather than keeping a second copy of the task around.\n\n## Progress\n\n### Current Status\n\n**As of 2026-08-18**: Planning complete via discussion; hardware, engine,\nprecision, security, versioning, and operational (systemd) decisions all\nfinalized. Repo `biz.dfch.LlmOps` created. No implementation started yet.\n\n### Blockers\n\n- [ ] vLLM's exact support for the FP8-expert override on DeepSeek-V4 is\n  unverified — impact: Flash may have to run at native FP4+FP8 mixed\n  instead of full FP8 experts; mitigation: verify early in Task 1.2\n- [ ] Pro's actual KV-cache cost at 350-370K tokens is unknown — impact:\n  can't confirm precision/context fit without empirical testing;\n  mitigation: Task 2.2 measures this directly before committing to a quant\n  level\n\n### Recent Updates\n\n#### 2026-08-18\n- Completed: Researched Ollama library listings (cloud-only tags),\n  confirmed official HF weights + existing GGUF quantizations, evaluated\n  hardware fit for both models on the DGX Spark and Dell 7960T, resolved\n  engine choice (vLLM/ktransformers), precision tradeoffs, security\n  posture (anonymous/no-auth accepted), version pinning, benchmark\n  approach, and operational model (systemd services only) through\n  discussion with user; repo `biz.dfch.LlmOps` created and this feature\n  folder scaffolded (including `.specmgr/_template/v1/README.md`, copied\n  from biz.dfch.SpecMgr's convention for reuse in this repo)\n- Next: Begin Phase 0 (environment prep)\n- Notes: Feature created without a GitHub issue (`feat-0-`) per user\n  instruction\n\n### Decisions Made\n\n- **2026-08-18**: Rejected Ollama's official `deepseek-v4-flash`/\n  `deepseek-v4-pro` library tags — cloud-proxy only, not on-prem\n- **2026-08-18**: Use official HF weights directly via vLLM/ktransformers\n  instead of community GGUF requantization, to preserve quality\n- **2026-08-18**: Flash served via vLLM (fits fully in VRAM, gets native\n  tool-call/reasoning-parser support); Pro served via ktransformers\n  (purpose-built GPU+CPU-RAM hybrid for MoE, needed since Pro doesn't fit\n  in VRAM alone)\n- **2026-08-18**: No new hardware for Pro; DGX Spark explicitly excluded\n  (no cross-node networking)\n- **2026-08-18**: For Pro, user accepted lower precision (below native\n  FP4+FP8 mixed) in exchange for guaranteed 350-370K context support\n- **2026-08-18**: Both models pinned to a specific HF revision, not\n  \"latest\"\n- **2026-08-18**: No authentication on either endpoint — anonymous access\n  accepted as internal-network-only risk\n- **2026-08-18**: Both engines run as systemd services exclusively, never\n  ad-hoc processes, including during testing\n- **2026-08-18**: GLM-5.2 fallback explicitly deferred to a separate,\n  future feature — not built here\n- **2026-08-18**: Repo named `biz.dfch.LlmOps` (generic, not\n  DeepSeek-specific, to host future model-serving features like GLM-5.2)\n\n### Related PRs / Commits\n\n- None yet\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 4.2s)

Both files are written. Let me verify the final structure and confirm nothing else needs adjusting.

**Tool: bash**

**Input:**
```json
{
  "command": "find ~/src/biz.dfch.LlmOps/.specmgr -type f | sort; echo \"---git status---\"; cd ~/src/biz.dfch.LlmOps && git status"
}
```

**Output:**
```
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md
/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md
---git status---
On branch dev
Your branch is up to date with 'origin/dev'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.specmgr/

nothing added to commit but untracked files present (use "git add" to track)

```

---

## Assistant (Build · Claude Sonnet 5 · 4.5s)

The feature is created. Full path:

```
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md
```

Also scaffolded the versioned template for future features:

```
/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md
```

Both are currently **untracked** in git (repo is on branch `dev`, up to date with `origin/dev`) — I haven't staged or committed anything, per your earlier instruction not to create a GitHub issue and since you didn't ask me to commit. Let me know if you'd like me to `git add`/commit these now, or leave them staged for your own review first.

---

## User

so anything else, before we wrap up this session and start with a fresh context?

---

## Assistant (Build · Claude Sonnet 5 · 17.5s)

_Thinking:_



Before wrapping up, here's the state of things and a couple of loose ends worth deciding now rather than rediscovering in a fresh context:

**What's done:**
- `biz.dfch.LlmOps` repo scaffolded with `.specmgr/_template/v1/README.md` and the feature file at `.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md`, capturing the full plan (Phase 0 env prep, Phase 1 Flash/vLLM, Phase 2 Pro/ktransformers), all decisions made, and open blockers.

**Loose ends to consider:**
1. **Git commit** — the `.specmgr/` folder is still untracked on branch `dev`. I haven't committed it (per your standing instruction, and mine, not to commit unless asked). Want me to commit it now so it's not lost/forgotten before a fresh context starts? If so, I'd also want a moment to check `conventional_commit_message` conventions for the message.
2. **Root `README.md`** — still just the one-line placeholder ("Describe the setup and tests of our LLM environment"). Not asked for, but worth a pointer to the feature folder for discoverability if this repo will grow more features later. Your call whether that matters now.
3. **No actual infrastructure work has started** — Phase 0 (disk space check, HF token setup, revision pinning, downloads) is still all `not-started`. That's expected/correct for where we are, just flagging so the fresh session picks up exactly there rather than assuming more progress happened.
4. **Nothing else outstanding** from the original DeepSeek-V4 question — Ollama's cloud-only tags were correctly identified and rejected, hardware fit was analyzed for both boxes, engine/precision/security/versioning/ops decisions are all recorded in the feature file.

Do you want me to commit the `.specmgr/` addition before we end here, or leave it uncommitted for you to review first?

---

## User

leave

---

## Assistant (Build · Claude Sonnet 5 · 6.1s)

Understood — I'll leave the `.specmgr/` addition uncommitted for your own review, as requested. No further action needed on my end.

**Summary for the fresh session's context:**
- Repo: `~/src/biz.dfch.LlmOps` (branch `dev`, untracked changes present: `.specmgr/`)
- Feature file: `.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md` — contains the full plan, requirements, acceptance criteria, task list (Phase 0/1/2), and decision log
- Next concrete step whenever you resume: Phase 0, Task 0.1 (disk space validation on the Dell 7960T)

Good stopping point. Let me know when you're ready to pick this back up.

---

