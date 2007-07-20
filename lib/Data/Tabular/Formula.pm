use strict;

package 
    Data::Tabular::Formula;

use overload '""' => \&_value;

sub attributes
{
   {};
}

sub _value
{
    my $self = shift;

use Data::Dumper;
#die 'XXXX ', Dumper $self if $self->{type} ne 'sum';
    $self->{html};
}

1;
