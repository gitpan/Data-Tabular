use strict;
package Data::Tabular::Group::Interface;

sub new
{
    my $class = shift;
    my $self = bless { @_ }, $class;

    $self;
}

sub get
{
    my $self = shift;
    my $column_name = shift;

    $self->{group}->get($column_name);
}

sub count
{
    my $self = shift;
    scalar $self->{group}->raw_rows();
}

sub header
{
    my $self = shift;
    my $args = { @_ };
    require Data::Tabular::Row::Header;
    Data::Tabular::Row::Header->new(
	text => $args->{text},
	table => $self->{group},
    );
}

sub titles
{
    my $self = shift;
    require Data::Tabular::Row::Titles;
    Data::Tabular::Row::Titles->new(
	@_,
	table => $self->{group},
    );
}

sub totals
{
    my $self = shift;
    my $args = { @_ };
    require Data::Tabular::Row::Totals;

    Data::Tabular::Row::Totals->new(
	text => $args->{text},
	table => $self->{group},
        sum_list => $self->{group}->{group}->{sum},
        extra => $self->{group}->{group}->{extra},
    );
}

sub averages
{
    my $self = shift;
    my $args = { @_ };
    require Data::Tabular::Row::Averages;

    Data::Tabular::Row::Averages->new(
        count => $self->count(),
	text => $args->{text},
	table => $self->{group},
        sum_list => $self->{group}->{group}->{sum},
        extra => $self->{group}->{group}->{extra},
    );
}

sub avg
{
    my $self = shift;
    my $args = { @_ };
    $self->averages(
	text => $args->{title},
    );
}

sub sum
{
    my $self = shift;
    my $args = { @_ };
    require Data::Tabular::Row::Totals;
    Data::Tabular::Row::Totals->new(
	text => $args->{title},
	table => $self->{group},
    );
}

1;
__END__

=head1 NAME

Data::Tabular::Group::Interface - Object that is passed into I<group_by> methods

=head1 SYNOPSIS

   group_by => {
       groups => [
          {
	     pre => sub {
	          my $self = shift;    # This is a Data::Tabular::Group::Interface object
	     },
	  }
       ],
    },

=head1 DESCRIPTION

Data::Tabular::Group::Interface is only used by the I<group_by> function of the
Data::Tabuler package.

There are several 2 major groups of methods in this object: access
methods and output methods. Access methods let the users groups methods
access information about the current table and the output methods that
return the rows that are being inserted into the table. 

=head2 Access Methods

=item get([column name])

This method returns the value of the column given my I<column name>.  This column should
be a grouped column or the value will unpredictable (one of the values from the group).

=item count

This give the number of input rows in the current group.

=head2 Output Methods

=item header(text => 'header text')

The header method returns a header row that will span the complete table.

=over 2

=head3 Arguments

=item text

The text that is printed in the header.  Often get() and count() are used
to build this string.

=back

=item titles

The titles method returns a row of titles. Normally all tables will use
this method at least once.

=over 4

=item 

=back

=item totals

This method return a row with the columns listed in the sum array summed.

=item averages

This is simular to the totals method, but each value is divied by the
number of input rows before being output.

=cut
