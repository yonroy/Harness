# Agent Team Playbook — Cổng 2: chọn hình thái thực thi

> File hướng dẫn cho **agent**: sau khi Feature Intake phân loại *việc gì* (tiny/normal/high-risk),
> playbook này quyết định *chạy bằng hình thái nào* — single session / sub-agent / agent team.

> **Mặc định là KHÔNG dùng team.** Token scale **tuyến tính** theo số agent. Team phải *thắng được* cổng quyết định ở Bước 2, không phải "cứ thấy việc to là chia".

---

## Bước 1 — Đọc nhiệm vụ, rút 5 dữ kiện

Trước khi quyết gì, trả lời (ngắn, không đoán bừa — thiếu thì **hỏi user**):

| # | Câu hỏi | Vì sao cần |
|---|---------|-----------|
| 1 | Nhiệm vụ chạm những **domain** nào? (FE/BE/infra/docs/test...) | Đếm domain độc lập |
| 2 | Các phần việc có **đụng cùng file** không? | File conflict = veto team |
| 3 | Bước sau có **cần output** bước trước không? | Tuần tự = veto team |
| 4 | Là **read-only** (research/review) hay **có ghi**? | Read-only an toàn để chạy song song |
| 5 | Có **nhiều giả thuyết / nhiều lens** độc lập không? | Đây là chỗ team thắng đậm nhất |

---

## Bước 2 — Cổng quyết định (chạy đúng thứ tự)

### 2a. Kiểm tra VETO trước — dính 1 cái là LOẠI team ngay

| VETO | Lý do |
|------|-------|
| ❌ Việc **tuần tự** — bước sau cần output bước trước | Team không giúp gì, chỉ tốn token |
| ❌ Nhiều phần **cùng sửa 1 file** | Agent ghi đè nhau. (git worktree **không** cứu được) |
| ❌ Task **nhỏ / gọn / 1 domain** | Dùng 1 session hoặc sub-agent |
| ❌ Cần **context hội thoại** đã build trong session này | Teammate **không kế thừa history** của lead |

→ Dính veto: dừng lại, chọn **single session** (hoặc sub-agent nếu chỉ cần 1 kết quả gọn).

### 2b. Không dính veto → chấm điểm tín hiệu ỦNG HỘ team (+1 mỗi cái)

| +1 | Tín hiệu |
|----|----------|
| ☐ | Chạm **≥2 domain độc lập** (FE/BE/architecture...) |
| ☐ | Có **≥3 giả thuyết cạnh tranh** cần điều tra ⭐ |
| ☐ | Cần **nhiều lens độc lập** trên cùng artifact (security/perf/test-coverage) ⭐ |
| ☐ | Kết quả **tốt hơn nếu các nhánh KHÔNG biết kết luận của nhau** (bias risk) ⭐ |
| ☐ | Phần lớn là **read-only** |
| ☐ | Các phần việc **sở hữu vùng file riêng biệt** |

### 2c. Kết luận

| Điểm | Quyết định |
|:----:|-----------|
| **≥2** | ✅ **Agent Team** |
| **1** | 🔸 **Sub-agent** — cần kết quả, không cần cộng tác |
| **0** | ▫️ **Single session** |

> Nguyên tắc gốc: **Sub-agent cho kết quả. Team cho cộng tác.**
> ⭐ = 3 tín hiệu vàng. Có 1 trong 3 cái này thì team gần như luôn thắng, vì lý do **cơ chế**: context tách biệt **chống confirmation bias** — "ngay khi agent nhặt được phần context nó tin là đúng, nó sẽ nghiêng về việc cho rằng mình đúng".

---

## Bước 3 — Báo cáo quyết định cho user (BẮT BUỘC, trước khi spawn)

Không tự ý spawn. Trình bày đúng format này rồi **đợi user duyệt**:

```
QUYẾT ĐỊNH: [Single session | Sub-agent | Agent Team]

Lý do:
- Veto: [không có / dính: ...]
- Điểm tín hiệu: X/6 → [liệt kê tín hiệu trúng]

[Nếu là Team] Đề xuất đội hình:
| Teammate | Vai trò | Model | Sở hữu file/vùng | Read-only? |
|----------|---------|-------|------------------|-----------|
| ...      | ...     | ...   | ...              | ...       |

Ước tính: N teammate × ~M task. Token ~N lần so với 1 session.
```

---

## Bước 4 — Nếu là Team: dựng đội theo luật

