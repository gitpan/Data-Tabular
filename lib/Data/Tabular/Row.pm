# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;
package Data::Tabular::Row;

use Data::Tabular::Cell;
use Carp qw(croak);

use overload '@{}' => \&array,
             '""'  => \&str;

sub new
{
    my $caller = shift;
    my $class = ref($caller) || $caller;
    my $self = { @_ };
    if (ref($caller)) {
        croak(q|Don't know how to copy object: | . $class)
	    unless $caller->isa(__PACKAGE__);
	$self = $caller->clone();
    }
    $self = bless $self, $class;

    croak 'need table' unless $self->table;

    $self;
}

sub str
{
    my $self = shift;
    'Row : '. $self->{input_row} .  join(':', $self->table->headers);
}

sub output_headers
{
# FIXME
    1;
}

sub headers
{
    my $self = shift;
    if (@_) {
        return @_;
    } else {
	return $self->table->headers;
    }
}

sub html_attribute_string
{
    my $self = shift;
    my $ret  = ' class="ende"';

    $ret;
}

sub cells
{
    my $self = shift;
    my @ret = ();
    my @headers = $self->headers(@_);

    my $x = 0;
    for my $header (@headers) {
        next unless $header;
        push(@ret, 
	    Data::Tabular::Cell->new(
		row => $self,
		cell => $header,
		colspan => $self->colspan($header),
		id => $x++,
	    )
	);
    }
    @ret;
}

sub colspan
{
    1;
}

sub new_cell
{
    my $self = shift;
    my $args = {@_};
    die unless defined $args->{input_col};
    my $input_column = $args->{input_col};
warn __PACKAGE__ . '::new_cell';
    $self->{cols}->[$input_column] = {};
}

sub table
{
    shift->{table};
}

sub array
{
    my $self = shift;
croak;
    my $data = $self;
    $data = $data->[1];
    $data;
}

sub attributes
{
    my $self = shift;
    $self->[0];
}

sub selected
{
    my $self = shift;
    map({ $self->new_cell(data => $_, input_col => 1); } ('a', 'b'));
}

sub hdr
{
}

sub data
{
    my $self = shift;
    wantarray ? @{$self->[1]} : $self->[1];
}

sub id
{
    my $self = shift;
print "Row: ", $self->{row_id}, "\n";
    $self->{row_id} || 'No ID available';
}

sub cell_html_attributes
{
    {
        align => undef,
    };
}

sub type
{
    my $self = shift;
    warn 'No type for ' . ref($self);
    'unknown';
}

1;
__END__

