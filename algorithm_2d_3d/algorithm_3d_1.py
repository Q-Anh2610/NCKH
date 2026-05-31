# algorithm_3d_1.py

import heapq
from collections import deque
from utils import (
    to_tuple_set,
    to_list,
    is_connected,
    is_move_connected,
    potential,
    apply_move,
    make_step_info,
    build_response,
    is_finished_3d
)

# ============================================================
# 1. HÌNH HỌC MOVE 3D: SLIDE VÀ CONVEX TRANSITION
# ============================================================

def is_slide_3d(c, e, blocks_set):
    """
    Slide trong 3D: Khối di chuyển theo đường thẳng c-e (khoảng cách Manhattan bằng 1).
    Ràng buộc 4-cycle: Phải tồn tại một chu trình 4 ô trong lưới Z^3, trong đó c, e 
    và ô kề bên của c đều thuộc blocks_set, tạo điểm tựa song song với hướng trượt.
    """
    dx = e[0] - c[0]
    dy = e[1] - c[1]
    dz = e[2] - c[2]

    if abs(dx) + abs(dy) + abs(dz) != 1:
        return False

    # Xác định các hướng vuông góc với vector dịch chuyển c->e
    directions = []
    if dx != 0:
        directions = [(0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]
    elif dy != 0:
        directions = [(1, 0, 0), (-1, 0, 0), (0, 0, 1), (0, 0, -1)]
    else:
        directions = [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0)]

    for v in directions:
        side_c = (c[0] + v[0], c[1] + v[1], c[2] + v[2])
        side_e = (e[0] + v[0], e[1] + v[1], e[2] + v[2])
        if side_c in blocks_set and side_e in blocks_set:
            return True

    return False


def is_convex_3d(c, e, blocks_set):
    """
    Convex transition trong 3D: c và e nằm chéo nhau trên một mặt phẳng lưới 2x2.
    Khoảng cách Manhattan bằng 2, thay đổi đúng 2 tọa độ.
    Đúng một trong hai ô trung gian nối giữa c và e phải chứa khối làm điểm tựa xoay góc.
    """
    dx = e[0] - c[0]
    dy = e[1] - c[1]
    dz = e[2] - c[2]

    # Kiểm tra xem có phải dịch chuyển chéo trên 1 mặt phẳng lưới không (Manhattan = 2, 1 tọa độ ko đổi)
    if (abs(dx) + abs(dy) + abs(dz) != 2) or (dx != 0 and dy != 0 and dz != 0):
        return False

    # Xác định 2 ô trung gian tạo thành hình vuông phẳng 2x2 chứa c và e
    if dx != 0 and dy != 0:
        n1 = (c[0] + dx, c[1], c[2])
        n2 = (c[0], c[1] + dy, c[2])
    elif dx != 0 and dz != 0:
        n1 = (c[0] + dx, c[1], c[2])
        n2 = (c[0], c[1], c[2] + dz)
    else:
        n1 = (c[0], c[1] + dy, c[2])
        n2 = (c[0], c[1], c[2] + dz)

    return (n1 in blocks_set) ^ (n2 in blocks_set)


def get_move_type_3d(c, e, blocks_set):
    if is_slide_3d(c, e, blocks_set):
        return "slide"
    if is_convex_3d(c, e, blocks_set):
        return "convex"
    return None


def bounding_search_area_3d(blocks_set, margin=2):
    min_x = min(b[0] for b in blocks_set) - margin
    max_x = max(b[0] for b in blocks_set) + margin
    min_y = min(b[1] for b in blocks_set) - margin
    max_y = max(b[1] for b in blocks_set) + margin
    min_z = min(b[2] for b in blocks_set) - margin
    max_z = max(b[2] for b in blocks_set) + margin
    return min_x, max_x, min_y, max_y, min_z, max_z


def generate_valid_moves_3d(blocks_set):
    moves = []
    if not blocks_set:
        return moves

    min_x, max_x, min_y, max_y, min_z, max_z = bounding_search_area_3d(blocks_set, margin=1)

    empty_cells = [
        (x, y, z)
        for x in range(max(0, min_x), max_x + 1)
        for y in range(max(0, min_y), max_y + 1)
        for z in range(max(0, min_z), max_z + 1)
        if (x, y, z) not in blocks_set
    ]

    for c in blocks_set:
        remaining = set(blocks_set)
        remaining.remove(c)
        if not is_connected(remaining, 3):
            continue

        for e in empty_cells:
            move_type = get_move_type_3d(c, e, blocks_set)
            if move_type is None:
                continue

            if is_move_connected(blocks_set, c, e, 3):
                moves.append((c, e, move_type))
    return moves


# ============================================================
# 2. ĐÁNH GIÁ CẤU HÌNH HÌNH HỌC 3D (Heuristic Scoring)
# ============================================================

