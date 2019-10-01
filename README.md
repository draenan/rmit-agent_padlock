# agent_padlock

This module provides Puppet Tasks to either allow or prevent the updating of
the `puppet-agent` package.  It achieves this by adding an `exclude` to
`/etc/yum.conf` on RHEL, or by running `pkg freeze` on Solaris.

* `agent_padlock::lock`: Prevents updates to the `puppet-agent` package
* `agent_padlock::unlock`: Allows updates to the `puppet-agent` package

## Requirements

Solaris or RHEL.  Tested on Solaris 11, RHEL 6, RHEL 7.

