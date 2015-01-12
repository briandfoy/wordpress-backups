package WordPress::Backups;

use strict;
use warnings;

use File::Spec::Functions;


=encoding utf8

=head1 NAME

WordPress::Backups - Backup a bunch of WordPress installations

=head1 SYNOPSIS


=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github

	git://github.com/briandfoy/file-fingerprint.git

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2015, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut


@ARGV = glob( '*/wp-config.php */public_html/wp-config.php' );

my $dir = "/home/mango/backups";
mkdir $dir, 0700 unless -d $dir;
die "Could not create backup dir!\n" unless -d $dir;

foreach my $file ( glob( "$dir/*.gz" ) ) {
	unlink $file if -M $file > 7;
	}

foreach my $file ( @ARGV ) {
	my $data = do { local( @ARGV, $/ ) = $file; <>; };
	
	my( $db )   = $data =~ m/define\(\s*'DB_NAME'\s*,\s*'(.*?)'\s*\)\s*;/;
	my( $user ) = $data =~ m/define\(\s*'DB_USER'\s*,\s*'(.*?)'\s*\)\s*;/;
	my( $pass ) = $data =~ m/define\(\s*'DB_PASSWORD'\s*,\s*'(.*?)'\s*\)\s*;/;

	my $time   = sprintf "%4d%02d%02d%02d%02d",
		(localtime)[5] + 1900, (localtime)[4] + 1,
		(localtime)[3,2,1,0];

	my $result_file = catfile( $dir, "$db-$time.sql" );

	system '/usr/local/bin/mysqldump',
		'--add-drop-table',
		'-u', $user,
		qq(--password=$pass),
		"--result-file=$result_file",
		$db;
		
	system '/usr/bin/gzip', $result_file;

	unlink $result_file;
	}