def finished_holes_3d(blocks_set):
    """Tính các vị trí ô trống còn thiếu trong Cuboid để cấu hình đạt trạng thái Finished."""
    holes = set()
    for x, y, z in blocks_set:
        for i in range(x + 1):
            for j in range(y + 1):
                for k in range(z + 1):
                    if (i, j, k) not in blocks_set:
                        holes.add((i, j, k))
    return holes


def compact_target_3d(n):
    """Xây dựng tập bia đích dồn n khối về phía gốc tọa độ tối ưu theo thế năng."""
    if n <= 0:
        return set()

    target = {(0, 0, 0)}
    frontier = {(1, 0, 0), (0, 1, 0), (0, 0, 1)}

    while len(target) < n:
        candidates = []
        for cell in frontier:
            x, y, z = cell
            if x < 0 or y < 0 or z < 0:
                continue

            ok = True
            if x > 0 and (x - 1, y, z) not in target: ok = False
            if y > 0 and (x, y - 1, z) not in target: ok = False
            if z > 0 and (x, y, z - 1) not in target: ok = False

            if ok:
                pot_val = potential([cell], 3)
                heapq.heappush(candidates, (pot_val, x + y + z, x, y, z, cell))

        if not candidates:
            break

        _, _, _, _, _, chosen = heapq.heappop(candidates)
        target.add(chosen)
        frontier.discard(chosen)

        x, y, z = chosen
        frontier.add((x + 1, y, z))
        frontier.add((x, y + 1, z))
        frontier.add((x, y, z + 1))

    return target


def manhattan_3d(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])


def target_distance_3d(blocks_set, target):
    if not blocks_set or not target:
        return 0
    blocks = list(blocks_set)
    target_cells = list(target)

    d1 = sum(min(manhattan_3d(b, t) for t in target_cells) for b in blocks)
    d2 = sum(min(manhattan_3d(t, b) for b in blocks) for t in target_cells)
    return d1 + d2


def compaction_score_3d(blocks_set):
    """
    Score đánh giá trạng thái 3D tổng hợp.
    Phạt nặng các lỗ hổng bên trong (holes) và khoảng cách hình học tới cấu hình lý tưởng.
    """
    pot = potential(blocks_set, 3)
    holes = finished_holes_3d(blocks_set)
    target = compact_target_3d(len(blocks_set))
    dist = target_distance_3d(blocks_set, target)

    return pot + 30 * len(holes) + 4 * dist


def is_better_state_3d(before, after):
    if is_finished_3d(after):
        return True
    if compaction_score_3d(after) < compaction_score_3d(before):
        return True
    if potential(after, 3) < potential(before, 3):
        return True
    return False


# ============================================================
# 3. PIPELINE OPERATIONS PHÂN LỚP THEO BÀI BÁO 3D
# ============================================================

def one_step_candidates_3d(blocks_set, operation_name, filter_func=None):
    result = []
    for c, e, move_type in generate_valid_moves_3d(blocks_set):
        if filter_func is not None and not filter_func(c, e, move_type):
            continue

        next_blocks = apply_move(blocks_set, c, e)
        if is_better_state_3d(blocks_set, next_blocks):
            result.append((c, e, move_type, operation_name, next_blocks))
    return result


def choose_best_candidate_3d(candidates):
    if not candidates:
        return None

    return min(
        candidates,
        key=lambda item: (
            0 if is_finished_3d(item[4]) else 1,
            compaction_score_3d(item[4]),
            potential(item[4], 3),
            item[1][2],  # Ưu tiên tọa độ z đích thấp hơn
            item[1][1],  # Tiếp đến y đích thấp hơn
            item[1][0]   # Cuối cùng là x đích thấp hơn
        )
    )


def local_z_reduction(blocks_set):
    """Operation [a-d]: Kéo hạ độ cao khối xuống tầng dưới."""
    def filt(c, e, move_type):
        return e[2] < c[2]  # Giảm cao độ z mang tính quyết định

    candidates = one_step_candidates_3d(blocks_set, "local_z_reduction", filt)
    res = choose_best_candidate_3d(candidates)
    return (res[0], res[1], res[2], res[3]) if res else None


def get_pillar_heights(blocks_set, x, y):
    return sorted([b[2] for b in blocks_set if b[0] == x and b[1] == y])


def pillar_shove_heuristic(blocks_set):
    """Operation [e]: Tịnh tiến cấu trúc cột hoặc xử lý kéo nghiêng."""
    def filt(c, e, move_type):
        # Ưu tiên các khối thuộc một trụ thẳng đứng có chiều cao >= 2
        heights = get_pillar_heights(blocks_set, c[0], c[1])
        if len(heights) < 2:
            return False
        # Di chuyển đẩy sang bên cạnh hoặc đi xuống dưới
        return e[2] <= c[2] or e[0] < c[0] or e[1] < c[1]

    candidates = one_step_candidates_3d(blocks_set, "pillar_shove", filt)
    res = choose_best_candidate_3d(candidates)
    return (res[0], res[1], res[2], res[3]) if res else None


