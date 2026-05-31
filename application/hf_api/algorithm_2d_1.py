# algorithm_2d_1.py

from collections import deque
import heapq

from utils import (
    to_tuple_set,
    to_list,
    is_connected,
    is_move_connected,
    potential,
    apply_move,
    make_step_info,
    build_response,
    is_finished_2d
)


# ============================================================
# 1. Hình học move 2D: slide và convex transition
# ============================================================

def is_slide_2d(c, e, blocks_set):
    """
    Slide trong 2D dựa trên 4-cycle.

    c và e phải kề cạnh.
    Tồn tại một phía của cạnh c-e sao cho hai ô còn lại của hình vuông 2x2 đều có block.
    """
    dx = e[0] - c[0]
    dy = e[1] - c[1]

    if abs(dx) + abs(dy) != 1:
        return False

    # Hai vector vuông góc với hướng di chuyển
    p1 = (-dy, dx)
    p2 = (dy, -dx)

    side1_a = (c[0] + p1[0], c[1] + p1[1])
    side1_b = (e[0] + p1[0], e[1] + p1[1])

    side2_a = (c[0] + p2[0], c[1] + p2[1])
    side2_b = (e[0] + p2[0], e[1] + p2[1])

    if side1_a in blocks_set and side1_b in blocks_set:
        return True

    if side2_a in blocks_set and side2_b in blocks_set:
        return True

    return False


def is_convex_2d(c, e, blocks_set):
    """
    Convex transition trong 2D.

    c và e nằm chéo nhau trong một hình vuông 2x2.
    Trong hai ô còn lại, đúng một ô có block làm điểm tựa.
    """
    dx = abs(c[0] - e[0])
    dy = abs(c[1] - e[1])

    if dx != 1 or dy != 1:
        return False

    n1 = (c[0], e[1])
    n2 = (e[0], c[1])

    in_n1 = n1 in blocks_set
    in_n2 = n2 in blocks_set

    return in_n1 ^ in_n2


def get_move_type_2d(c, e, blocks_set):
    if is_slide_2d(c, e, blocks_set):
        return "slide"

    if is_convex_2d(c, e, blocks_set):
        return "convex"

    return None


def bounding_search_area_2d(blocks_set, margin=2):
    min_x = min(x for x, y in blocks_set) - margin
    max_x = max(x for x, y in blocks_set) + margin
    min_y = min(y for x, y in blocks_set) - margin
    max_y = max(y for x, y in blocks_set) + margin

    return min_x, max_x, min_y, max_y


def generate_valid_moves_2d(blocks_set):
    """
    Sinh tất cả move hợp lệ quanh cấu hình hiện tại.

    Điều kiện:
    - ô đích trống
    - không dùng tọa độ âm
    - là slide hoặc convex
    - C \ {c} liên thông
    - cấu hình sau move liên thông
    """
    moves = []

    if not blocks_set:
        return moves

    min_x, max_x, min_y, max_y = bounding_search_area_2d(blocks_set, margin=2)

    empty_cells = [
        (x, y)
        for x in range(min_x, max_x + 1)
        for y in range(min_y, max_y + 1)
        if (x, y) not in blocks_set and x >= 0 and y >= 0
    ]

    for c in blocks_set:
        remaining = set(blocks_set)
        remaining.remove(c)

        if not is_connected(remaining, 2):
            continue

        for e in empty_cells:
            move_type = get_move_type_2d(c, e, blocks_set)

            if move_type is None:
                continue

            if is_move_connected(blocks_set, c, e, 2):
                moves.append((c, e, move_type))

    return moves


# ============================================================
# 2. Đánh giá cấu hình: potential + holes + compact target
# ============================================================

def cell_potential_2d(cell):
    """
    Potential của một ô 2D, coi z = 0.
    """
    x, y = cell

    if y > 1:
        w = 3
    elif y == 1:
        w = 2
    else:
        w = 1

    return w * (x + 2 * y)


