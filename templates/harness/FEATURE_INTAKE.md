# Feature Intake — {{PROJECT_NAME}}

> Cổng 1 — gate bắt buộc trước khi viết code. Mọi feature mới phải qua đây.

---

## Phân loại work

| Loại | Đặc điểm | Required artifact |
|------|----------|-------------------|
| **Tiny** | < 30 phút, không đổi public contract, không touch DB schema | Confirm verbal, có thể code thẳng |
| **Normal** | 30 phút – 1 ngày, touch 1-2 module, không đổi architecture | Story packet ở `stories/` |
| **High-risk** | > 1 ngày HOẶC đổi schema HOẶC đổi public API HOẶC liên quan auth/security/billing | Story + ADR ở `decisions/` |

## Checklist intake (trả lời 6 câu hỏi)

Trước khi code:
- [ ] **Q1 (read first)**: file/section nào cần đọc trước?
- [ ] **Q2 (work type)**: tiny / normal / high-risk?
- [ ] **Q3 (contract)**: chạm vào product contract nào? (API, schema, UI flow)
- [ ] **Q4 (risk)**: rủi ro cụ thể là gì? rollback thế nào?
- [ ] **Q5 (proof)**: làm xong thì kiểm chứng bằng cái gì? (test, manual flow, monitoring)
- [ ] **Q6 (lesson)**: bài học gì cần ghi lại cho future agent?

## Output của intake

- Tiny → confirm verbal, ghi 1 dòng vào `MEMORY/CONTEXT.md` TODO
- Normal → tạo `HARNESS/stories/[ID]-[slug].md` (dùng `templates/story-template.md`)
- High-risk → tạo story **+** `HARNESS/decisions/ADR-XXX-[slug].md` (dùng `templates/adr-template.md`)

## Sau intake → Cổng 2 (hình thái thực thi)

Chọn single / sub-agent / team theo `agent-team-playbook.md` (trong Harness package). Mặc định **single**. Team phải thắng cổng veto + chấm điểm và **đợi user duyệt** trước khi spawn.

## Anti-pattern
- ❌ Code trước, intake sau
- ❌ Skip intake vì "feature nhỏ" mà thực ra touch schema
- ❌ Gộp nhiều feature vào 1 story (mỗi story = 1 deployable unit)
