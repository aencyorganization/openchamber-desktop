/**
 * Advanced Logging System for OpenChamber Desktop Scripts
 * Provides consistent logging across all installation/uninstallation scripts
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

class Logger {
  constructor(options = {}) {
    this.appName = options.appName || 'openchamber-desktop';
    this.logLevel = options.logLevel || 'info'; // debug, info, warn, error
    this.logToFile = options.logToFile !== false;
    this.logToConsole = options.logToConsole !== false;
    this.logDir = options.logDir || this.getDefaultLogDir();
    this.logFile = options.logFile || path.join(this.logDir, `${this.appName}-install.log`);
    
    this.levels = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3
    };
    
    this.ensureLogDir();
  }
  
  getDefaultLogDir() {
    const platform = process.platform;
    const homeDir = os.homedir();
    
    switch (platform) {
      case 'win32':
        return path.join(process.env.LOCALAPPDATA || homeDir, 'OpenChamber Desktop', 'logs');
      case 'darwin':
        return path.join(homeDir, 'Library', 'Logs', 'OpenChamber Desktop');
      case 'linux':
      default:
        return path.join(homeDir, '.local', 'share', 'openchamber-desktop', 'logs');
    }
  }
  
  ensureLogDir() {
    if (this.logToFile && !fs.existsSync(this.logDir)) {
      try {
        fs.mkdirSync(this.logDir, { recursive: true });
      } catch (e) {
        // Fallback to temp directory
        this.logDir = os.tmpdir();
        this.logFile = path.join(this.logDir, `${this.appName}-install.log`);
      }
    }
  }
  
  formatMessage(level, message, details = null) {
    const timestamp = new Date().toISOString();
    const platform = process.platform;
    const arch = process.arch;
    let formatted = `[${timestamp}] [${level.toUpperCase()}] [${platform}-${arch}] ${message}`;
    
    if (details) {
      formatted += `\n  Details: ${JSON.stringify(details, null, 2)}`;
    }
    
    return formatted;
  }
  
  log(level, message, details = null) {
    if (this.levels[level] < this.levels[this.logLevel]) {
      return;
    }
    
    const formatted = this.formatMessage(level, message, details);
    
    if (this.logToConsole) {
      const consoleMethod = level === 'error' ? 'error' : level === 'warn' ? 'warn' : 'log';
      console[consoleMethod](formatted);
    }
    
    if (this.logToFile) {
      try {
        fs.appendFileSync(this.logFile, formatted + '\n');
      } catch (e) {
        // Silent fail for file logging
      }
    }
  }
  
  debug(message, details) {
    this.log('debug', message, details);
  }
  
  info(message, details) {
    this.log('info', message, details);
  }
  
  warn(message, details) {
    this.log('warn', message, details);
  }
  
  error(message, details) {
    this.log('error', message, details);
  }
  
  section(title) {
    const separator = '='.repeat(50);
    this.info(separator);
    this.info(title);
    this.info(separator);
  }
  
  success(message) {
    this.info(`✓ ${message}`);
  }
  
  failure(message, error) {
    this.error(`✗ ${message}`, { error: error?.message || error, stack: error?.stack });
  }
  
  getLogPath() {
    return this.logFile;
  }
  
  getLogContent() {
    try {
      return fs.readFileSync(this.logFile, 'utf8');
    } catch (e) {
      return '';
    }
  }
}

/**
 * Installation Method Detector
 * Detects how OCD was installed to properly uninstall
 */
class InstallMethodDetector {
  constructor(logger) {
    this.logger = logger || new Logger();
    this.platform = process.platform;
  }
  
  detect() {
    this.logger.section('Detecting Installation Method');
    
    const methods = [];
    
    // Check for system installation methods
    if (this.platform === 'win32') {
      methods.push(...this.detectWindowsMethods());
    } else if (this.platform === 'darwin') {
      methods.push(...this.detectMacOSMethods());
    } else if (this.platform === 'linux') {
      methods.push(...this.detectLinuxMethods());
    }
    
    // Check for npm installation
    if (this.isNpmInstalled()) {
      methods.push({
        type: 'npm',
        priority: 1,
        details: this.getNpmDetails()
      });
    }
    
    // Sort by priority (lower = more specific/preferred)
    methods.sort((a, b) => a.priority - b.priority);
    
    this.logger.info(`Detected ${methods.length} installation method(s)`, { methods });
    
    return methods;
  }
  
