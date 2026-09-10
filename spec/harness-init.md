# Harness Init — Bảng khởi tạo harness cho mọi dự án

## Mục đích

Một **bảng init harness dùng chung cho MỌI dự án**. Hợp nhất 3 nguồn:
- **Second Brain v2** (`second-brain-v2.md`) — cấu trúc **MEMORY + HARNESS** + 4 nghi lễ.
- **repository-harness** (kiến trúc Tool Registry, Symphony, Phase 5 self-evolving) → rút thành **thang trưởng thành 0→4**.
- **Agent Team Playbook** (`agent-team-playbook.md`) — sau khi intake phân loại *việc gì*, playbook quyết định *chạy bằng hình thái nào* (single / sub-agent / team).

**2 cổng nối tiếp nhau, không chồng nhau:**
```
Yêu cầu → [Cổng 1: FEATURE_INTAKE]  → việc loại gì?  tiny / normal / high-risk
        → [Cổng 2: TEAM PLAYBOOK]   → chạy thế nào?  single / sub-agent / team
        → thực thi
```

> Nguyên tắc: **không init full ngay**. Chọn cấp trưởng thành theo dự án (Bảng 2), init đúng phần đó (Bảng 1), lên cấp khi chạm trigger. Harness là *sản phẩm có backlog của chính nó* — audit → improve → level up.

> Init tất định bằng `harness init` (xem README): script copy đúng artifact của cấp đã chọn, thay token. Bảng dưới là *tham chiếu* để hiểu từng artifact & khi nào lên cấp.

---

## Bảng 1 — Init checklist (tạo gì, ở đâu, khi nào)

Base path mỗi dự án: `{{SECOND_BRAIN_ROOT}}/_projects/[project-name]/`

| # | Artifact | Path | Vai trò | Cấp tối thiểu |
|---|----------|------|---------|:-------------:|
| 1 | `AGENTS.md` | `./AGENTS.md` | Entrypoint — agent đọc đầu tiên, dẫn tới MEMORY + HARNESS | **L0** |
| 2 | `CONTEXT.md` | `MEMORY/CONTEXT.md` | Trạng thái hiện tại của dự án | **L0** |
| 3 | `DECISIONS.md` | `MEMORY/DECISIONS.md` | Log tactical, chronological | **L0** |
| 4 | `MISTAKES.md` | `MEMORY/MISTAKES.md` | Bug đã gặp + cách fix | **L0** |
| 5 | `sessions/` | `MEMORY/sessions/` | Session log append-only | **L0** |
| 6 | `FEATURE_INTAKE.md` | `HARNESS/FEATURE_INTAKE.md` | Phân loại tiny / normal / high-risk + 6 câu hỏi | **L0** |
| 7 | `TEST_MATRIX.md` | `HARNESS/TEST_MATRIX.md` | Behavior → proof | **L0** |
| 8 | `stories/` | `HARNESS/stories/` | Story packet trước khi code | **L0** |
| 9 | `decisions/` | `HARNESS/decisions/` | ADR durable (khác MEMORY/DECISIONS.md) | **L0** |
| 10 | `templates/` | `HARNESS/templates/` | Mẫu story / ADR / intake | **L0** |
| 10b | *Team playbook pointer* | `AGENTS.md` (Operating rules) | Trỏ tới `agent-team-playbook.md` — chọn hình thái sau intake. **Không copy playbook vào dự án**, chỉ trỏ để tránh drift | **L0** |
| 11 | `TOOL_REGISTRY.md` | `HARNESS/TOOL_REGISTRY.md` | Đăng ký capability: lint / test / build / deploy-check | **L1** |
| 12 | `story contract` | `HARNESS/stories/[id].contract.md` | Contract chạy story isolated (input, output, proof) | **L2** |
| 13 | `BOARD.md` | `HARNESS/BOARD.md` | Bảng điều phối work item: ready / in-progress / needs-attention / done | **L3** |
| 14 | `MATURITY.md` | `HARNESS/MATURITY.md` | Harness đang ở cấp nào (self-assessment) | **L4** |
| 15 | `AUDIT.md` | `HARNESS/AUDIT.md` | Tự kiểm harness: docs lệch code? thành phần thiếu? | **L4** |
| 16 | `IMPROVEMENT.md` | `HARNESS/IMPROVEMENT.md` | Quy trình cải tiến harness có kiểm soát | **L4** |

