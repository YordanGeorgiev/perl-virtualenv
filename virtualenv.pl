#!/usr/local/perl-5.18/bin/perl

use strict;
use warnings;

use Config;
use File::Path qw(make_path);
use File::Basename qw(dirname);

my $perl = $Config{perlpath};
my $venv = shift || 'venv';
if (! -d "$venv/bin") {
    make_path "$venv/bin" or die "Unable to create directory '$venv/bin'.\n"
}

sub spit {
    open my $fd, '>', shift;
    print $fd shift;
    close $fd;
}

spit "$venv/bin/perl", <<EOS;
#!/bin/sh
exec $perl -Mlocal::lib="$venv" "\$@"
EOS
chmod 0755, "$venv/bin/perl";

my $cpanm = dirname($perl) . "/cpanm";
spit "$venv/bin/cpanm", <<EOS;
#!/bin/sh
exec $cpanm --local-lib="$venv" "\$@"
EOS
chmod 0755, "$venv/bin/cpanm";

spit "$venv/bin/activate", <<EOS;
eval \$($perl -Mlocal::lib="$venv")

export _PV_OLD_PS1=\$PS1
export PS1="(`basename $venv`)\$PS1"

EOS

spit "$venv/bin/deactivate", <<EOS;
eval \$($perl -Mlocal::lib="--deactivate-all,$venv")

if [ -n "\$_PV_OLD_PS1" ]; then
    export PS1=\$_PV_OLD_PS1
    unset _PV_OLD_PS1
fi

EOS
