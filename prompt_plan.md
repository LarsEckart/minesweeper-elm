I'll create a detailed blueprint and break it down into small, iterative chunks that build on each other. Let me work through this systematically.

## High-Level Blueprint

### Phase 1: Foundation
1. Project setup with Elm 0.19, basic tooling, and CI
2. Core type definitions and module structure
3. Minimal UI with a single clickable cell

### Phase 2: Basic Game Loop
1. Grid generation and display
2. Mine placement logic
3. Cell revealing mechanics
4. Win/loss detection

### Phase 3: Game Features
1. Flag placement
2. Flood-fill algorithm
3. Timer functionality
4. Reset button

### Phase 4: UI Polish
1. Difficulty selection
2. Responsive design
3. Visual styling with Vibrant Sunset palette
4. Header bar with counters

### Phase 5: Persistence & Final Features
1. LocalStorage integration
2. Leaderboard modal
3. Win dialog
4. Seeded board support

Now let me break this down into smaller, iterative chunks:

## First Iteration - Chunks

1. **Setup & Hello World**
   - Initialize Elm project
   - Create basic module structure
   - Display "Hello Minesweeper"
   - Setup build scripts

2. **Basic Grid Display**
   - Define Cell and Board types
   - Generate static 9x9 grid
   - Display grid with basic styling
   - Make cells clickable (just log clicks)

3. **Mine Placement**
   - Add mine placement logic
   - Ensure first click safety
   - Display mines (for testing)
   - Add tests for mine placement

4. **Cell Revealing**
   - Implement reveal logic
   - Show numbers for adjacent mines
   - Add basic win/loss detection
   - Update UI to show game state

5. **Flood Fill**
   - Implement flood-fill for zero cells
   - Add comprehensive tests
   - Ensure first click triggers flood-fill

6. **Flagging**
   - Add right-click flagging
   - Update mine counter
   - Add long-press for mobile
   - Test flag toggle behavior

7. **Timer & Reset**
   - Add timer that starts on first reveal
   - Add reset button with emoji states
   - Stop timer on win/loss

8. **Styling & Responsive**
   - Apply Vibrant Sunset palette
   - Add number colors
   - Make grid responsive
   - Style header bar

9. **Difficulty & Modals**
   - Add difficulty selection modal
   - Implement all three grid sizes
   - Add win dialog
   - Add localStorage ports

10. **Leaderboard & Polish**
    - Implement leaderboard modal
    - Add seed support
    - Final testing and deployment

Let me refine these chunks one more time to ensure they're the right size:

## Final Task Breakdown

### Task 1: Project Setup & Basic Structure ✅
- [x] Initialize Elm 0.19 project with elm.json (already done)
- [x] Create folder structure: src/, tests/, scripts/, dist/
- [x] Create Main.elm with basic Browser.element program
- [x] Create Types.elm with initial type definitions (Cell, Board, Model, Msg)
- [x] Create scripts/check.sh for linting/formatting/testing
- [x] Setup .gitignore and README.md
- [x] Display "Minesweeper" heading and verify elm make works
- **Output**: Working Elm app that displays text

### Task 2: Static Grid Display ✅
- [x] Define Cell type with position and basic states (Hidden, Revealed)
- [x] Create Board.elm with empty board generation function
- [x] Create Cell.elm with basic cell view function
- [x] Display 9x9 grid of clickable cells in Main.elm
- [x] Add basic CSS for grid layout (using CSS Grid)
- [x] Add click handler that logs cell position
- [x] Write tests for board generation
- **Output**: Clickable 9x9 grid

### Task 3: Mine Placement Logic ✅
- [x] Add mine field to Cell type
- [x] Implement random mine placement in Board.elm
- [x] Add seed support for deterministic generation
- [x] Ensure correct mine count (10 for 9x9)
- [x] Write comprehensive tests for mine placement
- [x] Display mines temporarily for visual verification
- **Output**: Grid with randomly placed mines

### Task 4: Adjacent Mine Counting ✅
- [x] Add adjacentMines field to Cell type
- [x] Implement mine counting logic in Board.elm
- [x] Update cell view to show numbers when revealed
- [x] Add basic click-to-reveal functionality
- [x] Style numbers with temporary colors
- [x] Write tests for mine counting
- **Output**: Clicking reveals numbers

### Task 5: First Click Safety ✅
- [x] Implement first click detection in Model
- [x] Add logic to regenerate board if first click hits mine
- [x] Ensure first click always reveals a zero cell
- [x] Write tests for first click safety
- **Output**: Safe first click guaranteed

### Task 6: Basic Win/Loss Detection ✅
- [x] Add GameState type (Playing, Won, Lost)
- [x] Implement loss detection when clicking mine
- [x] Implement win detection (all non-mines revealed)
- [x] Show all mines on loss
- [x] Disable further clicks after game ends
- [x] Write tests for win/loss conditions
- **Output**: Playable game with end states