def local_potential_reduction_3d(blocks_set):
    """Operation [f]: Tìm mọi bước đi đơn lẻ tối ưu thế năng cục bộ."""
    candidates = one_step_candidates_3d(blocks_set, "local_potential_reduction")
    res = choose_best_candidate_3d(candidates)
    return (res[0], res[1], res[2], res[3]) if res else None


# ============================================================
# 4. PHÂN CHIA THÀNH PHẦN LOW / HIGH TRONG KHÔNG GIAN 3D
# ============================================================

def connected_components_3d(cells):
    cells = set(cells)
    if not cells:
        return []

    components = []
    unvisited = set(cells)

    while unvisited:
        start = next(iter(unvisited))
        comp = {start}
        queue = deque([start])
        unvisited.remove(start)

        while queue:
            x, y, z = queue.popleft()
            for dx, dy, dz in [(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(0,0,1),(0,0,-1)]:
                nb = (x + dx, y + dy, z + dz)
                if nb in unvisited:
                    unvisited.remove(nb)
                    comp.add(nb)
                    queue.append(nb)
        components.append(comp)
    return components


def get_low_high_components_3d(blocks_set):
    low_cells = {b for b in blocks_set if b[2] == 0}   # Mặt phẳng đáy z = 0
    high_cells = {b for b in blocks_set if b[2] > 0}  # Thành phần trên cao z > 0
    return connected_components_3d(low_cells), connected_components_3d(high_cells)


def handling_low_components_3d(blocks_set):
    """Operation [g-j]: Xử lý dồn ép các cấu trúc khối nằm ở lớp đáy z=0."""
    low_comps, _ = get_low_high_components_3d(blocks_set)
    if not low_comps:
        return None

    # Tìm thành phần root chứa gốc (0,0,0)
    root_comp = None
    for comp in low_comps:
        if (0, 0, 0) in comp:
            root_comp = comp
            break
    if root_comp is None:
        root_comp = low_comps[0]

    non_root_cells = set()
    for comp in low_comps:
        if comp != root_comp:
            non_root_cells.update(comp)

    if not non_root_cells:
        return None

    # Lọc dịch chuyển thuộc thành phần không phải root hướng về phía gốc tọa độ
    def filt(c, e, move_type):
        if c not in non_root_cells:
            return False
        return e[0] < c[0] or e[1] < c[1] or e[2] == 0

    candidates = one_step_candidates_3d(blocks_set, "handling_low_components", filt)
    res = choose_best_candidate_3d(candidates)
    return (res[0], res[1], res[2], res[3]) if res else None


# ============================================================
# 5. MACRO ESCAPE (BEAM SEARCH) PHÒNG TRÁNH BỊ KẸT 3D
# ============================================================

def move_sort_key_3d(blocks_set, move):
    c, e, move_type = move
    next_blocks = apply_move(blocks_set, c, e)
    return (
        0 if is_finished_3d(next_blocks) else 1,
        compaction_score_3d(next_blocks),
        potential(next_blocks, 3),
        e[2], e[1], e[0]
    )


def beam_escape_sequence_3d(blocks_set, max_depth=4, beam_width=40, branch_limit=20):
    """
    Chuỗi dịch chuyển vĩ mô nhiều bước. Giải phóng các trường hợp bị nghẽn (Unlock trụ).
    Chấp nhận thế năng tăng tạm thời ở các bước trung gian.
    """
    start_score = compaction_score_3d(blocks_set)
    start_pot = potential(blocks_set, 3)
    start_state = tuple(sorted(blocks_set))

    beam = [{
        "blocks": set(blocks_set),
        "sequence": [],
        "score": start_score,
        "potential": start_pot
    }]
    visited = {start_state}

    best_sequence = None
    best_key = None

    for depth in range(1, max_depth + 1):
        next_beam = []
        for node in beam:
            current_blocks = node["blocks"]
            moves = generate_valid_moves_3d(current_blocks)
            moves = sorted(moves, key=lambda m: move_sort_key_3d(current_blocks, m))[:branch_limit]

            for c, e, move_type in moves:
                after = apply_move(current_blocks, c, e)
                state = tuple(sorted(after))

                if state in visited:
                    continue
                visited.add(state)

                seq = node["sequence"] + [(c, e, move_type, "macro_escape")]
                after_score = compaction_score_3d(after)
                after_pot = potential(after, 3)

                key = (0 if is_finished_3d(after) else 1, after_score, after_pot, len(seq))

                if is_finished_3d(after) or after_score < start_score or (depth >= 2 and after_pot < start_pot):
                    if best_sequence is None or key < best_key:
                        best_sequence = seq
                        best_key = key

                next_beam.append({
                    "blocks": after,
                    "sequence": seq,
                    "score": after_score,
                    "potential": after_pot
                })

        if best_sequence is not None:
            return best_sequence

        next_beam.sort(key=lambda x: (x["score"], x["potential"], len(x["sequence"])))
        beam = next_beam[:beam_width]
        if not beam:
            break

    return None


# ============================================================
# 6. ĐIỀU PHỐI ĐA PIPELINE CHỌN BƯỚC ĐI TIẾP THEO
# ============================================================

def choose_next_sequence_3d(blocks_set):
    # 1. Thử các hoạt động Greedy 1 bước phân tầng
    for op in [local_z_reduction, pillar_shove_heuristic, local_potential_reduction_3d, handling_low_components_3d]:
        move = op(blocks_set)
        if move is not None:
            return [move]

    # 2. Nếu kẹt, sử dụng Beam Search tìm chuỗi thoát hiểm phục vụ "Unlock"
    macro_seq = beam_escape_sequence_3d(blocks_set, max_depth=4, beam_width=40, branch_limit=20)
    if macro_seq:
        return macro_seq

    return None


# ============================================================
# 7. VÒNG LẶP CHÍNH THỰC THI THUẬT TOÁN (Main Pipeline)
# ============================================================

def compact_3d_exact(blocks, max_steps):
    """
    Thuật toán nén cấu hình 3D hoàn chỉnh.
    Tên hàm đã được đổi thành compact_3d_exact để tương thích 100% với file compaction.py của Web Server.
    """
    blocks_set = to_tuple_set(blocks)
    curr_blocks = blocks_set
    curr_pot = potential(curr_blocks, 3)

    initial_info = {
        "blocks": to_list(curr_blocks),
        "potential": curr_pot,
        "is_connected": True,
        "is_finished": is_finished_3d(curr_blocks)
    }

    steps = []
    status = "completed" if is_finished_3d(curr_blocks) else "running"

    if status == "completed":
        return build_response(
            True, "Compaction completed successfully.", 3,
            initial_info, steps, initial_info, status, "paper_inspired_3d"
        )

    step_idx = 1
    while step_idx <= max_steps:
        if is_finished_3d(curr_blocks):
            status = "completed"
            break

        sequence = choose_next_sequence_3d(curr_blocks)
        if sequence is None:
            status = "no_valid_move_found"
            break

        broken_sequence = False
        for c, e, move_type, operation in sequence:
            if step_idx > max_steps:
                status = "max_steps_reached"
                break

            # Kiểm tra tính hợp lệ động tại thời điểm thực thi bước nhỏ trong chuỗi
            if c not in curr_blocks or e in curr_blocks:
                broken_sequence = True
                break

            current_move_type = get_move_type_3d(c, e, curr_blocks)
            if current_move_type is None or not is_move_connected(curr_blocks, c, e, 3):
                broken_sequence = True
                break

            blocks_before = set(curr_blocks)
            pot_before = curr_pot

            # Cập nhật trạng thái mô hình
            curr_blocks = apply_move(curr_blocks, c, e)
            curr_pot = potential(curr_blocks, 3)

            finished_after = is_finished_3d(curr_blocks)
            connected_after = is_connected(curr_blocks, 3)

            step_info = make_step_info(
                step_idx=step_idx,
                from_c=c,
                to_c=e,
                move_type=current_move_type,
                blocks_before=blocks_before,
                blocks_after=curr_blocks,
                pot_before=pot_before,
                pot_after=curr_pot,
                connected_after=connected_after,
                finished_after=finished_after,
                operation=operation
            )
            steps.append(step_info)
            step_idx += 1

            if finished_after:
                status = "completed"
                break

        if status in ["completed", "max_steps_reached"] or broken_sequence:
            if status == "running" and broken_sequence:
                continue  # Tính toán chọn lại chuỗi hành động mới nếu chuỗi cũ gãy động
            break

    if status == "running":
        status = "max_steps_reached" if step_idx > max_steps else "no_valid_move_found"

    final_finished = is_finished_3d(curr_blocks)
    if final_finished:
        status = "completed"

    final_info = {
        "blocks": to_list(curr_blocks),
        "potential": curr_pot,
        "is_connected": is_connected(curr_blocks, 3),
        "is_finished": final_finished
    }

    message = {
        "completed": "Compaction completed successfully.",
        "max_steps_reached": "Maximum number of steps reached before finishing compaction.",
        "no_valid_move_found": "No valid move found."
    }.get(status, "No valid move found.")

    return build_response(
        True, message, 3, initial_info, steps, final_info, status, "paper_inspired_3d"
    )