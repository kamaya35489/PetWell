const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Serve all files in this folder
app.use(express.static(path.join(__dirname)));

io.on('connection', (socket) => {
  console.log('✅ Device connected:', socket.id);

  socket.on('offer', (data) => {
    console.log('📤 Offer from phone → sending to viewer');
    socket.broadcast.emit('offer', data);
  });

  socket.on('answer', (data) => {
    console.log('📤 Answer from viewer → sending to phone');
    socket.broadcast.emit('answer', data);
  });

  socket.on('ice-candidate', (data) => {
    socket.broadcast.emit('ice-candidate', data);
  });

  socket.on('disconnect', () => {
    console.log('❌ Device disconnected:', socket.id);
  });
});

server.listen(3000, () => {
  console.log('');
  console.log('===========================================');
  console.log('  ✅  Server is running!');
  console.log('===========================================');
  console.log('');
  console.log('  PC (viewer) → http://localhost:3000/viewer.html');
  console.log('');
  console.log('  PHONE (camera) → http://YOUR-PC-IP:3000/sender.html');
  console.log('');
  console.log('  To find your PC IP:');
  console.log('  → Windows: run  ipconfig  in a new terminal');
  console.log('  → Look for IPv4 Address e.g. 192.168.1.105');
  console.log('===========================================');
});
