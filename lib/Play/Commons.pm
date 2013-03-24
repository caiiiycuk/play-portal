package Play::Commons;

use Dancer ':syntax';

use UUID::Tiny;
use Play::Assets;
use Play::Fragments;
use Play::Player;
use Play::Login;
use Play::Customize;
use Play::Save;
use Play::Games;

get '/commons/logout' => sub {
  redirect '/commons/logout/', 301;
};

get '/commons/logout/' => sub {
  redirect '/';
};

get '/commons/**' => sub {
    my $path = request->path;

    $path =~ s|/commons||;

    # security checks
    return send_error("unauthrorized request", 403) if $path =~ /\0/;
    return send_error("unauthrorized request", 403) if $path =~ /\.\./;

    # decompose the path_info into a file path
    my @path = split '/', $path;

    for my $location (public()) {
        my $file_path = File::Spec->catfile($location, @path);
        send_file($file_path, system_path => 1);
    }

    pass;
};

hook before => sub {
  my $uuid = cookie 'uuid';

  if (!$uuid || 
    request->request_uri() eq '/commons/logout/') {
    $uuid = create_UUID_as_string(UUID_V1);
    cookie 'uuid' => $uuid, expires => "1 year";
  }

  my $player = new Player($uuid);
  
  var 'player' => $player;
  var 'title' => config->{title};
  var 'commons' => {
    title => renderTitle,
    meta => renderMeta,
    css => renderCss,
    script => sub { renderScript(@_) },
    advertisment => renderAdvertisment,
    header => renderHeader
  };
};

true;