use strict;

package Data::Tabular::Output::CSV;

use base "Data::Tabular::Output";

sub text
{
    my $self = shift;
    my $ret = "\n";

    my $output = $self->output;


    for my $row ($self->rows()) {
	my @table;
	for my $cell ($row->cells($output->headers)) {
            my $cell_data = $cell->html_string;
            my $width = 20; # $cell->width;
	    $cell_data =~ s/^\s*(.*)\s*$/$1/;
	    my $quote;
	    if ($cell_data =~ /,/) {
	         $quote = 1;
	    }
	    if ($cell_data =~ /"/) {
	         $cell_data =~ s/"/""/g;
	         $quote = 1;
	    }
	    if ($quote) {
	         $cell_data = '"' . $cell_data . '"';
	    }
            push(@table, $cell_data);
	    my $length = $width - length($cell_data);
	    if ($length <=0) {
	        $length = 1;
	    }
	}
	$ret .= join(',', @table);
	$ret .= "\n";
    }

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

