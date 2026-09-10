# Harness — portable Second Brain v2 scaffold

Bộ khởi tạo **kỷ luật kỹ thuật cho AI agent** (Claude Code, Cursor, Copilot…) dùng chung cho **mọi dự án, mọi máy**.

Mỗi dự án được cấp một "second brain": lớp **MEMORY** (tri thức tích luỹ) + lớp **HARNESS** (cổng quy trình trước khi code). Package này chứa spec + template + script init; nó **không** chứa memory của dự án nào — memory sống trong một *hub tập trung* mà bạn trỏ tới qua biến môi trường `SECOND_BRAIN_ROOT`.

> A portable scaffolding toolkit that drops a MEMORY + HARNESS "second brain" into any project. The package holds only specs, templates and an init script — no project memory. Project memory lives in a central hub pointed to by `SECOND_BRAIN_ROOT`.

---

## Ý tưởng cốt lõi

```
SECOND_BRAIN_ROOT/               ← hub tập trung (KHÔNG nằm trong package, không lên git package)
├── _global/                     ← preferences cá nhân dùng chung mọi dự án
│   ├── my-stack.md
│   ├── patterns.md
│   └── mistakes.md
└── _projects/
    └── <project-name>/          ← harness init tạo ở đây
        ├── AGENTS.md            ← entrypoint agent đọc đầu tiên
        ├── MEMORY/              ← CONTEXT / DECISIONS / MISTAKES / sessions
        └── HARNESS/            ← FEATURE_INTAKE / TEST_MATRIX / stories / decisions / templates

Harness/                         ← package NÀY (git clone → GitHub)
├── bin/harness.ps1 | harness.sh ← script init (copy file + thay token)
├── templates/                   ← nguyên liệu scaffold
└── spec/                        ← tài liệu tham chiếu (đọc khi cần)
```

`harness init` copy template vào `SECOND_BRAIN_ROOT/_projects/<name>/`, đồng thời tạo/merge `CLAUDE.md` + `AGENTS.md` ngay trong codebase dự án.

---

## Cài đặt nhanh

```bash
git clone <repo-url> D:/SecondBrain/Harness      # hoặc bất kỳ đâu

# Windows (PowerShell)
setx SECOND_BRAIN_ROOT "D:\SecondBrain"          # set 1 lần, mở lại terminal

# Mac/Linux (bash)
echo 'export SECOND_BRAIN_ROOT="$HOME/SecondBrain"' >> ~/.profile && source ~/.profile
```

Chi tiết + alias: xem [docs/INSTALL.md](docs/INSTALL.md).

---

## Dùng

Từ thư mục gốc của **bất kỳ dự án nào**:

```powershell
# Windows
& "D:\SecondBrain\Harness\bin\harness.ps1" init                 # L0, tên = tên folder
& "D:\SecondBrain\Harness\bin\harness.ps1" init --level L1
& "D:\SecondBrain\Harness\bin\harness.ps1" init --name my-app --path D:\code\my-app
```

```bash
# Mac/Linux
bash /path/to/Harness/bin/harness.sh init --level L0
```

Sau khi có alias `harness` (xem INSTALL): chỉ cần `harness init`.

---

## Thang trưởng thành (chọn `--level`)

| Cấp | Tên | Thêm gì | Hợp cho |
|:---:|-----|---------|---------|
| **L0** | Docs-only | MEMORY + HARNESS docs (mặc định) | mọi dự án thật, solo |
| **L1** | CLI-enforced | + `HARNESS/TOOL_REGISTRY.md` | product có CI |
| **L2** | Isolated runner | + `HARNESS/stories/*.contract.md` | nhiều luồng song song |
| **L3** | Orchestrated | + `HARNESS/BOARD.md` | long-running 6+ tháng |
| **L4** | Self-evolving | + `MATURITY / AUDIT / IMPROVEMENT.md` | regulated / mission-critical |

Mặc định **L0**. Script chỉ copy artifact đúng cấp — không tạo thừa. Lên cấp khi chạm trigger (xem [spec/harness-init.md](spec/harness-init.md), Bảng 2).

---

## Sau khi init (tuỳ chọn — dùng AI điền chi tiết)

Init là **copy tất định**: các chỗ cần suy luận từ codebase để nguyên placeholder `[...]`. Muốn điền tự động, mở Claude Code trong dự án rồi:

```
Đọc AGENTS.md + MEMORY/CONTEXT.md. Đọc codebase (2 level, manifest, README).
Điền các placeholder [...] trong CONTEXT.md từ stack + cấu trúc thực. KHÔNG bịa, thiếu thì hỏi tôi.
```

---

## Tài liệu tham chiếu (đọc khi cần)

- [spec/harness-init.md](spec/harness-init.md) — 5 bảng: init checklist, thang trưởng thành, ánh xạ, where-to-write, cổng 2.
- [spec/second-brain-v2.md](spec/second-brain-v2.md) — spec đầy đủ MEMORY + HARNESS + 4 nghi lễ.
- [spec/agent-team-playbook.md](spec/agent-team-playbook.md) — Cổng 2: khi nào single / sub-agent / team.
