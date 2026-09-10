# Story Contract [ID] — {{PROJECT_NAME}} (L2+)

> Contract chạy story cách ly (Symphony-style). Định nghĩa input/output/proof để story chạy độc lập, không cần context hội thoại.

## Input
- Precondition: [state trước khi chạy]
- Files được phép đụng: [vùng file — không ra ngoài]
- Data mẫu / fixtures: [nếu có]

## Output
- Deliverable: [cái gì được tạo/sửa]
- Postcondition: [state sau khi chạy]

## Proof (cách nghiệm thu tự động)
- Command: `[lệnh chạy để verify]`
- Expected: [kết quả pass trông thế nào]
- Link TEST_MATRIX: B-XXX

## Isolation
- Không đụng ngoài vùng file khai báo.
- Không cần history session — mọi context cần thiết nhúng ở đây.
