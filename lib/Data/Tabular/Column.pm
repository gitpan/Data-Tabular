# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular::Column;

use Carp qw(croak);

sub new
{
    my $class = shift;
    my $self = bless({ @_ }, $class);

    die unless $self->{name};

    $self;
}

sub name
{
    my $self = shift;
    my $name = $self->{name};
    return $name;
}

sub align
{
    my $self = shift;
    my $output = $self->{output};

    "FIXME";
}

sub colgroup_attribute
{
}

sub html_attributes
{
    my $self = shift;
    my $output = $self->{output};

    "FIXME " . ref $self;
}

sub html_attribute_string
{
    my $self = shift;
    my $output = $self->{output};

#FIXME

    '';
}

sub _html_attribute_string
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

sub col_id 
{
    my $self = shift;
    $self->{offset};
}

1;
__END__

