const path = require('path');
const { Bundler } = require('neutralino-appimage-bundler');

const bundler = new Bundler({
    desktop: {
        name: 'OpenChamber Launcher',
        icon: path.join(__dirname, 'assets/openchamber-logo-dark.png'),
        categories: ['Utility', 'System']
    },
    binary: {
        name: 'openchamber-launcher',
        dist: path.join(__dirname, 'dist')
    },
    includeLibraries: false,
    output: path.join(__dirname, 'dist/OpenChamber-Launcher-x86_64.AppImage'),
    version: '1.0.0'
});

bundler.bundle()
    .then(() => console.log('✓ AppImage created successfully!'))
    .catch(err => console.error('✗ Error:', err));
