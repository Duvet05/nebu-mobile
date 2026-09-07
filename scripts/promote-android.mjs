import { appendFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

export function makeProductionRelease(source, production, {versionCode,fromTrack,status}) {
  if(!/^[1-9]\d*$/.test(versionCode??'')) throw new Error('version_code must be a positive integer');
  if(!['internal','alpha','beta','production'].includes(fromTrack)) throw new Error('Invalid source track');
  if(!['draft','completed'].includes(status)) throw new Error('Invalid release status');
  const matches=(source.releases??[]).filter(r=>r.versionCodes?.includes(versionCode));
  if(matches.length!==1) throw new Error(`Build ${versionCode} must occur in exactly one source release`);
  const selected=matches[0];
  if(selected.status!=='completed' && !(fromTrack==='production' && selected.status==='draft')) throw new Error('Source release is not ready; test it before promotion');
  for(const release of production.releases??[]) {
    const sameDraft=release.status==='draft' && release.versionCodes?.length===1 && release.versionCodes[0]===versionCode;
    if(!sameDraft && release.status!=='completed') throw new Error('Production contains another draft or staged rollout; resolve it in Play Console first');
    if(!sameDraft && release.versionCodes?.some(code=>BigInt(code)>=BigInt(versionCode))) throw new Error('Refusing a duplicate or older production version');
  }
  return {name:selected.name??versionCode,versionCodes:[versionCode],status,...(selected.releaseNotes ? {releaseNotes:selected.releaseNotes} : {})};
}

export async function promote(api,options) {
  // Validate inputs before even creating a temporary edit.
  makeProductionRelease({releases:[{versionCodes:[options.versionCode],status:'completed'}]},{},options);
  const edit=await api('POST','/edits',{});
  let committed=false;
  try {
    const base=`/edits/${edit.id}`;
    const source=await api('GET',`${base}/tracks/${options.fromTrack}`);
    const production=await api('GET',`${base}/tracks/production`);
    const countries=await api('GET',`${base}/countryAvailability/production`);
    if(!countries?.countries?.length && !countries?.restOfWorld) throw new Error('Production has no country availability. In Play Console → Production → Countries/regions, select your launch countries and save. The API cannot select them for you.');
    const release=makeProductionRelease(source,production,options);
    await api('PUT',`${base}/tracks/production`,{track:'production',releases:[release]});
    await api('POST',`${base}:validate`);
    const query=new URLSearchParams({changesInReviewBehavior:'ERROR_IF_IN_REVIEW'});
    if(options.status==='draft') query.set('changesNotSentForReview','true');
    await api('POST',`${base}:commit?${query}`);
    committed=true;
    return release;
  } finally {
    if(!committed) await api('DELETE',`/edits/${edit.id}`);
  }
}

async function main() {
  const options={versionCode:process.env.VERSION_CODE,fromTrack:process.env.FROM_TRACK??'internal',status:process.env.RELEASE_STATUS??'draft'};
  const token=process.env.PLAY_ACCESS_TOKEN;
  if(!token) throw new Error('Missing PLAY_ACCESS_TOKEN');
  const api=async(method,path,body)=>{
    const response=await fetch(`https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.nebu.mobile${path}`,{
      method,headers:{Authorization:`Bearer ${token}`,...(body!==undefined?{'Content-Type':'application/json'}:{})},
      ...(body!==undefined?{body:JSON.stringify(body)}:{}),signal:AbortSignal.timeout(30000),
    });
    const text=await response.text(),data=text?JSON.parse(text):null;
    if(!response.ok) throw new Error(`${method} ${path}: ${response.status}; ${data?.error?.message??'Play request failed'}. Check Production and Publishing overview in Play Console. No automatic retry or review cancellation was requested.`);
    return data;
  };
  const release=await promote(api,options);
  const summary=`### Google Play production\n- Version: ${options.versionCode}\n- From: ${options.fromTrack}\n- Status: ${release.status}\n- Reused the selected artifact; no rebuild or upload.\n- Review/availability must still be confirmed in Play Console.\n`;
  console.log(summary);
  if(process.env.GITHUB_STEP_SUMMARY) appendFileSync(process.env.GITHUB_STEP_SUMMARY,summary);
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href) main().catch(error=>{console.error(error.message);process.exitCode=1;});
