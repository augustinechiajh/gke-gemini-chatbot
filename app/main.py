import streamlit as st
from vertexai.preview.language_models import ChatModel, InputOutputTextPair
import vertexai

# Initialize Vertex AI
vertexai.init(project="your-gcp-project-id", location="us-central1")  # Update later

chat_model = ChatModel.from_pretrained("chat-bison")

chat = chat_model.start_chat()

st.title("Gemini Chatbot (GCP Vertex AI)")

user_input = st.text_input("Enter your prompt:")

if st.button("Send"):
    if user_input:
        response = chat.send_message(user_input)
        st.markdown(f"**Gemini:** {response.text}")
    else:
        st.warning("Please enter a prompt.")