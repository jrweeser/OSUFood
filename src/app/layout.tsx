import type { Metadata } from 'next';
import './globals.css';
export const metadata:Metadata={title:'OSU Food After Hours',description:'A local academic prototype connecting surplus campus food with community pantries.'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}
