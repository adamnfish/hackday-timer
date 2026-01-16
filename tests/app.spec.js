import { test, expect } from '@playwright/test';

test.describe('Elm Hello World Application', () => {
  test('should display the hello world page correctly', async ({ page }) => {
    // Navigate to the application
    await page.goto('/');

    // Wait for the page to load
    await page.waitForLoadState('networkidle');

    // Check that the h1 heading is present and has the correct text
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
    await expect(heading).toHaveText('Hello World!');

    // Verify the heading has the correct color style
    await expect(heading).toHaveCSS('color', 'rgb(90, 159, 212)'); // #5A9FD4

    // Check that the paragraph is present and has the correct text
    const paragraph = page.locator('p');
    await expect(paragraph).toBeVisible();
    await expect(paragraph).toContainText('Welcome to Elm with Parcel!');
    await expect(paragraph).toContainText('🚀');

    // Verify the main container (the parent div of both h1 and p) has flex layout
    const container = heading.locator('..'); // Get parent of h1
    await expect(container).toHaveCSS('display', 'flex');
    await expect(container).toHaveCSS('flex-direction', 'column');
    await expect(container).toHaveCSS('align-items', 'center');
    await expect(container).toHaveCSS('justify-content', 'center');
  });

  test('should have the correct page title', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle('Elm Hello World');
  });

  test('should render the Elm application content', async ({ page }) => {
    await page.goto('/');

    // Verify both the heading and paragraph are visible
    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('p')).toBeVisible();

    // Verify they are in the viewport
    await expect(page.locator('h1')).toBeInViewport();
    await expect(page.locator('p')).toBeInViewport();
  });

  test('should take a screenshot for visual verification', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Take a screenshot for visual regression testing
    await expect(page).toHaveScreenshot('hello-world.png', {
      fullPage: true,
    });
  });
});
