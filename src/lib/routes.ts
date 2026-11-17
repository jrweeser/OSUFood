export type DemoPage='home'|'dashboard'|'create'|'browse'|'detail'|'reservations'|'pickups'|'impact'|'admin'|'guide';
export const pathFor=(page:DemoPage,id?:string)=>page==='home'?'/':page==='dashboard'?'/staff':page==='detail'?`/listing/${encodeURIComponent(id||'')}`:`/${page}`;
export function routeFor(pathname:string):{page:DemoPage;id?:string}{
 const path=pathname.replace(/\/+$/,'')||'/';
 if(path==='/')return {page:'home'};
 if(path==='/staff')return {page:'dashboard'};
 const detail=path.match(/^\/listing\/([^/]+)$/);
 if(detail)return {page:'detail',id:decodeURIComponent(detail[1])};
 const pages:DemoPage[]=['create','browse','reservations','pickups','impact','admin','guide'];
 const page=pages.find(value=>path===`/${value}`);
 return page?{page}:{page:'home'};
}
