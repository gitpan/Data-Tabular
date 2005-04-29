# Copyright (C) 2003, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular::Group;
use base 'Data::Tabular::Table::Extra';

use Data::Tabular::Table::Group;

sub clone
{
    my $caller = shift;
    my $self = shift || {};
    my $class = ref($caller);
    for my $key (keys %$caller) {
	$self->{$key} = $caller->{$key};
    }
    bless $self, $class;
}

sub new
{
    my $caller = shift;

    my $self = $caller->SUPER::new(@_);

    if ($self->{groups}) {
        ;
    } else {
	die q|Columns are gone!| if $self->{columns};
        $self->{groups} = [
	    {
	       pre => sub {
		   my $self = shift;
		   ( $self->titles( class => 'xgam3x' ) );
	       }
	    }
	];
    }

#    die 'Group needs a table' unless $self->table;
#    die 'table must be a Data::Tabular::Output object.' unless $self->table->isa('Data::Tabular::Output');

#warn  'Output_config ', $self->output_config, ' self ', $self;

    $self;
}

sub sum_list
{
    my $self = shift;
    @{$self->{sum}};
}

sub compare
{
    my $self = shift;
    my $first = shift;
    my $row = shift;
    my $key = shift;

    $first->get_column($key) ne $row->get_column($key);
}

sub _doit
{
    my $self = shift;
    my $level = shift;

    if ($level < 0) {
	return( @_ );
    }
    if ($level > $self->max_level) {
	return( @_ );
    }
    my @sections = @_;

    my $first = shift @sections;

    my @inp = ();

    while (my $row = shift @sections) {
	for (my $x = 1; $x <= $level; $x++) {
	    if ($self->compare($first, $row, $self->{groups}->[$x]->{column})) {
                return ( $self->_do_group($level, $self->_doit($level+1, $first, @inp)),
                         $self->_doit($level, $row, @sections)
		       );
	    }
	}
	push(@inp, $row);
    }
    return($self->_do_group($level, $self->_doit($level + 1, $first, @inp)));
}

sub max_level
{
    my $self = shift;
    die 'no groups' unless(scalar(@{$self->{groups}}) - 1 >= 0);
    scalar(@{$self->{groups}}) - 1;
}

sub data
{
    my $self = shift;
    $self->{data};
}

sub _columns
{
    my $self = shift;
    $self->table->columns;
}

sub rows
{
    my $self = shift;

#    my $ret = $self->_do_group(0, $self->_doit($self->max_level, $self->SUPER::rows));
    my $ret = $self->_doit(0, $self->SUPER::rows);

    my @rows = $ret->rows;
    @rows;
}

sub group_it
{
    my $self   = shift;
    my $data   = shift;	# Data::Tabular::Output;
die;
    my $ret;
    my $grouped = $self->{grouped};
    unless ($self->{grouped} && $self->data eq $data) {
	$grouped = $self->new(data => $data);
        $ret = $grouped->_do_group(0, $self->_doit($self->max_level, $data->rows));
        $grouped->{grouped} = $ret;
    }
    $grouped;
}

sub _do_group
{
    my $self = shift;
    my $level = shift;

    my $ret = Data::Tabular::Table::Group->new(data => [ @_ ], level => $level, group => $self, output => $self->output_config);
    ($ret);
}

sub table
{
    my $self = shift;
    $self->{table};
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

=head1 METHODS

=over 4

=item get

Method to access the data for a column. Given a list of column names this method returns
a list of column data.

=item sum

Method to sum a set of columns. Given a list of column names this method returns
the sum of those columns.  The type of the data returned is the type of the 
first column.