---

## Bảng 2 — Thang trưởng thành harness (chọn cấp theo dự án)

| Cấp | Tên | Có gì | Init thêm (Bảng 1) | Trigger lên cấp | Hợp cho |
|:---:|-----|-------|--------------------|-----------------|---------|
| **L0** | Docs-only | MEMORY + HARNESS docs (AGENTS, intake, test matrix, stories, decisions) | #1–10 | Feature lặp cần công cụ kiểm tra tự động | Mọi dự án thật, solo |
| **L1** | CLI-enforced | Thêm Tool Registry — khai báo tool lint/test/deploy | #11 | Story bắt đầu cần chạy cách ly, có proof rõ | Product có CI |
| **L2** | Isolated runner | Mỗi story chạy trong contract cách ly | #12 | Nhiều story song song, cần theo dõi trạng thái | Team ≥ 1, nhiều luồng |
| **L3** | Orchestrated | Bảng điều phối work item + recovery việc lỗi | #13 | Harness đủ lớn để cần tự kiểm & tự tiến hoá | Long-running 6+ tháng |
| **L4** | Self-evolving | Harness tự audit + improvement protocol + changelog | #14–16 | — (đỉnh thang) | Regulated / mission-critical |

> **Mặc định khởi tạo ở L0.** Prototype/experiment có thể dừng ở v1 thuần (chỉ MEMORY, chưa cần HARNESS).

---

## Bảng 3 — Ánh xạ kiến trúc: repository-harness ↔ Second Brain v2

| Thành phần repository-harness | Vị trí trong Second Brain v2 | Ghi chú |
|-------------------------------|------------------------------|---------|
| `AGENTS.md` | `AGENTS.md` | Giống hệt — entrypoint |
| `docs/HARNESS.md` | `AGENTS.md` (Operating rules) | Gộp cho gọn ở scale solo |
| `docs/FEATURE_INTAKE.md` | `HARNESS/FEATURE_INTAKE.md` | 1-1 |
| `docs/ARCHITECTURE.md` | `MEMORY/CONTEXT.md` (mục Architecture) | Gộp vào context |
| `docs/TEST_MATRIX.md` | `HARNESS/TEST_MATRIX.md` | 1-1 |
| `docs/stories\|decisions\|templates/` | `HARNESS/stories\|decisions\|templates/` | 1-1 |
| Harness CLI + `TOOL_REGISTRY.md` | `HARNESS/TOOL_REGISTRY.md` | Solo: file khai báo thay cho binary |
| Symphony (isolated runner) | `HARNESS/stories/[id].contract.md` | Contract chạy story cách ly |
| Web UI Controller (Electron) | `HARNESS/BOARD.md` | Kanban markdown thay cho desktop app |
| Phase 5: MATURITY / AUDIT / IMPROVEMENT | `HARNESS/MATURITY\|AUDIT\|IMPROVEMENT.md` | 1-1 |
| — (không cần) | `MEMORY/` (CONTEXT/DECISIONS/MISTAKES/sessions) | **Điểm v2 hơn repo gốc**: lớp tri thức tích luỹ |

---

## Bảng 4 — Where to write (dán vào AGENTS.md của mỗi dự án)