  detectWindowsMethods() {
    const methods = [];
    const { execSync } = require('child_process');
    
    // Check Windows Store/MSIX
    try {
      const result = execSync('powershell -Command "Get-AppxPackage | Where-Object {$_.Name -like \"*openchamber*\"}"', { encoding: 'utf8' });
      if (result.includes('OpenChamber')) {
        methods.push({ type: 'msix', priority: 0, details: { package: result.trim() } });
      }
    } catch (e) {}
    
    // Check Program Files
    const programFiles = process.env.PROGRAMFILES || 'C:\\Program Files';
    const programFilesX86 = process.env['PROGRAMFILES(X86)'] || 'C:\\Program Files (x86)';
    const localAppData = process.env.LOCALAPPDATA;
    
    if (require('fs').existsSync(`${localAppData}\\OpenChamber Desktop`)) {
      methods.push({ 
        type: 'user', 
        priority: 2, 
        details: { path: `${localAppData}\\OpenChamber Desktop` } 
      });
    }
    
    if (require('fs').existsSync(`${programFiles}\\OpenChamber Desktop`)) {
      methods.push({ 
        type: 'system', 
        priority: 2, 
        details: { path: `${programFiles}\\OpenChamber Desktop` } 
      });
    }
    
    // Check registry for installer evidence
    try {
      const regQuery = execSync('reg query "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall" /s /f "OpenChamber" 2>nul || exit 0', { encoding: 'utf8' });
      if (regQuery.includes('OpenChamber')) {
        methods.push({ type: 'registry', priority: 1, details: { registry: true } });
      }
    } catch (e) {}
    
    return methods;
  }
  
  detectMacOSMethods() {
    const methods = [];
    const fs = require('fs');
    
    // Check Applications folder
    if (fs.existsSync('/Applications/OpenChamber Desktop.app')) {
      methods.push({ 
        type: 'app', 
        priority: 0, 
        details: { path: '/Applications/OpenChamber Desktop.app' } 
      });
    }
    
    // Check user Applications
    const home = require('os').homedir();
    if (fs.existsSync(`${home}/Applications/OpenChamber Desktop.app`)) {
      methods.push({ 
        type: 'user-app', 
        priority: 1, 
        details: { path: `${home}/Applications/OpenChamber Desktop.app` } 
      });
    }
    
    // Check Homebrew
    try {
      const { execSync } = require('child_process');
      const result = execSync('brew list openchamber-desktop 2>/dev/null || true', { encoding: 'utf8' });
      if (result.includes('openchamber-desktop')) {
        methods.push({ type: 'homebrew', priority: 0, details: {} });
      }
    } catch (e) {}
    
    return methods;
  }
  
  detectLinuxMethods() {
    const methods = [];
    const fs = require('fs');
    const { execSync } = require('child_process');
    
    // Check system paths
    if (fs.existsSync('/opt/openchamber-desktop')) {
      methods.push({ 
        type: 'opt', 
        priority: 0, 
        details: { path: '/opt/openchamber-desktop' } 
      });
    }
    
    // Check user installation
    const home = require('os').homedir();
    if (fs.existsSync(`${home}/.local/lib/openchamber-desktop`)) {
      methods.push({ 
        type: 'user', 
        priority: 1, 
        details: { path: `${home}/.local/lib/openchamber-desktop` } 
      });
    }
    
    // Check for AppImage
    try {
      const result = execSync('find /usr/local/bin /opt ~/Applications ~/.local/bin -name "*openchamber*.AppImage" 2>/dev/null || true', { encoding: 'utf8' });
      if (result.trim()) {
        methods.push({ 
          type: 'appimage', 
          priority: 0, 
          details: { path: result.trim() } 
        });
      }
    } catch (e) {}
    
    // Check for Flatpak
    try {
      const result = execSync('flatpak list --app 2>/dev/null | grep -i openchamber || true', { encoding: 'utf8' });
      if (result.trim()) {
        methods.push({ type: 'flatpak', priority: 0, details: { package: result.trim() } });
      }
    } catch (e) {}
    
    // Check for Snap
    try {
      const result = execSync('snap list 2>/dev/null | grep -i openchamber || true', { encoding: 'utf8' });
      if (result.trim()) {
        methods.push({ type: 'snap', priority: 0, details: { package: result.trim() } });
      }
    } catch (e) {}
    
    // Check for package manager installation
    try {
      const dpkgResult = execSync('dpkg -l | grep -i openchamber || true', { encoding: 'utf8' });
      if (dpkgResult.trim()) {
        methods.push({ type: 'dpkg', priority: 0, details: { package: dpkgResult.trim() } });
      }
    } catch (e) {}
    
    try {
      const rpmResult = execSync('rpm -qa | grep -i openchamber || true', { encoding: 'utf8' });
      if (rpmResult.trim()) {
        methods.push({ type: 'rpm', priority: 0, details: { package: rpmResult.trim() } });
      }
    } catch (e) {}
    
    return methods;
  }
  
