#!/usr/bin/env node

/**
 * Installation Tests for OpenChamber Desktop
 * Validates installation integrity across all platforms
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

const { Logger, InstallMethodDetector, SystemChecker } = require('../lib/logger');

class InstallationTests {
  constructor() {
    this.logger = new Logger({ 
      appName: 'openchamber-desktop-tests',
      logLevel: 'info'
    });
    this.platform = process.platform;
    this.results = [];
  }

  async runAllTests() {
    this.logger.section('OpenChamber Desktop Installation Tests');
    
    const tests = [
      { name: 'System Prerequisites', fn: () => this.testSystemPrerequisites() },
      { name: 'Source Files Integrity', fn: () => this.testSourceFiles() },
      { name: 'Logger System', fn: () => this.testLogger() },
      { name: 'Install Method Detection', fn: () => this.testInstallMethodDetection() },
      { name: 'Binary Compatibility', fn: () => this.testBinaryCompatibility() },
      { name: 'Configuration Files', fn: () => this.testConfigurationFiles() },
      { name: 'Resource Files', fn: () => this.testResourceFiles() }
    ];
    
    for (const test of tests) {
      try {
        this.logger.info(`Running: ${test.name}`);
        const result = await test.fn();
        this.results.push({ name: test.name, passed: result.passed, error: result.error });
        
        if (result.passed) {
          this.logger.success(`${test.name}: PASSED`);
        } else {
          this.logger.error(`${test.name}: FAILED`, { error: result.error });
        }
      } catch (e) {
        this.results.push({ name: test.name, passed: false, error: e.message });
        this.logger.error(`${test.name}: ERROR`, { error: e.message });
      }
    }
    
    this.printSummary();
    return this.results.every(r => r.passed);
  }

  async testSystemPrerequisites() {
    const checker = new SystemChecker(this.logger);
    
    try {
      const results = await checker.runAllChecks();
      const allPassed = results.every(r => r.passed);
      
      return {
        passed: allPassed,
        details: results
      };
    } catch (e) {
      return {
        passed: false,
        error: e.message
      };
    }
  }

  async testSourceFiles() {
    const requiredFiles = [
      'bin/cli.js',
      'package.json',
      'neutralino.config.json',
      'resources/index.html',
      'resources/js/main.js',
      'resources/js/neutralino.js',
      'resources/styles/main.css',
      'scripts/lib/logger.js',
      'scripts/install/install.js',
      'scripts/uninstall/uninstall.js'
    ];
    
    const rootDir = path.join(__dirname, '..', '..');
    const missing = [];
    
    for (const file of requiredFiles) {
      const fullPath = path.join(rootDir, file);
      if (!fs.existsSync(fullPath)) {
        missing.push(file);
      }
    }
    
    return {
      passed: missing.length === 0,
      error: missing.length > 0 ? `Missing files: ${missing.join(', ')}` : null,
      details: { checked: requiredFiles.length, missing }
    };
  }

  async testLogger() {
    try {
      const testLogger = new Logger({
        appName: 'test-logger',
        logLevel: 'debug',
        logToFile: true,
        logToConsole: false
      });
      
      // Test all log levels
      testLogger.debug('Debug message');
      testLogger.info('Info message');
      testLogger.warn('Warning message');
      testLogger.error('Error message');
      testLogger.section('Test Section');
      testLogger.success('Success message');
      
      // Verify log file was created
      const logPath = testLogger.getLogPath();
      const logContent = testLogger.getLogContent();
      
      const hasAllLevels = 
        logContent.includes('DEBUG') &&
        logContent.includes('INFO') &&
        logContent.includes('WARN') &&
        logContent.includes('ERROR');
      
      return {
        passed: hasAllLevels,
        error: hasAllLevels ? null : 'Not all log levels found in log file',
        details: { logPath, hasAllLevels }
      };
    } catch (e) {
      return {
        passed: false,
        error: e.message
      };
    }
  }

  async testInstallMethodDetection() {
    try {
      const detector = new InstallMethodDetector(this.logger);
      const methods = detector.detect();
      
      // Should return an array (may be empty if not installed)
      const isValid = Array.isArray(methods);
      
      return {
        passed: isValid,
        error: isValid ? null : 'Detection did not return an array',
        details: { methodsFound: methods.length, methods }
      };
    } catch (e) {
      return {
        passed: false,
        error: e.message
      };
    }
  }

  async testBinaryCompatibility() {
    const binDir = path.join(__dirname, '..', '..', 'bin');
    const expectedBinaries = {
      'linux': ['neutralino-linux_x64', 'neutralino-linux_arm64', 'neutralino-linux_armhf'],
      'darwin': ['neutralino-mac_x64', 'neutralino-mac_arm64'],
      'win32': ['neutralino-win_x64.exe']
    };
    
    const platformBins = expectedBinaries[this.platform];
    if (!platformBins) {
      return {
        passed: false,
        error: `Unsupported platform: ${this.platform}`
      };
    }
    
    const found = [];
    const missing = [];
    
    for (const bin of platformBins) {
      const binPath = path.join(binDir, bin);
      if (fs.existsSync(binPath)) {
        found.push(bin);
        
        // Check if executable (Unix only)
        if (this.platform !== 'win32') {
          try {
            const stats = fs.statSync(binPath);
            const isExecutable = (stats.mode & 0o111) !== 0;
            if (!isExecutable) {
              missing.push(`${bin} (not executable)`);
            }
          } catch (e) {
            missing.push(`${bin} (cannot stat)`);
          }
        }
      } else {
        missing.push(bin);
      }
    }
    
    // At least one binary for the current arch should exist
    const hasCompatibleBinary = found.length > 0;
    
    return {
      passed: hasCompatibleBinary,
      error: hasCompatibleBinary ? null : `Missing binaries: ${missing.join(', ')}`,
      details: { found, missing, platform: this.platform, arch: process.arch }
    };
  }

  async testConfigurationFiles() {
    const rootDir = path.join(__dirname, '..', '..');
    const errors = [];
    
    // Test package.json
    try {
      const packagePath = path.join(rootDir, 'package.json');
      const packageContent = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      
      if (!packageContent.name) errors.push('package.json missing name');
      if (!packageContent.version) errors.push('package.json missing version');
      if (!packageContent.bin) errors.push('package.json missing bin entries');
    } catch (e) {
      errors.push(`package.json parse error: ${e.message}`);
    }
    
    // Test neutralino.config.json
    try {
      const configPath = path.join(rootDir, 'neutralino.config.json');
      const configContent = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      
      if (!configContent.applicationId) errors.push('neutralino.config.json missing applicationId');
      if (!configContent.version) errors.push('neutralino.config.json missing version');
      if (!configContent.modes?.window) errors.push('neutralino.config.json missing window mode');
    } catch (e) {
      errors.push(`neutralino.config.json parse error: ${e.message}`);
    }
    
    return {
      passed: errors.length === 0,
      error: errors.length > 0 ? errors.join('; ') : null,
      details: { errors }
    };
  }

  async testResourceFiles() {
    const rootDir = path.join(__dirname, '..', '..');
    const requiredResources = [
      'resources/index.html',
      'resources/js/main.js',
      'resources/js/neutralino.js',
      'resources/styles/main.css'
    ];
    
    const missing = [];
    const errors = [];
    
    for (const resource of requiredResources) {
      const fullPath = path.join(rootDir, resource);
      if (!fs.existsSync(fullPath)) {
        missing.push(resource);
      } else {
        // Validate HTML structure
        if (resource.endsWith('.html')) {
          try {
            const content = fs.readFileSync(fullPath, 'utf8');
            if (!content.includes('<!DOCTYPE html>')) {
              errors.push(`${resource}: Missing DOCTYPE`);
            }
            if (!content.includes('<html')) {
              errors.push(`${resource}: Missing html tag`);
            }
          } catch (e) {
            errors.push(`${resource}: Read error - ${e.message}`);
          }
        }
        
        // Validate JS syntax (basic check)
        if (resource.endsWith('.js') && !resource.includes('neutralino.js')) {
          try {
            const content = fs.readFileSync(fullPath, 'utf8');
            // Check for basic syntax issues
            const openBraces = (content.match(/{/g) || []).length;
            const closeBraces = (content.match(/}/g) || []).length;
            if (openBraces !== closeBraces) {
              errors.push(`${resource}: Brace mismatch`);
            }
          } catch (e) {
            errors.push(`${resource}: Read error - ${e.message}`);
          }
        }
      }
    }
    
    return {
      passed: missing.length === 0 && errors.length === 0,
      error: missing.length > 0 ? `Missing: ${missing.join(', ')}` : 
             errors.length > 0 ? `Errors: ${errors.join('; ')}` : null,
      details: { missing, errors }
    };
  }

  printSummary() {
    this.logger.section('Test Summary');
    
    const passed = this.results.filter(r => r.passed).length;
    const failed = this.results.filter(r => !r.passed).length;
    
    console.log(`\nTotal: ${this.results.length} tests`);
    console.log(`Passed: ${passed}`);
    console.log(`Failed: ${failed}`);
    
    if (failed > 0) {
      console.log('\nFailed tests:');
      for (const result of this.results.filter(r => !r.passed)) {
        console.log(`  ✗ ${result.name}: ${result.error}`);
      }
    }
    
    console.log(`\nLog file: ${this.logger.getLogPath()}`);
    
    return failed === 0;
  }
}

// Run tests if called directly
if (require.main === module) {
  const tests = new InstallationTests();
  tests.runAllTests().then(success => {
    process.exit(success ? 0 : 1);
  }).catch(err => {
    console.error('Test runner error:', err);
    process.exit(1);
  });
}

module.exports = { InstallationTests };
