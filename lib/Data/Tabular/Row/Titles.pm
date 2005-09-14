use strict;
package Data::Tabular::Row::Titles;

use base 'Data::Tabular::Row';

use Carp qw(croak);

use overload '@{}' => \&array,
             '""'  => \&str;

sub str
{
    my $self = shift;
    'Row::Total';
}

sub get_column
{
    my $self = shift;
    $self->get(@_);
}

sub get
{
    my $self = shift;
    my $column_name = shift;

    my $ret = $self->{output}->title($column_name);

    $ret;
}

sub html_attribute_string
{
    my $self = shift;
    my $attributes = {
        class => "redbg",
    };
    my $ret = '';
    for my $attribute (keys %$attributes) {
        $ret .= qq| $attribute="| . $attributes->{$attribute} . qq|"|;
    }
    $ret;
}

sub html_cell_attributes
{
    my $self = shift;
    my $column = shift;
    {
        align => undef,
    };
}

sub hdr
{
    1;
}

sub type
{
    'title';
}

1;
__END__

