// Express.js routes for file, user, and role management
const express = require('express');
const router = express.Router();

// File routes

// In-memory file store (for demo)
let files = [];
let fileId = 1;

// File upload (accepts JSON: { name, content } or { name, contentBase64, mimeType, size })
router.post('/file/upload', (req, res) => {
  const { name, content, contentBase64, mimeType, size } = req.body;

  if (!name || (!content && !contentBase64)) {
    return res.status(400).json({ error: 'Missing name or content payload' });
  }

  const resolvedBuffer = contentBase64 ? Buffer.from(contentBase64, 'base64') : null;
  const resolvedSize = typeof size === 'number'
    ? size
    : (typeof size === 'string' && !Number.isNaN(Number(size)))
        ? Number(size)
        : resolvedBuffer?.length ?? (typeof content === 'string' ? Buffer.byteLength(content, 'utf8') : 0);
  const resolvedMime = mimeType || (contentBase64 ? 'application/octet-stream' : 'text/plain');
  const storedContent = contentBase64 || content;

  const file = {
    id: fileId++,
    name,
    content: storedContent,
    mimeType: resolvedMime,
    size: resolvedSize,
    isBase64: Boolean(contentBase64 && !content),
    uploadedAt: new Date().toISOString(),
  };

  if (!file.isBase64 && typeof storedContent === 'string') {
    file.preview = storedContent.length > 160
      ? `${storedContent.substring(0, 160)}...`
      : storedContent;
  }

  if (file.isBase64) {
    file.preview = `Binary file (${resolvedMime}) - ${resolvedSize} bytes`;
  }

  files.push(file);
  res.json({ message: 'File uploaded', file });
});

// List files
router.get('/file/list', (req, res) => {
  res.json(files);
});

// Delete file by id
router.delete('/file/:id', (req, res) => {
  const id = parseInt(req.params.id);
  files = files.filter(f => f.id !== id);
  res.json({ message: 'File deleted', id });
});

// User routes

// Simple user store (for demo) - In production, use a proper database
let users = [
  { id: 1, username: 'admin', password: 'admin123', role: 'admin', email: 'admin@kavtech.com', createdAt: new Date().toISOString() },
  { id: 2, username: 'user', password: 'user123', role: 'user', email: 'user@kavtech.com', createdAt: new Date().toISOString() }
];
let userIdCounter = 3;

// User registration (accepts JSON: { username, password, email, role })
router.post('/user/register', (req, res) => {
  const { username, password, email, role = 'user' } = req.body;
  
  if (!username || !password || !email) {
    return res.status(400).json({ error: 'Missing required fields: username, password, email' });
  }
  
  // Check if user already exists
  const existingUser = users.find(u => u.username === username || u.email === email);
  if (existingUser) {
    return res.status(409).json({ error: 'User with this username or email already exists' });
  }
  
  // Create new user
  const newUser = {
    id: userIdCounter++,
    username,
    password, // In production, hash this password!
    email,
    role,
    createdAt: new Date().toISOString()
  };
  
  users.push(newUser);
  
  // Return user data without password
  const { password: _, ...userWithoutPassword } = newUser;
  res.status(201).json({ 
    message: 'User registered successfully', 
    user: userWithoutPassword 
  });
});

// User login (accepts JSON: { username, password })
router.post('/user/login', (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ error: 'Missing username or password' });
  }
  
  const user = users.find(u => u.username === username && u.password === password);
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  // Return user data without password
  const { password: _, ...userWithoutPassword } = user;
  res.json({ 
    message: 'User logged in successfully', 
    role: user.role,
    user: userWithoutPassword
  });
});

// Get user roles
router.get('/user/roles', (req, res) => {
  res.json(users.map(u => u.role));
});

module.exports = router;
