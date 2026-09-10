# Cài đặt Harness trên máy mới

Package chỉ cần **một biến môi trường** để chạy: `SECOND_BRAIN_ROOT` — trỏ tới hub chứa `_projects/` và `_global/`.

---

## 1. Clone package

```bash
git clone <repo-url> D:/SecondBrain/Harness
```

Có thể clone vào bất kỳ đâu; script không phụ thuộc vị trí của chính nó.

---

## 2. Set `SECOND_BRAIN_ROOT`

Hub là nơi memory từng dự án được lưu. Nó **tách khỏi** package và **không** lên git của package.

### Windows (PowerShell)

```powershell
setx SECOND_BRAIN_ROOT "D:\SecondBrain"
```

Mở lại terminal để biến có hiệu lực. Kiểm tra: `echo $env:SECOND_BRAIN_ROOT`.

### Mac / Linux (bash/zsh)

```bash
echo 'export SECOND_BRAIN_ROOT="$HOME/SecondBrain"' >> ~/.profile
source ~/.profile
```

### Cách khác — file `.harnessrc`

Nếu không muốn set env var toàn hệ thống, tạo file `~/.harnessrc` với đúng 1 dòng là đường dẫn hub:

```
D:\SecondBrain
```

Script sẽ đọc file này khi env var trống.

> Thứ tự resolve: `SECOND_BRAIN_ROOT` (env) → `~/.harnessrc` → lỗi (báo hướng dẫn, không đoán bừa).

---

## 3. Alias `harness` (tuỳ chọn, nên làm)

### Windows — thêm vào `$PROFILE`

```powershell
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
notepad $PROFILE
```

Dán vào:

```powershell
function harness { & "D:\SecondBrain\Harness\bin\harness.ps1" @args }
```

Lưu, mở lại PowerShell (hoặc `. $PROFILE`).

### Mac / Linux — thêm vào `~/.profile` hoặc `~/.zshrc`

```bash
alias harness="bash /path/to/Harness/bin/harness.sh"
```

---

## 4. Dùng

Từ thư mục gốc của bất kỳ dự án:

```bash
harness init                     # L0, tên project = tên folder hiện tại
harness init --level L1          # chọn cấp trưởng thành
harness init --name my-app       # override tên (folder trong _projects/)
harness init --path D:\code\x    # override path codebase
harness help
```

---

## 5. Dùng nhiều máy

- Package: `git clone` mỗi máy, `git pull` để cập nhật spec/template.
- Hub (`_projects/`, `_global/`): **quản lý riêng** — có thể là repo private khác, thư mục sync (OneDrive/Dropbox/Syncthing), hoặc git riêng. Package cố tình `.gitignore` `_projects/` và `_global/` để không trộn lẫn.

---

## Troubleshooting

| Triệu chứng | Cách xử lý |
|---|---|
| `SECOND_BRAIN_ROOT chưa được set` | Làm lại Bước 2, mở lại terminal. |
| PowerShell chặn script | `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` |
| Tiếng Việt lỗi font trong file sinh ra | Script ghi UTF-8; đảm bảo terminal dùng UTF-8. |
| `harness.sh` báo permission denied | `chmod +x bin/harness.sh` hoặc gọi qua `bash bin/harness.sh`. |
