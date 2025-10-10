import os
import sys
from pathlib import Path
from threading import Lock
from llama_cpp import Llama as Llm 
from llama_cpp import CreateChatCompletionResponse



LLAMA_MODELS = {
    "7b": {
        "model_path": "?MUST_FILL?\\llama-2-7b.Q4_K_M.gguf",  
        "speed": 25.0,           # tokens per second
        "setup_time": 5.0,       # loading time in seconds
        "tokens": 4096,          # context_size
        "memory": "8-12GB RAM",  # RAM requirements
        "params": "7B",          # parameter count
        "description": "Fast inference, good for most tasks",
    }
}


def resolve_model_path(config_path: str | Path) -> str:
    """Return absolute model path found on disk or raise FileNotFoundError with helpful suggestions."""
    env_override = os.getenv("LLAMA_MODEL_PATH")
    if env_override:
        p = Path(env_override)
        if not p.is_absolute():
            p = Path.cwd() / p
        if p.exists():
            return str(p)

    base_dir = Path(getattr(sys, "_MEIPASS", Path(__file__).resolve().parent))
    cfg = Path(config_path)

    candidates = []
    # candidate order (customize if you want)
    if cfg.is_absolute():
        candidates.append(cfg)
    candidates.append(base_dir / cfg)                  # relative to package/exe
    candidates.append(base_dir / "models" / cfg.name)  # models/ next to package/exe
    candidates.append(Path.cwd() / cfg)                # current working dir
    candidates.append(Path.home() / cfg.name)          # user's home
    # (optional) additional local directories
    candidates = [p.resolve() for p in candidates]

    for p in candidates:
        if p.exists():
            return str(p)

    # not found -> helpful error
    checked = "\n".join(str(p) for p in candidates)
    raise FileNotFoundError(
        f"Model not found. looked for:\n{checked}\n\n"
        "Fix options:\n"
        " • Put the model file at one of the listed paths (recommended: project/models/).\n"
        " • Set LLAMA_MODEL_PATH env var to the exact file path.\n"
        " • Use an absolute path in LLAMA_MODELS for model_path."
    )

class Llama:
    """Singleton wrapper for the LLaMA model."""
    _instance = None  # Holds the single instance of this class
    _lock = Lock()    # Ensures thread-safe instantiation

    def __new__(cls):
        with cls._lock:  # Acquire lock for thread safety
            if cls._instance is None:  # Create instance only if it doesn't exist
                cls._instance = super().__new__(cls)

        return cls._instance

    def __init__(self, model_size: str = "7b"):
        # avoid re-initializing singleton
        if getattr(self, "_initialized", False):
            return

        model_config = LLAMA_MODELS.get(model_size, LLAMA_MODELS["7b"])
        raw_path = model_config.get("model_path", "models/ggml-7b-model.bin")
        ctx_size = int(model_config.get("tokens", 4096))

        model_path = resolve_model_path(raw_path)  # raises FileNotFoundError if missing

        # instantiate your Llm wrapper
        self.model = Llm(model_path=model_path, n_ctx=ctx_size, verbose=False)
        self.model_size = model_size
        self._initialized = True

    def generate(self, prompt: str, max_tokens: int = 150) -> str:
        response: CreateChatCompletionResponse = self.model.create_chat_completion(
            messages=[{"role": "user", "content": prompt}],
            max_tokens=max_tokens,
            stream=False
        )
        content = response["choices"][0]["message"]["content"]
        return content.strip() if content else ""





llama: Llama = Llama()  

if __name__ == "__main__":
    # simple test run
    test_prompt = "Hi, how are you?"
    try:
        result = llama.generate(test_prompt, max_tokens=100)
        print("Model output:\n", result)

    except FileNotFoundError as e:
        print("Model file not found:", e)

    except Exception as e:
        print("Error during model run:", e)
