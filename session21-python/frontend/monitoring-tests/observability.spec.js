import {test,expect} from '@playwright/test';
import {writeFile} from 'node:fs/promises';
test('Prometheus targets and Grafana application dashboard',async({page,request})=>{
  const targets=await request.get('http://127.0.0.1:9090/api/v1/targets');
  const payload=await targets.json();
  const appTargets=payload.data.activeTargets.filter(t=>t.labels.namespace==='kitledger');
  expect(appTargets.length).toBeGreaterThanOrEqual(2);
  expect(appTargets.every(t=>t.health==='up')).toBeTruthy();
  await writeFile('../../evidence/observability/browser-verified-targets.json',JSON.stringify(payload,null,2)+'\n');
  await page.goto('http://127.0.0.1:9090/targets');
  await expect(page.getByText(appTargets[0].scrapePool,{exact:false}).first()).toBeVisible({timeout:30000});
  await page.screenshot({path:'../../evidence/observability/prometheus-targets.png',fullPage:true});
  await page.goto('http://127.0.0.1:3001/login');
  await page.getByRole('textbox',{name:/email or username/i}).fill('admin');
  await page.getByLabel('Password',{exact:true}).fill(process.env.GRAFANA_PASSWORD);
  await page.getByRole('button',{name:/log in/i}).click();
  // Login redirects asynchronously; wait for its authenticated destination
  // before starting dashboard navigation (the original run hit ERR_ABORTED).
  await expect(page.getByRole('button',{name:'Profile',exact:true})).toBeVisible({timeout:30000});
  const dashboardQuery=page.waitForResponse(response=>response.url().includes('/api/ds/query') && response.request().method()==='POST');
  await page.goto('http://127.0.0.1:3001/d/kitledger');
  const queryData=await (await dashboardQuery).json();
  expect(Object.values(queryData.results).some(result=>(result.frames||[]).some(frame=>frame.data.values.flat().some(value=>typeof value==='number')))).toBeTruthy();
  await writeFile('../../evidence/observability/grafana-query.json',JSON.stringify(queryData,null,2)+'\n');
  await expect(page.getByText('Requests served',{exact:true})).toBeVisible({timeout:30000});
  await expect(page.getByText('Requests by route',{exact:true})).toBeVisible();
  await expect(page.getByText('No data',{exact:true})).toHaveCount(0,{timeout:30000});
  await page.evaluate(()=>new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve))));
  await page.screenshot({path:'../../evidence/observability/grafana-dashboard.png',fullPage:true});
});
