import streamlit as st
import requests
import json

OLLAMA_HOST = "http://ollama.chatbot-app.svc.cluster.local:11434"

def ask_ollama_stream(prompt):
    payload = {
        "model": "phi3.5",
        "prompt": prompt,
        "stream": True
    }

    with requests.post(f"{OLLAMA_HOST}/api/generate", json=payload, stream=True, timeout=180) as response:
        if response.status_code != 200:
            yield f"Error: {response.status_code} - {response.text}"
            return
        
        for line in response.iter_lines():
            if line:
                try:
                    data = line.decode("utf-8")
                    if data.startswith("data: "):
                        data = data[6:]
                    chunk = json.loads(data)["response"]
                    yield chunk
                except Exception as e:
                    yield f"\n[Error parsing line: {e}]"

st.title("Chat with Phi3.5 via Ollama")

user_input = st.text_input("Enter a prompt:")

if st.button("Submit"):
    if user_input:
        response_stream = ask_ollama_stream(user_input)
        full_response = ""
        response_placeholder = st.empty()
        for chunk in response_stream:
            full_response += chunk
            response_placeholder.markdown(full_response)
    else:
        st.warning("Please enter a prompt.")