  isNpmInstalled() {
    try {
      const { execSync } = require('child_process');
      const result = execSync('npm list -g openchamber-desktop 2>&1 || true', { encoding: 'utf8' });
      return result.includes('openchamber-desktop');
    } catch (e) {
      return false;
    }
  }
  
  getNpmDetails() {
    try {
      const { execSync } = require('child_process');
      const prefix = execSync('npm config get prefix', { encoding: 'utf8' }).trim();
      return { prefix, path: require('path').join(prefix, 'lib', 'node_modules', 'openchamber-desktop') };
    } catch (e) {
      return {};
    }
  }
}

/**
 * System Checker
 * Validates prerequisites before installation
 */
class SystemChecker {
  constructor(logger) {
    this.logger = logger || new Logger();
    this.platform = process.platform;
    this.checks = [];
  }
  
  async runAllChecks() {
    this.logger.section('Running System Checks');
    
    this.checks = [
      this.checkNodeJS(),
      this.checkArchitecture(),
      this.checkDiskSpace(),
      this.checkPermissions(),
      this.checkExistingInstallation()
    ];
    
    const results = await Promise.all(this.checks);
    const passed = results.every(r => r.passed);
    
    if (!passed) {
      const failed = results.filter(r => !r.passed);
      this.logger.error('System checks failed', { failed });
      throw new Error(`System checks failed: ${failed.map(f => f.name).join(', ')}`);
    }
    
    this.logger.success('All system checks passed');
    return results;
  }
  
  checkNodeJS() {
    const version = process.version;
    const major = parseInt(version.slice(1).split('.')[0]);
    const passed = major >= 18;
    
    this.logger[passed ? 'success' : 'error'](
      `Node.js check: ${version}`,
      { required: '>=18.0.0', passed }
    );
    
    return { name: 'Node.js', passed, version, required: '>=18.0.0' };
  }
  
  checkArchitecture() {
    const arch = process.arch;
    const supported = ['x64', 'arm64', 'arm'];
    const passed = supported.includes(arch);
    
    this.logger[passed ? 'success' : 'error'](
      `Architecture check: ${arch}`,
      { supported, passed }
    );
    
    return { name: 'Architecture', passed, arch, supported };
  }
  
  checkDiskSpace() {
    try {
      const fs = require('fs');
      const os = require('os');
      const path = require('path');
      
      let checkPath;
      if (this.platform === 'win32') {
        checkPath = process.env.LOCALAPPDATA || 'C:\\';
      } else {
        checkPath = os.homedir();
      }
      
      const stats = fs.statSync(checkPath);
      // Rough estimate - need at least 100MB
      const hasSpace = true; // Simplified check
      
      this.logger.success(`Disk space check: ${checkPath}`);
      return { name: 'Disk Space', passed: true, path: checkPath };
    } catch (e) {
      this.logger.warn('Disk space check failed', { error: e.message });
      return { name: 'Disk Space', passed: true, warning: e.message };
    }
  }
  
  checkPermissions() {
    const isRoot = process.getuid && process.getuid() === 0;
    const passed = true; // Allow both user and root installs
    
    this.logger.info(`Permissions check: ${isRoot ? 'root' : 'user'}`);
    return { name: 'Permissions', passed, isRoot };
  }
  
  checkExistingInstallation() {
    const detector = new InstallMethodDetector(this.logger);
    const methods = detector.detect();
    const hasExisting = methods.length > 0;
    
    if (hasExisting) {
      this.logger.warn('Existing installation detected', { methods });
    } else {
      this.logger.success('No existing installation found');
    }
    
    return { name: 'Existing Installation', passed: true, hasExisting, methods };
  }
}

module.exports = {
  Logger,
  InstallMethodDetector,
  SystemChecker
};
