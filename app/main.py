import streamlit as st
import requests

OLLAMA_HOST = "http://host.docker.internal:11434"

def ask_ollama(prompt):
    payload = {
        "model": "mistral",
        "prompt": prompt,
        "stream": False
    }

    response = requests.post(f"{OLLAMA_HOST}/api/generate", json=payload, timeout=60)
    
    if response.status_code == 200:
        return response.json()["response"]
    else:
        return f"Error: {response.status_code} - {response.text}"

st.title("Chat with Mistral via Ollama")

user_input = st.text_input("Enter a prompt:")

if st.button("Submit"):
    if user_input:
        response = ask_ollama(user_input)
        st.write(response)
    else:
        st.warning("Please enter a prompt.")