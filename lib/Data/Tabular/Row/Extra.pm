# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;

package Data::Tabular::Row::Extra;
use base 'Data::Tabular::Row';

use Carp qw (croak);

sub new
{
    my $caller = shift;
    my $self = $caller->SUPER::new(@_);

    croak unless $self->{extra};

    $self;
}

sub html_attribute_string
{
    my $self = shift;
    my $ret  = '';

    if ($self->id % 2 == 0) {
	$ret .= qq| class="ende"|;	# FIXME  get this data out of output config
    } else {
	$ret .= qq||;
    }
    $ret;
}

sub get_column
{
    my $self = shift;
    my $column_name = shift;
    my $ret;

    my $row    = $self->{input_row};

    if ($self->table()->is_extra($column_name)) {
        die "circulare reference for $column_name" if $self->{_working}->{$column_name}++;
	$ret = $self->extra_column($self, $column_name);
        $self->{_working}->{$column_name} = 0;
    } else {
	$ret = $self->table()->get_row_column_name($row, $column_name);
    }

    $ret;
}

sub extra_package
{
    require Data::Tabular::Extra;
    'Data::Tabular::Extra';
}

sub get
{
    my $self = shift;
    $self->get_column(@_);
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
        die 'Only know how to deal with code';
    }
    if (my $t = ref($ret)) {
        if ($t eq 'HASH') {
#            $ret;
        } elsif ($t eq 'ARRAY') {
die	    $t;
        } elsif ($t eq 'SCALAR') {
die	    $t;
        } elsif ($t eq 'CODE') {
die	    $t;
	} else {
#	    $ret;
	}
    }
    
    $ret;
}

sub type
{
    'normal data';
}

1;
__END__
