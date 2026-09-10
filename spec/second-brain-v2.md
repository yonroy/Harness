# Second Brain v2 — Memory + Harness

## Tóm tắt

Second Brain v2 = **MEMORY layer** (knowledge accumulation) + **HARNESS layer** (process gates, artifact-driven work). v1 trả lời *"agent cần biết gì"*. v2 thêm *"agent làm việc thế nào"*. Kết quả: project có cả tri thức tích lũy **và** quy trình có kiểm soát trước khi agent viết code.

> v1 là Second Brain. v2 là Second Brain + Harness. Cùng folder structure, thêm một layer.

---

## Cho agent (khi có file này trong context)

**1. Phạm vi** — Đây là **synthesis của 2 paradigm** (Memory + Harness), KHÔNG phải spec một sản phẩm. Mọi yêu cầu *"set up v2"*, *"audit harness"*, *"migrate sang v2"* → trace về đây.

**2. "Tạo Second Brain v2 cho project X"** — chạy `harness init` (xem README), tạo đúng cấu trúc tại `{{SECOND_BRAIN_ROOT}}/_projects/[project-name]/`. Confirm với user trước khi tạo nhiều file.

**3. Feature request trong project đã có v2** — ❌ KHÔNG jump to code. Chạy **Nghi lễ 2.5 (Feature Intake)** trước: classify *tiny / normal / high-risk*. Tiny → code sau confirm. Normal/high-risk → tạo story trước.

**4. "Review/audit project X"** — đọc `AGENTS.md`, `MEMORY/`, `HARNESS/`; báo cáo đang ở bước nào, thiếu gì, pain point nào trigger bước tiếp.

**5. Cuối session** — chạy **Nghi lễ 3**. Phân biệt rõ: tactical (session-scope) → `MEMORY/DECISIONS.md`; architecture (durable) → `HARNESS/decisions/ADR-xxx.md`. Update `TEST_MATRIX.md` nếu có behavior mới.

**6. Xung đột v1↔v2** — project chỉ có `MEMORY/`, không `HARNESS/` → đang ở v1, **đừng force v2**. Hỏi user có muốn migrate không.

**7. Output style** — khi báo cáo intake: liệt kê đủ 6 câu hỏi (Q1–Q6). Tạo story/ADR: dùng template trong `HARNESS/templates/`.

---

## Vì sao cần v2?

### Giới hạn v1 (Second Brain thuần)
- MEMORY tốt cho context, nhưng agent vẫn "jump to code" ngay khi nhận prompt.
- Không có **gate** trước implementation → code xong mới phát hiện sai requirement.
- `DECISIONS.md` là log chronological — durable architecture decisions lẫn vào tactical notes.
- Không có **risk classification** (tiny / normal / high-risk).
- Validation **implicit** — không có behavior → proof mapping rõ ràng.

### Giới hạn Harness thuần
- Tập trung vào *process/artifact* hiện tại, không có cơ chế tích lũy bài học qua thời gian.
- Không có **cross-project knowledge**. Mỗi project là silo.

### v2 = kết hợp
- **MEMORY**: passive context, knowledge tích lũy theo session.
- **HARNESS**: active process gates, artifact-driven trước code.
- Hai layer **độc lập nhưng bổ sung** — không gộp vào nhau.

---

## Kiến trúc v2

```
{{SECOND_BRAIN_ROOT}}/
├── _projects/
│   └── [project-name]/
│       ├── AGENTS.md              ← entrypoint, agent đọc đầu tiên
│       │
│       ├── MEMORY/                ← passive context
│       │   ├── CONTEXT.md         ← trạng thái hiện tại
│       │   ├── DECISIONS.md       ← tactical log (chronological)
│       │   ├── MISTAKES.md        ← bug đã gặp
│       │   └── sessions/          ← session log, append-only
│       │
│       └── HARNESS/               ← active process
│           ├── FEATURE_INTAKE.md  ← phân loại tiny/normal/high-risk
│           ├── TEST_MATRIX.md     ← behavior → proof
│           ├── stories/           ← story packet pre-code
│           ├── decisions/         ← durable ADR (khác MEMORY/DECISIONS.md)
│           └── templates/         ← story / adr / intake
│
└── _global/                       ← cross-project
    ├── my-stack.md
    ├── patterns.md
    └── mistakes.md
```

