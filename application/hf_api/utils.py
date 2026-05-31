# utils.py

from collections import deque


def to_tuple_set(blocks):
    return set(tuple(b) for b in blocks)


def to_list(blocks_set):
    return [list(b) for b in sorted(blocks_set)]


def get_neighbors(block, dimension):
    neighbors = []

    if dimension == 2:
        x, y = block
        moves = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        for dx, dy in moves:
            neighbors.append((x + dx, y + dy))

    else:
        x, y, z = block
        moves = [
            (1, 0, 0), (-1, 0, 0),
            (0, 1, 0), (0, -1, 0),
            (0, 0, 1), (0, 0, -1)
        ]
        for dx, dy, dz in moves:
            neighbors.append((x + dx, y + dy, z + dz))

    return neighbors


def is_connected(blocks_set, dimension):
    if not blocks_set:
        return True

    start_node = next(iter(blocks_set))
    visited = {start_node}
    queue = deque([start_node])

    while queue:
        curr = queue.popleft()

        for neighbor in get_neighbors(curr, dimension):
            if neighbor in blocks_set and neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    return len(visited) == len(blocks_set)


def apply_move(blocks_set, from_coord, to_coord):
    new_set = set(blocks_set)

    if from_coord not in new_set:
        raise ValueError("from_coord is not in the configuration.")

    if to_coord in new_set:
        raise ValueError("to_coord is already occupied.")

    new_set.remove(from_coord)
    new_set.add(to_coord)

    return new_set


def is_move_connected(blocks_set, from_coord, to_coord, dimension):
    # Điều kiện trong bài báo: C \ {c} phải liên thông trong khi cube đang move
    temp_set = set(blocks_set)
    temp_set.remove(from_coord)

    if not is_connected(temp_set, dimension):
        return False

    # Sau khi đặt cube xuống vị trí mới, cấu hình cũng nên liên thông
    new_set = apply_move(blocks_set, from_coord, to_coord)
    return is_connected(new_set, dimension)


def potential(blocks, dimension):
    """
    Potential theo bài báo:
    Πc = wc(cx + 2cy + 4cz)

    Với 2D, coi z = 0.
    """
    total_potential = 0

    for b in blocks:
        x = b[0]
        y = b[1]
        z = b[2] if dimension == 3 else 0

        if z > 1:
            w = 17
        elif z == 1:
            w = 16
        else:
            if y > 1:
                w = 3
            elif y == 1:
                w = 2
            else:
                w = 1

        total_potential += w * (x + 2 * y + 4 * z)

    return total_potential


def is_finished_2d(blocks_set):
    """
    Một ô (x,y) finished nếu toàn bộ hình chữ nhật
    {0..x} x {0..y} đều có trong cấu hình.
    """
    for x, y in blocks_set:
        for i in range(x + 1):
            for j in range(y + 1):
                if (i, j) not in blocks_set:
                    return False
    return True


def is_finished_3d(blocks_set):
    """
    Một cube (x,y,z) finished nếu toàn bộ cuboid
    {0..x} x {0..y} x {0..z} đều có trong cấu hình.
    """
    for x, y, z in blocks_set:
        for i in range(x + 1):
            for j in range(y + 1):
                for k in range(z + 1):
                    if (i, j, k) not in blocks_set:
                        return False
    return True


def make_step_info(
    step_idx,
    from_c,
    to_c,
    move_type,
    blocks_before,
    blocks_after,
    pot_before,
    pot_after,
    connected_after,
    finished_after,
    operation=None
):
    step = {
        "step": step_idx,
        "from": list(from_c),
        "to": list(to_c),
        "move_type": move_type,
        "blocks_before": to_list(blocks_before),
        "blocks_after": to_list(blocks_after),
        "potential_before": pot_before,
        "potential_after": pot_after,
        "is_connected_after": connected_after,
        "is_finished_after": finished_after
    }

    if operation is not None:
        step["operation"] = operation

    return step


def build_response(
    success,
    message,
    dimension,
    initial_info,
    steps,
    final_info,
    status,
    algorithm="greedy_potential"
):
    return {
        "success": success,
        "message": message,
        "dimension": dimension,
        "algorithm": algorithm,
        "initial": initial_info,
        "steps": steps,
        "final": final_info,
        "total_steps": len(steps),
        "status": status
    }