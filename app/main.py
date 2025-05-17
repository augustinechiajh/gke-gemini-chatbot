import streamlit as st

st.title("GKE LLM Chatbot Demo")

if "messages" not in st.session_state:
    st.session_state.messages = []

def submit_message():
    user_msg = st.session_state.user_input
    st.session_state.messages.append({"role": "user", "content": user_msg})
    
    # Dummy response (replace this with real LLM call later)
    bot_response = f"Echo: {user_msg}"
    st.session_state.messages.append({"role": "bot", "content": bot_response})
    
    st.session_state.user_input = ""

st.text_input("Talk to the bot:", key="user_input", on_change=submit_message)

for msg in st.session_state.messages:
    if msg["role"] == "user":
        st.markdown(f"**You:** {msg['content']}")
    else:
        st.markdown(f"**Bot:** {msg['content']}")
