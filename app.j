const chat = document.getElementById('chat');
const input = document.getElementById('msg');
const send = document.getElementById('send');
const menuBtn = document.getElementById('menu-btn');
const sidebar = document.getElementById('sidebar');
const overlay = document.getElementById('overlay');
const newChatBtn = document.getElementById('new-chat');
const newChatTop = document.getElementById('new-chat-top');
const moreBtn = document.getElementById('more-btn');
const attachBtn = document.getElementById('attach-btn');
const settingsBtn = document.getElementById('settings-btn');
const settingsScreen = document.getElementById('settings-screen');
const backBtn = document.getElementById('back-btn');
const themeToggle = document.getElementById('theme-toggle');
const welcome = document.getElementById('welcome');

let history = [];

// ===== ТЕМА =====
function applyTheme(isDark) {
  if (isDark) {
    document.body.classList.remove('light');
    localStorage.setItem('theme', 'dark');
  } else {
    document.body.classList.add('light');
    localStorage.setItem('theme', 'light');
  }
}

const savedTheme = localStorage.getItem('theme');
if (savedTheme === 'dark') {
  themeToggle.checked = true;
  applyTheme(true);
} else {
  themeToggle.checked = false;
  applyTheme(false);
}

themeToggle.addEventListener('change', e => {
  applyTheme(e.target.checked);
});

// ===== БОКОВОЕ МЕНЮ =====
function openSidebar() {
  sidebar.classList.add('open');
  overlay.classList.add('open');
}

function closeSidebar() {
  sidebar.classList.remove('open');
  overlay.classList.remove('open');
}

menuBtn.addEventListener('click', openSidebar);
overlay.addEventListener('click', closeSidebar);

// ===== НАСТРОЙКИ =====
settingsBtn.addEventListener('click', () => {
  settingsScreen.classList.remove('hidden');
  closeSidebar();
});

backBtn.addEventListener('click', () => {
  settingsScreen.classList.add('hidden');
});

// ===== НОВЫЙ ЧАТ =====
function startNewChat() {
  chat.innerHTML = '';
  history = [];
  welcome.classList.remove('hidden');
  closeSidebar();
}

newChatBtn.addEventListener('click', startNewChat);
newChatTop.addEventListener('click', startNewChat);

// ===== КНОПКА ⋯ (пока заглушка) =====
moreBtn.addEventListener('click', () => {
  alert('Меню появится позже');
});

// ===== КНОПКА ➕ (пока заглушка) =====
attachBtn.addEventListener('click', () => {
  alert('Меню вложений появится позже');
});

// ===== СООБЩЕНИЯ =====
function addMsg(text, cls) {
  welcome.classList.add('hidden');
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

// ===== ЗАПРОС К ИИ =====
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

// ===== ОТПРАВКА =====
send.onclick = () => {
  const t = input.value.trim();
  if (!t) return;
  input.value = '';
  ask(t);
};

input.addEventListener('keydown', e => {
  if (e.key === 'Enter') send.click();
});
