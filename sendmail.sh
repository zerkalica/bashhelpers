#!/bin/sh

out_dir="/home/nexor/public_html/tmp"

date_str=$(date +"%Y-%m-%d %H-%M-%S")

while [ 1 ] ; do
	file_date=$(date +"%Y-%m-%d_%H-%M-%S")
	out_file="$out_dir/sendmail-${file_date}.emf"
	[ -e "$out_file" ] || break
	sleep 1
done

echo "From admin@localhost $date_str\n" > "$out_file"

while read stdin_str ; do
	echo "$stdin_str" >> "$out_file"
done

