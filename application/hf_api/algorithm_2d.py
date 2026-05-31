# algorithm_2d_1.py

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

    # vector vuông góc với hướng di chuyển
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


def bounding_search_area_2d(blocks_set):
    min_x = min(x for x, y in blocks_set) - 1
    max_x = max(x for x, y in blocks_set) + 1
    min_y = min(y for x, y in blocks_set) - 1
    max_y = max(y for x, y in blocks_set) + 1

    return min_x, max_x, min_y, max_y


def generate_valid_moves_2d(blocks_set):
    """
    Sinh tất cả move hợp lệ trong vùng quanh cấu hình hiện tại.
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

    min_x, max_x, min_y, max_y = bounding_search_area_2d(blocks_set)

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
# 2. Công cụ chọn move
# ============================================================

def choose_best_reducing_move(blocks_set, candidate_moves):
    """
    Chọn move làm giảm potential nhiều nhất.
    """
    curr_pot = potential(blocks_set, 2)

    best = None
    best_pot = curr_pot

    for c, e, move_type, operation in candidate_moves:
        next_blocks = apply_move(blocks_set, c, e)
        next_pot = potential(next_blocks, 2)

        if next_pot < best_pot:
            best_pot = next_pot
            best = (c, e, move_type, operation, next_blocks, next_pot)

    return best


def all_reducing_moves_with_operation(blocks_set, operation_name, filter_func=None):
    moves = []

    for c, e, move_type in generate_valid_moves_2d(blocks_set):
        if filter_func is not None and not filter_func(c, e, move_type):
            continue

        next_blocks = apply_move(blocks_set, c, e)

        if potential(next_blocks, 2) < potential(blocks_set, 2):
            moves.append((c, e, move_type, operation_name))

    return moves


# ============================================================
# 3. Các bước paper-inspired cho bài toán 2D
# ============================================================

def local_y_reduction(blocks_set):
    """
    Bước 1: Local y-reduction.
    Phiên bản 2D của local z-reduction.
    Ưu tiên move làm giảm y, tức kéo ô xuống thấp hơn.
    """
    def filt(c, e, move_type):
        return e[1] < c[1]

    candidates = all_reducing_moves_with_operation(
        blocks_set,
        "local_y_reduction",
        filt
    )

    return choose_best_reducing_move(blocks_set, candidates)


def get_vertical_columns(blocks_set):
    """
    Nhóm các ô theo cùng x.
    Đây là phiên bản 2D của pillar theo trục y.
    """
    columns = {}

    for x, y in blocks_set:
        columns.setdefault(x, []).append(y)

    result = {}

    for x, ys in columns.items():
        ys = sorted(ys)
        segments = []
        start = ys[0]
        prev = ys[0]

        for y in ys[1:]:
            if y == prev + 1:
                prev = y
            else:
                segments.append((start, prev))
                start = y
                prev = y

        segments.append((start, prev))
        result[x] = segments

    return result


def is_in_nontrivial_column(c, blocks_set):
    """
    Kiểm tra c có thuộc một cột dọc có độ dài >= 2 không.
    """
    x, y = c

    count = 0
    for bx, by in blocks_set:
        if bx == x:
            count += 1

    return count >= 2


def column_shove(blocks_set):
    """
    Bước 2: Column shove.
    Đây là bản đơn giản hóa của pillar shove trong 3D.
    Ta ưu tiên move thuộc một cột dọc, làm giảm potential.
    """
    def filt(c, e, move_type):
        if not is_in_nontrivial_column(c, blocks_set):
            return False

        # Ưu tiên dịch xuống hoặc sang trái.
        return e[1] <= c[1] or e[0] < c[0]

    candidates = all_reducing_moves_with_operation(
        blocks_set,
        "column_shove",
        filt
    )

    return choose_best_reducing_move(blocks_set, candidates)


def local_potential_reduction(blocks_set):
    """
    Bước 3: Local potential reduction.
    Nếu có bất kỳ move hợp lệ nào làm giảm potential thì chọn move tốt nhất.
    """
    candidates = all_reducing_moves_with_operation(
        blocks_set,
        "local_potential_reduction"
    )

    return choose_best_reducing_move(blocks_set, candidates)


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
    """
    Trong 2D:
    - low cells: y = 0
    - high cells: y > 0
    """
    low_cells = {b for b in blocks_set if b[1] == 0}
    high_cells = {b for b in blocks_set if b[1] > 0}

    low_components = connected_components_2d(low_cells)
    high_components = connected_components_2d(high_cells)

    return low_components, high_components


def get_root_low_component(low_components):
    """
    Root là low component chứa (0,0), nếu có.
    Nếu chưa có (0,0), chọn component đầu tiên.
    """
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


def handling_low_components(blocks_set):
    """
    Bước 4-5: Handling low components.
    Nếu có low component không phải root, thử move các ô trong đó
    hoặc gần đó để giảm potential và tiến về phía root.
    """
    non_root = non_root_low_components(blocks_set)

    if not non_root:
        return None

    non_root_cells = set()
    for comp in non_root:
        non_root_cells.update(comp)

    def filt(c, e, move_type):
        # Ưu tiên xử lý các ô đáy không thuộc root
        if c not in non_root_cells:
            return False

        # Kéo về trái hoặc giữ y=0
        return e[0] < c[0] or e[1] == 0

    candidates = all_reducing_moves_with_operation(
        blocks_set,
        "handling_low_components",
        filt
    )

    return choose_best_reducing_move(blocks_set, candidates)


def is_small_low_component(component):
    """
    Heuristic 2D:
    Một low component nhỏ nếu số ô của nó nhỏ hơn khoảng cách từ ô trái nhất của nó về gốc.
    """
    if not component:
        return False

    min_x = min(x for x, y in component)
    return len(component) < min_x + 1


def small_low_components(blocks_set):
    """
    Bước 6: Small low components.
    Với low component nhỏ, dùng nó như phần hỗ trợ.
    Trong code mô phỏng, ta thử move từ component nhỏ nếu làm giảm potential.
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

    candidates = all_reducing_moves_with_operation(
        blocks_set,
        "small_low_components",
        filt
    )

    return choose_best_reducing_move(blocks_set, candidates)


