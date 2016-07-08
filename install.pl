
use strict;
use feature 'say';

use DE_EPAGES::Core::API::File qw ( RunOnDirectory GetFileContent WriteFile );
use IPC::Cmd qw ( can_run );

unless (can_run('git')) {
    say 'git not found, attempt to install it ...';
    say ` yum -y install git`;
}

die 'no git available' unless (can_run('git'));

my $BashRc = '/root/.bashrc';

my $BashRcContent = ${GetFileContent($BashRc, { 'utf8' => 1, 'encoding' => 'utf-8' })};
my $IsCliAlreadyThere = ($BashRcContent =~ m/EPAGES_CLI/) ? 1 : 0;

if (-d $ENV{'EPAGES'} . '/epages6-cli') {
    say 'epages6-cli already installed';
    exit;
}
else {
    RunOnDirectory($ENV{'EPAGES'}, sub {
        say 'clone epages6-cli repo';
        say `git clone https://github.com/vilkasgroup/epages6-cli.git`;

        my $BashRcCli = <<END;

# generated by epages6-cli installer
export EPAGES_CLI=\$EPAGES/epages6-cli
chmod a+x \$EPAGES_CLI/ep6-*
export PATH=\$EPAGES_CLI:\$PATH
# end

END

        WriteFile($BashRc, \$BashRcCli, { 'utf8' => 1, 'encoding' => 'utf-8' , 'append' => 1 }) unless $IsCliAlreadyThere;

        `source $BashRc`;
    });
}
