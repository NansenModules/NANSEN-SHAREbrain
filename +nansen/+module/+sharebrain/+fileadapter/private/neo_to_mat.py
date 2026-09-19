"""Read a file with Neo and write its block to a MATLAB .mat file.

Used by the NANSEN-SHAREbrain file adapters for formats that have no
MATLAB reader: pickled Neo objects, NIX files and Igor Pro files.

    python neo_to_mat.py <file> <format> <mat file>

<format> is "pickle", "nix" or "igor". The .mat file holds one struct,
block, with the block's name, description, annotations and segments. Each
segment holds its analog signals, irregularly sampled signals, spike
trains, events and epochs, with times in seconds, sampling rates in Hz and
the units of each signal as text. Lists (segments, signals, labels) are
cell arrays, also when they are empty.
"""

import pickle
import re
import sys

import numpy as np
import scipy.io


def read_block(file_path, file_format):
    """The first Neo block in a file."""
    if file_format == "pickle":
        with open(file_path, "rb") as file:
            content = pickle.load(file)
    elif file_format == "nix":
        import neo
        reader = neo.io.NixIO(file_path, mode="ro")
        try:
            content = reader.read_block()
        finally:
            reader.close()
    elif file_format == "igor":
        import neo
        content = neo.io.IgorIO(file_path).read_block()
    else:
        raise ValueError(f"Unknown format {file_format!r}; use pickle, nix or igor.")

    # A pickle can hold a list of blocks
    if isinstance(content, (list, tuple)):
        content = content[0]
    return content


def cell(items):
    """A 1-by-n object array, which a .mat file stores as a cell array.

    scipy.io.savemat writes an empty list as a 0-by-0 double and a list of
    strings as a padded char matrix; an object array keeps both a cell.
    """
    array = np.empty((1, len(items)), dtype=object)
    for index, item in enumerate(items):
        array[0, index] = item
    return array


def field_name(key, taken):
    """A valid MATLAB field name for an annotation key, not already in taken.

    Keys that differ only in characters MATLAB does not allow ("a-b", "a_b")
    get the suffixes _2, _3, ... instead of overwriting each other.
    """
    name = re.sub(r"\W", "_", str(key))
    if not re.match(r"[A-Za-z]", name):
        name = "x" + name
    name = name[:63]
    candidate, number = name, 1
    while candidate in taken:
        number += 1
        suffix = f"_{number}"
        candidate = name[:63 - len(suffix)] + suffix
    return candidate


def simple_value(value):
    """An annotation value that a .mat file can hold, or None to leave it out."""
    if isinstance(value, (str, bool, int, float, np.integer, np.floating, np.bool_)):
        return value
    if isinstance(value, np.ndarray) and value.dtype.kind in "biufU":
        return value
    if hasattr(value, "magnitude"):  # A quantity
        return np.asarray(value.magnitude)
    if isinstance(value, (list, tuple)) and all(
            isinstance(item, (str, int, float, bool)) for item in value):
        if value and all(isinstance(item, (int, float, bool)) for item in value):
            return np.asarray(value)
        return cell(list(value))
    if value is None:
        return None
    return str(value)


def annotations(obj):
    """The annotations of a Neo object that a .mat file can hold."""
    result = {}
    for key, value in getattr(obj, "annotations", {}).items():
        converted = simple_value(value)
        if converted is not None:
            result[field_name(key, result)] = converted
    return result


def text(value):
    return "" if value is None else str(value)


def seconds(quantity):
    return np.asarray(quantity.rescale("s").magnitude, dtype=float)


def array_annotations(obj):
    """One value per channel or event; values that are not numbers or text,
    such as None, are written as text in a cell array."""
    result = {}
    for key, value in getattr(obj, "array_annotations", {}).items():
        values = np.asarray(value)
        if values.dtype.kind not in "biufU":
            values = cell([text(item) for item in values.ravel()])
        result[field_name(key, result)] = values
    return result


def analog_signal(signal):
    return {
        "name": text(signal.name),
        "data": np.asarray(signal.magnitude),
        "units": str(signal.units.dimensionality),
        "sampling_rate": float(signal.sampling_rate.rescale("Hz").magnitude),
        "t_start": float(seconds(signal.t_start)),
        "array_annotations": array_annotations(signal),
        "annotations": annotations(signal),
    }


def irregular_signal(signal):
    return {
        "name": text(signal.name),
        "times": seconds(signal.times),
        "data": np.asarray(signal.magnitude),
        "units": str(signal.units.dimensionality),
        "array_annotations": array_annotations(signal),
        "annotations": annotations(signal),
    }


def spike_train(train):
    return {
        "name": text(train.name),
        "times": seconds(train.times),
        "t_start": float(seconds(train.t_start)),
        "t_stop": float(seconds(train.t_stop)),
        "annotations": annotations(train),
    }


def event(item):
    return {
        "name": text(item.name),
        "times": seconds(item.times),
        "labels": cell([str(label) for label in item.labels]),
        "annotations": annotations(item),
    }


def epoch(item):
    return {
        "name": text(item.name),
        "times": seconds(item.times),
        "durations": seconds(item.durations),
        "labels": cell([str(label) for label in item.labels]),
        "annotations": annotations(item),
    }


def segment(item):
    return {
        "name": text(item.name),
        "annotations": annotations(item),
        "analogsignals": cell([analog_signal(s) for s in item.analogsignals]),
        "irregularlysampledsignals": cell([irregular_signal(s) for s in item.irregularlysampledsignals]),
        "spiketrains": cell([spike_train(s) for s in item.spiketrains]),
        "events": cell([event(e) for e in item.events]),
        "epochs": cell([epoch(e) for e in item.epochs]),
    }


def block_to_dict(block):
    return {
        "name": text(block.name),
        "description": text(block.description),
        "file_origin": text(block.file_origin),
        "rec_datetime": text(block.rec_datetime),
        "annotations": annotations(block),
        "segments": cell([segment(s) for s in block.segments]),
    }


def main(file_path, file_format, mat_path):
    block = read_block(file_path, file_format)
    scipy.io.savemat(mat_path, {"block": block_to_dict(block)},
                     long_field_names=True, do_compression=True)


if __name__ == "__main__":
    main(*sys.argv[1:4])
