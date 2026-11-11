# Aemori · ระบบแจ้งสินค้าใกล้หมด

สาขาถ่ายรูปสินค้าที่ใกล้หมดแล้วใส่จำนวนที่ต้องการสั่ง สำนักงานใหญ่ตัดบิล แพ็คของ จัดส่ง และตามแก้ปัญหาจนบิลจบ
โปรเจกต์นี้คัดลอกมาจากระบบเดิม (ที่มีระบบเบิกสินค้าอยู่ด้วย) เหลือเฉพาะระบบแจ้งสินค้าใกล้หมด และใช้ฐานข้อมูล Supabase ของตัวเอง

- พนักงานสาขา: `/stock-request` (ไม่ต้องใช้รหัส เลือกสาขาแล้วใช้งาน)
- สำนักงานใหญ่: `/admin` (เข้าด้วยรหัสผู้ดูแล `ADMIN_ACCESS_PASSWORD`)
- ลิงก์หยิบของ: หลังบ้านสร้างลิงก์ต่อบิล ส่งให้คนเดินหยิบของเปิดบนมือถือได้โดยไม่ต้องใช้รหัส (`/pick/...`)

## ตั้งค่าครั้งแรก

1. **สร้างโปรเจกต์ Supabase ใหม่** (เลือก region ใกล้ผู้ใช้ เช่น Singapore / Tokyo)
2. **ติดตั้งฐานข้อมูล:** Supabase → SQL Editor → วางไฟล์ [`supabase/setup-all.sql`](supabase/setup-all.sql) ทั้งไฟล์ → Run (ถ้ามีกล่อง "Potential issue detected" กด Run query)
3. **เปิด schema ให้ API:** Project Settings → Data API → Exposed schemas → เพิ่ม `stock_request` → Save
4. **ตรวจผล (ไม่บังคับ):** รัน [`supabase/tests/stock_request_smoke_test.sql`](supabase/tests/stock_request_smoke_test.sql) ถ้าผ่านจะขึ้น `ALL STOCK REQUEST TESTS PASSED` (ทำใน transaction แล้ว rollback ไม่ทิ้งข้อมูล)
5. **ตั้งค่า .env.local:** คัดลอก `.env.example` เป็น `.env.local` แล้วใส่ค่า (URL, anon key, service role key, รหัสผู้ดูแล, secret)
6. **ติดตั้งและรัน**

```bash
npm install
npm run dev
```

7. เปิด `/admin` ใส่รหัสผู้ดูแล → เมนู **จัดการสาขา** → เพิ่มสาขา แล้วพนักงานจึงจะเลือกสาขาที่ `/stock-request` ได้

## หมายเหตุ

- รูปสินค้าเก็บใน Supabase Storage bucket `stock-request-photos` (private) ถูกสร้างโดย setup-all.sql แล้ว รูปของบิลที่เก่ากว่า 3 บิลล่าสุดของสาขาถูกลบอัตโนมัติ
- ขึ้นเว็บจริงบน Vercel: ตั้ง Environment Variables ชุดเดียวกับ `.env.example` และเลือก Function Region ให้ตรงกับ region ของ Supabase (Settings → Functions) เพื่อให้เร็ว
- คู่มือการใช้งานฉบับพิมพ์ (PDF หน้าบ้าน/หลังบ้าน): `docs/guide` · สร้างใหม่ด้วย `node scripts/build-guide-pdf.mjs`
