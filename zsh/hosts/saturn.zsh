# new new vm (!)
PATH="$HOME/pebble-dev/sdk/bin:$PATH"
PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

bundle-dir "$HOME/bundles"

JAVA_HOME="$HOME/bundles/jdk1.7.0_45"
M2_HOME="$HOME/bundles/apache-maven-3.0.5"
alias idea="$HOME/bundles/no-bundle/idea-IU-129.1359/bin/idea.sh"
alias intellij="idea"
alias winhome="sudo mount -t vboxsf -o uid=jitl,gid=jitl WinHome /mnt/winhome"

# jruby coaxing
# export JAVACMD=$(which drip)
# export DRIP_INIT_CLASS=org.jruby.main.DripMain
# export DRIP_INIT="" # Needs to be non-null for drip to use it at all!
