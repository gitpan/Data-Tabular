use strict;

package Data::Tabular::Row::Data;
use base 'Data::Tabular::Row';

sub html_attribute_string
{
    my $self = shift;
    my $ret  = '';

    if ($self->id % 2 == 0) {
#	$ret .= qq| bgcolor=#EDF3FE|;
    } else {
#	$ret .= qq| bgcolor=#EDF3FE|;
    }
    $ret;
}

sub headers
{
    my $self = shift;
    if ($self->{headers}) {
        @{$self->{headers}};
    } else {
        $self->table->all_headers;
    }
    return $self->table->all_headers;
}

sub get_column
{
    my $self = shift;
    my $column_name = shift;
    my $ret;

    my $column = $self->table()->header_offset($column_name);
    my $row    = $self->{input_row};

    $ret = $self->table()->get_row_column($row, $column);

    $ret;
}

1;
__END__
