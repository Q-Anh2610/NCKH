from validator import validate_input
from algorithm_2d_1 import compact_2d_1
from algorithm_3d_1 import compact_3d_exact


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
        return compact_2d_1(
            blocks=blocks,
            max_steps=max_steps
        )

    if dimension == 3:
        return compact_3d_exact(
            blocks=blocks,
            max_steps=max_steps
        )

    return {
        "success": False,
        "message": "Only dimension 2 and 3 are supported.",
        "dimension": dimension,
        "algorithm": None,
        "initial": None,
        "steps": [],
        "final": None,
        "total_steps": 0,
        "status": "invalid_input",
        "error_code": "INVALID_DIMENSION"
    }