# algorithm_3d.py
from utils import (
    to_tuple_set,
    to_list,
    is_move_connected,
    is_connected,
    potential,
    apply_move,
    make_step_info,
    build_response
)


def is_finished_3d(blocks_set):
    """
    Kiểm tra cấu hình 3D đã nén xong chưa.
    Theo định nghĩa: với mỗi cube (x,y,z), toàn bộ cuboid
    từ (0,0,0) đến (x,y,z) phải có mặt trong cấu hình.
    """
    for x, y, z in blocks_set:
        for i in range(x + 1):
            for j in range(y + 1):
                for k in range(z + 1):
                    if (i, j, k) not in blocks_set:
                        return False
    return True


def add_vec(a, b):
    return tuple(a[i] + b[i] for i in range(3))


def sub_vec(a, b):
    return tuple(a[i] - b[i] for i in range(3))


def is_unit_axis_vector(v):
    """
    Kiểm tra vector có phải dạng:
    (±1,0,0), (0,±1,0), (0,0,±1)
    """
    return sum(abs(x) for x in v) == 1


def perpendicular_axis_vectors(direction):
    """
    Với hướng slide direction, trả về 4 vector vuông góc theo 2 trục còn lại.

    Ví dụ:
    direction = (1,0,0)
    thì các hướng vuông góc là:
    (0,1,0), (0,-1,0), (0,0,1), (0,0,-1)
    """
    result = []

    for axis in range(3):
        if direction[axis] == 0:
            v_pos = [0, 0, 0]
            v_neg = [0, 0, 0]

            v_pos[axis] = 1
            v_neg[axis] = -1

            result.append(tuple(v_pos))
            result.append(tuple(v_neg))

    return result


def is_slide_3d(c, e, blocks_set):
    """
    Slide trong 3D:
    - c và e phải kề mặt nhau.
    - Tồn tại một mặt phẳng 2D chứa c và e sao cho trong 4-cycle:
        c, e, c + p, e + p
      thì e là ô trống, còn c, c+p, e+p đều có cube.
    """
    direction = sub_vec(e, c)

    if not is_unit_axis_vector(direction):
        return False

    for p in perpendicular_axis_vectors(direction):
        c_side = add_vec(c, p)
        e_side = add_vec(e, p)

        if c_side in blocks_set and e_side in blocks_set:
            return True

    return False


def is_convex_3d(c, e, blocks_set):
    """
    Convex transition trong 3D:
    - c và e nằm chéo nhau trong một mặt phẳng tọa độ.
    - Nghĩa là chúng khác nhau đúng 2 trục, mỗi trục lệch 1 đơn vị.
    - Trong 4-cycle đó, đúng một trong hai ô trung gian có cube.
    """
    diff = sub_vec(e, c)
    changed_axes = [i for i in range(3) if diff[i] != 0]

    # Convex phải lệch đúng 2 trục
    if len(changed_axes) != 2:
        return False

    # Mỗi trục lệch đúng 1
    if any(abs(diff[i]) != 1 for i in changed_axes):
        return False

    # Trục còn lại phải giữ nguyên
    if sum(abs(x) for x in diff) != 2:
        return False

    a, b = changed_axes

    n1 = list(c)
    n1[a] = e[a]
    n1 = tuple(n1)

    n2 = list(c)
    n2[b] = e[b]
    n2 = tuple(n2)

    in_n1 = n1 in blocks_set
    in_n2 = n2 in blocks_set

    return in_n1 ^ in_n2


def is_valid_move_3d(c, e, blocks_set):
    """
    Trả về loại move nếu hợp lệ về mặt hình học:
    - "slide"
    - "convex"
    - None nếu không hợp lệ
    """
    if is_slide_3d(c, e, blocks_set):
        return "slide"

    if is_convex_3d(c, e, blocks_set):
        return "convex"

    return None


def generate_valid_moves_3d(blocks_set):
    moves = []

    if not blocks_set:
        return moves

    min_x = min(b[0] for b in blocks_set) - 1
    max_x = max(b[0] for b in blocks_set) + 1
    min_y = min(b[1] for b in blocks_set) - 1
    max_y = max(b[1] for b in blocks_set) + 1
    min_z = min(b[2] for b in blocks_set) - 1
    max_z = max(b[2] for b in blocks_set) + 1

    empty_cells = [
        (x, y, z)
        for x in range(min_x, max_x + 1)
        for y in range(min_y, max_y + 1)
        for z in range(min_z, max_z + 1)
        if (x, y, z) not in blocks_set
    ]

    for c in blocks_set:
        # Điều kiện quan trọng của bài báo:
        # Trong lúc move, C \ {c} phải liên thông.
        remaining = set(blocks_set)
        remaining.remove(c)

        if not is_connected(remaining, 3):
            continue

        for e in empty_cells:
            # Bản simulator hiện tại chưa hỗ trợ tọa độ âm
            if e[0] < 0 or e[1] < 0 or e[2] < 0:
                continue

            move_type = is_valid_move_3d(c, e, blocks_set)

            # Kiểm tra thêm trạng thái sau khi đặt cube xuống vẫn liên thông
            if move_type and is_move_connected(blocks_set, c, e, 3):
                moves.append((c, e, move_type))

    return moves


def compact_3d(blocks, max_steps):
    blocks_set = to_tuple_set(blocks)
    pot_initial = potential(blocks_set, 3)

    initial_info = {
        "blocks": blocks,
        "potential": pot_initial,
        "is_connected": True,
        "is_finished": is_finished_3d(blocks_set)
    }

    steps = []
    curr_blocks = blocks_set
    curr_pot = pot_initial
    status = "completed" if is_finished_3d(curr_blocks) else "running"

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
            3,
            initial_info,
            steps,
            final_info,
            status
        )

    for step_idx in range(1, max_steps + 1):
        valid_moves = generate_valid_moves_3d(curr_blocks)

        best_move = None
        best_pot = curr_pot

        for c, e, move_type in valid_moves:
            next_blocks = apply_move(curr_blocks, c, e)
            next_pot = potential(next_blocks, 3)

            if next_pot < best_pot:
                best_pot = next_pot
                best_move = (c, e, move_type, next_blocks)

        if not best_move:
            status = "completed" if is_finished_3d(curr_blocks) else "no_valid_move_found"
            break

        c, e, move_type, next_blocks = best_move
        finished_after = is_finished_3d(next_blocks)

        step_info = make_step_info(
            step_idx,
            c,
            e,
            move_type,
            curr_blocks,
            next_blocks,
            curr_pot,
            best_pot,
            True,
            finished_after
        )

        steps.append(step_info)

        curr_blocks = next_blocks
        curr_pot = best_pot

        if finished_after:
            status = "completed"
            break

    if status == "running":
        if len(steps) == max_steps:
            status = "max_steps_reached"
        else:
            status = "no_valid_move_found"

    final_finished = is_finished_3d(curr_blocks)

    if final_finished:
        status = "completed"

    final_info = {
        "blocks": to_list(curr_blocks),
        "potential": curr_pot,
        "is_connected": True,
        "is_finished": final_finished
    }

    message = (
        "Compaction completed successfully."
        if status == "completed"
        else "No valid move found."
        if status == "no_valid_move_found"
        else "Maximum number of steps reached before finishing compaction."
    )

    return build_response(
        True,
        message,
        3,
        initial_info,
        steps,
        final_info,
        status
    )