#### Webdev things
# alias sasswatch="sass --watch stylesheets/source:stylesheets"
# function middleman-dev {
#     x-www-browser "http://localhost:4567" &
#     middleman
# }


# Start a shared tmux session anyone can join. UNSAFE!!!
# for them to join: `tmux -S /tmp/$socket_name attach`
function tmux-shared () {
    local socket_name="$1"
    tmux -S /tmp/"$socket_name" new-session 
    chmod 778 /tmp/"$socket_name"
    tmux -S /tmp/"$socket_name" attach
}

# Copy the audio out of a video into a seperate file
# Usage: ffmpeg-extract-audio Movies/some-movie.mp4 ~/audio.who_knows
#        file ~/audio.who_knows
ffmpeg-extract-audio() {
    local src="$1"
    local dest="$2"
    ffmpeg -i "$1" -acodec copy -vn "$2"
}