### Luật đội hình
- **Bắt đầu 3 teammate.** Tối đa 3–5. Hơn 3 thường overkill.
- **5–6 task/teammate.** Làm 1 việc gọn → gom lại → mới sang đợt kế. Không ôm hết cùng lúc.
- **Mỗi teammate sở hữu vùng file riêng.** Không chồng lấn.
- **Chỉ định model theo vai** (cách rẻ nhất để giảm token):

| Vai | Model gợi ý |
|-----|-------------|
| Debug / reasoning nặng | Opus |
| Implement / review thường | Sonnet |
| Check gọn, đối chiếu, format | Haiku |

- **Ưu tiên read-only trước** (review/research) — tránh file conflict khi còn đang khám phá.

### Luật context (chỗ hay hỏng nhất)
Teammate load `CLAUDE.md` + MCP như agent thường, nhưng **KHÔNG lấy lịch sử hội thoại của lead**. Chúng **không chia sẻ context** — chỉ trao đổi qua **message**.

→ **Bắt buộc**: nhúng **code pointer + phát hiện đã gom** vào *chi tiết từng task*. Đừng kỳ vọng teammate tự biết.

### Luật plan
**Phải có plan trước khi implement.** Bắt teammate lập plan (read-only) → lead duyệt → mới cho code.

### Prompt spawn mẫu
```
Tạo agent team cho nhiệm vụ: [MÔ TẢ].

Đội hình:
- [tên]: [vai trò] — model [X] — sở hữu [vùng file] — [read-only?]
- ...

Luật:
- Lập plan trước, tôi duyệt rồi mới implement.
- Nhúng code pointer đã gom được vào chi tiết từng task (teammate không có history của tôi).
- Mỗi teammate chỉ đụng vùng file của mình.
- Quality bar: [tiêu chí].
- Không teammate nào tự ý mở rộng scope.
```

---

## Bước 5 — Chạy & lái

| Việc | Luật |
|------|------|
| **Lead tự nhảy vào code** | Bẫy hay gặp → chặn ngay: *"delegate đi"* / *"đợi team xong đã"* |
| **Guide** | Ra lệnh **qua lead**, không đi từng teammate → trickle down cả đội |
| **Message** | Tự đến, không cần polling. Lead được notify khi teammate xong → **chỉ cần nhìn lead** |
| **Giám sát** | **Monitor & steer** — chạy lâu không người lái sẽ đi chệch và đốt token |
| **Dọn dẹp** | **Luôn tắt qua lead.** Tự tắt tay → trạng thái lạ / memory leak. Teammate idle lâu tự tắt |

---

## Bảng tra nhanh: nhiệm vụ → hình thái

| Nhiệm vụ | Chọn | Đội hình |
|----------|------|----------|
| Sửa 1 bug gọn, 1 file | Single | — |
| Tìm hiểu "code X nằm đâu" | Sub-agent | Explore (read-only) |
| Review PR toàn diện | ✅ **Team** | security / performance / test-coverage → lead gộp |
| Debug có 3–5 giả thuyết | ✅ **Team** ⭐ | mỗi teammate 1 giả thuyết, read-only, xong chia sẻ note |
| Feature full-stack (FE+BE+schema) | ✅ **Team** | frontend / backend / architecture — tách vùng file |
| Refactor 1 module theo thứ tự | Single | veto: tuần tự |
| 3 người cùng sửa 1 trang UI | Single | veto: file conflict |
| Viết bài dài có nghiên cứu | ✅ **Team** | context-gatherer(RO) / writer / editor |
| Audit docs lệch code | ✅ **Team** | chia theo module, read-only |

---

## Checklist trước khi spawn (tự soát)

- ☐ Đã chạy cổng veto — không dính cái nào?
- ☐ Điểm ≥2?
- ☐ Đã **báo cáo quyết định + đợi user duyệt**?
- ☐ Mỗi teammate có **vùng file riêng**, không chồng?
- ☐ Đã **nhúng context/code pointer vào task detail**?
- ☐ Đã **gán model theo vai**?
- ☐ ≤5 teammate, ≤6 task/người?
- ☐ Có yêu cầu **plan trước implement**?

---

## Liên kết
- `harness-init.md` — Cổng 2 là Bảng 5 rút gọn của file này; playbook này là bản đầy đủ.
- `second-brain-v2.md` — cấu trúc MEMORY + HARNESS + 4 nghi lễ.