### Task 7: Flood Fill Algorithm ✅
- [x] Implement flood-fill for revealing connected zeros
- [x] Ensure flood-fill triggers on first click
- [x] Add comprehensive tests for edge cases
- [x] Optimize for performance
- **Output**: Zeros auto-reveal neighbors

### Task 8: Flag Functionality ✅
- [x] Add Flagged state to Cell type
- [x] Implement right-click to flag/unflag
- [x] Add mine counter to Model
- [x] Update mine counter on flag/unflag
- [x] Prevent revealing flagged cells
- [x] Write tests for flagging logic
- **Output**: Right-click flagging works

### Task 9: Mobile Flag Support ✅
- [x] Add touch event subscriptions
- [x] Implement long-press detection (500ms)
- [x] Add long-press to flag on mobile
- [x] Test on mobile browser
- **Output**: Long-press flagging on mobile

### Task 10: Timer Implementation ✅
- [x] Create Timer.elm module
- [x] Add timer to Model (seconds elapsed)
- [x] Start timer on first reveal
- [x] Stop timer on win/loss
- [x] Display timer in UI (temporary position)
- [x] Write tests for timer logic
- **Output**: Working game timer

### Task 11: Reset Button ✅
- [x] Add reset button with smiley emoji
- [x] Implement emoji state changes (idle, pressed, win, loss)
- [x] Generate new random board on reset
- [x] Reset timer and mine counter
- [x] Write tests for reset functionality
- **Output**: Functional reset button

### Task 12: Header Bar Layout ✅
- [x] Create header bar with three sections
- [x] Position mine counter (left)
- [x] Position timer (right)
- [x] Position reset button (center)
- [x] Add basic styling
- **Output**: Proper header layout

### Task 13: Vibrant Sunset Styling ✅
- [x] Create Style.elm with color constants
- [x] Apply palette colors to all elements
- [x] Style cells with borders and shadows
- [x] Add hover/active states
- [x] Implement classic number colors
- **Output**: Fully styled game

### Task 14: Responsive Design ✅
- [x] Make grid scale to viewport width
- [x] Adjust cell sizes for mobile
- [x] Ensure header stays visible
- [x] Test on various screen sizes
- [x] Add viewport meta tag
- **Output**: Mobile-responsive game

### Task 15: Difficulty Selection Modal ✅
- [x] Add difficulty type (Beginner, Intermediate, Expert)
- [x] Create landing modal component  
- [x] Show modal on initial load
- [x] Generate appropriate grid size on selection
- [x] Close modal and start game
- [x] Add difficulty button to header for changing difficulty
- **Output**: Difficulty selection works

### Task 16: LocalStorage Ports ✅
- [x] Create ports for localStorage get/set
- [x] Add minimal JavaScript interop code
- [x] Create LeaderBoard.elm module
- [x] Implement best time storage per difficulty
- [x] Write tests for port messages
- **Output**: Best times persist

### Task 17: Win Dialog ✅
- [x] Create win dialog modal
- [x] Show current time vs best time
- [x] Update best time if beaten
- [x] Add "Play Again" button
- [x] Style with theme colors
- **Output**: Win celebration modal

### Task 18: Leaderboard Modal ✅
- [x] Add trophy icon to header
- [x] Create leaderboard modal view
- [x] Display best times by difficulty
- [x] Add "Clear Records" button
- [x] Implement clear functionality
- **Output**: Viewable leaderboard

### Task 19: Final Polish & Testing ✅
- [x] Add seed parameter support (?seed=123)
- [x] Hide seed from UI (testing only)
- [x] Comprehensive end-to-end testing
- [x] Fix any remaining bugs
- [x] Update README with instructions
- **Output**: Production-ready game

### Task 20: CI/CD Setup
- [ ] Create GitHub Actions workflow
- [ ] Configure elm-format validation
- [ ] Configure elm-review linting
- [ ] Configure elm-test execution
- [ ] Setup Netlify deployment
- [ ] Verify automatic deploys
- **Output**: Automated deployment pipeline

## Validation of Task Breakdown

Each task:
- ✓ Builds on previous work
- ✓ Produces testable output
- ✓ Is small enough to implement safely
- ✓ Moves the project forward meaningfully
- ✓ Has no orphaned code
- ✓ Integrates immediately with existing code

The progression ensures:
- Early visual feedback (Task 2)
- Core game loop by Task 6
- Full gameplay by Task 11
- Polish and persistence in final tasks
- No big complexity jumps

This breakdown provides a solid foundation for creating GitHub issues that a code-generation LLM can implement incrementally with strong testing at each step.
