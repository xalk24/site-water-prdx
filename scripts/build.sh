#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output_dir="$project_dir/dist"

rm -rf "$output_dir"
mkdir -p "$output_dir"
cp "$project_dir/index.html" "$project_dir/robots.txt" "$output_dir/"
cp -R "$project_dir/assets" "$output_dir/assets"

printf 'Static package built: %s\n' "$output_dir"
