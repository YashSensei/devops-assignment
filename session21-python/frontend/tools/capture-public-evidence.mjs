// Fresh, unauthenticated browser; never reads the user's Chrome profile.
import {chromium} from '@playwright/test';
import {mkdir, writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';

const destination = resolve('../../evidence/github');
await mkdir(destination, {recursive: true});
const browser = await chromium.launch({channel: 'chrome', headless: true});
const context = await browser.newContext({viewport: {width: 1440, height: 1050}});
const pages = [
  ['green-run', 'https://github.com/YashSensei/devops-assignment/actions/runs/38450469520'],
  ['backend-package', 'https://github.com/users/YashSensei/packages/container/package/kitledger-backend'],
  ['frontend-package', 'https://github.com/users/YashSensei/packages/container/package/kitledger-frontend'],
  ['commit-history', 'https://github.com/YashSensei/devops-assignment/commits/main/'],
];
const observations = [];
try {
  for (const [name, url] of pages) {
    const page = await context.newPage();
    const response = await page.goto(url, {waitUntil: 'networkidle', timeout: 60000});
    if (response.status() !== 200) throw new Error(`${name}: HTTP ${response.status()}`);
    const body = await page.locator('body').innerText();
    console.log(`${name}: ${body.slice(-3000)}`);
    await page.screenshot({path: `${destination}/${name}.png`, fullPage: true});
    observations.push({name, url: page.url(), captured_at: new Date().toISOString(), status: response.status(), body});
    await page.close();
  }
  await writeFile(`${destination}/observations.json`, JSON.stringify({browser: 'automated isolated Chrome, unauthenticated', observations}, null, 2) + '\n');
} finally {
  await context.close();
  await browser.close();
}
