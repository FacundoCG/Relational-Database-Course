#!/bin/bash
# Redirection of an input: ./translate.sh < kitty_ipsum_1.txt
# Idem: cat kitty_ipsum_1.txt | ./translate.sh 
#./translate.sh kitty_ipsum_1.txt | grep --color 'dogchow'
#./translate.sh kitty_ipsum_1.txt | grep --color 'dog[a-z]*'
#./translate.sh kitty_ipsum_1.txt | grep --color -E 'dog[a-z]*|woof[a-z]*'

cat $1 | sed -E 's/catnip/dogchow/g; s/cat/dog/g; s/meow|meowzer/woof/g'