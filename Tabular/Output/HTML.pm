use strict;

package Data::Tabular::Output::HTML;

use Time::HiRes qw ( gettimeofday tv_interval );

use Carp qw (croak);

use overload '""' => \&render;

sub new
{
    my $class = shift;
    my $args = { @_ };

    my $self = bless {}, $class;

    die 'No table' unless $args->{table};
    $self->{table} = $args->{table};

    $self->{output} = $args->{output} || $self->{table}->output;

    $self;
}

sub output
{
    my $self = shift;
    $self->{output};
}

sub columns
{
    my $self = shift;
    $self->{table}->columns;
}

sub rows
{
    my $self = shift;
    $self->{table}->rows;
}

sub attrib
{
     my $self = shift;

 warn $self->output;
 warn keys %{$self->output};

if (my $href = $self->output->{html}) {
warn 'HRef ', $href;
     $href->{attributes} = {};
     my $new_attributes = {
	 %{$href->{attributes}},
	 @_,
     };
     $href->{attributes} = $new_attributes;
 }

     $self;
}

sub render
{
    my $self = shift;
    $self->html;
}

sub html
{
    my $self = shift;
my $t0 = [gettimeofday];
    my $attributes = $self->output->html_attribute_string;
    $attributes .= '';
    my $ret = "<table$attributes>\n";
    my @columns = qw (type men women total average ratio);
    for my $col ($self->columns()) {
	my $attribute = $col->html_attribute_string;
        $ret .= " <colgroup$attribute>\n";
    }
warn 'columns: ', tv_interval($t0);
    my @table;
    for my $row ($self->rows()) {
	my $attribute = $row->html_attribute_string();
        push(@table, " <tr$attribute>\n");
	for my $cell ($row->cells()) {
	    my $attributes = $cell->html_attribute_string;
	    my $hdr = $cell->hdr;
	    if ($hdr) {
		push(@table, "  <th$attributes>");
	    } else {
		push(@table, "  <td$attributes>");
	    }
            my $cell_data = $cell->html_string;
	    $cell_data =~ s/^\s*(.*)\s*$/$1/;
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
    }
    $ret .= join('', @table);
    $ret .= "</table>\n";
warn 'rows: ', tv_interval($t0);
    $ret;
}

1;
__END__

=head1 NAME

Data::Tabular::Output;

=head1 SYNOPSIS

This object is used by Data::Tabular to render a table.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=cut
1;

