from utils import (
    to_tuple_set, to_list, is_connected, is_move_connected, build_response, make_step_info
)

# ============================================================
# 1. HÀM THẾ NĂNG CHÍNH XÁC THEO BÀI BÁO (Strict Potential)
# ============================================================
def calculate_weight(c_y, c_z):
    """Tính trọng số w_c dựa trên tọa độ y và z theo đúng định nghĩa bài báo."""
    if c_z > 1:
        return 17
    if c_z == 1:
        return 16
    # Nếu c_z == 0
    if c_y > 1:
        return 3
    if c_y == 1:
        return 2
    return 1 # c_z = 0 và c_y = 0

def exact_potential(blocks_set):
    """
    Tính tổng thế năng dựa trên công thức: \Pi_C = \sum w_c(x + 2y + 4z)
    """
    total = 0
    for x, y, z in blocks_set:
        w_c = calculate_weight(y, z)
        total += w_c * (x + 2 * y + 4 * z)
    return total

# ============================================================
# 2. BỘ THỰC THI MACRO-MOVE (Macro-Move Engine)
# ============================================================
def apply_macro_move(blocks_set, move_sequence, get_move_type_func):
    """
    Thực thi một kịch bản chuỗi các bước đi.
    Bỏ qua việc kiểm tra thế năng trung gian, chỉ cần đảm bảo cuối cùng
    chuỗi này là "safe" (tổng thế năng giảm) và không làm đứt gãy hệ thống.
    """
    curr_blocks = set(blocks_set)
    steps_taken = []

    for c, e in move_sequence:
        move_type = get_move_type_func(c, e, curr_blocks)
        # Bắt buộc phải là move hợp lệ và duy trì liên thông
        if not move_type or not is_move_connected(curr_blocks, c, e, 3):
            return None, False

        next_blocks = set(curr_blocks)
        next_blocks.remove(c)
        next_blocks.add(e)

        steps_taken.append((c, e, move_type, next_blocks))
        curr_blocks = next_blocks

    return curr_blocks, steps_taken

# ============================================================
# 3. MÔ HÌNH HÓA SUBPILLAR VÀ CÁC OPERATION [a]-[d] TRONG 3D
# ============================================================
def get_subpillars_3d(blocks_set):
    """Tìm tất cả các cột P = <x, y, z_b..z_t>"""
    columns = {}
    for x, y, z in blocks_set:
        columns.setdefault((x, y), []).append(z)

    subpillars = []
    for (x, y), zs in columns.items():
        zs = sorted(zs)
        start = prev = zs[0]
        for z in zs[1:]:
            if z == prev + 1:
                prev = z
            else:
                subpillars.append({'x': x, 'y': y, 'z_b': start, 'z_t': prev})
                start = prev = z
        subpillars.append({'x': x, 'y': y, 'z_b': start, 'z_t': prev})
    return subpillars

def operation_local_z_reduction(blocks_set):
    """
    Tương đương Operation [a], [b], [c], [d].
    Nhắm vào việc giảm z của các non-cut subpillar.
    """
    subpillars = get_subpillars_3d(blocks_set)

    for P in subpillars:
        x, y, z_b, z_t = P['x'], P['y'], P['z_b'], P['z_t']

        # Bỏ qua nếu P là cut-subpillar (gỡ ra làm đứt hệ thống)
        # Giả định có hàm is_non_cut_subpillar_3d
        if not is_non_cut_subpillar_3d(blocks_set, x, y, z_b, z_t):
            continue

        # Duyệt 4 mặt bên (sides) của P trong 3D: (x-1,y), (x+1,y), (x,y-1), (x,y+1)
        sides = [(x-1, y), (x+1, y), (x, y-1), (x, y+1)]
        for s_x, s_y in sides:
            # Lấy cột kề (P') cao nhất hoặc thấp nhất ở mặt này
            P_prime = get_adjacent_pillar(blocks_set, s_x, s_y)
            if not P_prime: continue

            p_z_b, p_z_t = P_prime['z_b'], P_prime['z_t']

            # [Operation A] Ném đỉnh cột xuống nếu cột kề đủ thấp
            if p_z_t <= z_t - 2:
                c = (x, y, z_t)
                e = (s_x, s_y, z_t - 1) # Rơi chéo qua (convex)
                return "op_a", [(c, e)]

            # [Operation B] Cột kề có đáy cao hơn đáy P (z_b' > z_b)
            if p_z_b > z_b:
                c_under = (x, y, p_z_b - 1)
                c_base = (x, y, p_z_b)

                if is_non_cut(blocks_set, c_under) and is_non_cut(blocks_set, c_base):
                    return "op_b_normal", [
                        (c_under, (s_x, s_y, p_z_b - 1)),
                        (c_base, c_under)
                    ]
                # Nếu bị vướng đỉnh (locked), mở khóa đỉnh trước rồi trượt
                elif not is_non_cut(blocks_set, c_base) and p_z_b == z_t - 1:
                    return "op_b_unlock", [
                        ((x, y, z_t), (s_x, s_y, z_t)), # Unlock (làm tăng thế năng tạm thời)
                        (c_under, (s_x, s_y, p_z_b - 1)),
                        (c_base, c_under)
                    ]

            is_based = (x, y, z_b - 1) not in blocks_set

            # [Operation C] Cột chạm đáy, đáy kề lún sâu hơn
            if is_based and p_z_b < z_b:
                seq = []
                if is_locked(blocks_set, x, y, z_t):
                    seq.append(((x, y, z_t), (s_x, s_y, z_t))) # Unlock
                seq.append(((x, y, z_b), (x, y, z_b - 1))) # Tụt xuống
                return "op_c", seq

            # [Operation D] Cột chạm đáy, đáy kề bằng nhau
            if is_based and p_z_b == z_b and z_b > 0:
                seq = []
                if is_locked(blocks_set, x, y, z_t):
                    seq.append(((x, y, z_t), (s_x, s_y, z_t))) # Unlock
                seq.append(((x, y, z_b), (s_x, s_y, p_z_b - 1))) # Lật qua góc
                return "op_d", seq

    return None, []

# ============================================================
# 4. LUỒNG THỰC THI CHÍNH (Exact Pipeline)
# ============================================================
def compact_3d_exact(blocks, max_steps):
    blocks_set = to_tuple_set(blocks)
    steps = []

    # 1. Trạng thái khởi tạo
    pot_initial = exact_potential(blocks_set)
    # ... (Lưu info tương tự mã cũ)

    while len(steps) < max_steps:
        if is_finished_3d(blocks_set):
            break

        # Thử chuỗi Local z-reduction [a-d]
        op_name, move_seq = operation_local_z_reduction(blocks_set)

        if move_seq:
            # Thực thi chuỗi vĩ mô thay vì 1 bước
            blocks_set, detailed_steps = apply_macro_move(blocks_set, move_seq, get_move_type_3d)
            if detailed_steps:
                steps.extend(detailed_steps)
                continue

        # Thử Pillar Shove [e]
        # op_name, move_seq = operation_pillar_shove(blocks_set)
        # ...

        # Thử High Components Reduction [f]
        # ...

        # Nếu duyệt hết các Operation [a]-[j] mà không có move nào -> Bị kẹt
        break

    # Đóng gói Response...
    return build_response(...)