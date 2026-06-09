# NCKH - Sliding Cubes Compaction Simulator

Dự án này được xây dựng phục vụ đề tài Nghiên cứu Khoa học về bài toán nén khối trượt trong không gian 2D và 3D. Mục tiêu của dự án là mô phỏng, triển khai và trực quan hóa quá trình đưa một cấu hình các khối rời rạc về trạng thái compact hơn thông qua các phép di chuyển hợp lệ.

Dự án gồm hai phần chính:

* `algorithm_2d_3d/`: Backend Python triển khai thuật toán nén khối trượt 2D/3D và cung cấp API bằng FastAPI.
* `application/`: Ứng dụng Flutter dùng để nhập cấu hình, gọi thuật toán từ backend và trực quan hóa quá trình mô phỏng.

---

## 1. Demo API online

Backend API đã được triển khai trên Hugging Face Space. Có thể chạy thử trực tiếp tại:

```text
https://sliding-cubes-lab-sliding-cubes-api.hf.space/docs
```

Endpoint chính:

```text
POST /compact
```

Link test trực tiếp endpoint `/compact`:

```text
https://sliding-cubes-lab-sliding-cubes-api.hf.space/docs#/default/compact_api_compact_post
```

Người dùng có thể mở link trên, chọn **Try it out**, nhập JSON input và bấm **Execute** để xem kết quả trả về.

---

## 2. Giới thiệu bài toán

Bài toán nén khối trượt xét một tập các ô/khối trên lưới nguyên. Mỗi khối có thể di chuyển theo một số quy tắc hình học nhất định, ví dụ như:

* **Slide**: trượt một khối sang vị trí lân cận khi thỏa mãn điều kiện điểm tựa.
* **Convex transition**: di chuyển theo dạng chuyển tiếp qua góc lồi trong một cấu trúc cục bộ.

Trong quá trình di chuyển, thuật toán cần đảm bảo cấu hình vẫn liên thông và hướng tới trạng thái compact/finished, tức là các khối được dồn về gần gốc tọa độ hơn và hạn chế tạo ra lỗ hổng trong cấu hình.

---

## 3. Cấu trúc thư mục

```text
NCKH/
│
├── algorithm_2d_3d/
│   ├── main.py              # FastAPI server
│   ├── compaction.py        # Bộ điều phối thuật toán 2D/3D
│   ├── algorithm_2d_1.py    # Thuật toán nén khối trượt trong 2D
│   ├── algorithm_3d_1.py    # Thuật toán nén khối trượt trong 3D
│   ├── utils.py             # Các hàm tiện ích: liên thông, potential, move, response
│   ├── validator.py         # Kiểm tra tính hợp lệ của input
│   ├── requirements.txt     # Thư viện Python cần cài đặt
│   ├── Dockerfile           # Cấu hình build backend
│   └── README.md            # Tài liệu riêng cho phần thuật toán/backend
│
├── application/
│   ├── lib/                 # Mã nguồn chính của ứng dụng Flutter
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── linux/
│   ├── macos/
│   ├── pubspec.yaml         # Cấu hình dependencies Flutter
│   └── README.md            # Tài liệu riêng cho phần ứng dụng
│
└── README.md                # Tài liệu tổng quan của toàn bộ dự án
```

---

## 4. Chức năng chính

### Backend thuật toán

Phần backend trong `algorithm_2d_3d/` có các chức năng:

* Nhận cấu hình khối 2D hoặc 3D từ client.
* Kiểm tra input hợp lệ.
* Chạy thuật toán nén tương ứng với số chiều.
* Trả về danh sách từng bước di chuyển, bao gồm.


### Ứng dụng mô phỏng

Phần `application/` là ứng dụng Flutter dùng để:

* Nhập hoặc tạo cấu hình khối 2D/3D.
* Gọi API backend để chạy thuật toán.
* Hiển thị quá trình nén theo từng bước.
* Theo dõi lịch sử move và giá trị potential.
* Hỗ trợ mô phỏng trực quan cho mục đích nghiên cứu và trình bày.

---

## 5. Công nghệ sử dụng

### Backend

