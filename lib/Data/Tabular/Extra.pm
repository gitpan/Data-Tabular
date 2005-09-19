# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular::Extra;

sub new
{
    my $class = shift;
    my $args = {@_};
    my $self = bless {}, $class;

    for my $arg (qw (row table)) {
	$self->{$arg} = $args->{$arg} || die 'No ' . $arg;
	delete $args->{$arg};
    }
    die q|Unknown argumet(s): |. join(' ', keys(%$args)) if keys(%$args);

    die unless $self->{row};
    die unless $self->{table};

    $self;
}

sub new_cell
{
    my $self = shift;
    my $args = { @_ };

    $args
}

sub get
{
    my $self = shift;
    my $column = shift;

    $self->{row}->get_column($column);
}

sub sum
{
    my $self = shift;
    my $column = shift;
    my $total = $self->{row}->get_column($column);
# FIX
    if (ref($total) eq 'HASH') {
	$total = $total->{html};
    }

    for $column (@_) {
	my $data = $self->{row}->get_column($column);
	if (ref($data) eq 'HASH') {
	    $data = $data->{html};
	}
	$total += $data;
    }
    $total;
}

sub average
{
    my $self = shift;
    my $count = scalar(@_);

    my $total = $self->{row}->get_column(shift);

    for my $column (@_) {
	$total += $self->{row}->get_column($column);
    }
    $total / $count;
}

1;
__END__

=head1 NAME

Data::Tabular::Extra;

=head1 SYNOPSIS

This object is used by Data::Tabular to create `extra'
columns on a table.

The subroutines in the `extra' section run under this package.

 ...
 extra => {
  'bob' => sub {
    my $self = shift;   # this is an Data::Tabular::Extra object
   }
 }
 ...

=head1 DESCRIPTION

This object is used to supply tools to the Data::Tabular designer.
It also helps to protect the data from that designer.

It is import to know that extra columns are created from left to
right.  Because of this you can use `extra' columns to create other
extra columns.  This means that you should order the extra columns
in the order that they need to be created in, and not in the the order
that they will be shown in the output.

=head1 METHODS

=over 4

=item get

Method to access the data for a column. Given a list of column names this method returns
a list of column data.  Extra columns are available after they have been generated.

=item sum

Method to sum a set of columns. Given a list of column names this method returns
the sum of those columns.  The type of the data returned is the type of the 
first column.

=item average

Method to sum a set of columns. Given a list of column names this method returns
the sum of those columns.  The type of the data returned is column type element,
but must conform to the Data::Tabular::Type::Frac constructor.