def big_low_components(blocks_set):
    """
    Bước 7: Big low components.
    Với low component lớn, ưu tiên kéo nó về phía gốc để nhập vào root.
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

    candidates = all_reducing_moves_with_operation(
        blocks_set,
        "big_low_components",
        filt
    )

    return choose_best_reducing_move(blocks_set, candidates)


# ============================================================
# 5. Vòng lặp chính
# ============================================================

def choose_paper_inspired_move_2d(blocks_set):
    """
    Thử lần lượt các bước theo thứ tự bạn rút ra từ bài báo.
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


def compact_2d_1(blocks, max_steps):
    """
    Thuật toán 2D paper-inspired.
    Đây là bản mô phỏng có thứ tự các bước:
    local_y_reduction -> column_shove -> local_potential_reduction
    -> handling_low_components -> small_low_components -> big_low_components.
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

    for step_idx in range(1, max_steps + 1):
        if is_finished_2d(curr_blocks):
            status = "completed"
            break

        chosen = choose_paper_inspired_move_2d(curr_blocks)

        if chosen is None:
            status = "no_valid_move_found"
            break

        c, e, move_type, operation, next_blocks, next_pot = chosen

        finished_after = is_finished_2d(next_blocks)
        connected_after = is_connected(next_blocks, 2)

        step_info = make_step_info(
            step_idx=step_idx,
            from_c=c,
            to_c=e,
            move_type=move_type,
            blocks_before=curr_blocks,
            blocks_after=next_blocks,
            pot_before=curr_pot,
            pot_after=next_pot,
            connected_after=connected_after,
            finished_after=finished_after,
            operation=operation
        )

        steps.append(step_info)

        curr_blocks = next_blocks
        curr_pot = next_pot

        if finished_after:
            status = "completed"
            break

    if status == "running":
        status = "max_steps_reached"

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