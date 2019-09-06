#!/usr/bin/env python3
"""Format telemetry-ingestion metadata into a markdown table."""
import json
import urllib.request
from typing import Any, Dict, List, Tuple


def transform(data: Dict[str, Any]) -> List[Tuple[str, str]]:
    """Transform a JSON Schema into a list of (path, description) pairs."""

    # transform must start at a valid node in the schema
    assert "properties" in data
    # the result set
    result = []
    # state for breadth first traversal
    queue = [([], data["properties"])]

    while queue:
        prefix, obj = queue.pop()
        for key, sub in sorted(obj.items()):
            path = prefix + [key]
            if sub["type"] == "object":
                queue += [(path, sub["properties"])]
            elif "description" in sub:
                result += [(".".join(path), sub["description"])]
            else:
                # not a leaf with a description
                pass
    return result


def printfmt(data: List[Tuple[str, str]]):
    """Print (path, description) pairs to stdout."""
    print("field | description")
    print("-|-")
    for field, description in data:
        print(f"`{field}` | {description}")


if __name__ == "__main__":
    telemetry_metadata_uri = "https://raw.githubusercontent.com/mozilla-services/mozilla-pipeline-schemas/master/schemas/metadata/telemetry-ingestion/telemetry-ingestion.1.schema.json"
    resp = urllib.request.urlopen(telemetry_metadata_uri)
    data = json.load(resp)
    printfmt(transform(data))