def finished_holes_2d(blocks_set):
    """
    Trả về tập các ô còn thiếu để mọi block hiện tại trở thành finished.

    Nếu có block (x,y), thì mọi ô trong hình chữ nhật
    {0..x} x {0..y} phải có mặt.
    """
    holes = set()

    for x, y in blocks_set:
        for i in range(x + 1):
            for j in range(y + 1):
                if (i, j) not in blocks_set:
                    holes.add((i, j))

    return holes


def compact_target_2d(n):
    """
    Tạo một cấu hình target compact gồm n ô.

    Đây là down-set gần gốc, được xây bằng cách thêm dần ô có potential nhỏ nhất
    mà vẫn giữ tính finished/down-set.
    """
    if n <= 0:
        return set()

    target = {(0, 0)}
    frontier = {(1, 0), (0, 1)}

    while len(target) < n:
        candidates = []

        for cell in frontier:
            x, y = cell

            if x < 0 or y < 0:
                continue

            # Một ô được thêm nếu các predecessor cần thiết đã có.
            ok = True

            if x > 0 and (x - 1, y) not in target:
                ok = False

            if y > 0 and (x, y - 1) not in target:
                ok = False

            if ok:
                heapq.heappush(candidates, (cell_potential_2d(cell), x + y, x, y, cell))

        if not candidates:
            break

        _, _, _, _, chosen = heapq.heappop(candidates)
        target.add(chosen)
        frontier.discard(chosen)

        x, y = chosen
        frontier.add((x + 1, y))
        frontier.add((x, y + 1))

    return target


def manhattan(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


def target_distance_2d(blocks_set, target):
    """
    Khoảng cách xấp xỉ giữa cấu hình hiện tại và target.

    Dùng khoảng cách Manhattan hai chiều:
    - mỗi block hiện tại đến target gần nhất
    - mỗi ô target đến block hiện tại gần nhất
    """
    if not blocks_set or not target:
        return 0

    blocks = list(blocks_set)
    target_cells = list(target)

    d1 = 0
    for b in blocks:
        d1 += min(manhattan(b, t) for t in target_cells)

    d2 = 0
    for t in target_cells:
        d2 += min(manhattan(t, b) for b in blocks)

    return d1 + d2


def compaction_score_2d(blocks_set):
    """
    Score dùng để tránh kẹt local optimum.

    Khác với potential, score phạt mạnh:
    - các lỗ khiến cấu hình chưa finished
    - khoảng cách tới target compact

    Score nhỏ hơn nghĩa là cấu hình tốt hơn.
    """
    pot = potential(blocks_set, 2)
    holes = finished_holes_2d(blocks_set)
    target = compact_target_2d(len(blocks_set))
    dist = target_distance_2d(blocks_set, target)

    return pot + 25 * len(holes) + 3 * dist


def is_better_state(before, after):
    """
    Kiểm tra after có tốt hơn before không.

    Ưu tiên:
    1. finished
    2. score giảm
    3. potential giảm
    """
    if is_finished_2d(after):
        return True

    before_score = compaction_score_2d(before)
    after_score = compaction_score_2d(after)

    if after_score < before_score:
        return True

    if potential(after, 2) < potential(before, 2):
        return True

    return False


# ============================================================
# 3. Các operation paper-inspired dạng một bước
# ============================================================

def one_step_candidates(blocks_set, operation_name, filter_func=None):
    """
    Sinh candidate move cho một operation.

    Khác bản cũ:
    - Không chỉ xét potential giảm.
    - Cho phép move nếu score tổng thể tốt hơn.
    """
    result = []

    for c, e, move_type in generate_valid_moves_2d(blocks_set):
        if filter_func is not None and not filter_func(c, e, move_type):
            continue

        next_blocks = apply_move(blocks_set, c, e)

        if is_better_state(blocks_set, next_blocks):
            result.append((c, e, move_type, operation_name, next_blocks))

    return result


def choose_best_candidate(blocks_set, candidates):
    if not candidates:
        return None

    best = None
    best_key = None

    for c, e, move_type, operation, next_blocks in candidates:
        key = (
            0 if is_finished_2d(next_blocks) else 1,
            compaction_score_2d(next_blocks),
            potential(next_blocks, 2),
            e[1],
            e[0]
        )

        if best is None or key < best_key:
            best = (c, e, move_type, operation, next_blocks, potential(next_blocks, 2))
            best_key = key

    return best


def local_y_reduction(blocks_set):
    """
    Bước 1: Local y-reduction.
    Ưu tiên kéo ô xuống dưới.
    """
    def filt(c, e, move_type):
        return e[1] < c[1]

    candidates = one_step_candidates(
        blocks_set,
        "local_y_reduction",
        filt
    )

    return choose_best_candidate(blocks_set, candidates)


def is_in_nontrivial_column(c, blocks_set):
    """
    Kiểm tra c có thuộc cột dọc độ dài >= 2 không.
    """
    x, _ = c
    return sum(1 for bx, by in blocks_set if bx == x) >= 2


def column_shove(blocks_set):
    """
    Bước 2: Column shove bản heuristic.

    Ưu tiên move từ một cột dọc, hướng xuống hoặc sang trái.
    """
    def filt(c, e, move_type):
        if not is_in_nontrivial_column(c, blocks_set):
            return False

        return e[1] <= c[1] or e[0] < c[0]

    candidates = one_step_candidates(
        blocks_set,
        "column_shove",
        filt
    )

    return choose_best_candidate(blocks_set, candidates)


def local_potential_reduction(blocks_set):
    """
    Bước 3: Local potential reduction.

    Tìm bất kỳ move một bước nào làm tốt score hoặc potential.
    """
    candidates = one_step_candidates(
        blocks_set,
        "local_potential_reduction"
    )

    return choose_best_candidate(blocks_set, candidates)


# ============================================================
# 4. Low / high components trong 2D
# ============================================================

def connected_components_2d(cells):
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
            x, y = queue.popleft()

            for nb in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]:
                if nb in unvisited:
                    unvisited.remove(nb)
                    comp.add(nb)
                    queue.append(nb)

        components.append(comp)

    return components


