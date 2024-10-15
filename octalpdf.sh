#!/bin/bash

usage() {
    echo "usage: octalpdf <input_pdf> [options...] <output_pdf>"
    echo "  -p <pages>           total number of pages (if omitted will be auto-detected)"
    echo "  -h                   show this help message"
    exit 0
}

total_pages=""

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
      ;;
    :)
      echo "option -$OPTARG requires an argument" >&2
      ;;
  esac
done

shift $((OPTIND-1))

input_pdf="$1"
output_pdf="$2"

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
	rm -rf $tmp_dir
}
trap cleanup EXIT

for ((i=1; i<=total_pages; i+=8)); do
    offsets=("1" "6" "2" "5" "7" "0" "4" "3")
	pages=()

	for idx in ${!offsets[@]}; do
		offset=${offsets[idx]}
		page=$((i + $offset))
		if [[ "$page" -le "$total_pages" ]]; then
			pages[$idx]=$page
			if [[ "$offset" -ge 3 && "$offset" -le 6 ]]; then
				pages[$idx]+="south"
			fi
		fi
	done

    pdftk "$input_pdf" cat "${pages[@]}" output "$tmp_dir/$i.pdf"
done

input_files=""
for ((i=1; i<=total_pages; i+=8)); do
    input_files+="$tmp_dir/$i.pdf "
done

formatted=$(mktemp -p $tmp_dir XXXXXXXXXX.pdf)
echo pdftk $input_files cat output $formatted
pdftk $input_files cat output $formatted
echo pdfjam --nup 2x2 $formatted --outfile $output_pdf
pdfjam --nup 2x2 $formatted --outfile $output_pdf
