import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import ChatWidget from '../components/ChatWidget';

export default function Home() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);
  const navigate = useNavigate();

  // Redirect to login if not authenticated
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      navigate('/login', { replace: true });
    }
  }, [navigate]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  const handleLogout = async () => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        await fetch('http://localhost:8000/ai/clear_history', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        });
      } catch (e) {
        console.error('Failed to clear history on backend:', e);
      }
    }
    localStorage.removeItem('token');
    navigate('/login', { replace: true });
  };

  const handleSend = async (e, forcedQuery = null) => {
    e?.preventDefault();
    const queryToSubmit = forcedQuery || input.trim();
    if (!queryToSubmit || isLoading) return;

    const token = localStorage.getItem('token');

    setMessages((prev) => [...prev, { role: 'user', content: queryToSubmit }]);
    if (!forcedQuery) setInput('');
    setIsLoading(true);

    try {
      const response = await fetch('http://localhost:8000/ai/query', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({ query: queryToSubmit }),
      });

      if (response.status === 401) {
        handleLogout();
        return;
      }

      if (!response.ok) {
        throw new Error('Failed to fetch AI response');
      }

      const data = await response.json();

      setMessages((prev) => [...prev, { 
        role: 'ai', 
        content: data.response,
        widget: data.widget // Store widget data
      }]);
    } catch (error) {
      console.error(error);
      setMessages((prev) => [...prev, { role: 'ai', content: 'An error occurred while connecting to the AI. Please try again later.' }]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="chat-page">
      {/* Top Header */}
      <header className="chat-header">
        <h1>
          <span className="login-logo-icon" style={{ width: '32px', height: '32px', fontSize: '1.2rem', borderRadius: '6px' }}>🎓</span> 
          CampusAI
        </h1>
        <button className="chat-logout-btn" onClick={handleLogout}>
          Logout
        </button>
      </header>

      {/* Main Chat Area */}
      <div className="chat-container">
        
        <div className="chat-messages">
          {messages.length === 0 ? (
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: 'var(--text-muted)' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>👋</div>
              <h2 style={{ fontSize: '1.5rem', fontWeight: '500', color: 'var(--text-dark)' }}>Hello! How can I help you today?</h2>
              <p style={{ marginTop: '0.5rem' }}>Ask me anything about your educational journey.</p>
            </div>
          ) : (
            messages.map((msg, index) => (
              <div key={index} className={`chat-message ${msg.role}`}>
                <div className="message-bubble markdown-body">
                  {msg.role === 'ai' ? (
                    <ReactMarkdown remarkPlugins={[remarkGfm]}>
                      {msg.content}
                    </ReactMarkdown>
                  ) : (
                    msg.content
                  )}
                </div>
                {msg.widget && (
                  <ChatWidget 
                    widgetData={msg.widget} 
                    onAction={(label, query) => handleSend(null, query)} 
                  />
                )}
              </div>
            ))
          )}

          {isLoading && (
            <div className="chat-message ai">
              <div className="message-bubble typing-indicator">
                <div className="typing-dot"></div>
                <div className="typing-dot"></div>
                <div className="typing-dot"></div>
              </div>
            </div>
          )}
          
          <div ref={messagesEndRef} />
        </div>

        {/* Input Area */}
        <form className="chat-input-container" onSubmit={handleSend}>
          <input
            type="text"
            className="chat-input"
            placeholder="Type your message here..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            disabled={isLoading}
            autoFocus
          />
          <button 
            type="submit" 
            className="chat-send-btn" 
            disabled={!input.trim() || isLoading}
            aria-label="Send message"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="22" y1="2" x2="11" y2="13"></line>
              <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
            </svg>
          </button>
        </form>
        
      </div>
    </div>
  );
}
