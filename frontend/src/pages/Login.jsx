import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [registerNo, setRegisterNo] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch('http://localhost:8000/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ register_no: registerNo, password }),
      });

      if (!response.ok) {
        throw new Error('Invalid register no or password');
      }

      const data = await response.json();
      
      if (data.access_token) {
        localStorage.setItem('token', data.access_token);
      }
      
      navigate('/home');
    } catch (err) {
      setError(err.message || 'An error occurred during login');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      {/* Left side Form */}
      <div className="login-left">
        <div className="login-glass-card">
          <div className="login-header">
            <div className="login-logo">
              <span className="login-logo-icon">🎓</span> CampusAI
            </div>
            <p>Welcome back! Please enter your details.</p>
          </div>

          {error && (
            <div className="error-message">
              {error}
            </div>
          )}

          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label htmlFor="registerNo">Register no</label>
              <input
                id="registerNo"
                type="text"
                className="form-input"
                placeholder="register no"
                value={registerNo}
                onChange={(e) => setRegisterNo(e.target.value)}
                required
              />
            </div>

            <div className="form-group">
              <label htmlFor="password">Password</label>
              <input
                id="password"
                type="password"
                className="form-input"
                placeholder="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button 
              type="submit" 
              className="btn-primary" 
              disabled={isLoading}
            >
              {isLoading ? <span className="spinner"></span> : 'Sign in'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
