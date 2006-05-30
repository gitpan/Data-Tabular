# Copyright (C) 2003-2005, G. Allen Morris III, all rights reserved

use strict;

package Data::Tabular::Output::TXT;

use base qw(Data::Tabular::Output);

use Carp qw (croak);

use overload '""' => \&render;

sub new
{
    my $class = shift;
    my $args = { @_ };

    my $self = bless {}, $class;

    die 'No table' unless $args->{table};
    $self->{table} = $args->{table};

    $self->{output} = $args->{output} || croak "Need output";

    $self;
}

sub output
{
    my $self = shift;
    $self->{output};
}

sub render
{
    my $self = shift;
    $self->text;
}

sub text
{
    my $self = shift;
    my $ret = "\n";

    my $output = $self->output;

    my @table;

    for my $row ($self->rows()) {
#        push(@table, " " . $row->id . " ");
	for my $cell ($row->cells($output->headers)) {
            my $cell_data = $cell->html_string;
            my $width = 20; # $cell->width;
	    $cell_data =~ s/^\s*(.*)\s*$/$1/;
            push(@table, $cell_data);
	    my $length = $width - length($cell_data);
	    if ($length <=0) {
	        $length = 1;
	    }
	    push(@table, " " x $length);
	}
	push(@table, "\n");
    }
    $ret .= join('', @table);

    $ret;
}

1;
__END__

=head1 NAME

Data::Tabular::Output::TXT;

=head1 SYNOPSIS

This object is used by Data::Tabular to render a table in text format.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=cut
1;

