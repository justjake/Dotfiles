### Aliases for rescomp machines

if [[ "$HOSTNAME" == *rescomp.berkeley.edu ]] ; then
    ### Paths
    export SVNCODE="https://svn.rescomp.berkeley.edu/code"
    export SVNTMPL="https://svn.rescomp.berkeley.edu/marketing"
    export CODE="/usr/code/jitl/"

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
fi
