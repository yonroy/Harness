<!-- SECOND-BRAIN-V2:START — block do `harness init` quản lý. An toàn để chèn/cập nhật lại. Nội dung ngoài 2 marker này không bị đụng tới. -->
## Second Brain v2 — Entrypoint

Project này dùng Harness (MEMORY + HARNESS). Đọc theo thứ tự trước khi làm bất cứ gì:

1. `{{SECOND_BRAIN_ROOT}}\_projects\{{PROJECT_NAME}}\AGENTS.md` — agent entrypoint (v2)
2. `{{SECOND_BRAIN_ROOT}}\_projects\{{PROJECT_NAME}}\MEMORY\CONTEXT.md` — trạng thái dự án
3. `{{SECOND_BRAIN_ROOT}}\_projects\{{PROJECT_NAME}}\HARNESS\FEATURE_INTAKE.md` — Cổng 1: phân loại work
4. `{{SECOND_BRAIN_ROOT}}\_global\my-stack.md` — preferences cá nhân (nếu có)

**Quy tắc cốt lõi:**
- ❌ KHÔNG jump-to-code. Feature normal/high-risk phải qua Feature Intake trước.
- ❌ KHÔNG tự `git commit`/`git push` khi chưa được xác nhận.
- ✅ Architecture decision durable → `HARNESS/decisions/ADR-XXX.md`
- ✅ Tactical decision session-scope → `MEMORY/DECISIONS.md`
- ✅ Behavior mới → update `HARNESS/TEST_MATRIX.md`
- ✅ Cuối session (Nghi lễ 3): update CONTEXT.md + tạo `MEMORY/sessions/YYYY-MM-DD-[name].md`.

Nếu `AGENTS.md` hoặc `MEMORY/CONTEXT.md` chưa tồn tại → báo user chạy `harness init`.
<!-- SECOND-BRAIN-V2:END -->
