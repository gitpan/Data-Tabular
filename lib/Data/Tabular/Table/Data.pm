# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular::Table::Data;
use base 'Data::Tabular::Table';

use Carp qw (croak);

sub new
{
    my $caller = shift;

    my $self = $caller->SUPER::new(@_);

    $self;
}

sub row_count
{
    my $self = shift;

    scalar(@{$self->{data}->{rows}});
}

sub all_headers
{
    my $self = shift;

    $self->{_all_headers} ||= [ @{$self->{data}->{headers} || []} ];
    my @headers = @{$self->{_all_headers}};

    @headers;
}

sub get_row_column
{
    my $self = shift;
    my $row = shift;
    my $column = shift;
    my $count = scalar(@{$self->{data}->{headers}});
    if ($column >= $count) {
        'boB';
    } else {
	$self->{data}->{rows}->[$row][$column];
    }
}

sub get_row_column_name
{
    my $self = shift;
    my $row = shift;
    my $column_name = shift;
    my $count = scalar(@{$self->{data}->{headers}});
    my $column;
    for ($column = 0; $column < $count; $column++) {
        last if $self->{data}->{headers}->[$column] eq $column_name;
    }

    if ($column >= $count) {
warn caller;
        'Unknown Column '. $column_name;
    } else {
	$self->{data}->{rows}->[$row][$column];
    }
}


sub row_package
{
    require Data::Tabular::Row::Data;
   'Data::Tabular::Row::Data';
}

sub rows
{
    my $self = shift;
    my $args = { @_ };
    my @ret;

croak("Need output") unless $args->{output};

    for (my $row = 0; $row < $self->row_count; $row++) {
	push(@ret, $self->row_package->new(
	    table => $self,	# FIXME: This is very bad!
	    input_row => $row,
	    extra => $self->{extra},
	    output => $args->{output},
	    row_id => $row + 1,
	));
    }

    $self->{rows} = \@ret;

    wantarray ? @{$self->{rows}} : $self->{rows};
}

1;
__END__

=head1 NAME

Data::Tabular::Table::Data;

=head1 SYNOPSIS

This object is used by Data::Tabular to hold a table.

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item new

=cut
