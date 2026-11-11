import 'server-only';
import { cookies } from 'next/headers';
import { ADMIN_COOKIE_NAME, verifyAdminSession } from '@/lib/admin-auth';
import { ApiError } from '@/lib/stock-request/errors';
import { getServiceClient } from '@/lib/stock-request/supabase-admin';

/** Supabase service role (ฝั่ง server เท่านั้น) — schema public ใช้กับตารางสาขา */
export const serviceDb = getServiceClient;

/** API หลังบ้านต้องเข้าโหมดผู้ดูแล (รหัสกลาง) ก่อน — /api/admin/* ไม่ผ่าน proxy จึงตรวจเองทุก route */
export async function requireAdminApi() {
  const store = await cookies();
  const valid = await verifyAdminSession(store.get(ADMIN_COOKIE_NAME)?.value, process.env.ADMIN_SESSION_SECRET ?? '');
  if (!valid) throw new ApiError(401, 'UNAUTHENTICATED', 'กรุณาเข้าสู่โหมดผู้ดูแลก่อน');
}

/** แปลง error จาก Supabase เป็นข้อความที่แสดงผู้ใช้ได้ (log รายละเอียดไว้ฝั่ง server) */
export function dbError(error: { message?: string; code?: string; details?: string | null } | null, message: string): ApiError {
  console.error('[admin] database error', { code: error?.code, message: error?.message, details: error?.details });
  if (error?.code === '23503') return new ApiError(409, 'IN_USE', `${message}: ข้อมูลนี้ถูกใช้งานอยู่`);
  if (error?.code === '23505') return new ApiError(409, 'DUPLICATE', `${message}: ข้อมูลซ้ำกับที่มีอยู่แล้ว`);
  return new ApiError(500, 'DB_ERROR', message);
}
