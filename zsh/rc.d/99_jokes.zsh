# Display the mandlebrot set on the terminal
function fractal {
   local lines columns colour a b p q i pnew
   ((columns=COLUMNS-1, lines=LINES-1, colour=0))
   for ((b=-1.5; b<=1.5; b+=3.0/lines)) do
       for ((a=-2.0; a<=1; a+=3.0/columns)) do
           for ((p=0.0, q=0.0, i=0; p*p+q*q < 4 && i < 32; i++)) do
               ((pnew=p*p-q*q+a, q=2*p*q+b, p=pnew))
           done
           ((colour=(i/4)%8))
            echo -n "\\e[4${colour}m "
        done
        echo
    done
    echo -n "\e[49m"
}

# can use these if imgderp exists
for gif in celeryman flarhgunnstow tayne hat-wobble ; do
  alias $gif="imgderp -animate -invert -w \$(tput cols) ${DOTFILES}/meta/${gif}.gif"
done
