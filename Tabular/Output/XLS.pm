use strict;

package Data::Tabular::Output::XLS;

use Carp qw (croak);

sub new
{
    my $class = shift;
    my $args = { @_ };

    my $self = bless {}, $class;

    my $arg_list = {
        table => {},
        output => {},
        workbook => {},
	worksheet => {},
	row_offset => {},
	column_offset => {},
    };
    for my $arg (keys %$arg_list) {
        $self->{$arg} = $args->{$arg};
	delete $args->{$arg};
    }

    if (my @x_list = keys %$args) {
        die 'Unknows arguments: ' . join(' ', sort @x_list);
    }

    $self->render;
}

sub output
{
    my $self = shift;
    $self->{output};
}

sub rows
{
    my $self = shift;
    $self->{table}->rows;
}

sub columns
{
    my $self = shift;
    $self->{table}->columns;
}

sub workbook
{
    my $self = shift;
    $self->{workbook};
}

sub worksheet
{
    my $self = shift;
    $self->{worksheet};
}

sub row_offset
{
    my $self = shift;
    $self->{row_offset};
}

sub col_offset
{
    my $self = shift;
    $self->{col_offset};
}

sub render
{
    my $self = shift;

    my $workbook = $self->workbook || croak 'need a workbook';
    my $worksheet = $self->worksheet || croak 'need a worksheet';

    my $row_offset = $self->row_offset;
    my $col_offset = $self->col_offset;

    my $pin_title = $self->output->test_xls_attribute('pin_title');

    my $format_default = $workbook->addformat(
	align => 'left',
	size => 8,
    );

    my $formats = {
        'right' => $workbook->addformat(
	    align => 'right',
	    text_wrap => 1,
	    bold => 1,
	),
	'left' => $workbook->addformat(
	    align => 'left',
	    text_wrap => 1,
	    bold => 1,
	),
    };

    for my $column ($self->columns()) {
        my $col = $column->x;
	my $align = $column->align || 'left';

	$worksheet->set_column($col, $col, $column->xls_width, $formats->{$align});
    }

    my $types = {
        default => {
	    align => 'left',
	    size => 8,
	},
	month => {
	    num_format => 'mm/yyyy',
	    align => 'right',
	    size => 8,
	},
	date => {
	    num_format => 'mm/dd/yyyy',
	    align => 'right',
	    size => 8,
	},
	dollar => {
	    num_format => '$#,##0.00_);[Red]($#,##0.00)',
	    align => 'right',
	    size => 8,
	},
	percent => {
	    num_format => '0.0%',
	    align => 'right',
	    size => 8,
	},
	number => {
	    num_format => '#,##0',
	    align => 'right',
	    size => 8,
	},
	text => {
	    align => 'left',
	    size => 8,
	},
    };
    my $formats;
    for my $type (keys %{$types}) {
       $formats->{$type} =  $workbook->addformat(%{$types->{$type}});
       $formats->{$type . '_hdr'} =  $workbook->addformat(%{$types->{$type}}, bold => 1, text_wrap => 0);
    }
    $formats->{'title_right'} =  $workbook->addformat(align => 'right', size => 8, bold => 1, text_wrap => 1);
    $formats->{'title_left'} =  $workbook->addformat(align => 'left', size => 8, bold => 1, text_wrap => 1);
    $formats->{'title_center'} =  $workbook->addformat(align => 'center', size => 8, bold => 1, text_wrap => 1);
    $formats->{'averages_right'} =  $workbook->addformat(align => 'right', size => 8, bold => 1, text_wrap => 0);
    $formats->{'averages_left'} =  $workbook->addformat(align => 'left', size => 8, bold => 1, text_wrap => 0);
    $formats->{'averages_center'} =  $workbook->addformat(align => 'center', size => 8, bold => 1, text_wrap => 0);

    my $title_pinned = 0;
    for my $row ($self->rows()) {
        if ($row->type eq 'title') {
	    if ($pin_title) {
	        next if $title_pinned;
		$title_pinned = 1;
	    }
	}
	for my $cell ($row->cells()) {
	    my $attributes = $cell->html_attribute_string;
	    my ($y, $x, $cell_data, $type) = ($cell->row_id, $cell->col_id, $cell->xls_string, $cell->xls_type);

	    my $cell_type = $type;
	    if ($row->hdr) {
	        $cell_type .= '_hdr';
	    }
	    if ($row->type eq 'title') {
	        $cell_type = $cell->title_format;
	    }
	    if ($row->type eq 'averages') {
	        $type = 'text';
	        $cell_type = 'averages_' . $cell->xls_align($cell);
#die $type, ' -> ', $cell_type;
	    }

#if ($row->isa('Data::Tabular::Row::Totals')) {
# warn 'Totals = ',  join(':', $y, $x, $cell_data, ref($cell_data), $type);
#}
	    my $format = undef;
            if ($type eq 'date') {
                if ($cell_data) {
                    $worksheet->write_number($y, $x, $cell_data, $formats->{$cell_type});
                }
            } elsif ($type eq 'month') {
                my $date_data = $cell_data;
                if ($cell_data) {
                    $worksheet->write_number($y, $x, $cell_data, $formats->{$cell_type});
                }
            } elsif ($type eq 'text') {
                $worksheet->write_string($y, $x, $cell_data, $formats->{$cell_type});
            } elsif ($type eq 'dollar') {
                $worksheet->write_number($y, $x, $cell_data, $formats->{$cell_type});
            } elsif ($type eq 'number') {
                $worksheet->write_number($y, $x, $cell_data, $formats->{$cell_type});
            } elsif ($type eq 'percent') {
                $worksheet->write_number($y, $x, $cell_data, $formats->{$cell_type});
            } else {
                warn "Unknown type $type";
                $worksheet->write($y, $x, 'unknows type ' . $cell_data);
            }
	}
    }
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

