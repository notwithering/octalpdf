#!/bin/bash

usage() {
    echo "usage: octalpdf [options...] <input_pdf> <output_pdf>"
    echo "  -p <pages>           total number of pages (if omitted, it will be auto-detected)"
    echo "  -h                   show this help message"
    exit 0
}

total_pages=""
input_pdf=""
output_pdf=""

# First, scan for options
while getopts ":p:h" opt; do
  case $opt in
    p)
      total_pages="$OPTARG"
      ;;
    h)
      usage
      ;;
    \?)
      echo "invalid option -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

for arg in "$@"; do
  if [[ -z "$input_pdf" ]]; then
    input_pdf="$arg"
  elif [[ -z "$output_pdf" ]]; then
    output_pdf="$arg"
  else
    echo "too many arguments"
    exit 1
  fi
done

if [[ -z "$input_pdf" || -z "$output_pdf" ]]; then
    echo "input pdf and output pdf are required"
    exit 1
fi

if [[ -z "$total_pages" ]]; then
    total_pages=$(pdftk "$input_pdf" dump_data | grep NumberOfPages | awk '{print $2}')
fi

if [[ -z "$total_pages" ]]; then
    echo "unable to determine the total number of pages"
    exit 1
fi

tmp_dir=$(mktemp -p /tmp -d octalpdf.XXXXXXXXXX)
cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT

pages=()
for ((i=1; i<=total_pages; i+=8)); do
    [[ $((i + 1)) -le $total_pages ]] && pages+=($((i + 1)))
    [[ $((i + 6)) -le $total_pages ]] && pages+=($((i + 6)))
    [[ $((i + 2)) -le $total_pages ]] && pages+=($((i + 2))south)
    [[ $((i + 5)) -le $total_pages ]] && pages+=($((i + 5))south)
    [[ $((i + 7)) -le $total_pages ]] && pages+=($((i + 7)))
    [[ $((i + 0)) -le $total_pages ]] && pages+=($((i + 0)))
    [[ $((i + 4)) -le $total_pages ]] && pages+=($((i + 4))south)
    [[ $((i + 3)) -le $total_pages ]] && pages+=($((i + 3))south)
done

formatted=$(mktemp -p "$tmp_dir" XXXXXXXXXX.pdf)
pdftk "$input_pdf" cat "${pages[@]}" output "$formatted"

pdfjam --nup 2x2 "$formatted" --outfile "$output_pdf"
