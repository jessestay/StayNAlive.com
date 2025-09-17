import { test, expect } from '@playwright/test';

test.describe('Performance tests', () => {
    test('page load performance', async ({ page }) => {
        const startTime = Date.now();
        
        await page.goto('http://localhost:8888');
        
        const metrics = await page.evaluate(() => ({
            loadTime: performance.timing.loadEventEnd - performance.timing.navigationStart,
            domContentLoaded: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
            firstPaint: performance.getEntriesByType('paint')[0]?.startTime || 0,
            firstContentfulPaint: performance.getEntriesByType('paint')[1]?.startTime || 0
        }));
        
        expect(metrics.loadTime).toBeLessThan(3000); // 3 seconds max
        expect(metrics.domContentLoaded).toBeLessThan(1500); // 1.5 seconds max
        expect(metrics.firstPaint).toBeLessThan(1000); // 1 second max
        expect(metrics.firstContentfulPaint).toBeLessThan(1500); // 1.5 seconds max
    });
}); 