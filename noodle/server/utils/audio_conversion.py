import struct


def pcm_to_wav(
    pcm_data: bytes,
    sample_rate: int = 24000
) -> bytes:

    channels = 1
    bits_per_sample = 16

    byte_rate = (
        sample_rate *
        channels *
        bits_per_sample // 8
    )

    block_align = (
        channels *
        bits_per_sample // 8
    )

    wav_header = b"RIFF"

    wav_header += struct.pack(
        "<I",
        36 + len(pcm_data)
    )

    wav_header += b"WAVE"

    wav_header += b"fmt "

    wav_header += struct.pack(
        "<I",
        16
    )

    wav_header += struct.pack(
        "<HHIIHH",
        1,
        channels,
        sample_rate,
        byte_rate,
        block_align,
        bits_per_sample
    )

    wav_header += b"data"

    wav_header += struct.pack(
        "<I",
        len(pcm_data)
    )

    return wav_header + pcm_data