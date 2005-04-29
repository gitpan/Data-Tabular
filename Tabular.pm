# Copyright (C) 2003, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular;
use Spreadsheet::WriteExcel::Utility qw(:dates);

our $VERSION = '0.21-eo';

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
        headers => $self->{headers},
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
	    output => $output,
	);
    if (my $group_by = $self->{group_by}) {
        if (ref $group_by eq 'HASH') {
	    $self->{grouped_table} = Data::Tabular::Group->new(
		table => $self->{extra_table},
		output => $output,
		title => $self->{title} || 1,
		%$group_by
	    );
	}
    } else {
	$self->{grouped_table} = Data::Tabular::Group->new(table => $self->{extra_table}, grouped => [ {} ]);
    }
    $self;
}

sub all_headers
{
    my $self = shift;

    wantarray ? @{$self->{_all_headers} || []} : $self->{_all_headers};
}

sub headers
{
    my $self = shift;

    wantarray ? @{$self->{headers} || []} : $self->{headers};
}

sub extra_headers
{
    my $self = shift;

    wantarray ? @{$self->{extra_headers} || []} 
              : $self->{extra_headers};
}

sub header_offset
{
    my $self = shift;
    my $column = shift;
    my $ret = $self->{_header_off}->{$column};
    croak "column '$column' not found in [",
          join(" ",
	      sort keys(%{$self->{_header_off}})
	  ), ']' unless defined $ret;
    $ret;
}

sub row_count
{
    my $self = shift;
    scalar @{$self->data};
}

sub col_count
{
    my $self = shift;
    scalar @{$self->{_all_headers}};
}

sub output_config
{
    my $self = shift;

    $self->{output_config};
}

sub data
{
    my $self = shift;

    $self->{data_table};
}

sub extra
{
    my $self = shift;

    $self->{extra_table};
}

sub grouped
{
    my $self = shift;

    $self->{grouped_table};
}

sub _extra_package
{
    require Data::Tabular::Extra;
    'Data::Tabular::Extra';
}

sub _extra_column
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
    $ret;
}

sub _extra
{
    my $self = shift;
    my $row = shift;
    my $extra_headers = $self->extra_headers;
    my $extra = $self->{extra};

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
    $self->grouped->html(@_);
}

sub xls
{
    my $self = shift;
    $self->grouped->xls(@_);
}

sub xml
{
    my $self = shift;
    $self->grouped->xml(@_);
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
             'bob';
         },
     },
     group_by => {
     },
     output {
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
type of ouput.  Currently HTML and Excel spreadsheets are supported.

Of these only the data section is requied.

=item Data Section

The Data section consisits of two pieces of information a list of headers names and 
a 2 dimintional array of data.


=item EXAMPLES

 my $st = $dbh->prepare('Select * from my_test_table');
 my $data = selectall_arrayref($st);
 my $headers = $st->{NAMES}
 
 my $table = Data::Tabular->new(
        data => $data,
        headers => $headers,
    );




=cut
