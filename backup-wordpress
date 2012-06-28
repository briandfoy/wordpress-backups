#!/usr/bin/perl
use strict;
use warnings;

use File::Spec::Functions;

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
