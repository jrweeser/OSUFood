import { snapshot } from '@/lib/db';
export const runtime='nodejs'; export const dynamic='force-dynamic';
export async function GET() {try{return Response.json(snapshot(),{headers:{'Cache-Control':'no-store'}});}catch{return Response.json({error:'Database unavailable. Check local data directory.'},{status:500});}}
