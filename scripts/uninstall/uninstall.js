#!/usr/bin/env node

/**
 * Unified Uninstall Script for OpenChamber Desktop
 * Detects installation method and performs complete cleanup
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Import our logging system
const { Logger, InstallMethodDetector } = require('../lib/logger');

const APP_NAME = 'openchamber-desktop';
const DISPLAY_NAME = 'OpenChamber Desktop';

class Uninstaller {
  constructor() {
    this.logger = new Logger({ 
      appName: 'openchamber-desktop-uninstall',
      logLevel: 'info'
    });
    this.platform = process.platform;
    this.homeDir = os.homedir();
    this.detector = new InstallMethodDetector(this.logger);
    this.removedItems = [];
    this.errors = [];
  }

  async run() {
    this.logger.section(`Uninstalling ${DISPLAY_NAME}`);
    this.logger.info(`Platform: ${this.platform}`);
    this.logger.info(`Architecture: ${process.arch}`);
    
    try {
      // Detect installation methods
      const methods = this.detector.detect();
      
      if (methods.length === 0) {
        this.logger.warn('No installation methods detected - performing full system scan');
        await this.performFullCleanup();
      } else {
        // Uninstall based on detected methods
        for (const method of methods) {
          await this.uninstallByMethod(method);
        }
      }
      
      // Always perform common cleanup
      await this.performCommonCleanup();
      
      // Print summary
      this.printSummary();
      
      if (this.errors.length > 0) {
        process.exit(1);
      }
      
      this.logger.success(`${DISPLAY_NAME} has been completely removed!`);
      
    } catch (error) {
      this.logger.error('Uninstallation failed', { error: error.message, stack: error.stack });
      process.exit(1);
    }
  }

  async uninstallByMethod(method) {
    this.logger.section(`Uninstalling via ${method.type}`);
    
    switch (method.type) {
      case 'npm':
        await this.uninstallNpm();
        break;
      case 'user':
      case 'system':
      case 'opt':
        await this.uninstallDirect(method.details.path);
        break;
      case 'app':
      case 'user-app':
        await this.uninstallMacApp(method.details.path);
        break;
      case 'msix':
        await this.uninstallMsix();
        break;
      case 'homebrew':
        await this.uninstallHomebrew();
        break;
      case 'appimage':
        await this.uninstallAppImage(method.details.path);
        break;
      case 'flatpak':
        await this.uninstallFlatpak();
        break;
      case 'snap':
        await this.uninstallSnap();
        break;
      case 'dpkg':
      case 'rpm':
        await this.uninstallPackageManager(method.type);
        break;
      default:
        this.logger.warn(`Unknown installation method: ${method.type}`);
    }
  }

  async uninstallNpm() {
    this.logger.info('Uninstalling npm package...');
    
    try {
      // Kill any running processes first
      await this.killProcesses();
      
      // Uninstall global package
      execSync('npm uninstall -g openchamber-desktop', { stdio: 'pipe' });
      this.removedItems.push('npm package: openchamber-desktop');
      this.logger.success('npm package removed');
    } catch (e) {
      this.errors.push({ type: 'npm', error: e.message });
      this.logger.error('Failed to uninstall npm package', { error: e.message });
    }
  }

  async uninstallDirect(installPath) {
    this.logger.info(`Removing installation at ${installPath}...`);
    
    try {
      // Kill any running processes
      await this.killProcesses();
      
      if (fs.existsSync(installPath)) {
        // Remove directory
        fs.rmSync(installPath, { recursive: true, force: true });
        this.removedItems.push(`Installation directory: ${installPath}`);
        this.logger.success(`Removed ${installPath}`);
      }
      
      // Remove symlinks/binaries
      await this.removeBinaries();
      
      // Remove desktop entries
      await this.removeDesktopEntries();
      
    } catch (e) {
      this.errors.push({ type: 'direct', path: installPath, error: e.message });
      this.logger.error(`Failed to remove ${installPath}`, { error: e.message });
    }
  }

  async uninstallMacApp(appPath) {
    this.logger.info(`Removing macOS app at ${appPath}...`);
    
    try {
      await this.killProcesses();
      
      if (fs.existsSync(appPath)) {
        // Move to trash using AppleScript (safer than rm)
        try {
          execSync(`osascript -e 'tell application "Finder" to delete POSIX file "${appPath}"'`, { stdio: 'pipe' });
        } catch (e) {
          // Fallback to rm if AppleScript fails
          fs.rmSync(appPath, { recursive: true, force: true });
        }
        this.removedItems.push(`macOS app: ${appPath}`);
        this.logger.success(`Removed ${appPath}`);
      }
    } catch (e) {
      this.errors.push({ type: 'mac-app', path: appPath, error: e.message });
      this.logger.error(`Failed to remove ${appPath}`, { error: e.message });
    }
  }

  async uninstallMsix() {
    this.logger.info('Removing MSIX/Windows Store installation...');
    
    try {
      await this.killProcesses();
      
      // Find and remove MSIX package
      const result = execSync('powershell -Command "Get-AppxPackage | Where-Object {$_.Name -like \"*openchamber*\"} | Remove-AppxPackage"', { 
        stdio: 'pipe',
        encoding: 'utf8'
      });
      
      this.removedItems.push('MSIX package');
      this.logger.success('MSIX package removed');
    } catch (e) {
      this.errors.push({ type: 'msix', error: e.message });
      this.logger.error('Failed to remove MSIX package', { error: e.message });
    }
  }

  async uninstallHomebrew() {
    this.logger.info('Removing Homebrew installation...');
    
    try {
      await this.killProcesses();
      execSync('brew uninstall openchamber-desktop', { stdio: 'pipe' });
      this.removedItems.push('Homebrew formula');
      this.logger.success('Homebrew package removed');
    } catch (e) {
      this.errors.push({ type: 'homebrew', error: e.message });
      this.logger.error('Failed to uninstall Homebrew package', { error: e.message });
    }
  }

  async uninstallAppImage(appImagePath) {
    this.logger.info(`Removing AppImage at ${appImagePath}...`);
    
    try {
      await this.killProcesses();
      
      if (fs.existsSync(appImagePath)) {
        fs.unlinkSync(appImagePath);
        this.removedItems.push(`AppImage: ${appImagePath}`);
        this.logger.success(`Removed ${appImagePath}`);
      }
      
      // Remove AppImage integration files
      const appImageConfigDir = path.join(this.homeDir, '.config', 'appimagekit');
      if (fs.existsSync(appImageConfigDir)) {
        const files = fs.readdirSync(appImageConfigDir);
        for (const file of files) {
          if (file.toLowerCase().includes('openchamber')) {
            const filePath = path.join(appImageConfigDir, file);
            fs.unlinkSync(filePath);
            this.removedItems.push(`AppImage config: ${filePath}`);
          }
        }
      }
    } catch (e) {
      this.errors.push({ type: 'appimage', error: e.message });
      this.logger.error('Failed to remove AppImage', { error: e.message });
    }
  }

  async uninstallFlatpak() {
    this.logger.info('Removing Flatpak installation...');
    
    try {
      await this.killProcesses();
      execSync('flatpak uninstall -y com.openchamber.desktop', { stdio: 'pipe' });
      this.removedItems.push('Flatpak package');
      this.logger.success('Flatpak package removed');
    } catch (e) {
      this.errors.push({ type: 'flatpak', error: e.message });
      this.logger.error('Failed to uninstall Flatpak', { error: e.message });
    }
  }

  async uninstallSnap() {
    this.logger.info('Removing Snap installation...');
    
    try {
      await this.killProcesses();
      execSync('snap remove openchamber-desktop', { stdio: 'pipe' });
      this.removedItems.push('Snap package');
      this.logger.success('Snap package removed');
    } catch (e) {
      this.errors.push({ type: 'snap', error: e.message });
      this.logger.error('Failed to remove Snap', { error: e.message });
    }
  }

  async uninstallPackageManager(type) {
    this.logger.info(`Removing ${type} package...`);
    
    try {
      await this.killProcesses();
      
      if (type === 'dpkg') {
        execSync('apt-get remove -y openchamber-desktop', { stdio: 'pipe' });
      } else if (type === 'rpm') {
        execSync('rpm -e openchamber-desktop', { stdio: 'pipe' });
      }
      
      this.removedItems.push(`${type} package`);
      this.logger.success(`${type} package removed`);
    } catch (e) {
      this.errors.push({ type, error: e.message });
      this.logger.error(`Failed to remove ${type} package`, { error: e.message });
    }
  }

  async killProcesses() {
    this.logger.info('Stopping any running OpenChamber processes...');
    
    try {
      if (this.platform === 'win32') {
        try {
          execSync('taskkill /F /IM neutralino-win_x64.exe 2>nul || exit 0', { stdio: 'pipe' });
          execSync('taskkill /F /IM openchamber.exe 2>nul || exit 0', { stdio: 'pipe' });
        } catch (e) {}
      } else if (this.platform === 'darwin') {
        try {
          execSync('pkill -9 -f "neutralino-mac" 2>/dev/null || true', { stdio: 'pipe' });
          execSync('pkill -9 -f "openchamber" 2>/dev/null || true', { stdio: 'pipe' });
        } catch (e) {}
      } else {
        try {
          execSync('pkill -9 -f "neutralino-linux" 2>/dev/null || true', { stdio: 'pipe' });
          execSync('pkill -9 -f "openchamber" 2>/dev/null || true', { stdio: 'pipe' });
        } catch (e) {}
      }
      
      this.logger.success('Processes stopped');
    } catch (e) {
      this.logger.warn('Some processes could not be stopped', { error: e.message });
    }
  }

  async removeBinaries() {
    this.logger.info('Removing binaries and symlinks...');
    
    const binaryPaths = [];
    
    if (this.platform === 'win32') {
      // Windows doesn't typically have symlinks for this
    } else {
      // User bin directories
      binaryPaths.push(
        path.join(this.homeDir, '.local', 'bin', 'openchamber-desktop'),
        path.join(this.homeDir, '.local', 'bin', 'ocd'),
        '/usr/local/bin/openchamber-desktop',
        '/usr/local/bin/ocd',
        '/usr/bin/openchamber-desktop',
        '/usr/bin/ocd'
      );
    }
    
    for (const binaryPath of binaryPaths) {
      try {
        if (fs.existsSync(binaryPath)) {
          fs.unlinkSync(binaryPath);
          this.removedItems.push(`Binary: ${binaryPath}`);
          this.logger.success(`Removed binary: ${binaryPath}`);
        }
      } catch (e) {
        this.logger.warn(`Could not remove binary: ${binaryPath}`, { error: e.message });
      }
    }
  }

  async removeDesktopEntries() {
    this.logger.info('Removing desktop entries and shortcuts...');
    
    if (this.platform === 'win32') {
      const shortcuts = [
        path.join(process.env.APPDATA || '', 'Microsoft', 'Windows', 'Start Menu', 'Programs', `${DISPLAY_NAME}.lnk`),
        path.join(this.homeDir, 'Desktop', `${DISPLAY_NAME}.lnk`),
        path.join(process.env.PUBLIC || '', 'Desktop', `${DISPLAY_NAME}.lnk`)
      ];
      
      for (const shortcut of shortcuts) {
        try {
          if (fs.existsSync(shortcut)) {
            fs.unlinkSync(shortcut);
            this.removedItems.push(`Shortcut: ${shortcut}`);
            this.logger.success(`Removed shortcut: ${shortcut}`);
          }
        } catch (e) {
          this.logger.warn(`Could not remove shortcut: ${shortcut}`, { error: e.message });
        }
      }
      
      // Remove from PATH
      try {
        const currentPath = process.env.PATH || '';
        const installDir = path.join(process.env.LOCALAPPDATA || '', DISPLAY_NAME);
        if (currentPath.includes(installDir)) {
          // Note: Actually modifying PATH requires registry changes
          this.logger.info('Note: Please manually remove from PATH if added');
        }
      } catch (e) {}
      
    } else if (this.platform === 'darwin') {
      // macOS apps are handled in uninstallMacApp
    } else {
      // Linux .desktop files
      const desktopFiles = [
        path.join(this.homeDir, '.local', 'share', 'applications', `${APP_NAME}.desktop`),
        '/usr/share/applications/openchamber-desktop.desktop',
        '/usr/local/share/applications/openchamber-desktop.desktop'
      ];
      
      for (const desktopFile of desktopFiles) {
        try {
          if (fs.existsSync(desktopFile)) {
            fs.unlinkSync(desktopFile);
            this.removedItems.push(`Desktop entry: ${desktopFile}`);
            this.logger.success(`Removed desktop entry: ${desktopFile}`);
          }
        } catch (e) {
          this.logger.warn(`Could not remove desktop entry: ${desktopFile}`, { error: e.message });
        }
      }
      
      // Update desktop database
      try {
        execSync('update-desktop-database ~/.local/share/applications 2>/dev/null || true', { stdio: 'pipe' });
      } catch (e) {}
    }
  }

  async performCommonCleanup() {
    this.logger.section('Performing Common Cleanup');
    
    // Remove cache directories
    const cacheDirs = [
      path.join(this.homeDir, '.cache', 'openchamber-desktop'),
      path.join(this.homeDir, '.config', 'openchamber-desktop'),
      path.join(this.homeDir, 'Library', 'Caches', 'com.openchamber.desktop'),
      path.join(this.homeDir, 'Library', 'Preferences', 'com.openchamber.desktop.plist'),
      path.join(process.env.LOCALAPPDATA || '', 'OpenChamber Desktop', 'cache'),
      path.join(process.env.LOCALAPPDATA || '', 'OpenChamber Desktop', 'logs')
    ];
    
    for (const cacheDir of cacheDirs) {
      try {
        if (fs.existsSync(cacheDir)) {
          fs.rmSync(cacheDir, { recursive: true, force: true });
          this.removedItems.push(`Cache/Config: ${cacheDir}`);
          this.logger.success(`Removed cache/config: ${cacheDir}`);
        }
      } catch (e) {
        this.logger.warn(`Could not remove cache: ${cacheDir}`, { error: e.message });
      }
    }
    
    // Remove npm cache
    try {
      execSync('npm cache clean --force 2>/dev/null || true', { stdio: 'pipe' });
      this.logger.success('Cleaned npm cache');
    } catch (e) {}
  }

  async performFullCleanup() {
    this.logger.section('Performing Full System Cleanup');
    
    // Kill processes
    await this.killProcesses();
    
    // Try all known installation paths
    const knownPaths = {
      win32: [
        path.join(process.env.LOCALAPPDATA || '', DISPLAY_NAME),
        path.join(process.env.PROGRAMFILES || '', DISPLAY_NAME),
        path.join(process.env['PROGRAMFILES(X86)'] || '', DISPLAY_NAME),
        path.join(this.homeDir, 'AppData', 'Local', DISPLAY_NAME),
        path.join(this.homeDir, 'AppData', 'Roaming', DISPLAY_NAME)
      ],
      darwin: [
        '/Applications/OpenChamber Desktop.app',
        path.join(this.homeDir, 'Applications', 'OpenChamber Desktop.app'),
        '/opt/openchamber-desktop',
        path.join(this.homeDir, '.local', 'lib', 'openchamber-desktop')
      ],
      linux: [
        '/opt/openchamber-desktop',
        path.join(this.homeDir, '.local', 'lib', 'openchamber-desktop'),
        '/usr/share/openchamber-desktop',
        '/usr/local/share/openchamber-desktop'
      ]
    };
    
    const paths = knownPaths[this.platform] || [];
    
    for (const installPath of paths) {
      if (fs.existsSync(installPath)) {
        await this.uninstallDirect(installPath);
      }
    }
    
    // Remove binaries and desktop entries
    await this.removeBinaries();
    await this.removeDesktopEntries();
    
    // Common cleanup
    await this.performCommonCleanup();
  }

  printSummary() {
    this.logger.section('Uninstallation Summary');
    
    console.log('\n✓ Removed items:');
    for (const item of this.removedItems) {
      console.log(`  - ${item}`);
    }
    
    if (this.errors.length > 0) {
      console.log('\n✗ Errors encountered:');
      for (const error of this.errors) {
        console.log(`  - ${error.type}: ${error.error}`);
      }
    }
    
    console.log(`\nLog file: ${this.logger.getLogPath()}`);
    
    if (this.removedItems.length === 0 && this.errors.length === 0) {
      console.log('\nℹ No OpenChamber Desktop installation found on this system.');
    }
  }
}

// Run if called directly
if (require.main === module) {
  const uninstaller = new Uninstaller();
  uninstaller.run().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
  });
}

module.exports = { Uninstaller };
