import {test,expect} from '@playwright/test';
test('Prometheus targets and Grafana application dashboard',async({page,request})=>{
  const targets=await request.get('http://127.0.0.1:9090/api/v1/targets');
  const payload=await targets.json();
  const appTargets=payload.data.activeTargets.filter(t=>t.labels.namespace==='kitledger');
  expect(appTargets.length).toBeGreaterThanOrEqual(2);
  expect(appTargets.every(t=>t.health==='up')).toBeTruthy();
  await page.goto('http://127.0.0.1:9090/targets');
  await page.screenshot({path:'../../evidence/observability/prometheus-targets.png',fullPage:true});
  await page.goto('http://127.0.0.1:3001/login');
  await page.getByRole('textbox',{name:/email or username/i}).fill('admin');
  await page.getByLabel('Password',{exact:true}).fill(process.env.GRAFANA_PASSWORD);
  await page.getByRole('button',{name:/log in/i}).click();
  await page.goto('http://127.0.0.1:3001/d/kitledger');
  await expect(page.getByText('Requests served',{exact:true})).toBeVisible({timeout:30000});
  await expect(page.getByText('Requests by route',{exact:true})).toBeVisible();
  await expect(page.getByText('No data',{exact:true})).toHaveCount(0,{timeout:30000});
  await page.screenshot({path:'../../evidence/observability/grafana-dashboard.png',fullPage:true});
});
