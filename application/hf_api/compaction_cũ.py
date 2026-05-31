from validator import validate_input
from algorithm_2d import compact_2d
from algorithm_3d import compact_3d


def compact(dimension, blocks, max_steps=500):
    """
    Main controller function.
    It validates input, then routes to 2D or 3D compaction.
    """

    error = validate_input(
        dimension=dimension,
        blocks=blocks,
        max_steps=max_steps
    )

    if error:
        return error

    if dimension == 2:
        return compact_2d(
            blocks=blocks,
            max_steps=max_steps
        )

    if dimension == 3:
        return compact_3d(
            blocks=blocks,
            max_steps=max_steps
        )

    return {
        "success": False,
        "message": "Only dimension 2 and 3 are supported.",
        "dimension": dimension,
        "algorithm": "greedy_potential",
        "initial": None,
        "steps": [],
        "final": None,
        "total_steps": 0,
        "status": "invalid_input",
        "error_code": "INVALID_DIMENSION"
    }