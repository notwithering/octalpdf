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
    p1=$((i))
    p2=$((i+1))
    p3=$((i+2))
    p4=$((i+3))
    p5=$((i+4))
    p6=$((i+5))
    p7=$((i+6))
    p8=$((i+7))

    [[ $p1 -gt $total_pages ]] && p1=""
    [[ $p2 -gt $total_pages ]] && p2="" 
    [[ $p3 -gt $total_pages ]] && p3="" || p3="$p3"south
    [[ $p4 -gt $total_pages ]] && p4="" || p4="$p4"south
    [[ $p5 -gt $total_pages ]] && p5="" || p5="$p5"south
    [[ $p6 -gt $total_pages ]] && p6="" || p6="$p6"south
    [[ $p7 -gt $total_pages ]] && p7=""
    [[ $p8 -gt $total_pages ]] && p8=""

    pdftk "$input_pdf" cat $p2 $p7 $p3 $p6 $p8 $p1 $p5 $p4 output "$tmp_dir/$i.pdf"
done

input_files=""
for ((i=1; i<=total_pages; i+=8)); do
    input_files+="$tmp_dir/$i.pdf "
done

formatted=$(mktemp -p $tmp_dir XXXXXXXXXX.pdf)
pdftk $input_files cat output $formatted

pdfjam --nup 2x2 $formatted --outfile $output_pdf
