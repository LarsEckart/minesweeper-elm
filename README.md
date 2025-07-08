# Minesweeper Elm

[![Netlify Status](https://api.netlify.com/api/v1/badges/3f9f16d5-6d65-4355-9907-655b7b375710/deploy-status)](https://app.netlify.com/projects/minesweepr-elm/deploys)

A modern Minesweeper game built with Elm 0.19, featuring classic gameplay with three difficulty levels, vibrant Sunset color palette, mobile-responsive design, and leaderboard with localStorage persistence.

**🌐 Play Online**: https://minesweepr-elm.netlify.app/

## Features

- **Classic Minesweeper gameplay** with left-click to reveal and right-click to flag
- **Three difficulty levels**: Beginner (9x9, 10 mines), Intermediate (12x12, 25 mines), and Expert (15x15, 50 mines)
- **Vibrant Sunset color palette** for a modern, appealing look
- **Mobile-responsive design** that works on all devices
- **Leaderboard system** with localStorage persistence
- **Deterministic seed support** for testing with URL parameter `?seed=123`
- **Comprehensive testing** and CI/CD pipeline

## Development

### Prerequisites

- Elm 0.19.1
- Node.js (for global tools)

### Setup

```bash
# Clone the repository
git clone https://github.com/LarsEckart/minesweeper-elm.git
cd minesweeper-elm

# Install global dependencies
npm install -g elm-format elm-test

# Build the project
./build_project.sh
```

### Development Commands

```bash
# Build the project
./build_project.sh

# Run tests, formatting, and linting
./check.sh

# Format code
elm-format src/ --yes

# Run tests
elm-test
```

### Testing with Seeds

For deterministic testing, you can use the seed parameter:

```bash
# Open the built game with a specific seed
open dist/index.html?seed=123

# Or in your browser:
# file:///path/to/minesweeper-elm/dist/index.html?seed=123
```

The seed parameter allows you to:
- Generate the same board layout every time
- Test specific scenarios consistently
- Debug issues with reproducible board states
- Compare game outcomes across different runs

Seeds are integers (e.g., 123, 999, 42) and are hidden from the UI for clean gameplay.

### Project Structure

```
├── src/           # Source code
│   ├── Main.elm   # Main application entry point
│   └── Types.elm  # Type definitions
├── tests/         # Test files
├── scripts/       # Build and development scripts
├── dist/          # Built output
└── elm.json       # Elm configuration
```

## Deployment

The project is automatically deployed to Netlify on pushes to the main branch.

## Contributing

1. Create a branch for your feature
2. Implement your changes and write tests
3. Run `./scripts/check.sh` to verify everything passes
4. Commit your changes with a descriptive message
5. Push your branch and create a pull request

## License

MIT License
