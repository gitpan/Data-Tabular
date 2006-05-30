# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular::Row::Averages;

use base 'Data::Tabular::Row';

use Carp qw(croak carp);

use overload '@{}' => \&array,
             '""'  => \&str;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    die unless $self->table;
    die "Need sum_list" unless $self->{sum_list};

    $self;
}

sub str
{
    my $self = shift;

    'Row::Averages';
}

sub cells
{
    my $self = shift;
    my @ret = ();
    my @headers = $self->headers();

    my $offset = 0;
    my $hash;
    for my $x ( @{$self->{sum_list} || []} ) {
        $hash->{$x} = { sum => 1 };
    }

    my $start;
    my $x = 0;
    my $state = 0;
    my $cols = 1;
    while (my $column_name = shift @headers) {
        if ($state == 0) {
	    if ($column_name && $hash->{$column_name} && $hash->{$column_name}->{sum}) {
		push(@ret,
		    Data::Tabular::Cell->new(
			row => $self,
			cell => $column_name,
			colspan => 1, 
			id => $x,
		    ),
		);
	    } else {
		$state++;
	    }
	}
	if ($state == 1) {
	    if ($column_name && $hash->{$column_name} && $hash->{$column_name}->{sum}) {
		push(@ret,
		    Data::Tabular::Cell->new(
			row => $self,
			cell => '_description',
			colspan => $cols - 1, 
			id => $x - ($cols - 1),
		    ),
		); 
		$cols = 1;
		$state++;
	    } else {
		$cols++;
	    }
	}
	if ($state == 2) {
	    if ($column_name && $hash->{$column_name} && $hash->{$column_name}->{sum}) {
	        if ($cols > 1) {
		    push(@ret,
			Data::Tabular::Cell->new(
			    row => $self,
			    cell => '_filler',
			    colspan => $cols - 1, 
			    id => $x,
			),
		    ); 
		    $cols = 1;
		}
		push(@ret,
		    Data::Tabular::Cell->new(
			row => $self,
			cell => $column_name,
			colspan => $cols, 
			id => $x,
		    ),
		); 
		$cols = 1;
	    } else {
	        $cols++;
	    }
	}
	die if ($state >= 3);
	$x++;
    }
    if ($cols > 1) {
	push(@ret,
	    Data::Tabular::Cell->new(
		row => $self,
		cell => '_filler',
		colspan => $cols, 
		id => $x - 1,
	    ),
	); 
	$cols = 1;
    }
die $cols if $cols > 1;
    @ret;
}

sub sum_list
{
    my $self = shift;

    $self->{sum_list};
}

sub get_column
{
    my $self = shift;
    my $column_name = shift;
    my $ret;
    my $reg = qr|^$column_name$|;

    if ($column_name eq '_description') {
        $ret = $self->{text};
    } elsif (grep(m|$reg|, @{$self->sum_list})) {
        $ret = $self->table->avg($column_name);
    } elsif (grep(m|$reg|, @{$self->{extra}->{headers} || []})) {
	$ret = "extra($column_name)";
    } elsif ($column_name eq '_filler') {
        $ret = undef;
    } else {
        $ret = 'N/A('. $column_name . ')';
    }
    $ret;
}

sub extra_column
{
    my $self = shift;
    my $row = shift;
    my $key = shift;

    my $extra = $self->{extra}->{columns};

    my $ret = undef;

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

sub hdr
{
    1;
}

sub data
{
    my $self = shift;
die;
    wantarray ? @{$self->[1]} : $self->[1];
}

sub id
{
    my $self = shift;

    $self->{row_id} || 'No ID available';
}

sub cell_html_attributes
{
    my $self = shift;
    my $cell = shift;

    {
        align => ($cell->name() eq '_description' ? 'left' : 'right'),
    };
}

sub type
{
    'totals';
}

1;
__END__

