# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;

package Data::Tabular::Output;

use Carp qw (croak);

use overload '""' => \&render;

sub new
{
    my $class = shift;
    my $args = { @_ };

    my $self = bless {}, $class;

    die 'No table' unless $args->{table};
    $self->{table} = $args->{table};

    $self->{output} = $args->{output} || croak "Need output";

    $self;
}

sub rows
{
    my $self = shift;

    $self->{table}->rows(output => $self->output);
}

sub columns
{
    my $self = shift;

    $self->{table}->columns(output => $self->output);
}

sub output
{
    my $self = shift;
    $self->{output};
}

sub attrib
{
     my $self = shift;

 warn $self->output;
 warn keys %{$self->output};

if (my $href = $self->output->{html}) {
warn 'HRef ', $href;
     $href->{attributes} = {};
     my $new_attributes = {
	 %{$href->{attributes}},
	 @_,
     };
     $href->{attributes} = $new_attributes;
}

     $self;
}

sub render
{
    my $self = shift;
    $self->text;
}

1;
__END__

=head1 NAME

Data::Tabular::Output;

=head1 SYNOPSIS

This object is used by Data::Tabular to render a table.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=cut
