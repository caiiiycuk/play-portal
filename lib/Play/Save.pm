package Play::Save;

use Dancer ':syntax';
use File::Slurp;
use Play::Fragments;

my $data = config->{'data'} . config->{'folder'};

# Routing

post '/save/:uuid/:file' => sub {
	Play::Save::write(param('file'), param('uuid'), request->{body});
};

get '/save/:file' => sub {
	Play::Save::read(param('file'));
};

get '/save/:uuid/:file' => sub {
	Play::Save::read(param('file'), param('uuid'));
};

get '/commons/saves' => sub {
	redirect '/commons/saves/', 301;
};

get '/commons/saves/' => sub {
	my $player = var 'player';
	Play::Fragments::renderView('saves.tt', { saves => saves($player->uuid()) });
};

# Impl

sub saves {
	my $uuid = shift;
	my $root = root($uuid);
	if (-e $root) {
		my @files = read_dir($root);
		my %files = map { $_ => "/save/$uuid/$_" } @files;
		return \%files;
	}
	return {};
}


sub mockFile {
	return $data . 'save/empty_slot.sav';
}

sub root {
	my $uuid = shift;
	my $root = $data . 'save/';
	$root .= $uuid . '/' if $uuid;
	return $root;
}

sub write {
	my ($file, $uuid, $body) = @_;

	my $root = root($uuid);
	mkdir($root) unless (-d $root);

	my $target = $root . $file;

	open F, ">$target";
	binmode F;
	print F $body;
	close F;
};

sub read {
	my ($file, $uuid) = @_;

	my $root = root($uuid);
	my $target = $root . $file;
	
	if (-e $target) {
		send_file($target, system_path => 1);
	} else {
		send_file(mockFile(), system_path => 1);
	}
};

true;