// backend/server.js
require("dotenv").config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');
const blockchain = require('./blockchain');

const app = express();
app.use(cors());
app.use(express.json()); // Parse JSON request bodies

const server = http.createServer(app);

// ── Socket.IO (existing — for WebRTC signaling) ───────────────────────────────
const io = new Server(server, {
  cors: { origin: '*' }
});

io.on('connection', socket => {
  console.log('socket connected', socket.id);

  socket.on('join-room', ({ roomId, userId }) => {
    console.log(`${userId} join-room ${roomId}`);
    socket.join(roomId);
    socket.to(roomId).emit('peer-joined', { from: userId });
  });

  socket.on('offer', data => {
    console.log('offer from', data?.from);
    socket.to(data.roomId).emit('offer', data);
  });

  socket.on('answer', data => {
    console.log('answer from', data?.from);
    socket.to(data.roomId).emit('answer', data);
  });

  socket.on('ice-candidate', data => {
    socket.to(data.roomId).emit('ice-candidate', data);
  });

  socket.on('disconnect', () => {
    console.log('socket disconnected', socket.id);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 🔗 BLOCKCHAIN API ROUTES — Medicine Validation on Polygon
// ─────────────────────────────────────────────────────────────────────────────

// ── GET /api/blockchain/verify/:batchId ───────────────────────────────────────
// PUBLIC — anyone can verify a medicine batch. Free (read-only blockchain call).
// Example: GET /api/blockchain/verify/PAR-500-2024-B1
app.get('/api/blockchain/verify/:batchId', async (req, res) => {
  try {
    const { batchId } = req.params;

    if (!batchId || batchId.trim() === '') {
      return res.status(400).json({ error: 'batchId is required' });
    }

    const result = await blockchain.verifyMedicine(batchId.trim());
    return res.json({ success: true, data: result });
  } catch (err) {
    console.error('[API] verify error:', err.message);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// ── POST /api/blockchain/register ─────────────────────────────────────────────
// ADMIN ONLY — Register a new medicine batch on-chain.
// Requires: Authorization header (simple shared secret for now)
// Body: { batchId, name, manufacturer, composition, expiryDate, ipfsHash }
app.post('/api/blockchain/register', async (req, res) => {
  try {
    // Simple admin auth — check shared secret header
    // TODO: Replace with Firebase Admin token verification
    const authHeader = req.headers['x-admin-secret'];
    const ADMIN_SECRET = process.env.ADMIN_SECRET || 'drugsure-admin-2024';
    if (authHeader !== ADMIN_SECRET) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const { batchId, name, manufacturer, composition, expiryDate, ipfsHash } = req.body;

    // Validate required fields
    if (!batchId || !name || !manufacturer || !composition || !expiryDate) {
      return res.status(400).json({
        error: 'Missing required fields: batchId, name, manufacturer, composition, expiryDate'
      });
    }

    const result = await blockchain.registerMedicine({
      batchId,
      name,
      manufacturer,
      composition,
      expiryDate: new Date(expiryDate),
      ipfsHash: ipfsHash || '',
    });

    return res.json({ success: true, data: result });
  } catch (err) {
    console.error('[API] register error:', err.message);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// ── POST /api/blockchain/revoke ───────────────────────────────────────────────
// ADMIN ONLY — Revoke / recall a medicine batch (mark as counterfeit/unsafe)
// Body: { batchId }
app.post('/api/blockchain/revoke', async (req, res) => {
  try {
    const authHeader = req.headers['x-admin-secret'];
    const ADMIN_SECRET = process.env.ADMIN_SECRET || 'drugsure-admin-2024';
    if (authHeader !== ADMIN_SECRET) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const { batchId } = req.body;
    if (!batchId) {
      return res.status(400).json({ error: 'batchId is required' });
    }

    const result = await blockchain.revokeMedicine(batchId);
    return res.json({ success: true, data: result });
  } catch (err) {
    console.error('[API] revoke error:', err.message);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// ── GET /api/blockchain/stats ─────────────────────────────────────────────────
// PUBLIC — Get total medicines registered on blockchain
app.get('/api/blockchain/stats', async (req, res) => {
  try {
    const total = await blockchain.getTotalBatches();
    return res.json({ success: true, data: { totalRegistered: total } });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

// ── GET /api/health ───────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─────────────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`🚀 DrugSure backend running on port ${PORT}`);
  console.log(`🔗 Blockchain API ready at http://localhost:${PORT}/api/blockchain`);
});