def get_low_high_components_2d(blocks_set):
    low_cells = {b for b in blocks_set if b[1] == 0}
    high_cells = {b for b in blocks_set if b[1] > 0}

    return connected_components_2d(low_cells), connected_components_2d(high_cells)


def get_root_low_component(low_components):
    if not low_components:
        return None

    for comp in low_components:
        if (0, 0) in comp:
            return comp

    return low_components[0]


def non_root_low_components(blocks_set):
    low_components, _ = get_low_high_components_2d(blocks_set)
    root = get_root_low_component(low_components)

    if root is None:
        return []

    return [comp for comp in low_components if comp != root]


def is_small_low_component(component):
    """
    Heuristic 2D:
    component nhỏ nếu số ô nhỏ hơn khoảng cách từ ô trái nhất về gốc.
    """
    if not component:
        return False

    min_x = min(x for x, y in component)
    return len(component) < min_x + 1


def handling_low_components(blocks_set):
    """
    Bước 4-5: Handling low components.
    """
    comps = non_root_low_components(blocks_set)

    if not comps:
        return None

    cells = set()
    for comp in comps:
        cells.update(comp)

    def filt(c, e, move_type):
        if c not in cells:
            return False

        return e[0] < c[0] or e[1] == 0

    candidates = one_step_candidates(
        blocks_set,
        "handling_low_components",
        filt
    )

    return choose_best_candidate(blocks_set, candidates)


def small_low_components(blocks_set):
    """
    Bước 6: Small low components.
    """
    comps = non_root_low_components(blocks_set)
    small_cells = set()

    for comp in comps:
        if is_small_low_component(comp):
            small_cells.update(comp)

    if not small_cells:
        return None

    def filt(c, e, move_type):
        return c in small_cells and (e[0] <= c[0] or e[1] <= c[1])

    candidates = one_step_candidates(
        blocks_set,
        "small_low_components",
        filt
    )

    return choose_best_candidate(blocks_set, candidates)


