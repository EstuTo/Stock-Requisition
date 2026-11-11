import { redirect } from 'next/navigation';

// ระบบนี้มีระบบเดียว: พนักงานสาขาเข้า /stock-request · ผู้ดูแลเข้า /admin
export default function Home() {
  redirect('/stock-request');
}
