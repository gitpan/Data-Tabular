# Copyright (C) 2003-2007, G. Allen Morris III, all rights reserved

use strict;

package
    Data::Tabular::Table::Group;

use base 'Data::Tabular::Table';

use Data::Tabular::Group::Interface;

sub new
{
    my $class = shift;
    bless { @_ }, $class;
}

sub _row_count
{
    my $self = shift;

    die;
}

sub sum_list
{
    my $self = shift;
    $self->group->sum_list;
}

sub sum
{
    my $self = shift;
    my $column_name = shift;
    my $ret;
    if ($ret = $self->{memo}->{$column_name}) {
        return $ret;
    }
    my $formula = '=SUM(';
    my $sum = 0;
    my @rows;
    for my $row ($self->raw_rows) {
        push(@rows, $row->id());
	my $next = $row->get($column_name);
	if (UNIVERSAL::isa($next, 'Data::Tabular::Formula')) {
	    $next = $next->{html};
	}
	$sum += $next;
    }
    require Data::Tabular::Formula;
    $ret = bless {
        html => $sum,
	type => 'sum',
	column => $column_name,
	rows => \@rows,
    }, 'Data::Tabular::Formula';

    $self->{memo}->{$column_name} = $ret;
    $ret;
}

sub avg
{
    my $self = shift;
    my $column_name = shift;
    my $ret;
    if ($ret = $self->{memoa}->{$column_name}) {
        return $ret;
    }
    my $formula = '=SUM(';
    my $sum = 0;
    my @rows;
    my $count = 0;
    for my $row ($self->raw_rows) {
        push(@rows, $row->id());
	my $next = $row->get($column_name);
	if (UNIVERSAL::isa($next, 'Data::Tabular::Formula')) {
	    $next = $next->{html};
	}
	$sum += $next;
	$count++;
    }
    require Data::Tabular::Formula;

    $ret = bless {
        html => $sum / $count,
	count => $count,
	type => 'avg',
	column => $column_name,
	rows => \@rows,
    }, 'Data::Tabular::Formula';

    $self->{memoa}->{$column_name} = $ret;
    $ret;
}

sub group
{
    my $self = shift;
    $self->{group};
}

sub all_headers
{
    my $self = shift;

    $self->group->headers;
}

sub raw_rows
{
    my $self = shift;
    my @ret = ();

    for my $value (@{$self->{data}}) {
	next unless $value;
	if ($value->isa(__PACKAGE__)) {
	    push(@ret, $value->raw_rows);
	} else {
	    push(@ret, $value);
	}
    }
    @ret;
}

sub level
{
    shift->{level};
}

sub groups
{
    my $self = shift;
    $self->{group}->{groups};
}

sub get_column
{
    my $self = shift;
    $self->get(@_);
}

sub get
{
    my $self = shift;
    my $key = shift;

    my $ret = $self->{data}->[0]->get_column($key);
    die "Bad Column $key"  unless $ret eq $self->{data}->[-1]->get_column($key);

    $ret;
}

sub get_all
{
    my $self = shift;
    my $key = shift;
    my $temp = {};
    my @ret;

    for my $value (@{$self->{data}}) {
        next unless $value;
	my $item = $value->get_column($key);
	unless ($temp->{$item}++) {
	    push(@ret, $item);
	}
    }

    \@ret;
}

sub rows
{
    my $self = shift;
    my $info = { 
        @_,
	row => 0,
	pre_once => 0,
	x => 'ok'
    };
    return $self->{rows} if $self->{rows};

    return unless $self->{data};
    return unless $self->{data}->[0];

    my $rid = 1;
    my @ret = ();
    if (my $action = $self->groups->[$self->level]->{pre}) {
	my $grouper = Data::Tabular::Group::Interface->new(
	   group => $self,
	);
	my @data = $action->($grouper);
	eval {
	    push(@ret, map({ $_->{row_id} = $rid++; $_->{output} = $info->{output}; $_ } @data));
	};
	if ($@) { warn $@; }
    }

    for my $value (@{$self->{data}}) {
	if (my $x = $value->isa(__PACKAGE__)) {
	    push(@ret, map({ $_->{row_id} = $rid++; $_->{output} = $info->{output}; $_ } ($value->rows(%$info))));
	} else {
	    push(@ret, map({ $_->{row_id} = $rid++; $_->{output} = $info->{output}; $_ } ($value)));
	}
    }

    $info->{x} = 'ok';
    if (my $action = $self->groups->[$self->level]->{post}) {
	my $grouper = Data::Tabular::Group::Interface->new(
	   group => $self,
	   table => $self,
	);
	my @data = $action->($grouper);
	push(@ret, map({ $_->{row_id} = $rid++; $_->{output} = $info->{output}; $_ } @data));
    }
    $self->{rows} = \@ret;
    @{$self->{rows}};
}

1;
__END__

=head1 NAME

Data::Tabular::Table::Group

=head1 SYNOPSIS

This object is used by Data::Tabular to hold a table with grouped rows.

=head1 DESCRIPTION

=head2 METHODS

=over

=item rows

Generate the rows for a table with the required calculated rows.

=back

=head1 SEE ALSO

 Data::Tabular::Data

=cut
