
package Data::Tabular::Config::Extra;

sub new
{
    my $class = shift;
    my $self = bless { @_ }, $class;
    $self;
}

sub output
{
    my $ret = $_[0]->{output};
    $_[0]->{output} = $_[1] if $_[1];
    $ret;
}

1;
