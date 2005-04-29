use strict;
package Data::Tabular::Table::Group;
use base 'Data::Tabular::Table';

use Data::Tabular::Group::Interface;

sub new
{
    my $class = shift;
    bless { @_ }, $class;
}

sub row_count
{
    my $self = shift;

    1;
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
    for my $row ($self->raw_rows) {
	$sum = $row->get($column_name) + $sum;
	$formula .= $row->id. ", $column_name, ";
    }
    $formula .= ')';
    $ret = {
        html => $sum,
        xls => $formula,
    };
# FIXME : This needs to be a facny type, so that Extra can add and subtract elements.
    $ret = $sum;
    $self->{memo}->{$column_name} = $ret;
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
    my $info = shift || { row => 0, pre_once => 0, x => 'ok' };

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
	    push(@ret, map({ $_->{row_id} = $rid++; $_ } @data));
	};
	if ($@) { warn $@; }
    }

    for my $value (@{$self->{data}}) {
	if (my $x = $value->isa(__PACKAGE__)) {
	    push(@ret, map({ $_->{row_id} = $rid++; $_ } ($value->rows($info))));
	} else {
	    push(@ret, map({ $_->{row_id} = $rid++; $_ } ($value)));
	}
    }
    $info->{x} = 'ok';
    if (my $action = $self->groups->[$self->level]->{post}) {
	my $grouper = Data::Tabular::Group::Interface->new(
	   group => $self,
	   table => $self,
	);
	my @data = $action->($grouper);
	push(@ret, map({ $_->{row_id} = $rid++; $_ } @data));
    }
    $self->{rows} = \@ret;
    @{$self->{rows}};
}

1;
__END__

