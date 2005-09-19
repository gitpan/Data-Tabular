# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular;

our $VERSION = '0.24';

use Carp qw (croak);

use Data::Tabular::Group;
use Data::Tabular::Table::Extra;
use Data::Tabular::Table::Data;
use Data::Tabular::Config::Output;
use Data::Tabular::Config::Extra;
use Data::Tabular::Extra;

sub new
{
    my $caller = shift;
    my $class = ref($caller) || $caller;
    my $self = bless { @_ }, $class;

    my $output = Data::Tabular::Config::Output->new(
        headers => [ @{$self->{headers}}, 
	    $self->{extra_headers} ? @{$self->{extra_headers}} : keys %{$self->{extra}} ],
	%{$self->{output}},
    );
    my $extra  = Data::Tabular::Config::Extra->new(
	headers => $self->{extra_headers}, 
	columns => $self->{extra}, 
    );

    if (ref($caller)) {
        die q|Don't know how to copy object.|
	    unless $caller->isa(__PACKAGE__);
	$self = $caller->clone()
    }
    my $count = 0;
    if ($self->{headers}) {
        $self->{_all_headers} = [ (@{$self->{headers} || []}, @{$self->{extra_headers} || []}) ];
        for my $elm (@{$self->{_all_headers}}) {
	    $self->{_header_off}->{$elm} = $count++;
	}
    }
    $self->{data_table} =
	Data::Tabular::Table::Data->new(
	    data => bless({
		headers => $self->{headers},
		rows    => $self->{data},
	    }, 'Data::Tabular::Data'),
	);
    $self->{extra_table} =
	 Data::Tabular::Table::Extra->new(
            table => $self->{data_table},
	    extra => $extra,
	);
    if (my $group_by = $self->{group_by}) {
        if (ref $group_by eq 'HASH') {
	    $self->{grouped_table} = Data::Tabular::Group->new(
		table => $self->{extra_table},
		title => $self->{title} || 1,
		%$group_by
	    );
	}
    } else {
	$self->{grouped_table} = $self->{extra_table};
    }
    $self->{output_config} = $output;
    $self;
}

sub _all_headers
{
    my $self = shift;
die;
    wantarray ? @{$self->{_all_headers} || []} : $self->{_all_headers};
}

sub headers
{
    my $self = shift;

    $self->{extra_table}->headers;
}

sub _extra_headers
{
    my $self = shift;

die;
    wantarray ? @{$self->{extra_headers} || []} 
              : $self->{extra_headers};
}

sub _header_offset
{
    my $self = shift;
    my $column = shift;
    my $ret = $self->{_header_off}->{$column};
die;
    croak "column '$column' not found in [",
          join(" ",
	      sort keys(%{$self->{_header_off}})
	  ), ']' unless defined $ret;
    $ret;
}

sub _row_count
{
    my $self = shift;
die;
    scalar @{$self->data};
}

sub _col_count
{
    my $self = shift;
die;
    scalar @{$self->{_all_headers}};
}

sub _output
{
    my $self = shift;
    $self->{output_config};
}

sub _output_config
{
    my $self = shift;
die;
    $self->{output_config};
}

sub _data
{
    my $self = shift;
die;
    $self->{data_table};
}

sub _extra
{
    my $self = shift;
die;
    $self->{extra_table};
}

sub grouped
{
    my $self = shift;

    $self->{grouped_table};
}

sub title
{
    my ($self, $column, $title) = @_;

    $self->{output}->{columns}->{$column}->{title} = $title;
}

sub _extra_package
{
    require Data::Tabular::Extra;
die;
    'Data::Tabular::Extra';
}

sub _extra_column
{
    my $self = shift;
    my $row = shift;
    my $key = shift;
    my $ret = 'N/A';

die;
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
    $ret;
}

