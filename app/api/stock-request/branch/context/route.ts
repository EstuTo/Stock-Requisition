import { NextRequest, NextResponse } from 'next/server';
import { clearBranchCookies, readBranchId, setBranchCookie } from '@/lib/stock-request/branch-context';
import { ApiError, fromDbError, handle } from '@/lib/stock-request/errors';
import { getBranch } from '@/lib/stock-request/queries';
import { getServiceClient } from '@/lib/stock-request/supabase-admin';
import { parseBranchId, readJson } from '@/lib/stock-request/validation';

export const dynamic = 'force-dynamic';

export const GET = handle(async (request: NextRequest) => {
  const branchId = readBranchId(request);
  const branch = branchId ? await getBranch(branchId) : null;
  if (!branch) return NextResponse.json({ branch: null, awaitingReceipt: 0 });
  // บิลที่สำนักงานใหญ่จัดส่งแล้ว รอสาขากดยืนยันรับ — ใช้แสดงจุดแจ้งเตือนที่แท็บ "ติดตามสถานะ"
  // ไม่ใช้ head: true เพราะคำขอแบบ HEAD ไม่มีข้อความ error ให้เห็นสาเหตุจริง
  const { data, error } = await getServiceClient()
    .from('bills')
    .select('id')
    .eq('branch_id', branch.id)
    .eq('status', 'shipped');
  if (error) throw fromDbError(error);
  return NextResponse.json({ branch, awaitingReceipt: data?.length ?? 0 });
});

export const POST = handle(async (request: NextRequest) => {
  const body = await readJson(request);
  const branchId = parseBranchId(body.branchId);
  const branch = branchId ? await getBranch(branchId) : null;
  if (!branch) throw new ApiError(404, 'SR_BRANCH_NOT_FOUND', 'ไม่พบสาขาที่เลือก');
  const response = NextResponse.json({ ok: true });
  setBranchCookie(response, branch.id);
  return response;
});

export const DELETE = handle(async () => {
  const response = NextResponse.json({ ok: true });
  clearBranchCookies(response);
  return response;
});
