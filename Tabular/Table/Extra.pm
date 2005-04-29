use strict;
package Data::Tabular::Table::Extra;
use base 'Data::Tabular::Table::Data';

use Carp qw (croak);

sub new
{
    my $caller = shift;
    my $self = $caller->SUPER::new(@_);

    $self;
}

sub is_extra
{
    my $self = shift;
    my $column_name = shift;

    grep(/^$column_name$/, @{$self->extra->{headers}});
}

sub all_headers
{
    my $self = shift;

    my @headers = @{[ (@{$self->{data}->{headers} || []}, @{$self->extra->{headers} || []}) ]};

    @headers;
}

sub row_package
{
    require Data::Tabular::Row::Extra;
   'Data::Tabular::Row::Extra';
}

sub header_offset
{
    my $self = shift;
    my $column = shift;
    my $count = 0;
    unless ($self->{_header_off}) {
	for my $header ($self->headers) {
	    $self->{_header_off}->{$header} = $count++;
	} 
    }
    my $ret = $self->{_header_off}->{$column};
    croak "column '$column' not found in [",
          join(" ",
	      sort keys(%{$self->{_header_off}})
	  ), ']' unless defined $ret;
    $ret;
}

sub get_row_column
{
    my $self = shift;
    my $row = shift;
    my $column = shift;
    my $count = scalar(@{$self->{data}->{headers}});

    if ($column >= $count) {
        die 'column out of range';
    } else {
	$self->{data}->{rows}->[$row][$column];
    }
}

1;
__END__

=head1 NAME

Data::Tabular::Table::Extra;

=head1 SYNOPSIS

This object is used by Data::Tabular to hold a table with calculated columns.

=head1 DESCRIPTION

This object holds a table that has calculated columns.

=head1 METHODS

=over 4

=item is_extra

The is extra method is used by underlying row to deside if a column needs to be
calulated.

=back

=head1 SEE ALSO

 Data::Tabular::Row::Extra

=cut
