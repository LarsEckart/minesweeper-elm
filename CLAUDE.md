# Minesweeper Elm Project - CLAUDE.md

## Project Overview
A modern Minesweeper game built with Elm 0.19

## Development

```bash
# Build the project
./build_project.sh
```

```bash
# Verify tests, formatting and linting
./check.sh
```

### Workflow - Trunk-Based Development

0. Ask which issue on GitHub we shall tackle
1. Read issue on GitHub using GitHub CLI
2. Pull latest changes from main branch
3. Implement changes directly on main, keep commits small and focused
4. Verify continuously: Run `./check.sh` frequently
5. Use Playwright MCP to verify the game also from user's perspective
6. **IMPORTANT**: Bump version in `package.json` when making changes (for PWA cache invalidation)
7. Commit often with small, descriptive commits
8. Push frequently to main branch

**Key Principles:**
- Work directly on main branch
- Keep commits small and atomic
- Push frequently to share progress
- Use feature flags for incomplete features
- Always ensure main is in working state
- Always bump version in `package.json` for changes (enables PWA cache updates)
