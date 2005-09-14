use strict;

package Data::Tabular::Output::TXT;

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

    $self->{output} = $args->{output} || croak "Need output";

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

    $self->{table}->rows(output => $self->output);
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
