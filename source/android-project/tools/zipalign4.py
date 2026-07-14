#!/usr/bin/env python3
"""Minimal deterministic 4-byte aligner for stored ZIP entries in APK files.

It rewrites the ZIP before APK Signature Scheme v2 signing. Every uncompressed
entry receives a valid private extra-field whose total size aligns the entry's
data offset to a 4-byte boundary. Compressed entries are copied normally.
"""
from __future__ import annotations
import argparse
import io
import os
import struct
import tempfile
import zipfile
from pathlib import Path

ALIGNMENT = 4
PRIVATE_HEADER_ID = 0xA11E


def clone_info(src: zipfile.ZipInfo) -> zipfile.ZipInfo:
    dst = zipfile.ZipInfo(src.filename, date_time=src.date_time)
    dst.compress_type = src.compress_type
    dst.comment = src.comment
    dst.create_system = src.create_system
    dst.create_version = src.create_version
    dst.extract_version = src.extract_version
    dst.flag_bits = src.flag_bits & ~0x08  # sizes/CRC are known; no data descriptor
    dst.internal_attr = src.internal_attr
    dst.external_attr = src.external_attr
    dst.volume = src.volume
    return dst


def align_apk(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(source, 'r') as zin, zipfile.ZipFile(
        destination, 'w', allowZip64=True
    ) as zout:
        zout.comment = zin.comment
        for src_info in zin.infolist():
            data = zin.read(src_info.filename)
            dst_info = clone_info(src_info)
            if src_info.compress_type == zipfile.ZIP_STORED and not src_info.is_dir():
                # Local header starts at current stream position. Python emits:
                # 30-byte fixed header + UTF-8 filename + dst_info.extra.
                current = zout.fp.tell()
                name_bytes = src_info.filename.encode('utf-8')
                base_offset = current + 30 + len(name_bytes)
                needed = (-base_offset) % ALIGNMENT
                if needed:
                    # A valid extra field is 4-byte id/length header plus payload.
                    # Its total length has the same modulo 4 as payload length.
                    payload_len = needed
                    dst_info.extra = struct.pack('<HH', PRIVATE_HEADER_ID, payload_len) + (b'\0' * payload_len)
                else:
                    dst_info.extra = b''
            else:
                dst_info.extra = b''
            level = 9 if dst_info.compress_type == zipfile.ZIP_DEFLATED else None
            zout.writestr(dst_info, data, compress_type=dst_info.compress_type, compresslevel=level)


def data_offset(apk: Path, info: zipfile.ZipInfo) -> int:
    with apk.open('rb') as fh:
        fh.seek(info.header_offset)
        header = fh.read(30)
    if len(header) != 30 or header[:4] != b'PK\x03\x04':
        raise ValueError(f'Invalid local ZIP header for {info.filename}')
    filename_len, extra_len = struct.unpack_from('<HH', header, 26)
    return info.header_offset + 30 + filename_len + extra_len


def verify(apk: Path) -> None:
    errors: list[str] = []
    with zipfile.ZipFile(apk, 'r') as zf:
        bad = zf.testzip()
        if bad:
            errors.append(f'CRC failure: {bad}')
        for info in zf.infolist():
            if info.compress_type == zipfile.ZIP_STORED and not info.is_dir():
                offset = data_offset(apk, info)
                if offset % ALIGNMENT:
                    errors.append(f'{info.filename}: data offset {offset} is not 4-byte aligned')
    if errors:
        raise SystemExit('\n'.join(errors))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    align_apk(args.source, args.destination)
    verify(args.destination)
    print(f'ALIGNED={args.destination}')


if __name__ == '__main__':
    main()