---

## Sự khác biệt v1 ↔ v2

| Khía cạnh | v1 | v2 |
|-----------|----|----|
| Layer | MEMORY only | MEMORY + HARNESS |
| Focus | What agent should *know* | What + *How* agent should work |
| Entrypoint | CONTEXT.md | AGENTS.md → MEMORY + HARNESS |
| Pre-code gate | Không có | Feature intake bắt buộc |
| Risk classification | Implicit | Tiny / normal / high-risk |
| Validation | Implicit | TEST_MATRIX (behavior → proof) |
| Decisions | DECISIONS.md (log) | MEMORY/DECISIONS.md (log) + HARNESS/decisions/ (ADR durable) |

---

## Nghi lễ v2

### Nghi lễ 1 — Khởi tạo dự án
Chạy `harness init` (xem README). Tạo AGENTS.md + MEMORY/ + HARNESS/ đúng cấp trưởng thành.

### Nghi lễ 2 — Start session
```
Đọc AGENTS.md trước. Từ đó load MEMORY/CONTEXT.md. Đọc _global/my-stack.md (nếu có).
Tóm tắt trạng thái hiện tại để confirm đã load đúng.
```

### Nghi lễ 2.5 — Feature Intake (bắt buộc trước khi code feature mới)
```
Tôi muốn làm: [INTENT].
Qua HARNESS/FEATURE_INTAKE.md:
1. Loại work nào (tiny / normal / high-risk)?
2. Chạm product contract nào?
3. Validation proof nào chứng minh "done"?
4. Quyết định kiến trúc nào cần ghi?
5. Nếu normal/high-risk: tạo story tại HARNESS/stories/.
Chỉ bắt đầu code sau khi intake xong.
```

### Nghi lễ 3 — End session
```
1. Update MEMORY/CONTEXT.md
2. Tạo session log: MEMORY/sessions/YYYY-MM-DD-[name].md
3. Tactical decision → MEMORY/DECISIONS.md (append)
4. Bug đã fix → MEMORY/MISTAKES.md (append)
5. Architecture decision durable → HARNESS/decisions/ADR-XXX.md (file mới)
6. Story hoàn thành → mark done ở HARNESS/stories/
7. Behavior mới → HARNESS/TEST_MATRIX.md (append row)
```

### Nghi lễ 4 — Weekly review
```
1. Sessions: pattern nào lên _global/patterns.md?
2. Mistakes lặp lại → _global/mistakes.md
3. ADR mới tổng quát hóa được → HARNESS/templates/
4. TEST_MATRIX có hole nào (behavior chưa có proof)?
```

---

## Khi nào dùng v1, khi nào v2?

| Tình huống | v1 đủ | Cần v2 |
|------------|:----:|:----:|
| Solo experiment / prototype | ✅ | — |
| Side project < 100h | ✅ | — |
| Real product, có user | — | ✅ |
| Team > 1 người | — | ✅ |
| Regulated (legal/compliance) | — | ✅ |
| High-risk migration | — | ✅ |
| Long-running (6+ tháng) | — | ✅ |
| AI agent quyền cao (write code, deploy) | — | ✅ |

---

## Tóm tắt 1 dòng cho mỗi level
- **v0**: Không có gì, mỗi session AI khởi tạo lại context bằng tay.
- **v1**: MEMORY tích lũy — AI có context, nhưng vẫn jump-to-code.
- **v2**: MEMORY + HARNESS — AI có context **và** đi qua intake/story/validation trước khi code.

---

## Liên kết
- `harness-init.md` — bảng init + thang trưởng thành L0→L4.
- `agent-team-playbook.md` — Cổng 2: single / sub-agent / team.
