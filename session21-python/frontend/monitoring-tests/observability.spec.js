import {test,expect} from '@playwright/test';
import {writeFile} from 'node:fs/promises';
test('Prometheus targets and Grafana application dashboard',async({page,request})=>{
  let payload,appTargets;
  await expect.poll(async()=>{
    const targets=await request.get('http://127.0.0.1:9090/api/v1/targets');
    payload=await targets.json();
    appTargets=payload.data.activeTargets.filter(t=>t.labels.namespace==='kitledger');
    await writeFile('../../evidence/observability/browser-verified-targets.json',JSON.stringify(payload,null,2)+'\n');
    return appTargets.length>=2 && appTargets.every(t=>t.health==='up');
  },{timeout:60000,intervals:[2000,5000]}).toBe(true);
  // Target health alone does not prove that application samples are queryable.
  await expect.poll(async()=>{
    const sample=await request.get('http://127.0.0.1:9090/api/v1/query',{params:{query:'sum(kitledger_http_requests_total{namespace="kitledger"})'}});
    const sampleData=await sample.json();
    const allSeries=await request.get('http://127.0.0.1:9090/api/v1/query',{params:{query:'kitledger_http_requests_total'}});
    await writeFile('../../evidence/observability/prometheus-query.json',JSON.stringify({scoped:sampleData,unscoped:await allSeries.json()},null,2)+'\n');
    return Number(sampleData.data.result[0]?.value[1]||0);
  },{timeout:90000,intervals:[5000]}).toBeGreaterThan(0);
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
  const queries=[],captures=[];
  page.on('response',response=>{
    if(response.url().includes('/api/ds/query') && response.request().method()==='POST'){
      captures.push(response.json().then(data=>queries.push({request:JSON.parse(response.request().postData()||'{}'),response:data})));
    }
  });
  await page.goto('http://127.0.0.1:3001/d/kitledger');
  await expect(page.getByText('Requests served',{exact:true})).toBeVisible({timeout:30000});
  await expect(page.getByText('Requests by route',{exact:true})).toBeVisible();
  const countPanel=page.getByRole('region').filter({has:page.getByRole('heading',{name:'Requests served',exact:true})});
  try {
    await expect(countPanel.getByText(/^[1-9]\d*(?:\.\d+)?[kKmM]?$/).first()).toBeVisible({timeout:60000});
    await expect(page.getByText('No data',{exact:true})).toHaveCount(0,{timeout:60000});
  } finally {
    await Promise.all(captures);
    await writeFile('../../evidence/observability/grafana-query.json',JSON.stringify(queries,null,2)+'\n');
  }
  expect(queries.some(query=>Object.values(query.response.results).some(result=>(result.frames||[]).some(frame=>frame.data.values.flat().some(value=>typeof value==='number'))))).toBeTruthy();
  await page.evaluate(()=>new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve))));
  await page.screenshot({path:'../../evidence/observability/grafana-dashboard.png',fullPage:true});
});
