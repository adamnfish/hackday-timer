# Hackday Timer

An Elm application built with Parcel and tested with Playwright.

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
- ✅ Page title is correct
- ✅ "Hello World!" heading is visible with correct styling
- ✅ Welcome message with emoji is displayed
- ✅ CSS flex layout is properly applied
- ✅ Visual regression testing with screenshots

## Tools

This project uses:
- **elm**: The Elm compiler
- **elm-json**: Manage Elm dependencies
- **elm-test**: Run Elm tests
- **elm-review**: Lint Elm code
- **Parcel**: Zero-config bundler with Elm support
- **Playwright**: End-to-end testing framework
