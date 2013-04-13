package Play::Assets;

use Exporter 'import';
use Dancer;

our @EXPORT = qw(view public root);

my $root = root();

my @publics = (
		$root . "/public",
		$root . "/public/images/",
		$root . "/public/css/",
	);

sub root {
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
	return @publics;
};

1;