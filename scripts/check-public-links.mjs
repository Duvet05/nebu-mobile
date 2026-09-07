import { readFileSync, writeFileSync } from 'node:fs';
import { resolveMx } from 'node:dns/promises';
import { fileURLToPath } from 'node:url';

const config=readFileSync(new URL('../lib/core/config/config.dart',import.meta.url),'utf8');
const configured=[...config.matchAll(/static const String (privacyPolicyUrl|supportUrl|deleteAccountUrl|deleteDataUrl)\s*=\s*'([^']+)'/g)];
if(configured.length!==4) throw new Error('Expected all four public links in Config');
const links=[
  ...configured.map(([,name,url])=>({name,url})),
  {name:'storeWebsite',url:'https://flow-telligence.com'},
  {name:'emailVerification',url:'https://nebu.flow-telligence.com/verify-email'},
  {name:'passwordReset',url:'https://nebu.flow-telligence.com/reset-password'},
  {name:'androidAppLinks',url:'https://nebu.flow-telligence.com/.well-known/assetlinks.json',kind:'assetlinks'},
  {name:'appleAppLinks',url:'https://nebu.flow-telligence.com/.well-known/apple-app-site-association',kind:'applelinks'},
  {name:'apiHealth',url:'https://api.flow-telligence.com/api/v1/health',kind:'health'},
];
const results=await Promise.all(links.map(async link=>{
  try {
    const response=await fetch(link.url,{signal:AbortSignal.timeout(25000),redirect:'follow'});
    const body=await response.text();
    let ok=response.ok && new URL(response.url).protocol==='https:';
    if(link.kind==='health') ok &&= JSON.parse(body).status==='ok';
    else if(link.kind==='assetlinks') ok &&= JSON.parse(body).some(x=>x.target?.package_name==='com.nebu.mobile' && x.target?.sha256_cert_fingerprints?.length>0 && x.relation?.includes('delegate_permission/common.handle_all_urls'));
    else if(link.kind==='applelinks') ok &&= JSON.parse(body).applinks?.details?.length>0;
    else ok &&= /text\/html/.test(response.headers.get('content-type')??'') && !/<title[^>]*>[^<]*(?:404|Página no encontrada|Page not found)/i.test(body);
    return {...link,ok,status:response.status,finalUrl:response.url,title:body.match(/<title[^>]*>(.*?)<\/title>/s)?.[1]};
  }catch(error){return {...link,ok:false,error:error.message};}
}));
try {
  const records=await resolveMx('flow-telligence.com');
  results.push({name:'contactEmailDomain',ok:records.some(x=>Boolean(x.exchange)),scope:'MX only; mailbox delivery was not tested and no email was sent.'});
}catch(error){results.push({name:'contactEmailDomain',ok:false,error:error.message});}
for(const result of results) console.log(`${result.ok?'PASS':'FAIL'} ${result.name}: ${result.status??result.error??'MX configured'} ${result.url??''}`);
const report={at:new Date().toISOString(),results,scope:'Public GETs and MX records only. No login/reset/deletion form was submitted. Deep-link routing on a physical phone and mailbox delivery need separate checks.'};
if(process.argv[2]) writeFileSync(fileURLToPath(new URL(process.argv[2],`file://${process.cwd()}/`)),JSON.stringify(report,null,2));
if(results.some(x=>!x.ok)) process.exitCode=1;
