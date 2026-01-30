#!/usr/bin/env node

/**
 * Post-install script
 * Downloads the correct Neutralino binary for the user's platform
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const platform = process.platform;
const arch = process.arch;

const binaryUrls = {
  'linux': {
    'x64': 'https://github.com/neutralinojs/neutralinojs/releases/download/v5.3.0/neutralino-linux_x64',
    'arm64': 'https://github.com/neutralinojs/neutralinojs/releases/download/v5.3.0/neutralino-linux_arm64',
    'arm': 'https://github.com/neutralinojs/neutralinojs/releases/download/v5.3.0/neutralino-linux_armhf'
  },
  'darwin': {
    'x64': 'https://github.com/neutralinojs/neutralinojs/releases/download/v5.3.0/neutralino-mac_x64',
    'arm64': 'https://github.com/neutralinojs/neutralinojs/releases/download/v5.3.0/neutralino-mac_arm64'
  },
  'win32': {
    'x64': 'https://github.com/neutralinojs/neutralinojs/releases/download/v5.3.0/neutralino-win_x64.exe'
  }
};

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // Follow redirect
        downloadFile(response.headers.location, dest).then(resolve).catch(reject);
        return;
      }
      
      if (response.statusCode !== 200) {
        reject(new Error(`Download failed: ${response.statusCode}`));
        return;
      }
      
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        fs.chmodSync(dest, 0o755);
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
}

async function main() {
  const platformBinaries = binaryUrls[platform];
  if (!platformBinaries) {
    console.error(`Unsupported platform: ${platform}`);
    process.exit(0); // Don't fail install, just warn
  }
  
  const url = platformBinaries[arch];
  if (!url) {
    console.error(`Unsupported architecture: ${arch} on ${platform}`);
    process.exit(0);
  }
  
  const binDir = path.join(__dirname, '..', 'bin');
  const binaryName = path.basename(url);
  const destPath = path.join(binDir, binaryName);
  
  // Check if binary already exists
  if (fs.existsSync(destPath)) {
    console.log(`Binary already exists: ${binaryName}`);
    return;
  }
  
  console.log(`Downloading ${binaryName}...`);
  
  try {
    await downloadFile(url, destPath);
    console.log(`✓ Downloaded ${binaryName}`);
  } catch (err) {
    console.error(`✗ Failed to download: ${err.message}`);
    console.error('You may need to download manually from:');
    console.error('https://github.com/neutralinojs/neutralinojs/releases');
    process.exit(0); // Don't fail npm install
  }
}

main();
