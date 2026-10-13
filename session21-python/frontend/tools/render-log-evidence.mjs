// Render authentic transcript excerpts. These are NOT native terminal captures.
import {chromium} from '@playwright/test';
import {readFile,mkdir,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';

const root=resolve('../..');
const destination=resolve(root,'evidence/rendered');
await mkdir(destination,{recursive:true});
const pytestPath='evidence/runs/20261013T181937583957Z-pytest.json';
const ciPath='evidence/runs/20261013T190529979724Z-capstone-ci-38450469520.json';
const pytestRaw=await readFile(resolve(root,pytestPath),'utf8');
const ciRaw=await readFile(resolve(root,ciPath),'utf8');
const pytest=JSON.parse(pytestRaw);
const ci=JSON.parse(ciRaw);
function scanExcerpt(app){
  const lines=ci.output.split('\n').filter(line=>line.split('\t')[1]===`Trivy ${app} HIGH and CRITICAL gate`);
  const start=lines.findIndex(line=>line.includes('Report Summary'));
  const end=lines.findIndex(line=>line.includes("'0': Clean"));
  if(start<0||end<start) throw new Error(`Missing actual ${app} scan summary`);
  return lines.slice(start,end+1).map(line=>line.split('\t').slice(2).join('\t')).join('\n');
}
const excerpts=[
  {name:'pytest',title:'Actual isolated API test output',source:pytestPath,raw:pytestRaw,text:pytest.output},
  ...['backend','frontend'].map(app=>({name:`trivy-${app}`,title:`Actual Trivy ${app} HIGH / CRITICAL scan`,source:ciPath,raw:ciRaw,
    text:scanExcerpt(app)})),
  {name:'kubernetes',title:'Actual Minikube Pods, Services and Ingress',source:'evidence/ci/capstone-38450469520/evidence/ci/kubernetes.txt',raw:null,
    text:await readFile(resolve(root,'evidence/ci/capstone-38450469520/evidence/ci/kubernetes.txt'),'utf8')},
];
const escape=value=>value.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
const browser=await chromium.launch({channel:'chrome',headless:true});
const context=await browser.newContext({viewport:{width:1600,height:1100}});
const metadata=[];
try {
  for(const item of excerpts){
    const page=await context.newPage();
    const cleaned=item.text.replace(/\x1b\[[0-9;]*m/g,'');
    await page.setContent(`<html><head><meta charset="utf-8"><style>body{margin:32px;background:#111827;color:#e5e7eb;font-family:system-ui}h1{font-size:25px}aside{background:#713f12;color:#fef3c7;padding:14px;border-radius:8px}p{font-size:14px;overflow-wrap:anywhere}pre{white-space:pre-wrap;overflow-wrap:anywhere;font:13px/1.6 monospace;background:#030712;padding:20px;border-radius:8px}</style></head><body><aside>RENDERED TRANSCRIPT — not a native terminal or GitHub job screenshot</aside><h1>${escape(item.title)}</h1><p>Yash Agrawal · 24bcs10164</p><p>Unmodified historical source: ${escape(item.source)}. ANSI colour codes removed for rendering; CI sections are excerpts. Original timestamps/results are retained.</p><pre>${escape(cleaned)}</pre></body></html>`);
    await page.screenshot({path:resolve(destination,`${item.name}.png`),fullPage:true});
    metadata.push({name:item.name,source:item.source,source_sha256:createHash('sha256').update((item.raw||item.text).replaceAll('\r\n','\n')).digest('hex'),hash_format:'LF-normalized UTF-8 source',rendered_at:new Date().toISOString(),kind:'rendered historical transcript, not native capture'});
    await page.close();
  }
  await writeFile(resolve(destination,'provenance.json'),JSON.stringify(metadata,null,2)+'\n');
} finally {await context.close();await browser.close();}
