-- =====================================================================
-- ลบข้อมูลตัวอย่างที่สร้างจาก seed-sample.sql
-- ลบเฉพาะสาขาที่ชื่อขึ้นต้นด้วย "ตัวอย่าง · " พร้อมบิล รายการ ประวัติ แจ้งเตือน และลิงก์หยิบของของสาขาเหล่านั้น
-- สาขาจริงและบิลจริงไม่ถูกแตะ · ทั้งไฟล์อยู่ใน transaction เดียว
-- =====================================================================
begin;

do $$
declare
  v_ids bigint[];
begin
  select coalesce(array_agg(id), '{}') into v_ids from public.branches where name like 'ตัวอย่าง · %';
  if cardinality(v_ids) = 0 then
    raise notice 'ไม่พบข้อมูลตัวอย่าง — ไม่มีอะไรถูกลบ';
    return;
  end if;

  -- ตารางประวัติถูกป้องกันการลบ ต้องเปิดสวิตช์ชั่วคราวในรอบนี้ (ปิดเองเมื่อจบ transaction)
  perform set_config('stock_request.allow_purge', 'on', true);
  delete from stock_request.bills where branch_id = any (v_ids);
  perform set_config('stock_request.allow_purge', '', true);
  delete from stock_request.notifications where branch_id = any (v_ids);
  delete from stock_request.bill_counters where branch_id = any (v_ids);
  delete from public.branches where id = any (v_ids) and name like 'ตัวอย่าง · %';
  raise notice 'ลบข้อมูลตัวอย่างแล้ว (% สาขา)', cardinality(v_ids);
end;
$$;

select
  (select count(*) from public.branches where name like 'ตัวอย่าง · %') as sample_branches_left,
  (select count(*) from stock_request.bills) as bills_left;

commit;
