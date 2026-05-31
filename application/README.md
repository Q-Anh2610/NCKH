# Sliding Cubes Compaction Simulator (Ứng dụng Mô phỏng Nén Khối Trượt)
Chào mừng bạn đến với **Sliding Cubes Compaction Simulator**, một ứng dụng web/desktop được xây dựng bằng **Flutter** nhằm mô phỏng và trực quan hóa các thuật toán nén cho bài toán khối trượt (sliding cubes) trong không gian 2D và 3D. Dự án này là một phần của đề tài Nghiên cứu Khoa học (NCKH).
## Tính năng chính
- **Hỗ trợ không gian 2D và 3D**: Trực quan hóa cấu trúc lưới và các bước di chuyển của các khối lập phương trong cả hai hệ tọa độ.
- **Trình chỉnh sửa lưới tương tác (Interactive Grid Editor)**: Cho phép người dùng trực tiếp nhấp chuột lên lưới 2D hoặc các lớp lưới 3D để thêm hoặc xóa các khối (blocks) một cách nhanh chóng.
- **Thuật toán Nén đa dạng**:
  - *Greedy Potential Reduction*: Thuật toán tham lam giảm thế năng (hiện đang được kích hoạt ở backend).
  - *Paper-Inspired Compaction*: Thuật toán lấy cảm hứng từ các bài báo khoa học liên quan.
  - *Random Valid Moves*: Các bước di chuyển ngẫu nhiên hợp lệ để so sánh hiệu quả.
- **Trình điều khiển mô phỏng trực quan**:
  - Phát/Tạm dừng (Play/Pause) mô phỏng.
  - Chuyển tiếp/Lùi lại từng bước (Step Forward/Backward).
  - Điều chỉnh tốc độ mô phỏng (Playback Speed).
  - Reset về trạng thái ban đầu.
- **Phân tích số liệu trực quan (Analytics & Logs)**:
  - Biểu đồ biến thiên thế năng (Potential Chart) qua từng bước chạy.
  - Bảng ghi lịch sử chi tiết (Step Log Table) ghi nhận tọa độ và hướng di chuyển của từng khối tại mỗi bước.
- **Đa dạng nguồn đầu vào**:
  - Chọn từ danh sách cấu hình mẫu có sẵn (Sample Configuration).
  - Nhập trực tiếp cấu hình dưới định dạng JSON.
  - Khởi tạo cấu hình ngẫu nhiên (Random Generator).
  - Vẽ trực tiếp trên lưới (Grid Interactive).
## 🛠️ Công nghệ sử dụng
- **Frontend**: Flutter Web (sử dụng Material 3, hỗ trợ Responsive hoàn hảo trên Web, Tablet và Desktop).
- **Backend API**: Python API được deploy trên Hugging Face Spaces (`https://sliding-cubes-lab-sliding-cubes-api.hf.space`).
- **State Management & Controller**: Mô hình Controller/Presenter tùy chỉnh kết hợp với `AnimatedBuilder` giúp tối ưu hiệu năng hiển thị 3D/2D mượt mà.
## Hướng dẫn chạy chương trình dưới local
### Yêu cầu hệ thống
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (Khuyến nghị phiên bản mới nhất hỗ trợ Material 3).
- Trình duyệt Chrome hoặc Edge (để chạy bản Web).
### Các bước thực hiện
1. **Di chuyển vào thư mục ứng dụng**:
   ```bash
   cd application
   ```
2. **Cài đặt các gói phụ thuộc (dependencies)**:
   ```bash
   flutter pub get
   ```
3. **Chạy ứng dụng**:
   - **Chạy trên Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **Chạy trên các thiết bị/nền tảng khác (nếu có)**:
     ```bash
     flutter run
     ```
4. **Build ứng dụng Web**:
   ```bash
   flutter build web --release
   ```
   Sau khi build xong, mã nguồn tĩnh của Web sẽ nằm trong thư mục `build/web`.
## Cấu trúc định dạng JSON mẫu (Input Schema)
Định dạng cấu hình của một bài toán nén được lưu trữ dưới dạng JSON như sau:
```json
{
  "dimension": 3,
  "max_steps": 150,
  "blocks": [
    [0, 0, 0],
    [1, 0, 0],
    [1, 1, 0],
    [0, 1, 1]
  ]
}
```
Trong đó:
- `dimension`: Chiều không gian (2 hoặc 3).
- `max_steps`: Số bước tối đa cho phép mô phỏng.
- `blocks`: Danh sách các tọa độ điểm của các khối. Với 2D tọa độ là `[x, y]`, với 3D tọa độ là `[x, y, z]`.
---
Chúc bạn có những trải nghiệm nghiên cứu và mô phỏng hiệu quả với dự án!
