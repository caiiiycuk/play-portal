package Play::Games;

use Dancer ':syntax';

use Try::Tiny;
use Play::Fragments;

get '/games' => sub {
  redirect '/games/', 301;
};

get '/games/' => sub {
  renderView 'games.tt', {
    pageTitle => "Browser games: Dune 2, Transport Tycoon Deluxe",
    pageMeta => "Here you can play in recreations of classic games: Dune 2, Transport Tycoon Deluxe",
    pageKeywords => "dune 2, transport tycoon deluxe, online, browser, javascript, game"
  };
};

true;