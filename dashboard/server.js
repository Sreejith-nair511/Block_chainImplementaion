const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Mock blockchain data
let blockchainStats = {
    totalRecords: 50,
    encryptedRecords: 50,
    verifiedRecords: 50,
    activeNodes: 5,
    totalTransactions: 150,
    networkHealth: 'Healthy'
};

let recentTransactions = [];
let patientRecords = [];

// Load mock patient data
try {
    const mockData = fs.readFileSync(path.join(__dirname, '../data/mock_patients.json'), 'utf8');
    patientRecords = JSON.parse(mockData);
} catch (error) {
    console.log('Mock data not found, using empty array');
}

// Routes
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/api/stats', (req, res) => {
    res.json(blockchainStats);
});

app.get('/api/records', (req, res) => {
    res.json(patientRecords);
});

app.get('/api/records/:id', (req, res) => {
    const record = patientRecords.find(r => r.recordId === req.params.id);
    if (record) {
        res.json(record);
    } else {
        res.status(404).json({ error: 'Record not found' });
    }
});

app.get('/api/transactions', (req, res) => {
    res.json(recentTransactions);
});

app.post('/api/simulate/add-record', (req, res) => {
    const { recordId, patientName, condition } = req.body;
    
    const newTransaction = {
        id: `tx_${Date.now()}`,
        type: 'ADD_RECORD',
        recordId: recordId,
        patientName: patientName,
        condition: condition,
        timestamp: new Date().toISOString(),
        status: 'SUCCESS',
        encrypted: true,
        hash: `hash_${Math.random().toString(36).substr(2, 16)}`
    };
    
    recentTransactions.unshift(newTransaction);
    if (recentTransactions.length > 20) {
        recentTransactions.pop();
    }
    
    blockchainStats.totalTransactions++;
    
    // Emit real-time update
    io.emit('new-transaction', newTransaction);
    io.emit('stats-update', blockchainStats);
    
    res.json(newTransaction);
});

app.post('/api/simulate/verify-record', (req, res) => {
    const { recordId } = req.body;
    
    const verifyTransaction = {
        id: `tx_${Date.now()}`,
        type: 'VERIFY_INTEGRITY',
        recordId: recordId,
        timestamp: new Date().toISOString(),
        status: Math.random() > 0.1 ? 'VALID' : 'TAMPERED',
        details: 'SHA-256 hash verification completed'
    };
    
    recentTransactions.unshift(verifyTransaction);
    if (recentTransactions.length > 20) {
        recentTransactions.pop();
    }
    
    blockchainStats.totalTransactions++;
    
    // Emit real-time update
    io.emit('new-transaction', verifyTransaction);
    io.emit('stats-update', blockchainStats);
    
    res.json(verifyTransaction);
});

app.post('/api/simulate/decrypt-record', (req, res) => {
    const { recordId } = req.body;
    
    const decryptTransaction = {
        id: `tx_${Date.now()}`,
        type: 'DECRYPT_RECORD',
        recordId: recordId,
        timestamp: new Date().toISOString(),
        status: 'SUCCESS',
        details: 'AES-256 decryption completed for authorized access'
    };
    
    recentTransactions.unshift(decryptTransaction);
    if (recentTransactions.length > 20) {
        recentTransactions.pop();
    }
    
    blockchainStats.totalTransactions++;
    
    // Emit real-time update
    io.emit('new-transaction', decryptTransaction);
    io.emit('stats-update', blockchainStats);
    
    res.json(decryptTransaction);
});

// Socket.IO connection handling
io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);
    
    // Send initial data
    socket.emit('stats-update', blockchainStats);
    socket.emit('transactions-update', recentTransactions);
    
    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
    });
});

// Simulate periodic blockchain activity
setInterval(() => {
    // Simulate random blockchain activity
    if (Math.random() > 0.7) {
        const activities = ['QUERY_RECORD', 'AUDIT_ACCESS', 'CONSENT_VERIFY'];
        const activity = activities[Math.floor(Math.random() * activities.length)];
        
        const transaction = {
            id: `tx_${Date.now()}`,
            type: activity,
            recordId: `REC${String(Math.floor(Math.random() * 50) + 1).padStart(3, '0')}`,
            timestamp: new Date().toISOString(),
            status: 'SUCCESS',
            automated: true
        };
        
        recentTransactions.unshift(transaction);
        if (recentTransactions.length > 20) {
            recentTransactions.pop();
        }
        
        blockchainStats.totalTransactions++;
        
        io.emit('new-transaction', transaction);
        io.emit('stats-update', blockchainStats);
    }
}, 5000);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Arogya Dashboard server running on port ${PORT}`);
});
