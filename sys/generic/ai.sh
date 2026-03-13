# https://medium.com/@sealteamsecs/local-llm-installation-guide-install-llama3-using-ollama-ef8cf68bb461

curl -fsSL https://ollama.com/install.sh | sh

# check Ollama is running.
# http://localhost:11434

ollama pull llama3
ollama run llama3

