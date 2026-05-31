from utils import to_tuple_set, is_connected


def validate_input(dimension, blocks, max_steps):
    """
    Validate request input before running the compaction algorithm.
    """

    if dimension not in [2, 3]:
        return {
            "success": False,
            "message": "Dimension must be 2 or 3.",
            "dimension": dimension,
            "algorithm": "greedy_potential",
            "initial": None,
            "steps": [],
            "final": None,
            "total_steps": 0,
            "status": "invalid_input",
            "error_code": "INVALID_DIMENSION"
        }

    if not blocks:
        return {
            "success": False,
            "message": "Blocks cannot be empty.",
            "dimension": dimension,
            "algorithm": "greedy_potential",
            "initial": None,
            "steps": [],
            "final": None,
            "total_steps": 0,
            "status": "invalid_input",
            "error_code": "EMPTY_CONFIGURATION"
        }

    if not isinstance(max_steps, int) or max_steps <= 0:
        return {
            "success": False,
            "message": "max_steps must be a positive integer.",
            "dimension": dimension,
            "algorithm": "greedy_potential",
            "initial": None,
            "steps": [],
            "final": None,
            "total_steps": 0,
            "status": "invalid_input",
            "error_code": "INVALID_MAX_STEPS"
        }

    for block in blocks:
        if not isinstance(block, list):
            return {
                "success": False,
                "message": "Each block must be a list of coordinates.",
                "dimension": dimension,
                "algorithm": "greedy_potential",
                "initial": None,
                "steps": [],
                "final": None,
                "total_steps": 0,
                "status": "invalid_input",
                "error_code": "INVALID_BLOCK_FORMAT"
            }

        if len(block) != dimension:
            return {
                "success": False,
                "message": f"Each block must have exactly {dimension} coordinates.",
                "dimension": dimension,
                "algorithm": "greedy_potential",
                "initial": None,
                "steps": [],
                "final": None,
                "total_steps": 0,
                "status": "invalid_input",
                "error_code": "INVALID_BLOCK_DIMENSION"
            }

        for value in block:
            if not isinstance(value, int):
                return {
                    "success": False,
                    "message": "All coordinates must be integers.",
                    "dimension": dimension,
                    "algorithm": "greedy_potential",
                    "initial": None,
                    "steps": [],
                    "final": None,
                    "total_steps": 0,
                    "status": "invalid_input",
                    "error_code": "INVALID_COORDINATE_TYPE"
                }

            if value < 0:
                return {
                    "success": False,
                    "message": "Negative coordinates are not supported.",
                    "dimension": dimension,
                    "algorithm": "greedy_potential",
                    "initial": None,
                    "steps": [],
                    "final": None,
                    "total_steps": 0,
                    "status": "invalid_input",
                    "error_code": "NEGATIVE_COORDINATES"
                }

    blocks_set = to_tuple_set(blocks)

    if len(blocks_set) != len(blocks):
        return {
            "success": False,
            "message": "Duplicate block coordinates found.",
            "dimension": dimension,
            "algorithm": "greedy_potential",
            "initial": None,
            "steps": [],
            "final": None,
            "total_steps": 0,
            "status": "invalid_input",
            "error_code": "DUPLICATE_BLOCKS"
        }

    if not is_connected(blocks_set, dimension):
        return {
            "success": False,
            "message": "Initial configuration is not connected.",
            "dimension": dimension,
            "algorithm": "greedy_potential",
            "initial": None,
            "steps": [],
            "final": None,
            "total_steps": 0,
            "status": "invalid_input",
            "error_code": "NOT_CONNECTED"
        }

    return None