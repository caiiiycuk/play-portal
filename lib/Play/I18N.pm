package Play::I18N;

use Dancer;
use Exporter 'import';
use Hash::Merge qw( merge );

our @EXPORT = qw(i18n);

my @i18n = ();

my $cached;

sub init {
  @i18n = @_;
}

sub i18n {
  return $cached if $cached;

  my $i18n = {};

  foreach my $file (@i18n) {
    my $yaml = readYaml($file);
    $i18n = merge($i18n, $yaml);
  }

  foreach my $path (keys %$i18n) {
    my $en = $i18n->{$path}->{en};

    for my $lang (keys %{ $i18n->{$path} }) {
      next if $lang eq 'en'; 
      $i18n->{$path}->{$lang} = merge($i18n->{$path}->{$lang}, $en);
    }
  }

  my $common = $i18n->{'+'};
  foreach my $path (keys %$i18n) {
    next if $path eq '+';

    for my $lang (keys %{ $i18n->{$path} }) {
      $i18n->{$path}->{$lang} = merge($i18n->{$path}->{$lang}, $common->{$lang});
    }
  }
  
  $cached = $i18n;
  return $i18n;
};

sub readYaml {
  my $file = shift;

  local $/;

  open(my $fh, "<:encoding(utf-8)", $file);
  my $data = <$fh>;
  close($fh);

  return from_yaml($data);
};

true;