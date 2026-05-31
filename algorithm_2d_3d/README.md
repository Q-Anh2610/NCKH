# algorithm_2d_3d - Sliding Cubes Compaction Backend

Thư mục này chứa phần backend và thuật toán chính của dự án **Sliding Cubes Compaction Simulator**. Backend được xây dựng bằng FastAPI, nhận cấu hình các khối trong không gian 2D hoặc 3D, sau đó chạy thuật toán nén và trả về toàn bộ lịch sử di chuyển.

---

## 1. Vai trò của thư mục

`algorithm_2d_3d/` đảm nhiệm các nhiệm vụ:

* Cung cấp API cho ứng dụng Flutter gọi thuật toán.
* Kiểm tra tính hợp lệ của input.
* Điều phối thuật toán 2D hoặc 3D tùy theo `dimension`.
* Sinh các bước di chuyển hợp lệ.
* Tính toán potential, kiểm tra liên thông và kiểm tra trạng thái finished.
* Trả về kết quả mô phỏng dưới dạng JSON.

---

## 2. Cấu trúc file

```text
algorithm_2d_3d/
│
├── main.py
├── compaction.py
├── algorithm_2d_1.py
├── algorithm_3d_1.py
├── utils.py
├── validator.py
├── requirements.txt
├── Dockerfile
└── README.md
```

Ý nghĩa từng file:

| File                | Vai trò                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------- |
| `main.py`           | Khởi tạo FastAPI server và định nghĩa endpoint `/compact`                                                  |
| `compaction.py`     | Điều phối thuật toán: nếu `dimension = 2` thì gọi thuật toán 2D, nếu `dimension = 3` thì gọi thuật toán 3D |
| `algorithm_2d_1.py` | Cài đặt thuật toán nén khối trượt trong không gian 2D                                                      |
| `algorithm_3d_1.py` | Cài đặt thuật toán nén khối trượt trong không gian 3D                                                      |
| `utils.py`          | Chứa các hàm tiện ích như kiểm tra liên thông, tính potential, áp dụng move, tạo response                  |
| `validator.py`      | Kiểm tra input trước khi chạy thuật toán                                                                   |
| `requirements.txt`  | Danh sách thư viện Python cần cài đặt                                                                      |
| `Dockerfile`        | Cấu hình chạy backend bằng Docker                                                                          |

---

## 3. Luồng xử lý tổng quát

Luồng xử lý của backend như sau:

```text
Client / Flutter App
        |
        v
POST /compact
        |
        v
main.py
        |
        v
compaction.py
        |
        v
validator.py
        |
        v
algorithm_2d_1.py hoặc algorithm_3d_1.py
        |
        v
utils.py hỗ trợ tính toán
        |
        v
Trả về JSON kết quả
```

Cụ thể:

1. Client gửi request đến endpoint `/compact`.
2. `main.py` nhận dữ liệu gồm:

   * `dimension`
   * `blocks`
   * `max_steps`
3. `compaction.py` gọi `validate_input` để kiểm tra dữ liệu.
4. Nếu input hợp lệ:

   * `dimension = 2` thì gọi `compact_2d_1`.
   * `dimension = 3` thì gọi `compact_3d_exact`.
5. Thuật toán sinh từng bước di chuyển.
6. Backend trả về danh sách các bước và trạng thái cuối cùng.

---

## 4. API

### 4.1. Kiểm tra server

```http
GET /
```

Response mẫu:

```json
{
  "success": true,
  "message": "Sliding Cubes Compaction API is running."
}
```

---

### 4.2. Chạy thuật toán nén

```http
POST /compact
```

Request body:

```json
{
  "dimension": 2,
  "blocks": [
    [0, 0],
    [1, 0],
    [1, 1]
  ],
  "max_steps": 100
}
```

Ý nghĩa các trường:

| Trường      | Kiểu dữ liệu      | Ý nghĩa                                              |
| ----------- | ----------------- | ---------------------------------------------------- |
| `dimension` | `int`             | Số chiều của bài toán, chỉ nhận giá trị `2` hoặc `3` |
| `blocks`    | `List[List[int]]` | Danh sách tọa độ các khối                            |
| `max_steps` | `int`             | Số bước tối đa thuật toán được phép chạy             |

---

## 5. Ví dụ input

### 5.1. Input 2D

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

Trong 2D, mỗi khối có tọa độ dạng:

```text
[x, y]
```

---

### 5.2. Input 3D

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

Trong 3D, mỗi khối có tọa độ dạng:

```text
[x, y, z]
```

---

## 6. Output trả về

Response tổng quát:

```json
{
  "success": true,
  "message": "Compaction completed successfully.",
  "dimension": 2,
  "algorithm": "paper_inspired_2d",
  "initial": {
    "blocks": [],
    "potential": 0,
    "is_connected": true,
    "is_finished": false
  },
  "steps": [],
  "final": {
    "blocks": [],
    "potential": 0,
    "is_connected": true,
    "is_finished": true
  },
  "total_steps": 0,
  "status": "completed"
}
```

Các trạng thái `status` có thể gặp:

| Status                | Ý nghĩa                                           |
| --------------------- | ------------------------------------------------- |
| `completed`           | Thuật toán đã đưa cấu hình về trạng thái finished |
| `max_steps_reached`   | Đã đạt số bước tối đa nhưng chưa hoàn tất         |
| `no_valid_move_found` | Không tìm được bước di chuyển hợp lệ tiếp theo    |
| `invalid_input`       | Input không hợp lệ                                |

---

## 7. Điều kiện input hợp lệ

Input phải thỏa mãn:

