from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

from compaction import compact


app = FastAPI(
    title="Sliding Cubes Compaction API",
    description="API for 2D/3D sliding cubes compaction simulator",
    version="1.0.0"
)


class CompactRequest(BaseModel):
    dimension: int
    blocks: List[List[int]]
    max_steps: int = 500


@app.get("/")
def root():
    return {
        "success": True,
        "message": "Sliding Cubes Compaction API is running."
    }


@app.post("/compact")
def compact_api(req: CompactRequest):
    return compact(
        dimension=req.dimension,
        blocks=req.blocks,
        max_steps=req.max_steps
    )