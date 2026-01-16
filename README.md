# Hackday Timer

A 2-minute countdown timer built with Elm, bundled with Parcel, and tested with Playwright.

## Features

⏱️ **2 Minute Countdown Timer**
- Displays `2:00` on initial load
- **Start** button begins the countdown
- **Pause** button pauses the timer (changes to "Resume")
- **Resume** button continues counting from where it was paused
- **Reset** button returns timer to 2:00
- Timer automatically stops at `0:00`
- Color-coded states:
  - Gray (#333) - Not started
  - Blue (#5A9FD4) - Running
  - Orange (#FFA500) - Paused
  - Red (#E74C3C) - Finished

## Setup

Install dependencies:
```bash
npm install
```

## Development

Run the development server:
```bash
npm start
```

Then open http://localhost:1234 in your browser.

## Build

Build for production:
```bash
npm run build
```

## Testing

Run end-to-end tests with Playwright:
```bash
npm test              # Run tests in headless mode
npm run test:headed   # Run tests with browser visible
npm run test:ui       # Run tests in interactive UI mode
```

The Playwright tests verify:
- ✅ Initial display shows 2:00
- ✅ Start button begins countdown
- ✅ Pause button stops the timer
- ✅ Resume button continues countdown
- ✅ Reset button returns to 2:00
- ✅ Timer color changes based on state
- ✅ Timer stops at 0:00
- ✅ Correct buttons appear for each state
- ✅ Visual regression testing with screenshots

## Tools

This project uses:
- **elm**: The Elm compiler
- **elm-json**: Manage Elm dependencies
- **elm-test**: Run Elm tests
- **elm-review**: Lint Elm code
- **Parcel**: Zero-config bundler with Elm support
- **Playwright**: End-to-end testing framework
