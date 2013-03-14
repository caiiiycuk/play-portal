package Play::Customize;

use Dancer ':syntax';

use Try::Tiny;
use Play::Fragments;

get '/commons/customize' => sub {
	redirect '/commons/customize/', 301;
};

get '/commons/customize/' => sub {
	renderView 'customize.tt';
};

post '/commons/customize/' => sub {
	my $context = {};

	my $player =  var 'player';

	my $name = param 'name';
	my $password = param 'password';
	my $confirm = param('confirm-password') || $password;
	my $newPassword = param('new-password') || $password;
	my $noSound = param 'no-sound';

	try {
		die "Name is empty\n"  unless ($name);
		die "Confirm password does not match password\n" unless ($newPassword eq $confirm);
		die "Wrong password\n" unless ($player->matchPassword($password));

		if (shouldChangeName($player, $name)) {
			changeName($player, $name);
		}

		$player->setPassword($newPassword);
		$player->setNoSound(defined $noSound);
		$player->update();

		if (param('go')) {
			redirect param('go');
		} else {
			redirect '/';
		}
	} catch {
		renderView 'customize.tt', { error => $_ };
	};

	
};

sub shouldChangeName {
	my ($player, $name) = @_;
	return $player->name() ne $name;
};

sub changeName {
	my ($player, $name) = @_;

	die "Name '$name' is used by other player\n" if (Player::nameIsUsed($name));

	$player->setName($name);
};


true;