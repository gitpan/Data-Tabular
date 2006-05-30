package 
    Data::Tabular::Formula;

use overload '""' => \&_value;

sub attributes
{
   {};
}

sub _value
{
    shift->{html};
}

1;