def big_low_components(blocks_set):
    """
    Bước 7: Big low components.
    """
    comps = non_root_low_components(blocks_set)
    big_cells = set()

    for comp in comps:
        if not is_small_low_component(comp):
            big_cells.update(comp)

    if not big_cells:
        return None

    def filt(c, e, move_type):
        return c in big_cells and e[0] < c[0]

    candidates = one_step_candidates(
        blocks_set,
        "big_low_components",
        filt
    )

    return choose_best_candidate(blocks_set, candidates)


# ============================================================
# 5. Macro escape / Beam search
# ============================================================

def move_sort_key(blocks_set, move):
    """
    Sắp xếp move để beam search ưu tiên move có vẻ tốt.
    """
    c, e, move_type = move
    next_blocks = apply_move(blocks_set, c, e)

    return (
        0 if is_finished_2d(next_blocks) else 1,
        compaction_score_2d(next_blocks),
        potential(next_blocks, 2),
        e[1],
        e[0]
    )


def beam_escape_sequence_2d(
    blocks_set,
    max_depth=5,
    beam_width=80,
    branch_limit=35
):
    """
    Tìm một chuỗi move ngắn để thoát kẹt.

    Khác greedy:
    - Cho phép potential tăng tạm thời.
    - Chỉ cần sau vài bước score tốt hơn hoặc finished.
    """
    start_score = compaction_score_2d(blocks_set)
    start_pot = potential(blocks_set, 2)
    start_state = tuple(sorted(blocks_set))

    beam = [
        {
            "blocks": set(blocks_set),
            "sequence": [],
            "score": start_score,
            "potential": start_pot
        }
    ]

    visited = {start_state}

    best_sequence = None
    best_key = None

    for depth in range(1, max_depth + 1):
        next_beam = []

        for node in beam:
            current_blocks = node["blocks"]
            moves = generate_valid_moves_2d(current_blocks)

            moves = sorted(
                moves,
                key=lambda m: move_sort_key(current_blocks, m)
            )[:branch_limit]

            for c, e, move_type in moves:
                after = apply_move(current_blocks, c, e)
                state = tuple(sorted(after))

                if state in visited:
                    continue

                visited.add(state)

                seq = node["sequence"] + [(c, e, move_type, "macro_escape")]
                after_score = compaction_score_2d(after)
                after_pot = potential(after, 2)

                key = (
                    0 if is_finished_2d(after) else 1,
                    after_score,
                    after_pot,
                    len(seq)
                )

                # Điều kiện nhận chuỗi:
                # finished hoặc score giảm rõ ràng hoặc potential giảm rõ ràng sau vài bước
                accepted = (
                    is_finished_2d(after)
                    or after_score < start_score
                    or (depth >= 2 and after_pot < start_pot)
                )

                if accepted:
                    if best_sequence is None or key < best_key:
                        best_sequence = seq
                        best_key = key

                next_beam.append(
                    {
                        "blocks": after,
                        "sequence": seq,
                        "score": after_score,
                        "potential": after_pot
                    }
                )

        if best_sequence is not None:
            return best_sequence

        next_beam.sort(
            key=lambda node: (
                node["score"],
                node["potential"],
                len(node["sequence"])
            )
        )

        beam = next_beam[:beam_width]

        if not beam:
            break

    return None


# ============================================================
# 6. Chọn operation theo pipeline
# ============================================================

def choose_one_step_paper_move_2d(blocks_set):
    """
    Thử lần lượt các operation một bước.
    """
    operations = [
        local_y_reduction,
        column_shove,
        local_potential_reduction,
        handling_low_components,
        small_low_components,
        big_low_components
    ]

    for op in operations:
        move = op(blocks_set)
        if move is not None:
            return move

    return None


