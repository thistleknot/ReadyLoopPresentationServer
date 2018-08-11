cut -f 1 -d . reruns.txt > reruns2.txt
cut -f 2 -d - reruns2.txt > reruns3.txt
xcopy reruns3.txt reruns.txt /y
erase reruns2.txt
erase reruns3.txt