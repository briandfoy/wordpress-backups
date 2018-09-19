package WordPress::Backups;
use v5.14; # maybe I needed this in the past?

use warnings;

use File::Spec::Functions;

=encoding utf8

=head1 NAME

WordPress::Backups - Backup a bunch of WordPress installations

=head1 SYNOPSIS

	use Wordpress::Backups;

	Wordpress::Backups::run( $backup_dir, @wp_configs );

=head1 DESCRIPTION

This is a modulino that I use to backup my Wordpress installations. I
give it a directory name and a list of wp_configs. It dumps the database
for each, gzips the results, and stores it in the backup directory.

It also removes backups older than a week.

=head1 TO DO

Everything. I'm only playing with this when I need it to do something
different.


=head1 SOURCE AVAILABILITY

This source is in Github

	https://github.com/briandfoy/wordpress-grep

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

our $VERSION = '0.001';

unless( caller ) {
	unless( @ARGV ) {
		@ARGV = glob( '*/wp-config.php */public_html/wp-config.php' );
		unshift @ARGV, 'wordpress_backups.d';
		}

	run( @ARGV );
	}

sub run {
	my( $dir, @files ) = @_;

	mkdir $dir, 0700 unless -d $dir;
	die "Could not create backup dir!\n" unless -d $dir;

	foreach my $file ( glob( "$dir/*.gz" ) ) {
		unlink $file if -M $file > 7;
		}

	foreach my $file ( @files ) {
		my $data = do { local( *ARGV, $/ ) = $file; <>; };

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
	}
