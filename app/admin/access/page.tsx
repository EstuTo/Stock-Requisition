'use client';

import Link from 'next/link';
import { FormEvent, useState } from 'react';

export default function AdminAccessPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // เว็บตัวอย่าง: ปุ่มเข้าใช้งานทันทีแสดงเสมอ (ลบบรรทัดนี้และปุ่มด้านล่างก่อนนำไปใช้จริง)
  const demoMode = true;

  const goToDestination = () => {
    const params = new URLSearchParams(window.location.search);
    const requestedPath = params.get('returnTo');
    // กลับไปหน้าที่ขอไว้: หลังบ้าน หรือฝั่งสาขาของระบบแจ้งสินค้าใกล้หมด
    const allowed = (requestedPath?.startsWith('/admin/') && requestedPath !== '/admin/access') || requestedPath?.startsWith('/stock-request');
    const destination = allowed && requestedPath ? requestedPath : '/admin';
    window.location.replace(destination);
  };

  const handleDemoEnter = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await fetch('/api/admin/demo-enter', { method: 'POST' });
      if (!response.ok) {
        setError('ยังไม่ได้เปิดโหมดตัวอย่าง');
        return;
      }
      goToDestination();
    } catch {
      setError('เชื่อมต่อระบบไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (!email || !password) return;
    setLoading(true);
    setError('');
    try {
      const response = await fetch('/api/admin/access', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, remember }),
      });
      const result = await response.json() as { error?: string };
      if (!response.ok) {
        setError(result.error || 'ไม่สามารถเข้าสู่ระบบได้');
        setPassword('');
        return;
      }
      goToDestination();
    } catch {
      setError('เชื่อมต่อระบบไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-linear-to-br from-indigo-50 via-white to-sky-100/60 px-4 py-10 text-slate-800">
      <div className="absolute -left-24 top-10 h-72 w-72 rounded-full bg-indigo-200/30 blur-3xl" />
      <div className="absolute -right-24 bottom-10 h-80 w-80 rounded-full bg-sky-200/30 blur-3xl" />
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-indigo-100 bg-white shadow-2xl shadow-indigo-200/50">
        <div className="bg-linear-to-r from-indigo-600 via-indigo-500 to-sky-500 px-7 py-6 text-white">
          <p className="text-xs font-bold uppercase tracking-widest text-indigo-100">สำนักงานใหญ่</p>
          <p className="mt-1 text-xl font-black">ระบบแจ้งสินค้าใกล้หมด</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-5 p-7">
          <div>
            <h1 className="text-xl font-black text-slate-800">เข้าสู่ระบบ</h1>
            <p className="mt-1.5 text-sm font-semibold leading-relaxed text-slate-500">กรอกอีเมลและรหัสผ่านของผู้ดูแลระบบ</p>
          </div>
          <div>
            <label htmlFor="admin-email" className="mb-2 block text-xs font-black uppercase tracking-widest text-indigo-500">อีเมล</label>
            <input id="admin-email" type="email" value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="username" autoFocus className="h-12 w-full rounded-xl border border-indigo-200 bg-indigo-50/50 px-4 text-sm font-bold text-slate-700 outline-none transition-all focus:border-indigo-400 focus:ring-4 focus:ring-indigo-100" placeholder="name@example.com" />
          </div>
          <div>
            <label htmlFor="admin-password" className="mb-2 block text-xs font-black uppercase tracking-widest text-indigo-500">รหัสผ่าน</label>
            <div className="relative">
              <input id="admin-password" type={showPassword ? 'text' : 'password'} value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="current-password" className="h-12 w-full rounded-xl border border-indigo-200 bg-indigo-50/50 px-4 pr-14 text-sm font-bold text-slate-700 outline-none transition-all focus:border-indigo-400 focus:ring-4 focus:ring-indigo-100" placeholder="กรอกรหัสผ่าน" />
              <button type="button" onClick={() => setShowPassword((value) => !value)} className="absolute inset-y-0 right-0 px-4 text-xs font-bold text-indigo-500">{showPassword ? 'ซ่อน' : 'แสดง'}</button>
            </div>
          </div>
          {error && <div role="alert" className="rounded-xl border border-sky-100 bg-sky-50 px-4 py-3 text-sm font-bold text-sky-600">⚠️ {error}</div>}
          <label className="flex cursor-pointer items-start gap-3 rounded-xl bg-indigo-50/60 px-4 py-3 ring-1 ring-indigo-100">
            <input type="checkbox" checked={remember} onChange={(event) => setRemember(event.target.checked)} className="mt-0.5 h-5 w-5 accent-indigo-500" />
            <span className="text-sm">
              <span className="block font-black text-slate-700">จดจำการเข้าสู่ระบบในเครื่องนี้</span>
              <span className="block text-xs font-semibold text-slate-500">ไม่ควรติ๊กในเครื่องที่ใช้ร่วมกับคนอื่น</span>
            </span>
          </label>
          <button type="submit" disabled={loading || !email || !password} className="flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-linear-to-r from-indigo-500 to-sky-500 text-sm font-black text-white shadow-lg shadow-indigo-200 transition-all hover:from-indigo-600 hover:to-sky-600 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-50">{loading ? <><span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />กำลังตรวจสอบ...</> : 'เข้าสู่ระบบ →'}</button>
          {demoMode && (
            <button type="button" onClick={handleDemoEnter} disabled={loading} className="flex h-12 w-full items-center justify-center gap-2 rounded-xl border-2 border-indigo-400 bg-white text-sm font-black text-indigo-600 transition-all hover:bg-indigo-50 active:scale-[0.98] disabled:opacity-50">
              ⚡ เข้าใช้งานทันที (โหมดตัวอย่าง)
            </button>
          )}
          <Link href="/" className="block text-center text-xs font-bold text-slate-500 hover:text-indigo-600">← กลับหน้าหลัก</Link>
        </form>
      </div>
    </main>
  );
}
