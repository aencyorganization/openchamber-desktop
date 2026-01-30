# Contributing to OpenChamber Launcher

Thank you for your interest in contributing to OpenChamber Launcher! We welcome contributions from the community.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear title and description
- Steps to reproduce the bug
- Expected vs actual behavior
- Your operating system and version
- Screenshots if applicable

### Suggesting Features

We welcome feature suggestions! Please open an issue with:
- A clear description of the feature
- Why it would be useful
- Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/openchamber-desktop.git
cd openchamber-desktop

# Install dependencies
bun install

# Run in development mode
bun run dev

# Build for production
bun run build:release
```

### Code Style

- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Follow the existing code structure

### Testing

- Test on multiple platforms if possible (Linux, macOS, Windows)
- Ensure the app starts correctly
- Verify that OpenChamber detection works
- Test the cleanup process on exit

## Questions?

Feel free to open an issue for any questions you may have.

Thank you for contributing! 🚀
