# Tool Registry — {{PROJECT_NAME}} (L1+)

> Khai báo capability đã trang bị để agent biết "dùng gì để kiểm chứng".
> Mỗi tool: `kind` = cli / binary / mcp / skill / http.

---

| Capability | Kind | Lệnh / endpoint | Ghi chú |
|------------|------|-----------------|---------|
| lint | cli | `[lệnh lint]` | CI gate? |
| test | cli | `[lệnh test]` | unit / integration |
| build | cli | `[lệnh build]` | |
| deploy-check | cli | `[lệnh]` | dry-run trước deploy |

<!-- Thêm dòng khi trang bị tool mới. Agent phải ưu tiên tool ở đây thay vì tự chế lệnh. -->
