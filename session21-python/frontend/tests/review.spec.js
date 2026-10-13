import {test, expect} from '@playwright/test';

// Controlled network fixtures test UI races, not database persistence.
const asset = {id: 1, asset_tag: 'REVIEW-1', name: 'Review camera', category: 'Camera',
  condition: 'ready', notes: '', version: 1, available: true};
const summary = {total: 1, available: 1, on_loan: 0, overdue: 0, maintenance: 0};

test.beforeEach(async ({page}) => {
  await page.route('**/api/**', route => {
    const path = new URL(route.request().url()).pathname;
    return route.fulfill({json: path === '/api/equipment' ? [asset]
      : path === '/api/summary' ? summary : []});
  });
});

test('a delayed older refresh cannot replace newer ledger data', async ({page}) => {
  // Deliberately ignore AbortSignal to verify the generation guard as well.
  await page.addInitScript(({asset, summary}) => {
    let calls = 0;
    window.fetch = async path => {
      if (path === '/api/equipment') {
        calls++;
        if (calls === 1) return new Promise(resolve => {
          window.releaseOlder = () => resolve(Response.json([{...asset, name: 'Old response'}]));
        });
        return Response.json([{...asset, name: 'New response'}]);
      }
      return Response.json(path === '/api/summary' ? summary : []);
    };
  }, {asset, summary});
  await page.goto('/');
  await expect.poll(() => page.evaluate(() => typeof window.releaseOlder)).toBe('function');
  await page.getByRole('button', {name: 'Refresh ledger'}).click();
  await expect(page.getByText('New response', {exact: true})).toBeVisible();
  await page.evaluate(async () => {
    window.releaseOlder();
    await new Promise(resolve => setTimeout(resolve, 100));
  });
  await expect(page.getByText('New response', {exact: true})).toBeVisible();
  await expect(page.getByText('Old response', {exact: true})).toHaveCount(0);
});

test('two submit events send only one mutation', async ({page}) => {
  let mutations = 0, release;
  await page.route('**/api/equipment/1', async route => {
    mutations++;
    await new Promise(resolve => {release = resolve;});
    await route.fulfill({json: {...asset, version: 2}});
  });
  await page.goto('/');
  await page.getByRole('button', {name: 'Edit Review camera', exact: true}).click();
  await page.getByLabel('Equipment name', {exact: true}).fill('Edited camera');
  await page.locator('form').evaluate(form => {form.requestSubmit(); form.requestSubmit();});
  await expect.poll(() => mutations).toBe(1);
  release();
  await expect(page.getByRole('dialog')).toHaveCount(0);
  expect(mutations).toBe(1);
});

test('dialog traps keyboard focus and restores the opener', async ({page}) => {
  await page.goto('/');
  const opener = page.getByRole('button', {name: 'Edit Review camera', exact: true});
  await opener.click();
  const dialog = page.getByRole('dialog');
  await expect(page.getByLabel('Asset tag', {exact: true})).toBeFocused();
  await dialog.getByRole('button', {name: 'Save equipment', exact: true}).focus();
  await page.keyboard.press('Tab');
  await expect(dialog.getByRole('button', {name: 'Close dialog'})).toBeFocused();
  await page.keyboard.press('Shift+Tab');
  await expect(dialog.getByRole('button', {name: 'Save equipment', exact: true})).toBeFocused();
  await page.keyboard.press('Escape');
  await expect(dialog).toHaveCount(0);
  await expect(opener).toBeFocused();
});

test('stale edit keeps user input and reports the conflict', async ({page}) => {
  await page.route('**/api/equipment/1', async route => {
    expect(route.request().postDataJSON().version).toBe(1);
    await route.fulfill({status: 409, json: {detail: 'Equipment changed; refresh before retrying'}});
  });
  await page.goto('/');
  await page.getByRole('button', {name: 'Edit Review camera', exact: true}).click();
  await page.getByLabel('Equipment name', {exact: true}).fill('Unsaved user input');
  await page.getByRole('button', {name: 'Save equipment', exact: true}).click();
  await expect(page.getByRole('alert')).toContainText('refresh before retrying');
  await expect(page.getByLabel('Equipment name', {exact: true})).toHaveValue('Unsaved user input');
});

test('failed refresh reports an error and retry recovers', async ({page}) => {
  let calls = 0;
  await page.route('**/api/equipment', route => {
    calls++;
    return calls === 1 ? route.fulfill({status: 503, body: 'Unavailable'})
      : route.fulfill({json: [asset]});
  });
  await page.goto('/');
  await expect(page.getByRole('alert')).toContainText('Server request failed');
  await page.getByRole('button', {name: 'Try again', exact: true}).click();
  await expect(page.getByText('Review camera', {exact: true})).toBeVisible();
  await expect(page.getByRole('alert')).toHaveCount(0);
});

test('network failure during mutation warns about its unknown outcome', async ({page}) => {
  await page.route('**/api/equipment/1', route => route.abort('failed'));
  await page.goto('/');
  await page.getByRole('button', {name: 'Edit Review camera', exact: true}).click();
  await page.getByRole('button', {name: 'Save equipment', exact: true}).click();
  await expect(page.getByRole('alert')).toContainText('Request outcome unknown');
  await expect(page.getByRole('alert')).toContainText('refresh the ledger before retrying');
});
