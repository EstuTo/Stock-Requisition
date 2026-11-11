import Link from 'next/link';

// หน้าแรก: ปุ่มเดียวต่อกลุ่มผู้ใช้ กดแล้วเข้าใช้งานได้เลย
export default function Home() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-linear-to-br from-indigo-50 via-white to-sky-100/60 px-4 py-10 text-slate-800">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <h1 className="text-2xl font-black">ระบบแจ้งสินค้าใกล้หมด</h1>
          <p className="mt-2 text-sm font-semibold text-slate-500">เลือกกลุ่มผู้ใช้งานของคุณ</p>
        </div>

        <Link
          href="/stock-request"
          className="flex w-full items-center justify-between gap-4 rounded-2xl bg-linear-to-r from-indigo-500 to-sky-500 px-6 py-5 text-white shadow-lg shadow-indigo-200 transition-all hover:from-indigo-600 hover:to-sky-600 active:scale-[0.98]"
        >
          <span>
            <span className="block text-lg font-black">🏪 พนักงานสาขา</span>
            <span className="mt-0.5 block text-xs font-semibold text-indigo-100">แจ้งสินค้าใกล้หมด · เลือกสาขาแล้วใช้งานได้เลย</span>
          </span>
          <span className="text-2xl">›</span>
        </Link>

        <Link
          href="/admin"
          className="flex w-full items-center justify-between gap-4 rounded-2xl border border-indigo-200 bg-white px-6 py-5 text-slate-800 shadow-sm transition-all hover:border-indigo-400 hover:shadow-md active:scale-[0.98]"
        >
          <span>
            <span className="block text-lg font-black">🏢 สำนักงานใหญ่</span>
            <span className="mt-0.5 block text-xs font-semibold text-slate-500">ตัดบิล แพ็คของ จัดส่ง · ต้องเข้าสู่ระบบ</span>
          </span>
          <span className="text-2xl text-slate-300">›</span>
        </Link>
      </div>
    </main>
  );
}
