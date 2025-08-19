import zlib
import sys
from pathlib import Path


def get_tree_object_content(data: bytes) -> bytes:
    output = bytearray()

    # 기존 헤더 ("tree <size>\x00") 그대로 복사
    header_end = data.find(b"\x00")
    output += data[: header_end + 1]
    i = header_end + 1

    # 각 엔트리 파싱 및 SHA를 .hex()로 변환
    while i < len(data):
        mode_end = data.find(b" ", i)
        name_end = data.find(b"\x00", mode_end)
        mode = data[i:mode_end]
        name = data[mode_end + 1 : name_end]

        sha_start = name_end + 1
        sha_end = sha_start + 20
        sha = data[sha_start:sha_end]
        sha_hex = sha.hex().encode("ascii")

        # 기존 구조 유지
        output += b" " + mode + b" " + name + r"\0".encode() + sha_hex

        i = sha_end

    return bytes(output)


# .git/objects/xx/yyyyyy 에서 Git object 읽기
path = Path(".git", "objects", sys.argv[1][:2], sys.argv[1][2:])
with open(path, "rb") as f:
    compressed = f.read()
    raw = zlib.decompress(compressed)

    result = get_tree_object_content(raw) + b"\n"
    sys.stdout.buffer.write(result)
