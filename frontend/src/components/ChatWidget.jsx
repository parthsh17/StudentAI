import React, { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

const ChatWidget = ({ widgetData, onAction }) => {
  const [openMenuIndex, setOpenMenuIndex] = useState(null);
  const [formData, setFormData] = useState({});
  const widgetRef = useRef(null);
  const navigate = useNavigate();

  // Close dropdown if clicked outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (widgetRef.current && !widgetRef.current.contains(event.target)) {
        setOpenMenuIndex(null);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  if (!widgetData) return null;

  const handleAction = (label, query) => {
    setOpenMenuIndex(null);
    onAction(label, query);
  };

  const handleFormSubmit = (e) => {
    e.preventDefault();
    let query = widgetData.submit_query;
    // Replace placeholders {field_name} with actual values
    widgetData.fields.forEach(field => {
      const val = formData[field.name] || '';
      query = query.replace(`{${field.name}}`, val);
    });
    onAction(widgetData.submit_label, query);
  };

  const toggleMenu = (index, e) => {
    e.stopPropagation();
    setOpenMenuIndex(openMenuIndex === index ? null : index);
  };

  if (widgetData.type === 'form') {
    return (
      <div className="widget-container" ref={widgetRef}>
        {widgetData.title && <div className="widget-title">{widgetData.title}</div>}
        <form className="widget-form" onSubmit={handleFormSubmit}>
          {widgetData.fields.map((field, fIdx) => (
            <div key={fIdx} className="form-field">
              <label>{field.label}</label>
              {field.type === 'select' ? (
                <select 
                  className="form-select"
                  value={formData[field.name] || ''}
                  onChange={(e) => setFormData({...formData, [field.name]: e.target.value})}
                  required
                >
                  <option value="">Select an option...</option>
                  {field.options.map((opt, oIdx) => <option key={oIdx} value={opt}>{opt}</option>)}
                </select>
              ) : field.type === 'textarea' ? (
                <textarea 
                  className="form-textarea"
                  placeholder={field.placeholder}
                  value={formData[field.name] || ''}
                  onChange={(e) => setFormData({...formData, [field.name]: e.target.value})}
                  required
                />
              ) : (
                <input 
                  type={field.type} 
                  className="form-input"
                  value={formData[field.name] || ''}
                  onChange={(e) => setFormData({...formData, [field.name]: e.target.value})}
                  required
                />
              )}
            </div>
          ))}
          <button type="submit" className="form-submit-btn">{widgetData.submit_label}</button>
        </form>
      </div>
    );
  }

  return (
    <div className="widget-container" ref={widgetRef}>
      {widgetData.title && <div className="widget-title">{widgetData.title}</div>}
      <div className="widget-actions">
        {widgetData.actions?.map((action, idx) => {
          if (action.type === 'menu') {
            return (
              <div key={idx} className="widget-menu-wrapper">
                <button 
                  className="widget-btn widget-menu-btn" 
                  onClick={(e) => toggleMenu(idx, e)}
                >
                  {action.label}
                  <small style={{ fontSize: '0.6rem' }}>▼</small>
                </button>
                {openMenuIndex === idx && (
                  <div className="widget-dropdown">
                    {action.options.map((option, sIdx) => (
                      <div 
                        key={sIdx} 
                        className="dropdown-item"
                        onClick={() => handleAction(option.label, option.query)}
                      >
                        {option.label}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          }

          if (action.type === 'link') {
            return (
              <button 
                key={idx} 
                className="widget-btn" 
                onClick={() => navigate(action.url)}
              >
                {action.label}
                <small style={{ fontSize: '0.6rem' }}>↗</small>
              </button>
            );
          }

          return (
            <button 
              key={idx} 
              className="widget-btn" 
              onClick={() => handleAction(action.label, action.query)}
            >
              {action.label}
            </button>
          );
        })}
      </div>
    </div>
  );
};

export default ChatWidget;