def choose_next_sequence_2d(blocks_set):
    """
    Trả về một sequence move.

    Thường sequence chỉ có 1 move.
    Nếu greedy bị kẹt, dùng macro_escape để tìm chuỗi nhiều bước.
    """
    one_step = choose_one_step_paper_move_2d(blocks_set)

    if one_step is not None:
        c, e, move_type, operation, next_blocks, next_pot = one_step
        return [(c, e, move_type, operation)]

    macro_seq = beam_escape_sequence_2d(
        blocks_set,
        max_depth=5,
        beam_width=80,
        branch_limit=35
    )

    if macro_seq:
        return macro_seq

    return None


# ============================================================
# 7. Vòng lặp chính
# ============================================================

def compact_2d_1(blocks, max_steps):
    """
    Thuật toán 2D paper-inspired cải tiến.

    Giữ nguyên input/output.
    Bên trong dùng:
    - guided operation one-step
    - macro_escape beam search để tránh local optimum
    """
    blocks_set = to_tuple_set(blocks)
    curr_blocks = blocks_set
    curr_pot = potential(curr_blocks, 2)

    initial_info = {
        "blocks": to_list(curr_blocks),
        "potential": curr_pot,
        "is_connected": True,
        "is_finished": is_finished_2d(curr_blocks)
    }

    steps = []
    status = "completed" if is_finished_2d(curr_blocks) else "running"

    if status == "completed":
        final_info = {
            "blocks": to_list(curr_blocks),
            "potential": curr_pot,
            "is_connected": True,
            "is_finished": True
        }

        return build_response(
            True,
            "Compaction completed successfully.",
            2,
            initial_info,
            steps,
            final_info,
            status,
            algorithm="paper_inspired_2d"
        )

    step_idx = 1

    while step_idx <= max_steps:
        if is_finished_2d(curr_blocks):
            status = "completed"
            break

        sequence = choose_next_sequence_2d(curr_blocks)

        if sequence is None:
            status = "no_valid_move_found"
            break

        for c, e, move_type, operation in sequence:
            if step_idx > max_steps:
                status = "max_steps_reached"
                break

            # Có thể sau khi chạy vài bước trong sequence, move tiếp theo không còn hợp lệ.
            # Khi đó thoát sequence và chọn lại ở vòng ngoài.
            if c not in curr_blocks or e in curr_blocks:
                break

            current_move_type = get_move_type_2d(c, e, curr_blocks)

            if current_move_type is None:
                break

            if not is_move_connected(curr_blocks, c, e, 2):
                break

            blocks_before = set(curr_blocks)
            pot_before = curr_pot

            next_blocks = apply_move(curr_blocks, c, e)
            next_pot = potential(next_blocks, 2)

            finished_after = is_finished_2d(next_blocks)
            connected_after = is_connected(next_blocks, 2)

            step_info = make_step_info(
                step_idx=step_idx,
                from_c=c,
                to_c=e,
                move_type=current_move_type,
                blocks_before=blocks_before,
                blocks_after=next_blocks,
                pot_before=pot_before,
                pot_after=next_pot,
                connected_after=connected_after,
                finished_after=finished_after,
                operation=operation
            )

            steps.append(step_info)

            curr_blocks = next_blocks
            curr_pot = next_pot
            step_idx += 1

            if finished_after:
                status = "completed"
                break

        if status in ["completed", "max_steps_reached"]:
            break

    if status == "running":
        status = "max_steps_reached" if step_idx > max_steps else "no_valid_move_found"

    final_finished = is_finished_2d(curr_blocks)

    if final_finished:
        status = "completed"

    final_info = {
        "blocks": to_list(curr_blocks),
        "potential": curr_pot,
        "is_connected": is_connected(curr_blocks, 2),
        "is_finished": final_finished
    }

    if status == "completed":
        message = "Compaction completed successfully."
    elif status == "max_steps_reached":
        message = "Maximum number of steps reached before finishing compaction."
    else:
        message = "No valid move found."

    return build_response(
        True,
        message,
        2,
        initial_info,
        steps,
        final_info,
        status,
        algorithm="paper_inspired_2d"
    )