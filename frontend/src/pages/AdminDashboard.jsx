import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function AdminDashboard() {
  const [tools, setTools] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTool, setEditingTool] = useState(null);
  const navigate = useNavigate();

  // Form State
  const [toolForm, setToolForm] = useState({
    name: '',
    module: '',
    function_name: '',
    description: '',
    properties: [{ name: '', type: 'string', description: '' }],
    active: true
  });

  useEffect(() => {
    fetchTools();
  }, []);

  const fetchTools = async () => {
    const token = localStorage.getItem('adminToken');
    if (!token) { navigate('/admin/login'); return; }

    try {
      const response = await fetch('http://localhost:8000/admin/tools', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.status === 401) navigate('/admin/login');
      const data = await response.json();
      setTools(data);
    } catch (err) {
      console.error('Fetch error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleToggle = async (id, currentStatus) => {
    const token = localStorage.getItem('adminToken');
    try {
      await fetch(`http://localhost:8000/admin/tools/${id}/toggle`, {
        method: 'PATCH',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      setTools(tools.map(t => t.id === id ? { ...t, active: !currentStatus } : t));
    } catch (err) {
      alert('Failed to toggle tool status');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this tool?')) return;
    const token = localStorage.getItem('adminToken');
    try {
      await fetch(`http://localhost:8000/admin/tools/${id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      setTools(tools.filter(t => t.id !== id));
    } catch (err) {
      alert('Failed to delete tool');
    }
  };

  const handleAddProperty = () => {
    setToolForm({
      ...toolForm,
      properties: [...toolForm.properties, { name: '', type: 'string', description: '' }]
    });
  };

  const handleRemoveProperty = (index) => {
    const newProps = toolForm.properties.filter((_, i) => i !== index);
    setToolForm({ ...toolForm, properties: newProps });
  };

  const handlePropChange = (index, field, value) => {
    const newProps = [...toolForm.properties];
    newProps[index][field] = value;
    setToolForm({ ...toolForm, properties: newProps });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const token = localStorage.getItem('adminToken');
    
    // Construct the parameters JSON
    const propertiesObj = {};
    toolForm.properties.forEach(p => {
      if (p.name) {
        propertiesObj[p.name] = { type: p.type, description: p.description };
      }
    });

    const body = {
      name: toolForm.name,
      module: toolForm.module,
      function_name: toolForm.function_name,
      description: toolForm.description,
      active: toolForm.active,
      parameters: {
        type: 'object',
        properties: propertiesObj,
        required: toolForm.properties.filter(p => p.name).map(p => p.name)
      }
    };

    try {
      const url = editingTool 
        ? `http://localhost:8000/admin/tools/${editingTool.id}`
        : 'http://localhost:8000/admin/tools';
      
      const response = await fetch(url, {
        method: editingTool ? 'PUT' : 'POST',
        headers: { 
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      });

      if (!response.ok) throw new Error('Submission failed');
      
      setIsModalOpen(false);
      setEditingTool(null);
      fetchTools();
    } catch (err) {
      alert(err.message);
    }
  };

  const openEditModal = (tool) => {
    setEditingTool(tool);
    // Convert backend parameters back to our form properties array
    const propArray = [];
    const props = tool.parameters.properties || {};
    Object.keys(props).forEach(key => {
      propArray.push({
        name: key,
        type: props[key].type || 'string',
        description: props[key].description || ''
      });
    });

    setToolForm({
      name: tool.name,
      module: tool.module,
      function_name: tool.function_name,
      description: tool.description,
      active: tool.active,
      properties: propArray.length > 0 ? propArray : [{ name: '', type: 'string', description: '' }]
    });
    setIsModalOpen(true);
  };

  return (
    <div className="admin-page">
      <aside className="admin-sidebar">
        <div className="admin-sidebar-header">
          <span>🎓</span> CampusAI
        </div>
        <nav className="admin-nav">
          <button className="admin-nav-item active">🛠️ Tool Registry</button>
          <button className="admin-nav-item">📈 Performance</button>
          <button className="admin-nav-item">⚙️ Settings</button>
          <div style={{ marginTop: 'auto', paddingTop: '2rem' }}>
            <button className="admin-nav-item" onClick={() => { localStorage.removeItem('adminToken'); navigate('/admin/login'); }}>
              🚪 Sign Out
            </button>
          </div>
        </nav>
      </aside>

      <main className="admin-main">
        <header className="admin-header">
          <h1 className="admin-title">Tool Registry</h1>
          <button className="btn-primary" onClick={() => { setEditingTool(null); setIsModalOpen(true); }}>
            + Add New Tool
          </button>
        </header>

        <div className="admin-card">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Tool Name</th>
                <th>Module / Function</th>
                <th>Description</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '3rem' }}>Loading tools...</td></tr>
              ) : tools.map(tool => (
                <tr key={tool.id}>
                  <td style={{ fontWeight: 600 }}>{tool.name}</td>
                  <td>
                    <code style={{ fontSize: '0.75rem', background: '#F3F4F6', padding: '2px 4px', borderRadius: '4px' }}>
                      {tool.module}.{tool.function_name}
                    </code>
                  </td>
                  <td style={{ maxWidth: '300px', color: '#6B7280' }}>{tool.description}</td>
                  <td>
                    <span className={`status-badge ${tool.active ? 'status-active' : 'status-inactive'}`}>
                      {tool.active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
                      <label className="toggle-switch">
                        <input type="checkbox" checked={tool.active} onChange={() => handleToggle(tool.id, tool.active)} />
                        <span className="slider"></span>
                      </label>
                      <button onClick={() => openEditModal(tool)} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1.2rem' }}>✏️</button>
                      <button onClick={() => handleDelete(tool.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1.2rem' }}>🗑️</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>

      {isModalOpen && (
        <div className="modal-overlay">
          <div className="modal-card">
            <h2>{editingTool ? 'Edit Tool' : 'Register New Tool'}</h2>
            <form onSubmit={handleSubmit} style={{ marginTop: '1.5rem' }}>
              <div className="verify-grid">
                <div className="form-group">
                  <label>Display Name</label>
                  <input className="form-input" value={toolForm.name} onChange={e => setToolForm({...toolForm, name: e.target.value})} required placeholder="e.g. get_attendance" />
                </div>
                <div className="form-group">
                  <label>Module Path</label>
                  <input className="form-input" value={toolForm.module} onChange={e => setToolForm({...toolForm, module: e.target.value})} required placeholder="backend.services.exam_service" />
                </div>
              </div>
              <div className="verify-grid">
                <div className="form-group">
                  <label>Function Name</label>
                  <input className="form-input" value={toolForm.function_name} onChange={e => setToolForm({...toolForm, function_name: e.target.value})} required placeholder="get_exam_data" />
                </div>
                <div className="form-group">
                  <label>Initial Status</label>
                  <select className="form-select" value={toolForm.active} onChange={e => setToolForm({...toolForm, active: e.target.value === 'true'})}>
                    <option value="true">Active</option>
                    <option value="false">Inactive</option>
                  </select>
                </div>
              </div>
              <div className="form-group">
                <label>Description (for AI Orchestrator)</label>
                <textarea className="form-textarea" value={toolForm.description} onChange={e => setToolForm({...toolForm, description: e.target.value})} required />
              </div>

              <div style={{ marginTop: '2rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                  <label style={{ fontWeight: 600 }}>Arguments (Parameters)</label>
                  <button type="button" onClick={handleAddProperty} className="back-btn">+ Add Field</button>
                </div>
                {toolForm.properties.map((prop, idx) => (
                  <div key={idx} className="builder-prop-row">
                    <div className="form-field">
                      <label>Prop Name</label>
                      <input className="form-input" value={prop.name} onChange={e => handlePropChange(idx, 'name', e.target.value)} placeholder="reg_no" />
                    </div>
                    <div className="form-field">
                      <label>Type</label>
                      <select className="form-select" value={prop.type} onChange={e => handlePropChange(idx, 'type', e.target.value)}>
                        <option value="string">String</option>
                        <option value="number">Number</option>
                        <option value="boolean">Boolean</option>
                      </select>
                    </div>
                    <div className="form-field">
                      <label>Description (Prop)</label>
                      <input className="form-input" value={prop.description} onChange={e => handlePropChange(idx, 'description', e.target.value)} placeholder="Student register no" />
                    </div>
                    <button type="button" onClick={() => handleRemoveProperty(idx)} className="btn-icon">🗑️</button>
                  </div>
                ))}
              </div>

              <div style={{ display: 'flex', gap: '1rem', marginTop: '2.5rem' }}>
                <button type="submit" className="btn-primary" style={{ flex: 1 }}>{editingTool ? 'Save Changes' : 'Create Tool'}</button>
                <button type="button" className="btn-primary" style={{ flex: 1, backgroundColor: '#9CA3AF' }} onClick={() => setIsModalOpen(false)}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
