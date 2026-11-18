import App from '@/components/app';
export default async function StudentListingPage({params}:{params:Promise<{id:string}>}){const {id}=await params;return <App initialPage="studentDetail" initialId={id}/>}
