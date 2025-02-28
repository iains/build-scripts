find ./ -name configure | while read f; do d=$( dirname "$f" ) && echo "$d": && l=$d/regenerate.log && ( cd "$d"/ && autoreconf -f ) > "$l" 2>&1; if test -s "$l"; then echo "Review '$l'"; else rm "$l"; fi; done

find . -d -name autom4te.cache -exec rm -r {} \;
