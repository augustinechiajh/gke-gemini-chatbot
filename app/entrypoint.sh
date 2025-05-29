#!/bin/sh

# Start Ollama in the background
ollama serve &

# Wait a few seconds for the server to be ready
sleep 5

# Pre-pull the model
ollama pull phi3.5

# Keep the server running in foreground
wait