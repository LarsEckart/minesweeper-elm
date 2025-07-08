# Minesweeper Elm

[![Netlify Status](https://api.netlify.com/api/v1/badges/3f9f16d5-6d65-4355-9907-655b7b375710/deploy-status)](https://app.netlify.com/projects/minesweepr-elm/deploys)

A modern Minesweeper game built with Elm 0.19, featuring classic gameplay with three difficulty levels, vibrant Sunset color palette, mobile-responsive design, and leaderboard with localStorage persistence.

**🌐 Play Online**: https://minesweepr-elm.netlify.app/

## Features

- **Classic Minesweeper gameplay** with left-click to reveal and right-click to flag
- **Three difficulty levels**: Beginner, Intermediate, and Expert
- **Vibrant Sunset color palette** for a modern, appealing look
- **Mobile-responsive design** that works on all devices
- **Leaderboard system** with localStorage persistence
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
./scripts/check.sh

# Format code
elm-format src/ --yes

# Run tests
elm-test
```

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
