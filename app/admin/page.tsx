import { redirect } from 'next/navigation';

// ทางเข้าหลังบ้าน: หลังเข้าสู่โหมดผู้ดูแล (/admin/access) ไปหน้าสำนักงานใหญ่
export default function AdminHome() {
  redirect('/admin/stock-request');
}
