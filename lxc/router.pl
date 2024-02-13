#!/usr/bin/perl

# Exmple hook script for PVE guests (hookscript config option)
# You can set this via pct/qm with
# pct set <vmid> -hookscript <volume-id>
# qm set <vmid> -hookscript <volume-id>
# where <volume-id> has to be an executable file in the snippets folder
# of any storage with directories e.g.:
# qm set 100 -hookscript local:snippets/hookscript.pl

use strict;
use warnings;

print "GUEST HOOK: " . join(' ', @ARGV). "\n";

my $vmid = shift;
my $phase = shift;

if ($phase eq 'pre-start') {
    print "$vmid is starting, doing preparations.\n";
    if (! -e "/dev/ppp") {
        print "creating /dev/ppp\n";
        system("mknod /dev/ppp c 108 0");
        system("chown 100000:100000 /dev/ppp");
    } else {
        print "/dev/ppp already exists\n";
    }
} elsif ($phase eq 'post-stop') {
    print "$vmid stopped. Doing cleanup.\n";
    if (-e "/dev/ppp") {
        print "removing /dev/ppp\n";
        system("rm /dev/ppp");
    } else {
        print "/dev/ppp already removed\n";
    }
} else {
    die "got unknown phase '$phase'\n";
}

exit(0);