package Play::Fragments;

use Dancer ':syntax';
use Exporter 'import';

our @EXPORT = qw(renderTitle renderCss renderScript renderHeader renderMeta renderAdvertisment renderView);

use Play::Assets;
use Play::Save;

sub renderTitle {
  my $title = shift || config->{'title'};
  return <<TITLE;
<title>$title</title>
TITLE
}

sub renderMeta {
  my $description = shift || config->{'description'};
  my $keywords = shift || config->{'keywords'};

	return <<META;
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="chrome=1">
<meta name="author" content="Guryanov Aleksander" />	
<meta name="description" content="$description" />
<meta name="keywords" content="$keywords" />
<link rel="icon" type="image/ico" href="/favicon.ico" />
META
}

sub renderView {
  my $view = shift;
  my $options = shift || {};

  $options->{vars} = vars;

  my $template_engine = engine 'template';
  my $content = $template_engine->render(view($view), $options);

  if ($options->{without_layout}) {
    return $content;
  } 

  $options->{content} = $content;

  return $template_engine->render(view("layout.tt"), $options);
}

sub renderHeader {
  renderView('header.tt', { 'without_layout' => 1 });
}

sub renderAdvertisment {
  renderView('advertisment.tt', { 'without_layout' => 1 });
}

sub renderCss {
	return <<CSS;
<link rel="stylesheet" href="/commons/css/header.css?v=1.0">
CSS
}

sub renderScript {
  my $arguments = shift || '[]';
	my $player = var 'player';
	my $name = $player->name();	
	my $uuid = $player->uuid();
	my $googleAnalytics = config->{'analytics'};
  my $saves = to_json(Play::Save::saves($uuid));

	die "Google analytics not set\n" unless $googleAnalytics;

	return <<SCRIPT;
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '$googleAnalytics']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>

<script type="text/javascript">
  var Engine = {
    'player-name': '$name',
    'player-uuid': '$uuid',
    'arguments': $arguments,
    'saves': $saves
  };
</script>

<!--[if lt IE 9]>
  <script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
SCRIPT
}

1;