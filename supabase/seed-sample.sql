-- =====================================================================
-- ข้อมูลตัวอย่าง 100 รายการ คละสถานะ (สำหรับเว็บตัวอย่าง / ทดลองใช้)
-- รันหลัง setup-all.sql: Supabase → SQL Editor → วางทั้งไฟล์ → Run
-- ลบออกทีหลัง: supabase/remove-sample.sql
--
-- สร้าง: สาขาตัวอย่าง 8 สาขา (ชื่อขึ้นต้น "ตัวอย่าง · ") + บิล 19 ใบ รวม 100 รายการ
--   รอตัดบิล        5 บิล / 20 รายการ
--   ตัดบิลแล้ว (กำลังแพ็คของ) 3 บิล / 18 รายการ  — ติ๊กแพ็คแล้วบางส่วน, ส่งได้ไม่ครบ 1, ใช้ของแทน 1, ไม่มีของ 1
--   จัดส่งแล้ว       3 บิล / 15 รายการ  — มีส่งได้ไม่ครบ 1
--   ได้รับแล้ว       8 บิล / 47 รายการ  — ได้ครบ 5 บิล, มีปัญหาค้าง 1 บิล, แก้ไขปัญหาแล้ว 1 บิล, ได้ครบอีก 1 บิล
-- รูปสินค้าไม่มีไฟล์จริง (หน้าเว็บจะแสดงไอคอน 📷 แทน)
-- ถ้ารันซ้ำ: ระบบจะหยุดและไม่สร้างซ้ำ (ลบด้วย remove-sample.sql ก่อน)
-- ทั้งไฟล์อยู่ใน transaction เดียว: ถ้ามีบรรทัดไหน Error จะไม่มีอะไรถูกสร้างเลย
-- =====================================================================
begin;

do $$
declare
  c_admin constant text := 'ผู้ดูแลระบบ';
  c_resp  constant text := 'ตัวอย่าง ผู้รับผิดชอบ';
  v_names text[] := array[
    'ตัวอย่าง · สาขาเมืองใหม่', 'ตัวอย่าง · สาขาริมน้ำ', 'ตัวอย่าง · สาขาตลาดเช้า', 'ตัวอย่าง · สาขาสถานีรถไฟ',
    'ตัวอย่าง · สาขาโรงเรียน', 'ตัวอย่าง · สาขาศูนย์การค้า', 'ตัวอย่าง · สาขาหน้าโรงพยาบาล', 'ตัวอย่าง · สาขาถนนใหญ่'];
  v_pnames text[] := array[
    'ปากกาลูกลื่นสีน้ำเงิน', 'ปากกาเจลสีดำ 0.5', 'ปากกาไฮไลท์สีเหลือง', 'ดินสอไม้ 2B', 'ยางลบก้อนใหญ่',
    'ไม้บรรทัด 30 ซม.', 'สมุดโน้ตปกแข็ง A5', 'สมุดบันทึกลายน่ารัก', 'กระดาษโน้ตกาวในตัว', 'กระดาษ A4 80 แกรม',
    'แฟ้มเอกสารพลาสติกใส', 'ซองจดหมายสีขาว', 'เทปกาวใส 1 นิ้ว', 'เทปปิดกล่องสีน้ำตาล', 'กรรไกรสำนักงาน',
    'ที่เย็บกระดาษ', 'ลวดเย็บกระดาษ No.10', 'แท่นประทับตราพร้อมหมึก', 'สติกเกอร์ฉลากราคา', 'ถุงซิปล็อกใส',
    'ถุงผ้าลายการ์ตูน', 'กล่องพลาสติกใส่ของ', 'แก้วน้ำเก็บความเย็น', 'พวงกุญแจอะคริลิค', 'กระจกพกพาขนาดเล็ก',
    'หวีพลาสติกพกพา', 'ยางรัดผมคละสี', 'กิ๊บติดผมชุด 12 ชิ้น', 'ที่คาดผมผ้า', 'แผ่นรองเมาส์',
    'สายชาร์จ Type-C', 'ที่ชาร์จ USB 2 ช่อง', 'หูฟังแบบมีสาย', 'พาวเวอร์แบงค์ 10000 mAh', 'เคสโทรศัพท์ใส',
    'ที่วางโทรศัพท์ตั้งโต๊ะ', 'ร่มพับขนาดเล็ก', 'ผ้าเช็ดหน้าผ้าฝ้าย', 'ถุงมือผ้ากันลื่น', 'กระเป๋าใส่เหรียญ'];
  v_staff text[] := array['พนักงานสมชาย', 'พนักงานสุดา', 'พนักงานวิภา', 'พนักงานอนันต์', 'พนักงานมาลี', 'พนักงานประเสริฐ'];
  v_notes text[] := array['ขายดีมาก', 'ลูกค้าถามบ่อย', 'เหลือไม่กี่ชิ้น', 'ของโปรโมชัน', 'สั่งเพิ่มก่อนสิ้นเดือน'];

  v_admin uuid;
  v_bids  bigint[] := '{}';
  v_id    bigint;
  rec     record;
  v_bid   bigint;
  v_bill  uuid;
  v_item  uuid;
  v_no    integer;
  v_day   date;
  v_base  timestamptz;
  v_billed timestamptz;
  v_shipped timestamptz;
  v_received timestamptz;
  v_rby   text;
  v_bill_no text;
  v_status text;
  v_seq   integer := 0;
  i       integer;
  v_pi    integer;
  v_qty   integer;
  v_code  text;
  v_item_at timestamptz;
  v_picked  boolean;
  v_partial boolean;
  v_removed boolean;
  v_sub     boolean;
  v_ship_qty integer;
  v_recv  text;
  v_recv_note text;
  v_picker text;
  v_picked_at timestamptz;
  v_miss_name text;
  v_miss_code text;
  v_miss_note text;
  v_total integer;
