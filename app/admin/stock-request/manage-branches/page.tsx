'use client';

import { FormEvent, useCallback, useEffect, useState } from 'react';
import { ConfirmDialog, EmptyState, ErrorState, InlineError, LoadingState, inputClass, primaryButton } from '@/components/stock-request/ui';
import { apiFetch, errorMessage } from '@/lib/stock-request/client';
import type { Branch } from '@/lib/stock-request/types';

// จัดการสาขา (หลังบ้าน): เพิ่ม / ลบสาขา
// สาขาที่มีประวัติบิลจะถูก "ซ่อน" แทนการลบ (ประวัติยังอยู่) — เพิ่มชื่อเดิมอีกครั้งเพื่อกู้คืน
export default function ManageBranchesPage() {
  const [branches, setBranches] = useState<Branch[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [name, setName] = useState('');
  const [adding, setAdding] = useState(false);
  const [message, setMessage] = useState<{ tone: 'ok' | 'error'; text: string } | null>(null);
  const [removing, setRemoving] = useState<Branch | null>(null);
  const [removeBusy, setRemoveBusy] = useState(false);
  const [removeError, setRemoveError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setBranches((await apiFetch<{ branches: Branch[] }>('/api/stock-request/branches')).branches);
      setLoadError(null);
    } catch (err) {
      setLoadError(errorMessage(err));
    }
  }, []);

  useEffect(() => {
    const timer = setTimeout(load, 0);
    return () => clearTimeout(timer);
  }, [load]);

  // รายชื่อสาขามีแคชฝั่ง server สั้นๆ — รอบหลังเพิ่ม/ลบ โหลดซ้ำเมื่อ API ล้างแคชแล้ว
  const add = async (event: FormEvent) => {
    event.preventDefault();
    const value = name.trim();
    if (!value) return setMessage({ tone: 'error', text: 'กรุณากรอกชื่อสาขา' });
    setAdding(true);
    setMessage(null);
    try {
      const result = await apiFetch<{ restored?: boolean }>('/api/admin/branches', { method: 'POST', json: { name: value } });
      setName('');
      setMessage({ tone: 'ok', text: result.restored ? `กู้คืนสาขา “${value}” พร้อมประวัติบิลแล้ว` : `เพิ่มสาขา “${value}” แล้ว` });
      await load();
    } catch (err) {
      setMessage({ tone: 'error', text: errorMessage(err) });
    } finally {
      setAdding(false);
    }
  };

  const remove = async () => {
    if (!removing) return;
    setRemoveBusy(true);
    setRemoveError(null);
    try {
      const result = await apiFetch<{ result: 'deleted' | 'archived' }>(`/api/admin/branches/${removing.id}`, { method: 'DELETE' });
      setMessage({
        tone: 'ok',
        text: result.result === 'archived' ? `ซ่อนสาขา “${removing.name}” แล้ว (มีประวัติบิล ประวัติยังอยู่ · เพิ่มชื่อเดิมอีกครั้งเพื่อกู้คืน)` : `ลบสาขา “${removing.name}” แล้ว`,
      });
      setRemoving(null);
      await load();
    } catch (err) {
      setRemoveError(errorMessage(err));
    } finally {
      setRemoveBusy(false);
    }
  };

  if (loadError && !branches) return <ErrorState message={loadError} onRetry={load} />;
  if (!branches) return <LoadingState />;

  return (
    <div className="mx-auto max-w-2xl space-y-5">
      <div>
        <h1 className="text-2xl font-black">🏪 จัดการสาขา</h1>
        <p className="text-sm text-slate-500">เพิ่มสาขาที่จะใช้แจ้งสินค้า · สาขาเรียงตามชื่อ · พนักงานเลือกสาขาจากรายการนี้</p>
      </div>

      <form onSubmit={add} className="flex gap-2 rounded-2xl border border-indigo-100 bg-white p-3 shadow-sm">
        <input value={name} onChange={(event) => setName(event.target.value)} maxLength={200} placeholder="ชื่อสาขาใหม่ เช่น สาขาบุรีรัมย์" className={inputClass} aria-label="ชื่อสาขาใหม่" />
        <button type="submit" disabled={adding} className={`${primaryButton} shrink-0`}>
          {adding ? 'กำลังเพิ่ม...' : '➕ เพิ่ม'}
        </button>
      </form>

      {message && (
        <p className={`rounded-xl px-4 py-2.5 text-sm font-bold ${message.tone === 'ok' ? 'bg-emerald-50 text-emerald-700' : 'bg-sky-50 text-sky-700'}`}>
          {message.tone === 'ok' ? '✅ ' : '⚠️ '}
          {message.text}
        </p>
      )}

      {branches.length === 0 ? (
        <EmptyState icon="🏪" title="ยังไม่มีสาขา" description="เพิ่มสาขาแรกด้านบน พนักงานจึงจะเลือกสาขาและแจ้งสินค้าได้" />
      ) : (
        <ul className="space-y-2">
          {branches.map((branch) => (
            <li key={branch.id} className="flex items-center justify-between gap-3 rounded-2xl border border-indigo-100 bg-white px-4 py-3 shadow-sm">
              <span className="min-w-0 truncate font-bold text-slate-800">🏪 {branch.name}</span>
              <button
                type="button"
                onClick={() => {
                  setRemoveError(null);
                  setRemoving(branch);
                }}
                className="shrink-0 rounded-lg px-3 py-1.5 text-xs font-bold text-sky-600 hover:bg-sky-50"
              >
                ลบ
              </button>
            </li>
          ))}
        </ul>
      )}
      <p className="text-center text-xs text-slate-400">ทั้งหมด {branches.length} สาขา</p>

      <ConfirmDialog
        open={Boolean(removing)}
        title="ลบสาขา"
        tone="danger"
        confirmLabel="ลบสาขา"
        busy={removeBusy}
        onCancel={() => setRemoving(null)}
        onConfirm={remove}
        message={
          <>
            ลบ <b>{removing?.name}</b> — ถ้าสาขานี้มีประวัติบิลแล้ว ระบบจะซ่อนสาขาแทนการลบ (ประวัติยังอยู่) ถ้าไม่มีประวัติ จะลบจริง
          </>
        }
      >
        <InlineError message={removeError} />
      </ConfirmDialog>
    </div>
  );
}
