#!/usr/bin/env node
// Universal Cross-Platform ASL Install Resolver (Windows vs POSIX)
const os = require('os');
const { spawnSync } = require('child_process');
const path = require('path');

const isWindows = process.platform === 'win32';
const scriptDir = __dirname;

console.log(`[ASL Install Resolver] Platform: ${process.platform} (${os.type()} ${os.arch()})`);

if (isWindows) {
  console.log('--> Executing Windows PowerShell installer...');
  const ps1 = path.join(scriptDir, 'install.ps1');
  const res = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', ps1], { stdio: 'inherit' });
  process.exit(res.status || 0);
} else {
  console.log('--> Executing POSIX shell installer (macOS/Linux)...');
  const sh = path.join(scriptDir, 'install.sh');
  const res = spawnSync('bash', [sh, ...process.argv.slice(2)], { stdio: 'inherit' });
  process.exit(res.status || 0);
}