begin
  if exists (select 1 from public.branches b join stock_request.bills x on x.branch_id = b.id where b.name like 'ตัวอย่าง · %') then
    raise exception 'มีข้อมูลตัวอย่างอยู่แล้ว — รัน supabase/remove-sample.sql ก่อนถ้าต้องการสร้างใหม่';
  end if;

  -- ผู้ดูแลกลาง (ตัวเดียวกับที่หน้าเว็บสร้างให้เองตอนเข้าหลังบ้าน)
  select id into v_admin from stock_request.admin_profiles where lower(btrim(display_name)) = lower(c_admin);
  if v_admin is null then
    insert into stock_request.admin_profiles (display_name, role) values (c_admin, 'super_admin') returning id into v_admin;
  end if;

  -- สาขาตัวอย่าง
  insert into public.branches (name)
  select n from unnest(v_names) as n where not exists (select 1 from public.branches b where b.name = n);
  for k in 1..array_length(v_names, 1) loop
    select id into v_id from public.branches where name = v_names[k];
    v_bids := v_bids || v_id;
  end loop;

  -- แผนบิล: (ลำดับ, สาขา, รูปแบบ, ย้อนหลังกี่ชั่วโมง, จำนวนรายการ)
  for rec in
    select * from (values
      (1,  1, 'p',                       4,  6),
      (2,  2, 'p',                      27,  4),
      (3,  3, 'p',                       7,  5),
      (4,  5, 'p',                       2,  3),
      (5,  7, 'p',                      15,  2),
      (6,  4, 'packing',                50,  7),
      (7,  6, 'packing-sub',            52,  5),
      (8,  8, 'fresh',                  51,  6),
      (9,  2, 'shipped-partial',        76,  6),
      (10, 5, 'shipped',                80,  5),
      (11, 7, 'shipped',                84,  4),
      (12, 1, 'received-ok',           110,  7),
      (13, 3, 'received-ok',           120,  6),
      (14, 4, 'received-ok',           130,  6),
      (15, 8, 'received-ok',           140,  5),
      (16, 2, 'received-issue-open',   150,  5),
      (17, 6, 'received-issue-resolved', 160, 6),
      (18, 5, 'received-ok',           170,  6),
      (19, 7, 'received-ok',           180,  6)
    ) as t(n, branch_idx, variant, hours_back, n_items)
    order by n
  loop
    v_bid := v_bids[rec.branch_idx];
    v_status := case
      when rec.variant = 'p' then 'pending'
      when rec.variant in ('packing', 'packing-sub', 'fresh') then 'billed'
      when rec.variant in ('shipped-partial', 'shipped') then 'shipped'
      else 'received' end;
    v_base := now() - make_interval(hours => rec.hours_back);
    v_billed := null; v_shipped := null; v_received := null; v_rby := null;
    if v_status <> 'pending' then v_billed := v_base + interval '24 hours'; end if;
    if v_status in ('shipped', 'received') then v_shipped := v_base + interval '32 hours'; end if;
    if v_status = 'received' then
      v_received := v_base + interval '46 hours';
      v_rby := v_staff[1 + (rec.n % 6)];
    end if;

    -- เลขบิล (ตัวนับเดียวกับที่ระบบใช้ เพื่อไม่ให้เลขชนกับบิลที่สร้างทีหลัง)
    v_day := (v_base at time zone 'Asia/Bangkok')::date;
    insert into stock_request.bill_counters as c (branch_id, bill_date, last_no)
    values (v_bid, v_day, 1)
    on conflict (branch_id, bill_date) do update set last_no = c.last_no + 1
    returning c.last_no into v_no;
    v_bill_no := format('AMR-%s-%s-%s', lpad(v_bid::text, 2, '0'), to_char(v_day, 'YYMMDD'), lpad(v_no::text, 3, '0'));

    insert into stock_request.bills
      (bill_no, branch_id, status, version, billed_at, billed_by, shipped_at, shipped_by, shipped_name,
       received_at, received_by_name, responsible_name, created_at, updated_at)
    values
      (v_bill_no, v_bid, v_status::stock_request.bill_status, 1 + rec.n_items, v_billed,
       case when v_billed is not null then v_admin end, v_shipped, case when v_shipped is not null then v_admin end,
       case when v_shipped is not null then 'ตัวอย่าง ผู้ส่งของ' end, v_received, v_rby,
       case when v_billed is not null then c_resp end, v_base,
       least(coalesce(v_received, v_shipped, v_billed, v_base + interval '3 hours'), now()))
    returning id into v_bill;

    for i in 1..rec.n_items loop
      v_seq := v_seq + 1;
      v_pi := 1 + ((v_seq * 7) % 40);
      v_code := 'SP-' || (1000 + v_pi);
      v_qty := 1 + ((v_seq * 5) % 18);
      v_item_at := v_base + make_interval(mins => 5 + i * 9);

      v_picked := rec.variant in ('shipped-partial', 'shipped') or rec.variant like 'received%';
      v_partial := false; v_removed := false; v_sub := false; v_ship_qty := null;
      if rec.variant = 'packing' then
        v_picked := i <= 5; v_partial := (i = 5); v_removed := (i = 6);
      elsif rec.variant = 'packing-sub' then
        v_picked := i <= 3; v_sub := (i = 3);
      elsif rec.variant = 'fresh' then
        v_picked := false;
      elsif rec.variant = 'shipped-partial' then
        v_partial := (i = 3);
      end if;
      if v_partial then
        v_qty := case when rec.variant = 'packing' then 10 else 8 end;
        v_ship_qty := case when rec.variant = 'packing' then 4 else 5 end;
      end if;

      v_recv := null; v_recv_note := null;
      if rec.variant like 'received%' then
        v_recv := 'ok';
        if rec.variant = 'received-issue-open' and i = 5 then
          v_recv := 'missing'; v_recv_note := 'ของมาไม่ครบ ขาด 3 ชิ้น';
        elsif rec.variant = 'received-issue-resolved' and i = 2 then
          v_recv := 'missing'; v_recv_note := 'ได้รับของผิดรายการ';
        end if;
        if v_recv = 'missing' then v_miss_name := v_pnames[v_pi]; v_miss_code := v_code; v_miss_note := v_recv_note; end if;
      end if;

      v_picker := v_staff[1 + ((rec.n + i) % 6)];
      v_picked_at := case when v_picked then v_billed + make_interval(mins => 15 + i * 6) end;

      insert into stock_request.bill_items
        (bill_id, product_name, product_code, stock_on_hand, staff_note, photo_path, reported_by_name, source,
         hq_ship_qty, is_removed, removed_at, removed_by, created_at, updated_at, picked_at, picked_by,
         received_state, received_note, received_checked_by, received_checked_at)
      values
        (v_bill, v_pnames[v_pi], v_code, v_qty,
         case when v_seq % 3 = 0 then v_notes[1 + (v_seq % 5)] end,
         v_bid::text || '/' || to_char(v_base, 'YYYYMM') || '/' || gen_random_uuid()::text || '.jpg',
         v_staff[1 + (v_seq % 6)], 'branch', v_ship_qty, v_removed,
         case when v_removed then v_billed + interval '40 minutes' end, case when v_removed then v_admin end,
         v_item_at, v_item_at, v_picked_at, case when v_picked then v_picker end,
         v_recv, v_recv_note, case when v_recv is not null then v_rby end,
         case when v_recv is not null then v_received - interval '15 minutes' end)
      returning id into v_item;

      if v_partial then
        insert into stock_request.audit_logs (bill_id, bill_item_id, admin_id, admin_name, action, before_data, after_data, reason, after_billing, created_at)
        values (v_bill, v_item, v_admin, c_admin, 'ship_qty_change',
                jsonb_build_object('hq_ship_qty', null), jsonb_build_object('hq_ship_qty', v_ship_qty),
                format('ของไม่พอ ส่งได้ %s/%s: ของในคลังไม่พอ · ผู้แพ็ค: %s', v_ship_qty, v_qty, v_picker), true, v_picked_at);
      end if;
      if v_removed then
        insert into stock_request.audit_logs (bill_id, bill_item_id, admin_id, admin_name, action, before_data, after_data, reason, after_billing, created_at)
        values (v_bill, v_item, v_admin, c_admin, 'item_remove',
                jsonb_build_object('is_removed', false), jsonb_build_object('is_removed', true),
                'ไม่มีของ: ของหมด · ผู้หยิบ: ' || v_picker, true, v_billed + interval '40 minutes');
      end if;
      if v_sub then
        insert into stock_request.item_substitutions (bill_item_id, product_name, product_code, ship_qty, reason, is_active, created_by, created_at)
        values (v_item, 'ปากกาลูกลื่นสีแดง (ใช้แทน)', 'SP-2001', 0, 'ของหมด ใช้รุ่นใกล้เคียง', true, v_admin, v_billed + interval '30 minutes');
        insert into stock_request.audit_logs (bill_id, bill_item_id, admin_id, admin_name, action, before_data, after_data, reason, after_billing, created_at)
        values (v_bill, v_item, v_admin, c_admin, 'substitution_set', null,
                jsonb_build_object('product_name', 'ปากกาลูกลื่นสีแดง (ใช้แทน)', 'product_code', 'SP-2001'),
                'ของหมด ใช้รุ่นใกล้เคียง · ผู้หยิบ: ' || v_picker, true, v_billed + interval '30 minutes');
      end if;
    end loop;

    -- ร่องรอยการตัดบิล / เปลี่ยนสถานะ
    if v_billed is not null then
      insert into stock_request.bill_snapshots (bill_id, data, taken_by, taken_at)
      values (v_bill, stock_request.bill_snapshot_json(v_bill), v_admin, v_billed);
      insert into stock_request.status_logs (bill_id, from_status, to_status, admin_id, actor_name, changed_at)
      values (v_bill, 'pending', 'billed', v_admin, c_admin, v_billed);
      insert into stock_request.audit_logs (bill_id, admin_id, admin_name, action, after_data, after_billing, created_at)
      values (v_bill, v_admin, c_admin, 'bill_cut', jsonb_build_object('item_count', rec.n_items), false, v_billed);
    end if;
    if v_shipped is not null then
      insert into stock_request.status_logs (bill_id, from_status, to_status, admin_id, actor_name, changed_at)
      values (v_bill, 'billed', 'shipped', v_admin, c_admin, v_shipped);
      insert into stock_request.notifications (audience, branch_id, bill_id, type, title, body, created_at, updated_at)
      values ('branch', v_bid, v_bill, 'bill_shipped', 'สำนักงานใหญ่จัดส่งสินค้าแล้ว',
              format('บิล %s จัดส่งแล้ว กรุณาเช็คของและยืนยันเมื่อได้รับสินค้า', v_bill_no), v_shipped, v_shipped);
    end if;
    if v_received is not null then
      insert into stock_request.status_logs (bill_id, from_status, to_status, admin_id, actor_name, changed_at)
      values (v_bill, 'shipped', 'received', null, v_rby, v_received);
    end if;
    if v_status = 'pending' then
      insert into stock_request.notifications (audience, branch_id, bill_id, type, title, body, created_at, updated_at)
      values ('hq', v_bid, v_bill, 'new_items', 'มีรายการแจ้งสินค้าใหม่',
              format('%s · บิล %s มี %s รายการรอตัดบิล', v_names[rec.branch_idx], v_bill_no, rec.n_items), v_base + interval '30 minutes', v_base + interval '30 minutes');
    end if;

    -- บิลที่สาขาแจ้งว่าได้รับของไม่ครบ
    if rec.variant = 'received-issue-open' then
      update stock_request.bills
         set issue_status = 'open', issue_opened_at = v_received + interval '10 minutes',
             issue_summary = format('%s (%s) — %s', v_miss_name, v_miss_code, v_miss_note)
       where id = v_bill;
      insert into stock_request.notifications (audience, branch_id, bill_id, type, title, body, created_at, updated_at)
      values ('hq', v_bid, v_bill, 'receive_missing', 'สาขาแจ้งได้รับของไม่ครบ',
              format('%s · บิล %s: %s (%s) — %s', v_names[rec.branch_idx], v_bill_no, v_miss_name, v_miss_code, v_miss_note),
              v_received + interval '10 minutes', v_received + interval '10 minutes');
    elsif rec.variant = 'received-issue-resolved' then
      update stock_request.bills
         set issue_status = 'resolved', issue_opened_at = v_received + interval '10 minutes',
             issue_summary = format('%s (%s) — %s', v_miss_name, v_miss_code, v_miss_note),
             issue_resolved_note = 'ส่งสินค้าที่ถูกต้องให้สาขาแล้ว (ข้อมูลตัวอย่าง)', issue_resolved_by = c_resp,
             issue_resolved_at = v_received + interval '6 hours'
       where id = v_bill;
    end if;
  end loop;

  select count(*) into v_total
  from stock_request.bill_items i join stock_request.bills b on b.id = i.bill_id
  where b.branch_id = any (v_bids);
  if v_total <> 100 then
    raise exception 'สร้างรายการได้ % รายการ ไม่ใช่ 100 — ยกเลิกทั้งหมด', v_total;
  end if;
  raise notice 'สร้างข้อมูลตัวอย่างแล้ว: % รายการ', v_total;
end;
$$;

-- สรุปผล: จำนวนบิล/รายการแยกตามสถานะ
select b.status, count(distinct b.id) as bills, count(i.id) as items
from stock_request.bills b
join public.branches br on br.id = b.branch_id and br.name like 'ตัวอย่าง · %'
left join stock_request.bill_items i on i.bill_id = b.id
group by b.status
order by array_position(array['pending', 'billed', 'shipped', 'received'], b.status::text);

commit;
