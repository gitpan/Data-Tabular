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

    $self->{_all_headers} ||= [ (@{$self->{data}->{headers} || []}, @{$self->{extra}->{headers} || []}) ];
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
        'Unknown Column '. $column_name;
    } else {
	$self->{data}->{rows}->[$row][$column];
    }
}

sub extra_column
{
    my $self = shift;
    my $row = shift;
    my $key = shift;
    my $ret = 'N/A';

    my $extra = $self->{extra};

    return undef unless $row;

    my $offset = $self->header_offset($key);

    my $x = $self->extra_package->new(row => $row, table => $self);

    if (ref($extra->{$key}) eq 'CODE') {
	eval {
	    $ret = $extra->{$key}->($x);
	};
	if ($@) {
	    die $@;
	}
    } else {
	die 'only know how to deal with code';
    }
    die $ret;
    if (ref($ret)) {
        die if (ref($ret) eq 'HASH');
    }

    $ret;
}

sub row_package
{
    require Data::Tabular::Row::Data;
   'Data::Tabular::Row::Data';
}

sub rows
{
    my $self = shift;
    my @output;

    for (my $row = 0; $row < $self->row_count; $row++) {
	push(@output, $self->row_package->new(
	    table => $self,
	    input_row => $row,
	    extra => $self->{extra},
	));
    }

    $self->{rows} = \@output;

    wantarray ? @{$self->{rows}} : $self->{rows};
}

1;
__END__

=head1 NAME

Data::Tabular::Table::Data;

=head1 SYNOPSIS

This object is used by Data::Tabular to hold a table.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=cut
