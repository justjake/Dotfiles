### Aliases for rescomp machines

if [[ $(hostname -f) == *rescomp.berkeley.edu || \
    $(hostname -f) == *it.housing.berkeley.edu ]] ; then
    ### Paths
    export SVNCODE="https://svn.rescomp.berkeley.edu/code"
    export SVNTMPL="https://svn.rescomp.berkeley.edu/marketing"
    export CODE="/usr/code/jitl"
    export webtree="/usr/local/www/rescomp/docs"
    export phplib="/usr/local/rescomp/lib/php"

    ### PostgreSQL Database Access
    alias devdb='psql -h test-db -p 5433 rescomp'
    #For dev-cc, ssh into hal then dev-cougar first.
    #alias devcc='psql -h dev-sal -p 5432 cc'
    alias testdb='psql -h test-db -p 5432 rescomp'
    alias proddb='psql -h db rescomp'

    ### Dev util
    alias apacherl='sudo /usr/local/etc/rc.d/apache23 restart;sleep 5;sudo /usr/local/etc/rc.d/apache22 status'

    ### Log Access
    alias deverror='sudo /usr/bin/tail -f /var/log/httpd-error.log'
    alias devaccess='sudo /usr/bin/tail -f /var/log/httpd-access.log'
    #alias fixlogs='sudo /usr/local/etc/rc.d/syslog-ng restart'

    ### Webtree sync
    alias websync='sudo svn export --force $SVNTMPL/webtree/ /usr/local/www/rescomp/docs/'

    # directories
    typeset -A NAMED_DIRS

    NAMED_DIRS=(
        wsgi    /usr/local/etc/rssp/django
        vhosts  /etc/httpd/conf.d/vhosts
        scunc   /usr/code/jitl/git/scunc
        httpd   /usr/local/etc/apache22/Includes
    )

    for key in ${(k)NAMED_DIRS}
    do
        if [[ -d ${NAMED_DIRS[$key]} ]]; then
            export $key=${NAMED_DIRS[$key]}
        else
            unset "NAMED_DIRS[$key]"
        fi
    done

    alias rescompsettings="$EDITOR ~/.zsh/rc.d/21_rescomp.zsh"
    alias dev-mount="sshfs dev-www9.rescomp.berkeley.edu:/usr/code/jitl $HOME/mnt/devbox"
    alias dev-unmount="fusermount -u $HOME/mnt/devbox"
    alias slack="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=jeogkiiogjbmhklcnbgkdcjoioegiknm"
fi
