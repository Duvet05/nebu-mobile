import { test } from 'node:test';
import assert from 'node:assert/strict';
import { makeProductionRelease, promote } from './promote-android.mjs';
const options={versionCode:'2001',fromTrack:'internal',status:'draft'};
const source={releases:[{name:'next',versionCodes:['2000','2001'],status:'completed',releaseNotes:[{language:'es-419',text:'Mejoras'}]}]};
test('promotes exactly the selected artifact and preserves release notes',()=>{
  assert.deepEqual(makeProductionRelease(source,{},options),{name:'next',versionCodes:['2001'],status:'draft',releaseNotes:source.releases[0].releaseNotes});
});
for(const change of [{versionCode:'$(bad)'},{versionCode:'0'},{fromTrack:'../../other'},{status:'inProgress'}]) test(`rejects invalid input ${JSON.stringify(change)}`,()=>assert.throws(()=>makeProductionRelease(source,{},{...options,...change})));
test('rejects an unavailable source artifact',()=>assert.throws(()=>makeProductionRelease({}, {},options)));
test('rejects downgrades and duplicate production versions',()=>{
  for(const code of ['2001','2002']) assert.throws(()=>makeProductionRelease(source,{releases:[{status:'completed',versionCodes:[code]}]},options));
});
test('does not overwrite another draft or staged rollout',()=>{
  for(const status of ['draft','inProgress','halted']) assert.throws(()=>makeProductionRelease(source,{releases:[{status,versionCodes:['1999']}]},options));
});
test('can submit an existing production draft',()=>{
  const draft={releases:[{status:'draft',versionCodes:['2001']}]};
  assert.equal(makeProductionRelease(draft,draft,{...options,fromTrack:'production',status:'completed'}).status,'completed');
});
test('missing countries fails before track mutation and discards the edit',async()=>{
  const calls=[];
  const api=async(method,path)=>{calls.push([method,path]);if(path==='/edits')return {id:'test'};if(path.endsWith('/tracks/internal'))return source;if(path.endsWith('/tracks/production'))return {};return null;};
  await assert.rejects(promote(api,options),/no country availability/);
  assert.equal(calls.some(([method])=>method==='PUT'),false);
  assert.deepEqual(calls.at(-1),['DELETE','/edits/test']);
});
test('validates then commits draft without cancelling an existing review',async()=>{
  const calls=[];
  const api=async(method,path)=>{calls.push([method,path]);if(path==='/edits')return {id:'test'};if(path.endsWith('/tracks/internal'))return source;if(path.includes('countryAvailability'))return {countries:[{countryCode:'PE'}]};return {};};
  await promote(api,options);
  assert.deepEqual(calls.at(-2),['POST','/edits/test:validate']);
  assert.match(calls.at(-1)[1],/changesInReviewBehavior=ERROR_IF_IN_REVIEW/);
  assert.match(calls.at(-1)[1],/changesNotSentForReview=true/);
  assert.equal(calls.some(([method])=>method==='DELETE'),false);
});
