"""2x2 방향 시트를 32x32 프레임과 가로 스프라이트시트로 분할한다.

사용법:
    python tools/slice_sheet.py <sheet.png> <out_dir> [--cell 32] [--cols 2] [--rows 2]

출력:
    <out_dir>/frames/down.png, up.png, left.png, right.png   (각 32x32)
    <out_dir>/kang_minwoo_sheet.png                          (32x128 가로 1행)
    <out_dir>/kang_minwoo_sheet.json                          (프레임 인덱스 메타)
"""

import argparse
import json
import os

from PIL import Image

# 2x2 셀 순서 -> 방향 이름. 생성 프롬프트의 배치와 일치해야 한다.
CELL_ORDER = ["down", "up", "left", "right"]


def trim(img):
    """알파 경계로 잘라낸다. 완전히 빈 셀이면 원본을 그대로 돌려준다."""
    box = img.getbbox()
    return img.crop(box) if box else img


def fit_cell(img, cell):
    """가로세로 비율을 유지한 채 cell x cell 안에 넣고 하단 중앙에 정렬한다.

    발밑이 타일 격자에 맞아야 하므로 세로 중앙이 아니라 하단 기준으로 붙인다.
    """
    src = trim(img)
    scale = min(cell / src.width, cell / src.height)
    w = max(1, int(src.width * scale))
    h = max(1, int(src.height * scale))
    scaled = src.resize((w, h), Image.NEAREST)

    out = Image.new("RGBA", (cell, cell), (0, 0, 0, 0))
    out.alpha_composite(scaled, ((cell - w) // 2, cell - h))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet")
    ap.add_argument("out_dir")
    ap.add_argument("--cell", type=int, default=32)
    ap.add_argument("--cols", type=int, default=2)
    ap.add_argument("--rows", type=int, default=2)
    ap.add_argument("--name", default="kang_minwoo")
    args = ap.parse_args()

    sheet = Image.open(args.sheet).convert("RGBA")
    cw = sheet.width // args.cols
    ch = sheet.height // args.rows

    frame_dir = os.path.join(args.out_dir, "frames")
    os.makedirs(frame_dir, exist_ok=True)

    frames = []
    for idx in range(args.cols * args.rows):
        r, c = divmod(idx, args.cols)
        cell = sheet.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
        frame = fit_cell(cell, args.cell)

        name = CELL_ORDER[idx] if idx < len(CELL_ORDER) else f"frame_{idx}"
        frame.save(os.path.join(frame_dir, f"{name}.png"))
        frames.append((name, frame))

    # 가로 1행 시트. Godot AtlasTexture / SpriteFrames 가 그대로 읽는 배치다.
    strip = Image.new("RGBA", (args.cell * len(frames), args.cell), (0, 0, 0, 0))
    for i, (_, frame) in enumerate(frames):
        strip.alpha_composite(frame, (i * args.cell, 0))
    strip_path = os.path.join(args.out_dir, f"{args.name}_sheet.png")
    strip.save(strip_path)

    meta = {
        "name": args.name,
        "frame_size": [args.cell, args.cell],
        "sheet": os.path.basename(strip_path),
        "layout": "horizontal",
        "frames": [
            {"index": i, "direction": name, "region": [i * args.cell, 0, args.cell, args.cell]}
            for i, (name, _) in enumerate(frames)
        ],
    }
    meta_path = os.path.join(args.out_dir, f"{args.name}_sheet.json")
    with open(meta_path, "w", encoding="utf-8") as fh:
        json.dump(meta, fh, ensure_ascii=False, indent=2)

    print(f"sheet  {strip_path}  {strip.size}")
    print(f"meta   {meta_path}")
    print(f"frames {frame_dir}  ({len(frames)})")


if __name__ == "__main__":
    main()