sub __extra
{
    my $self = shift;
    my $row = shift;
    my $extra_headers = $self->extra_headers;
    my $extra = $self->{extra};
die;
    return undef unless $row;

    my $out = [ @$row ];
    for my $key ($self->extra_headers()) {
        my $offset = $self->header_offset($key);

	my $x = $self->extra_package->new(row => $out, table => $self);

        if (ref($extra->{$key}) eq 'CODE') {
	    eval {
		$out->[$offset] = $self->new_cell($extra->{$key}->($x));
	    };
	    if ($@) {
		die $@;
	    }
        } else {
	    die 'only know how to deal with code';
        }
    }
    wantarray ? @$out : $out;
}

sub html
{
    my $self = shift;

    require Data::Tabular::Output::HTML;

    return Data::Tabular::Output::HTML->new(
        table => $self->grouped,
	output => $self->_output,
	@_
    );
}

sub xls
{
    my $self = shift;
    require Data::Tabular::Output::XLS;

    return Data::Tabular::Output::XLS->new(
	table => $self->grouped,
	output => $self->_output,
	@_);
}

sub xml
{
    my $self = shift;
    require Data::Tabular::Output::XML;

    return Data::Tabular::Output::XML->new(
	table => $self->grouped,
	output => $self->_output,
	@_);
}

sub txt 
{
    my $self = shift;
    require Data::Tabular::Output::TXT;

    return Data::Tabular::Output::TXT->new(
	table => $self->grouped,
	output => $self->_output,
	@_
    );
}

sub csv 
{
    my $self = shift;
    require Data::Tabular::Output::CSV;

    return Data::Tabular::Output::CSV->new(
	table => $self->grouped,
	output => $self->_output,
	@_
    );
}

1;
__END__

=head1 NAME

Data::Tabular - Handy Table Manipulation and rendering Object

=head1 SYNOPSIS

 use Data::Tabular;

 $table = Data::Tabular->new(
     headers => ['one', 'two'],
     data    => [
          ['a', 'b'],
          ['c', 'd']
     ],
     extra_headers => [ 'three' ],
     extra => {
         'three' => sub {
             my $self = shift;
             my $a = $self->get('one');
             my $b = $self->get('two');
             $a . $b;
         },
     },
     group_by => {
     },
     output => {
         headers => [ 'three', 'one', 'two' ],
     },
 );


=head1 DESCRIPTION

Data::Tabular has four major sections:

The data section.  This is the base table, it contains a set of rows that is made up of 
named columns.

The extra section. This is a set of named columns that are added to the table.

The group_by section. This is allows titles, and subtotals to be inserted into table.

The output section.  This allows the output to be formated and rendered for a particular
type of output.  Currently HTML and Excel spreadsheets are supported.

Of these only the data section is required.

=head1 Data Section

The Data section consists of two pieces of information a list of headers names and 
a 2 dimensional array of data.

=head1 API

=head2 Constructor

=over

=item new

The new method

=back

=head2 Output Control Methods

=over

=item title

Control output titles.

=back

=head2 Accessor Methods

=over

=item data

The data method returns a Data::Table object.

=item extra

The extra method returns a Data::Table::Extra object.

=item grouped

The grouped method returns a Data::Table::Grouped object.

=item headers

The headers method returns the available headers in the
Data::Table::Extra object. This is the headers from both the data
section and the extra section. These are the headers that can be in the
output section.

=back

=head2 Configure Methods

=head2 Display Methods

=over

=item html

returns html representation of the table.

=item xml

returns xml representation of the table.

=item xls

returns xls representation of the table.

=item txt

returns text representation of the table.

=item csv

returns a comma separated representation of the table.

=back

=head1 EXAMPLES


 my $st = $dbh->prepare('Select * from my_test_table');
 my $data = selectall_arrayref($st);
 my $headers = $st->{NAMES}
 
 my $table = Data::Tabular->new(
        data => $data,
        headers => $headers,
    );

=head1 AUTHOR

"G. Allen Morris III" <gam3@gam3.net>

=cut