* Python
* FastAPI
* Uvicorn
* Pydantic
* Docker

### Frontend/Application

* Flutter
* Dart
* HTTP package
* Chart/visualization package

---

## 6. Chạy project ở môi trường local

Lưu ý: GitHub chỉ dùng để lưu trữ mã nguồn. Để chạy backend hoặc frontend ở môi trường local, cần clone hoặc tải mã nguồn project về máy.

Clone repository:

```bash
git clone https://github.com/Q-Anh2610/NCKH.git
cd NCKH
```

---

## 7. Cách chạy backend local

Di chuyển vào thư mục backend:

```bash
cd algorithm_2d_3d
```

Cài đặt thư viện:

```bash
pip install -r requirements.txt
```

Chạy API server:

```bash
uvicorn main:app --reload
```

Mặc định API sẽ chạy tại:

```text
http://127.0.0.1:8000
```

API documentation:

```text
http://127.0.0.1:8000/docs
```

Endpoint chính:

```text
POST /compact
```

Ví dụ input 2D:

```json
{
  "dimension": 2,
  "max_steps": 100,
  "blocks": [
    [0, 0],
    [1, 0],
    [1, 1],
    [2, 1]
  ]
}
```

Ví dụ input 3D:

```json
{
  "dimension": 3,
  "max_steps": 150,
  "blocks": [
    [0, 0, 0],
    [1, 0, 0],
    [1, 1, 0],
    [1, 1, 1]
  ]
}
```

---

## 8. Cách chạy backend bằng Docker

Di chuyển vào thư mục backend:

```bash
cd algorithm_2d_3d
```

Build image:

```bash
docker build -t sliding-cubes-api .
```

Chạy container:

```bash
docker run -p 7860:7860 sliding-cubes-api
```

API sẽ chạy tại:

```text
http://localhost:7860
```

API documentation:

```text
http://localhost:7860/docs
```

---

## 9. Cách chạy ứng dụng Flutter

Di chuyển vào thư mục ứng dụng:

```bash
cd application
```

Cài đặt dependencies:

```bash
flutter pub get
```

Chạy trên Chrome:

```bash
flutter run -d chrome
```

Build bản web release:

```bash
flutter build web --release
```

Sau khi build, mã nguồn web tĩnh sẽ nằm trong:

```text
application/build/web
```

---

## 10. Kết quả đầu ra của thuật toán

API trả về kết quả theo cấu trúc tổng quát:

```json
{
  "success": true,
  "message": "Compaction completed successfully.",
  "dimension": 2,
  "algorithm": "paper_inspired_2d",
  "initial": {},
  "steps": [],
  "final": {},
  "total_steps": 0,
  "status": "completed"
}
```

Trong đó:

* `success`: Cho biết quá trình xử lý có thành công hay không.
* `message`: Thông báo kết quả.
* `dimension`: Số chiều của bài toán.
* `algorithm`: Tên thuật toán được sử dụng.
* `initial`: Trạng thái ban đầu.
* `steps`: Danh sách các bước di chuyển.
* `final`: Trạng thái cuối cùng.
* `total_steps`: Tổng số bước đã thực hiện.
* `status`: Trạng thái kết thúc, ví dụ `completed`, `max_steps_reached`, `no_valid_move_found`, `invalid_input`.

---

## 11. Mục tiêu nghiên cứu

Dự án hướng tới các mục tiêu:

* Tìm hiểu bài toán nén khối trượt trong không gian 2D và 3D.
* Triển khai các phép di chuyển hợp lệ như slide và convex transition.
* Xây dựng chiến lược heuristic để giảm potential và đưa cấu hình về trạng thái compact.
* Mô phỏng trực quan quá trình hoạt động của thuật toán.
* Tạo công cụ hỗ trợ kiểm thử, trình bày và đánh giá kết quả nghiên cứu.

---

## 12. Ghi chú

Đây là dự án phục vụ mục đích học tập và nghiên cứu. Thuật toán trong project hiện được triển khai theo hướng heuristic/paper-inspired, ưu tiên khả năng mô phỏng và quan sát quá trình nén hơn là chứng minh tối ưu tuyệt đối trong mọi trường hợp.
