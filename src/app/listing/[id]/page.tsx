import App from '@/components/app';
export default async function ListingPage({params}:{params:Promise<{id:string}>}){const {id}=await params;return <App initialPage="detail" initialId={id}/>}
