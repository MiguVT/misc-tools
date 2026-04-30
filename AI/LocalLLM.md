Basically the commands I use in my RTX 3090 (24GB VRAM) to run my locally LLMs for agentic use (Hermes)

Vision:
```
❯ llama-server \
          -hf unsloth/GLM-4.6V-Flash-GGUF:UD-Q4_K_XL \
          --n-gpu-layers 99 \
          --ctx-size 120000 \
          --parallel 1 \
          --flash-attn on \
          --cache-type-k q4_0 \
          --cache-type-v q4_0 \
          --mlock \
          --threads 32 \
          --ubatch-size 1024 \
          --batch-size 8192 \
          --temp 0.7 \
          --top-p 1.0 \
          --min-p 0.01 \
          --repeat-penalty 1.0 \
          --seed 3407 \
          --warmup
```

Text-only:
```
❯ llama-server \
          -hf unsloth/GLM-4.7-Flash-GGUF:UD-Q4_K_XL \
          --n-gpu-layers 99 \
          --ctx-size 120000 \
          --parallel 1 \
          --flash-attn on \
          --cache-type-k q4_0 \
          --cache-type-v q4_0 \
          --mlock \
          --threads 32 \
          --ubatch-size 1024 \
          --batch-size 8192 \
          --temp 0.7 \
          --top-p 1.0 \
          --min-p 0.01 \
          --repeat-penalty 1.0 \
          --seed 3407 \
          --warmup
```
