import { test, expect } from '@playwright/test';
import lighthouse from 'lighthouse';
import chromeLauncher from 'chrome-launcher';

test.describe('Performance testing', () => {
    test('lighthouse performance audit', async () => {
        const chrome = await chromeLauncher.launch({chromeFlags: ['--headless']});
        const options = {
            logLevel: 'info',
            output: 'json',
            port: chrome.port,
            onlyCategories: ['performance']
        };

        const runnerResult = await lighthouse('http://localhost:8888', options);
        const performanceScore = runnerResult.lhr.categories.performance.score * 100;

        await chrome.kill();

        // Performance thresholds
        expect(performanceScore).toBeGreaterThan(90);
        expect(runnerResult.lhr.audits['first-contentful-paint'].numericValue).toBeLessThan(1000);
        expect(runnerResult.lhr.audits['interactive'].numericValue).toBeLessThan(3500);
        expect(runnerResult.lhr.audits['speed-index'].numericValue).toBeLessThan(2000);
    });

    test('resource loading', async ({ page }) => {
        const [response] = await Promise.all([
            page.goto('http://localhost:8888'),
            page.waitForLoadState('networkidle')
        ]);

        // Check response times
        const timing = JSON.parse(await response.headerValue('server-timing') || '{}');
        expect(timing.total).toBeLessThan(1000);

        // Check resource counts
        const resources = await page.evaluate(() => 
            performance.getEntriesByType('resource').map(r => ({
                name: r.name,
                duration: r.duration,
                size: r.transferSize
            }))
        );

        expect(resources.filter(r => r.name.endsWith('.js')).length).toBeLessThan(10);
        expect(resources.filter(r => r.name.endsWith('.css')).length).toBeLessThan(5);
    });
}); 