| Cái gì | Vào đâu |
|--------|---------|
| Session log | `MEMORY/sessions/YYYY-MM-DD-*.md` |
| Tactical decision (đổi được sau) | `MEMORY/DECISIONS.md` |
| Architecture decision (durable) | `HARNESS/decisions/ADR-XXX-*.md` |
| Bug + fix | `MEMORY/MISTAKES.md` |
| Feature spec trước code | `HARNESS/stories/` |
| Quyết định hình thái (single/sub-agent/team) | Báo cáo user trước khi spawn — ghi vào story nếu normal/high-risk |
| Behavior → proof | `HARNESS/TEST_MATRIX.md` |
| Tool/capability đã trang bị (L1+) | `HARNESS/TOOL_REGISTRY.md` |
| Trạng thái work item (L3+) | `HARNESS/BOARD.md` |
| Đánh giá harness / cải tiến (L4) | `HARNESS/MATURITY.md`, `HARNESS/AUDIT.md`, `HARNESS/IMPROVEMENT.md` |

---

## Bảng 5 — Cổng 2: chọn hình thái thực thi (sau Feature Intake)

Bản rút gọn của `agent-team-playbook.md` — đủ để quyết trong 90% trường hợp. Case khó thì mở playbook đầy đủ.

**Mặc định: KHÔNG dùng team.** Token scale tuyến tính theo số agent — team phải *thắng* cổng này.

**Bước A — VETO (dính 1 cái là loại team ngay):**

| ❌ | Veto |
|----|------|
| 1 | Việc **tuần tự** — bước sau cần output bước trước |
| 2 | Nhiều phần **cùng sửa 1 file** (git worktree không cứu được) |
| 3 | Task **nhỏ / gọn / 1 domain** |
| 4 | Cần **context hội thoại** đã build trong session |

**Bước B — không veto thì chấm điểm (+1 mỗi tín hiệu):** ≥2 domain độc lập · ≥3 giả thuyết cạnh tranh ⭐ · nhiều lens độc lập trên cùng artifact ⭐ · tốt hơn nếu các nhánh không biết kết luận của nhau ⭐ · phần lớn read-only · các phần sở hữu vùng file riêng.

**Bước C — kết luận:** `≥2` → **Team** · `1` → **Sub-agent** · `0` → **Single**

> ⭐ = tín hiệu vàng. Lý do team thắng là **cơ chế**, không phải tốc độ: context tách biệt **chống confirmation bias**.

**Nếu chọn Team:** 3 teammate (max 5) · 5–6 task/người · model theo vai (debug→Opus, implement→Sonnet, check→Haiku) · mỗi người **vùng file riêng** · **nhúng code pointer vào task detail** · plan trước implement · dọn dẹp qua lead.

**Ánh xạ intake → hình thái (gợi ý mặc định):**

| Feature Intake | Hình thái thường gặp |
|----------------|---------------------|
| **tiny** | Single (gần như luôn — dính veto #3) |
| **normal** | Single, hoặc Sub-agent nếu cần gom thông tin trước |
| **high-risk** | Chấm điểm nghiêm túc — chỗ **team review nhiều lens** đáng giá nhất |

---

## Init bằng CLI (thay cho init prompt cũ)

```bash
# Từ thư mục gốc dự án — copy tất định, thay token:
harness init                 # L0, tên = tên folder
harness init --level L1      # chọn cấp trưởng thành
harness init --name my-app   # override tên
```

Sau init (tuỳ chọn) mở AI agent để điền placeholder `[...]` trong CONTEXT.md từ codebase thực — KHÔNG bịa, thiếu thì hỏi user.

## Nghi lễ lên cấp (level-up ritual)

```
Audit harness dự án [TÊN]:
1. Đọc HARNESS/ + MEMORY/. Đối chiếu Bảng 1 cấp hiện tại.
2. Thành phần nào thiếu? Docs nào lệch code thực?
3. Có story/behavior nào chưa có proof trong TEST_MATRIX?
4. Ghi kết quả vào HARNESS/AUDIT.md, đề xuất cải tiến vào HARNESS/IMPROVEMENT.md.
5. Update HARNESS/MATURITY.md: cấp hiện tại + trigger đã chạm để lên cấp kế.
```

---

## Liên kết
- `agent-team-playbook.md` — **Cổng 2**: đầy đủ luật chọn hình thái + dựng team (Bảng 5 là bản rút gọn)
- `second-brain-v2.md` — cấu trúc MEMORY + HARNESS + nghi lễ (nền của bảng này)
