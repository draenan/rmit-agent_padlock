#!/usr/bin/env bash
#
# agent_padlock::unlock task.
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin

function linux_unexclude() {
    line=$(grep '^exclude=' /etc/yum.conf)

    # Check if there was an exclude line, and whether or not it contains
    # puppet-agent.

    if [[ ! -z "$line" && "$line" =~ puppet-agent ]]; then

       # We have an exclude, and puppet-agent is in it.

       # Check if puppet-agent is the only thing excluded, act accordingly.

       if [[ "$line" =~ ^exclude=[[:space:]]*puppet-agent$ ]]; then
           sed -e '/^exclude=/d' -i /etc/yum.conf
       else
           sed -e '/^exclude=/ s/[[:space:]]*puppet-agent//' \
               -e '/^exclude=/ s/=[[:space:]]\+/=/' \
               -i /etc/yum.conf
       fi

    fi

    # Just confirm that the exclude actually worked.

    grep -q '^exclude=.*puppet-agent' /etc/yum.conf && state="still "

    echo "puppet-agent is ${state:-not }excluded in /etc/yum.conf."
}

function solaris_unfreeze() {

    # Trusting Solaris to do the right thing here.

    pkg unfreeze puppet-agent

    # pkg will return 4 if there is nothing to do (ie puppet-agent isn't frozen.)

    if [ "$?" -eq 4 ]; then
        echo "puppet-agent was not frozen, nothing to do."
    else

        # Trust, but verify!

        pkg freeze | grep -q puppet-agent

        if [ "$?" -eq 0 ]; then
            echo "WARNING: puppet-agent is still in the list of frozen packages."
        fi
    fi

}

osfamily=$(/opt/puppetlabs/bin/facter osfamily)

case $osfamily in
    'RedHat')
        linux_unexclude
        ;;
    'Solaris')
        solaris_unfreeze
        ;;
    *)
        echo "This task is only supported on RedHat and Solaris."
        exit 1
        ;;
esac
exit 0