* `dimension` phải là `2` hoặc `3`.
* `blocks` không được rỗng.
* Mỗi block phải là một danh sách tọa độ.
* Số tọa độ của mỗi block phải đúng bằng số chiều.
* Tất cả tọa độ phải là số nguyên.
* Không hỗ trợ tọa độ âm.
* Không được có hai block trùng tọa độ.
* Cấu hình ban đầu phải liên thông.
* `max_steps` phải là số nguyên dương.

---

## 8. Thuật toán 2D

File chính:

```text
algorithm_2d_1.py
```

Thuật toán 2D sử dụng hướng tiếp cận heuristic/paper-inspired. Các bước xử lý chính gồm:

* Sinh các move hợp lệ trong 2D.
* Kiểm tra hai loại move:

  * `slide`
  * `convex`
* Đánh giá trạng thái bằng:

  * potential
  * số lượng holes
  * khoảng cách tới target compact
* Ưu tiên các operation:

  * `local_y_reduction`
  * `column_shove`
  * `local_potential_reduction`
  * `handling_low_components`
  * `small_low_components`
  * `big_low_components`
* Khi bị kẹt local optimum, thuật toán dùng `macro_escape` bằng beam search để tìm chuỗi move ngắn có khả năng cải thiện cấu hình.

Hàm chính:

```python
compact_2d_1(blocks, max_steps)
```

Tên thuật toán trả về trong response:

```text
paper_inspired_2d
```

---

## 9. Thuật toán 3D

File chính:

```text
algorithm_3d_1.py
```

Thuật toán 3D mở rộng ý tưởng từ 2D sang không gian ba chiều. Các thành phần chính gồm:

* Sinh các move hợp lệ trong 3D.
* Kiểm tra move dạng:

  * `slide`
  * `convex`
* Tính potential trong không gian 3D.
* Đánh giá trạng thái bằng heuristic score gồm:

  * potential
  * số holes
  * khoảng cách tới target compact
* Ưu tiên các operation:

  * `local_z_reduction`
  * `pillar_shove`
  * `local_potential_reduction`
  * `handling_low_components`
* Khi không tìm được move tốt ngay lập tức, thuật toán sử dụng beam search dạng `macro_escape` để tìm chuỗi move nhiều bước.

Hàm chính:

```python
compact_3d_exact(blocks, max_steps)
```

Tên thuật toán trả về trong response:

```text
paper_inspired_3d
```

---

## 10. Các hàm tiện ích quan trọng

File:

```text
utils.py
```

Một số hàm chính:

| Hàm                 | Vai trò                                                      |
| ------------------- | ------------------------------------------------------------ |
| `to_tuple_set`      | Chuyển danh sách block sang set các tuple để xử lý nhanh hơn |
| `to_list`           | Chuyển set tuple về list để trả JSON                         |
| `get_neighbors`     | Sinh các ô kề cạnh của một block                             |
| `is_connected`      | Kiểm tra cấu hình có liên thông hay không                    |
| `apply_move`        | Áp dụng một bước di chuyển từ ô cũ sang ô mới                |
| `is_move_connected` | Kiểm tra move có giữ được tính liên thông hay không          |
| `potential`         | Tính giá trị thế năng của cấu hình                           |
| `is_finished_2d`    | Kiểm tra trạng thái finished trong 2D                        |
| `is_finished_3d`    | Kiểm tra trạng thái finished trong 3D                        |
| `make_step_info`    | Tạo thông tin chi tiết cho một bước move                     |
| `build_response`    | Tạo response JSON trả về cho client                          |

---

## 11. Cài đặt và chạy local

### 11.1. Tạo môi trường Python

```bash
cd algorithm_2d_3d
python -m venv venv
```

Kích hoạt môi trường ảo trên Windows:

```bash
venv\Scripts\activate
```

Kích hoạt môi trường ảo trên macOS/Linux:

```bash
source venv/bin/activate
```

---

### 11.2. Cài đặt thư viện

```bash
pip install -r requirements.txt
```

---

### 11.3. Chạy server

```bash
uvicorn main:app --reload
```

Server mặc định chạy tại:

```text
http://127.0.0.1:8000
```

Có thể mở tài liệu API tự động tại:

```text
http://127.0.0.1:8000/docs
```

---

## 12. Chạy bằng Docker

Build image:

```bash
docker build -t sliding-cubes-api .
```

Chạy container:

```bash
docker run -p 7860:7860 sliding-cubes-api
```

Server sẽ chạy tại:

```text
http://localhost:7860
```

---

## 13. Test nhanh bằng curl

Ví dụ với input 2D:

```bash
curl -X POST "http://127.0.0.1:8000/compact" ^
  -H "Content-Type: application/json" ^
  -d "{\"dimension\":2,\"max_steps\":100,\"blocks\":[[0,0],[1,0],[1,1],[2,1]]}"
```

Trên macOS/Linux có thể dùng:

```bash
curl -X POST "http://127.0.0.1:8000/compact" \
  -H "Content-Type: application/json" \
  -d '{"dimension":2,"max_steps":100,"blocks":[[0,0],[1,0],[1,1],[2,1]]}'
```

---

## 14. Ghi chú triển khai

Thuật toán hiện tại tập trung vào mô phỏng và kiểm thử hướng nghiên cứu. Cách tiếp cận sử dụng heuristic score, potential reduction và beam search để tăng khả năng đưa cấu hình về trạng thái compact. Vì vậy, kết quả phù hợp cho mục đích minh họa, đánh giá thực nghiệm và trình bày quá trình hoạt động của thuật toán.
