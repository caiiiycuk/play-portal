package Play::Games;

use Dancer ':syntax';

use Try::Tiny;
use Play::Fragments;

get '/games' => sub {
  redirect '/games/', 301;
};

get '/games/' => sub {
  renderView 'games.tt';
};

true;