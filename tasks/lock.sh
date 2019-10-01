#!/usr/bin/env bash
#
# agent_padlock::lock task.
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin

function linux_exclude() {
    line=$(grep '^exclude=' /etc/yum.conf)

    # Check if there was an exclude line, and whether or not it contains
    # puppet-agent.

    if [[ ! -z "$line" && ! "$line" =~ puppet-agent ]]; then

       # We have an exclude, but puppet-agent isn't in it.

       sed -e '/^exclude=/ s/$/ puppet-agent/' -i /etc/yum.conf

    elif [ -z "$line" ]; then

       # We don't have an exclude line

       sed -e '/^\[main\]/!b;:a;n;/./ba;iexclude=puppet-agent' -i /etc/yum.conf

    else

       # We have an exclude line that contains puppet-agent.

       state="already "

    fi

    # Just confirm that the exclude actually worked.

    if [[ ! "$state" =~ already ]]; then
        grep -q '^exclude=.*puppet-agent' /etc/yum.conf || state="is not "
    fi

    echo "puppet-agent ${state:-now }excluded in /etc/yum.conf."
}

function solaris_freeze() {

    # Trusting Solaris to do the right thing here.

    pkg freeze puppet-agent

    # Trust, but verify!

    pkg freeze | grep -q puppet-agent

    if [ "$?" -ne 0 ]; then
        echo "WARNING: puppet-agent is NOT in the list of frozen packages."
    fi

}

osfamily=$(/opt/puppetlabs/bin/facter osfamily)

case $osfamily in
    'RedHat')
        linux_exclude
        ;;
    'Solaris')
        solaris_freeze
        ;;
    *)
        echo "This task is only supported on RedHat and Solaris."
        exit 1
        ;;
esac
exit 0
