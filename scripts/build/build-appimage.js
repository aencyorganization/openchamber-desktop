const path = require('path');
const { Bundler } = require('neutralino-appimage-bundler');

// Get project root (3 levels up from scripts/build/)
const PROJECT_ROOT = path.join(__dirname, '..', '..');
const DIST_DIR = path.join(PROJECT_ROOT, 'dist');

const bundler = new Bundler({
    desktop: {
        name: 'OpenChamber Launcher',
        icon: path.join(PROJECT_ROOT, 'assets/openchamber-logo-dark.png'),
        categories: ['Utility', 'System']
    },
    binary: {
        name: 'openchamber-launcher',
        dist: DIST_DIR
    },
    includeLibraries: false,
    output: path.join(DIST_DIR, 'OpenChamber-Launcher-x86_64.AppImage'),
    version: '1.2.0'
});

bundler.bundle()
    .then(() => console.log('✓ AppImage created successfully!'))
    .catch(err => console.error('✗ Error:', err));
