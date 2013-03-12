package Play::Login;

use Dancer ':syntax';

use Try::Tiny;
use Play::Fragments;

get '/commons/login' => sub {
	redirect '/commons/login/', 301;
};

get '/commons/login/' => sub {
	renderView 'login.tt';
};

post '/commons/login/' => sub {
	my $name = param 'name';
	my $password = param 'password';

	try {
		my $uuid = Player::uuidByName($name);
		die "Wrong login or password\n" unless $uuid;
		
		my $player = new Player($uuid);	
		die "Wrong login or password\n" unless ($player->matchPassword($password));

		cookie 'ttd-save-uuid' => $player->uuid(), expires => "1 year";
		redirect '/';
	} catch {
		renderView 'login.tt', {error => $_};
	};

	
};

true;