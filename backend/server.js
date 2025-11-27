// backend/server.js
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: '*' }
});

io.on('connection', socket => {
  console.log('socket connected', socket.id);

  socket.on('join-room', ({ roomId, userId }) => {
    console.log(`${userId} join-room ${roomId}`);
    socket.join(roomId);
    // notify others
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

const PORT = 4000;
server.listen(PORT, () => console.log('Signaling server running on', PORT));
