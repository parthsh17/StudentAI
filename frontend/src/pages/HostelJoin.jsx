import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { jwtDecode } from 'jwt-decode';

export default function HostelJoin() {
  const [studentInfo, setStudentInfo] = useState({ register_no: '', name: '' });
  const [selectedHostel, setSelectedHostel] = useState(null);
  const navigate = useNavigate();

  const hostels = [
    { id: 1, name: 'Jonas Hall', type: 'GIRLS', food: true, laundry: true, price: '12,500' },
    { id: 2, name: 'St. Kuriakose Hall', type: 'BOYS', food: true, laundry: true, price: '12,500' }
  ];

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      navigate('/login');
      return;
    }
    try {
      const decoded = jwtDecode(token);
      setStudentInfo({ register_no: decoded.sub, name: '' });
    } catch (e) {
      navigate('/login');
    }
  }, [navigate]);

  return (
    <div className="join-page">
      <div className="join-container">
        <header className="join-header">
          <button className="back-btn" onClick={() => navigate('/home')}>← Back to Chat</button>
          <h1>Hostel Registration</h1>
          <p>Secure your accommodation for the upcoming semester.</p>
        </header>

        <main className="join-content">
          <section className="student-verify-card">
            <h3>Student Verification</h3>
            <div className="verify-grid">
              <div className="verify-item">
                <span className="label">Register Number</span>
                <span className="value">{studentInfo.register_no}</span>
              </div>
              <div className="verify-item">
                <span className="label">Academic Year</span>
                <span className="value">2025-26</span>
              </div>
            </div>
          </section>

          <section className="hostel-selection">
            <h3>Choose Your Residence</h3>
            <div className="hostel-grid">
              {hostels.map((h) => (
                <div 
                  key={h.id} 
                  className={`hostel-card ${selectedHostel?.id === h.id ? 'selected' : ''}`}
                  onClick={() => setSelectedHostel(h)}
                >
                  <div className="hostel-type">{h.type}</div>
                  <h4>{h.name}</h4>
                  <ul className="hostel-amenities">
                    <li>{h.food ? '✅ Food Included' : '❌ No Food'}</li>
                    <li>{h.laundry ? '✅ Laundry Service' : '❌ No Laundry'}</li>
                  </ul>
                  <div className="hostel-price">
                    <span>Monthly Dues</span>
                    <strong>INR {h.price}</strong>
                  </div>
                </div>
              ))}
            </div>
          </section>

          <footer className="join-footer">
            <button 
              className="btn-primary payment-btn" 
              disabled={!selectedHostel}
              onClick={() => alert('Proceeding to Secure Payment Gateway...')}
            >
              {selectedHostel ? `Pay INR ${selectedHostel.price} & Join` : 'Select a Hostel to Proceed'}
            </button>
          </footer>
        </main>
      </div>
    </div>
  );
}
