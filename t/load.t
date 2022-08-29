use Test::More;

my @classes = qw(WordPress::Backups);
foreach my $class ( @classes ) {
	use_ok($class) or BAIL_OUT("$class did not compile!\n$@");
	}

done_testing();
