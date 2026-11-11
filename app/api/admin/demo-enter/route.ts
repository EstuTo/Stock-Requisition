import { NextResponse } from 'next/server';
import { ADMIN_COOKIE_NAME, ADMIN_SESSION_SECONDS, createAdminSession } from '@/lib/admin-auth';

// เว็บตัวอย่าง: ปุ่ม "เข้าใช้งานทันที" ข้ามการยืนยันอีเมลและรหัสผ่าน — ห้ามใช้ในระบบจริง
export async function POST() {
  const sessionSecret = process.env.ADMIN_SESSION_SECRET ?? '';
  if (!sessionSecret) {
    return NextResponse.json({ error: 'ระบบยังไม่ได้ตั้งค่า ADMIN_SESSION_SECRET' }, { status: 503 });
  }
  const response = NextResponse.json({ ok: true });
  response.cookies.set(ADMIN_COOKIE_NAME, await createAdminSession(sessionSecret, ADMIN_SESSION_SECONDS), {
    httpOnly: true,
    sameSite: 'strict',
    secure: process.env.NODE_ENV === 'production',
    maxAge: ADMIN_SESSION_SECONDS,
    path: '/',
  });
  return response;
}
