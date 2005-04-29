use strict;
package Data::Tabular::Column;

use Carp qw(croak);

use overload '""'  => \&str;

sub new
{
    my $class = shift;
    my $self = bless({ @_ }, $class);

    die unless $self->{name};
    die unless $self->{output};

    $self;
}

sub name
{
    my $self = shift;
    my $name = $self->{name};
    return $name;
}

sub output
{
    my $self = shift;
    my $output = $self->{output};
    return $output;
}

sub align
{
    my $self = shift;
    my $output = $self->{output};
    $output->align($self->{name});
}

sub html_attributes
{
    my $self = shift;
    my $output = $self->{output};
    $output->html_column_attributes($self->{name});
}

sub html_attribute_string
{
    my $self = shift;
    my $attributes = {
        id => $self->{name},
    };
    my $na = $self->html_attributes();
    for my $key (keys %$na) {
	$attributes->{$key} = $na->{$key};
    }

    my $ret = '';
    for my $attribute (sort keys %$attributes) {
	$ret .= qq| $attribute="| . $attributes->{$attribute} . qq|"|;
    }

    $ret;
}

sub xls_width
{
    my $self = shift;
    my $ret = undef;

    $ret = $self->output->xls_width($self->name) || 10;

    $ret;
}

sub x
{
    my $self = shift;
    $self->{offset};
}

1;
__END__

