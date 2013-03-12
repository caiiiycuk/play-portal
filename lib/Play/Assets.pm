package Play::Assets;

use Exporter 'import';

our @EXPORT = qw(view public);

my $root = libPath();
my @publcs = (
		$root . "/public",
		$root . "/public/images/",
		$root . "/public/css/",
	);

sub libPath {
	foreach (@INC) {
		if (m/(^.*play-portal)/) {
			return $1;
		}
	}

	die "Unable to find play-portal path\n";
};


sub view {
	return $root . "/views/" . shift; 
};

sub public {
	return @publcs;
}

1;