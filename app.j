const chat = document.getElementById('chat');
const input = document.getElementById('msg');
const send = document.getElementById('send');
let history = [];

function addMsg(text, cls) {
  const d = document.createElement('div');
  d.className = 'msg ' + cls;
  d.textContent = text;
  chat.appendChild(d);
  chat.scrollTop = chat.scrollHeight;
}

function showTyping() {
  const d = document.createElement('div');
  d.className = 'typing';
  d.id = 'typing-indicator';
  d.innerHTML = '<span></span><span></span><span></span>';
  chat.appendChild(d);
  chat.scrollTop = chat.scrollHeight;
}

function hideTyping() {
  const t = document.getElementById('typing-indicator');
  if (t) t.remove();
}

async function ask(text) {
  addMsg(text, 'user');
  history.push({ role: 'user', content: text });
  showTyping();
  try {
    const res = await fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ messages: history })
    });
    const data = await res.json();
    hideTyping();
    if (data.error) {
      addMsg("Ошибка: " + data.error.message, 'ai');
      return;
    }
    const reply = data.choices[0].message.content;
    history.push({ role: 'assistant', content: reply });
    addMsg(reply, 'ai');
  } catch (e) {
    hideTyping();
    addMsg("Ошибка сети: " + e.message, 'ai');
  }
}

send.onclick = () => {
  const t = input.value.trim();
  if (!t) return;
  input.value = '';
  ask(t);
};

input.addEventListener('keydown', e => {
  if (e.key === 'Enter') send.click();
});
