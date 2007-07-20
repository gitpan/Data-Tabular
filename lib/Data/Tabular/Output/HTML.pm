# Copyright (C) 2003-2007, G. Allen Morris III, all rights reserved

use strict;

package Data::Tabular::Output::HTML;

use base 'Data::Tabular::Output';

use Carp qw (croak);

use overload '""' => \&_render;

sub new
{
    my $class = shift;
    my $args = { @_ };

    my $self = bless {}, $class;

    die 'No table' unless $args->{table};
    $self->{table} = $args->{table};
    die 'No output config' unless $args->{output};
    die 'No output config' unless ref $args->{output};
    die 'No output config' unless $args->{output}->isa('Data::Tabular::Config::Output');
    $self->{output} = $args->{output};

    $self;
}

sub _render
{
    my $self = shift;
    $self->html;
}

sub html
{
    my $self = shift;

    my $output = $self->output;
    my $attributes = $output->html_attribute_string;

    $attributes .= '';
    my $ret = "<table$attributes>\n";

    $ret .= " <colgroup>\n";
    for my $col ($self->columns()) {
        my $attribute = $col->align();

        $ret .= "  <col$attribute/>\n";
    }
    $ret .= " </colgroup>\n";
    my @table;
    if ($output->table) {
	push(@table, "<tr>\n");
# FIX me -- it would be better to put a Title row on the top of the table.
	for my $col ($self->columns()) {
	    my $attributes = '';
	    push(@table, "  <th$attributes>");
	    push(@table, $col->name());
	    push(@table, "</th>\n");
        }
	push(@table, "</tr>\n");
    }
    for my $row ($self->rows()) {
	my $attribute = $row->html_attribute_string();
        push(@table, " <tr$attribute>\n");

	for my $cell ($row->cells()) {
	    my $type = $self->output->type($cell->column_name);
	    my $attributes = $cell->html_attribute_string || '';
	    if ($type eq 'dollar' or $type eq 'number') {
	        $attributes.= ' align="right"';
	    }

            if ($cell->type eq 'sum') {
	        $attributes .= ' style="color: red;"';
	    } else {
	        $attributes .= '';
	    }
	    my $hdr = $cell->hdr;
	    if ($hdr) {
		push(@table, "  <th$attributes>");
	    } else {
		push(@table, "  <td$attributes>");
	    }
            my $cell_data = $cell->html_string;
#	    $cell_data =~ s/^\s*(.*)\s*$/$1/;
	    if (length($cell_data) == 0) {
	       $cell_data = '<br>';
	    }
            push(@table, $cell_data);
	    if ($hdr) {
		push(@table, "</th>\n");
	    } else {
		push(@table, "</td>\n");
	    }
	}
	push(@table, " </tr>\n");
    }
    $ret .= join('', @table);
    $ret .= "</table>\n";
    $ret;
}

1;
__END__

=head1 NAME

Data::Tabular::Output::HTML

=head1 SYNOPSIS

This object is used by C<Data::Tabular> to render an HTML table.

=head1 DESCRIPTION

This object takes a Table and an output object and return an HTML table.

 my $table = Data::Tabular::Output::HTML->new(table => $t, output => $o);
 print $table;

Note that if the object is used as a string the table is rendered.

=head1 CONSTRUCTOR

=over 4

=item new

Normally this object is constructed by the Data::Tabular::html method.

It requires two arguments: a table and and an output object.

=back

=head1 METHODS

=over 4

=item html

This method returns a string that is an HTML table.

=back

=head1 AUTHOR

"G. Allen Morris III" <gam3@gam3.net>

=cut

