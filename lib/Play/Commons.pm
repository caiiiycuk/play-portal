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
use Play::I18N;

use FindBin qw($Bin);

Play::I18N::init(root()."/i18n.yaml", "$Bin/../i18n.yaml");

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

  my $player      = new Player($uuid);
  my $locale      = localeForHost(request->host);
  my $i18n        = i18n()->{request->path}->{$locale} || i18n()->{'+'}->{$locale};
  my $alternates  = i18nAlternates(request->path);


  var 'locale' => $locale;
  var 'i18n' => $i18n;
  var 'player' => $player;
  var 'alternates' => $alternates;

  var 'title' => config->{title};
  var 'commons' => {
    title => sub { renderTitle(@_) },
    meta => sub { renderMeta(@_) },
    css => renderCss,
    script => sub { renderScript(@_) },
    advertisment => renderAdvertisment,
    header => renderHeader
  };
};

sub localeForHost {
  my $host = shift;
  if ($host =~ m/^(\w\w)\./) {
    return "$1";
  }

  return "en";
};

sub i18nAlternates {
  my $path = shift;
  my @alternates = keys %{ i18n()->{$path} || i18n()->{'+'} };
  my $alternates = '';

  foreach my $alt (@alternates) {
    my $uri = request->uri_for(request->uri());
    $uri =~ s|http://\w\w\.|http://|;

    if ($alt ne 'en') {
      $uri =~ s|http://|http://$alt.|;
    } 

    $alternates .= "<link rel=\"alternate\" hreflang=\"$alt\" href=\"$uri\" />\n";
  }
  
  return $alternates;
};

true;