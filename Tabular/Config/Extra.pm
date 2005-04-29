
package Data::Tabular::Config::Extra;

sub new
{
    my $class = shift;
    my $self = bless { @_ }, $class;
    $self;
}

1;
