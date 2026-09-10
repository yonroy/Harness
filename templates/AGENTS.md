# AGENTS.md — {{PROJECT_NAME}}

> Entrypoint cho mọi AI agent làm việc trên project này. Đọc file này TRƯỚC khi đụng code.
> File nằm trong memory hub: `{{SECOND_BRAIN_ROOT}}/_projects/{{PROJECT_NAME}}/`.
> Codebase thực tế: `{{PROJECT_PATH}}`.

## Read first (theo thứ tự)

1. `MEMORY/CONTEXT.md` — trạng thái hiện tại của project
2. `HARNESS/FEATURE_INTAKE.md` — Cổng 1: phân loại work (tiny / normal / high-risk)
3. `{{SECOND_BRAIN_ROOT}}/_global/my-stack.md` — preferences của user (nếu có)

## Operating rules — 2 cổng nối tiếp

```
Yêu cầu → [Cổng 1: FEATURE_INTAKE]  → việc loại gì?  tiny / normal / high-risk
        → [Cổng 2: TEAM PLAYBOOK]   → chạy thế nào?  single / sub-agent / team
        → thực thi
```

- ❌ **KHÔNG** jump to code. Mọi feature mới phải qua **Cổng 1** trước.
- ✅ Sau intake → **Cổng 2** chọn hình thái thực thi. Mặc định **KHÔNG dùng team**.
  Luật đầy đủ: `<đường dẫn Harness package>/spec/agent-team-playbook.md`. VETO team nếu: việc tuần tự · nhiều phần cùng sửa 1 file · task nhỏ 1 domain · cần context hội thoại trong session.
- ✅ Decision kiến trúc durable → `HARNESS/decisions/ADR-XXX-[slug].md`
- ✅ Decision tactical (session-scope) → `MEMORY/DECISIONS.md`
- ✅ Behavior mới → update `HARNESS/TEST_MATRIX.md`
- ✅ Cuối session: chạy Nghi lễ 3 (End session)

## Where to write

| Cái gì | Vào đâu |
|--------|---------|
| Session log | `MEMORY/sessions/YYYY-MM-DD-[name].md` |
| Tactical decision | `MEMORY/DECISIONS.md` (append) |
| Architecture decision (durable) | `HARNESS/decisions/ADR-XXX-[slug].md` (file mới) |
| Bug + fix | `MEMORY/MISTAKES.md` (append) |
| Feature spec trước code | `HARNESS/stories/[id]-[slug].md` (file mới) |
| Behavior → proof | `HARNESS/TEST_MATRIX.md` (append row) |
| Context fact mới | `MEMORY/CONTEXT.md` (update section) |
| Quyết định hình thái (single/sub-agent/team) | Báo cáo user trước khi spawn; ghi vào story nếu normal/high-risk |

## Feature flow (bắt buộc)

```
User intent
   ↓
[Cổng 1] HARNESS/FEATURE_INTAKE.md  →  classify (tiny / normal / high-risk)
   ↓
Tiny? → có thể code ngay sau confirm
Normal/High-risk? → tạo HARNESS/stories/[id].md trước
   ↓
[Cổng 2] chọn hình thái  →  single / sub-agent / team  (team thì đợi user duyệt)
   ↓
Implement
   ↓
Update HARNESS/TEST_MATRIX.md (behavior → proof)
   ↓
End session (Nghi lễ 3)
```

## 6 câu hỏi Harness phải trả lời được (trước khi đụng code)

1. What should I read first? → `MEMORY/CONTEXT.md`
2. What type of work is this? → FEATURE_INTAKE classify
3. Which product contract does it affect? → CONTEXT.md "Tổng quan" + stories
4. How risky is the change? → tiny / normal / high-risk
5. What proof will show the work is done? → TEST_MATRIX entry
6. What decision or lesson should future agents inherit? → ADR hoặc MISTAKES

## Project info

- **Name:** {{PROJECT_NAME}}
- **Codebase:** {{PROJECT_PATH}}
- **Memory hub:** {{SECOND_BRAIN_ROOT}}/_projects/{{PROJECT_NAME}}/
- **Stack:** {{STACK}}
- **Started:** {{DATE}}
