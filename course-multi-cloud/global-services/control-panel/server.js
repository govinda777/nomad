const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Root script path
const ROOT_DIR = path.resolve(__dirname, '../..');

// Helper to execute commands
function runCommand(cmd) {
    return new Promise((resolve) => {
        exec(cmd, { cwd: ROOT_DIR }, (error, stdout, stderr) => {
            resolve({
                success: !error,
                stdout: stdout || '',
                stderr: stderr || ''
            });
        });
    });
}

// API: Get container status
app.get('/api/status', async (req, res) => {
    const { stdout } = await runCommand('docker ps --format "{{.Names}}||{{.Status}}"');
    const runningContainers = stdout.split('\n').filter(Boolean).map(line => {
        const [name, status] = line.split('||');
        return { name, status };
    });
    res.json({ containers: runningContainers });
});

// API: Trigger Module Action (up, down, test)
app.post('/api/action', async (req, res) => {
    const { action, module } = req.body;
    if (!['up', 'down', 'test'].includes(action) || !module) {
        return res.status(400).json({ error: 'Invalid action or module' });
    }

    const command = `./sandbox.sh ${action} ${module}`;
    const result = await runCommand(command);
    res.json(result);
});

app.listen(PORT, () => {
    console.log(`Global Control Panel is running on http://localhost:${PORT}`);
});
