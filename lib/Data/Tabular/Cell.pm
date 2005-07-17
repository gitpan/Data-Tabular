use strict;
package Data::Tabular::Cell;

use Carp qw(croak);

use overload '""'  => \&str;

sub new
{
    my $class = shift;

    my $args = { @_ };

    die unless $args->{row};
    die unless $args->{cell};

    my $self = bless($args, $class);

    $self;
}

sub title_format
{
    my $self = shift;
    $self->row->output->xls_title_format($self->name) || 'title_center';
}

sub row_id
{
    my $self = shift;
    $self->row->id() - 1;
}

sub col_id
{
    my $self = shift;
    $self->{id};
}

sub row
{
    my $self = shift;
    $self->{row};
}

sub str
{
    my $self = shift;
    'Cell : '. $self->{cell} . ' ' . $self->html_string;
}

sub html_string
{
    my $self = shift;

    my $ret = $self->{row}->get_column($self->{cell});
    if (my $type = ref($ret)) {
        if ($type eq 'HASH') {
	    $ret = $ret->{html} || $ret->{text} || $ret->{data};
        } elsif ($type eq 'ARRAY') {
die 'XXXXX';
	} else {
	    if ($ret->can('bob')) {
# we just use it;
	    } else {
# we just use it;
	    }
	}
    } else {
#        $ret;
    }
    length($ret) ? $ret : '&nbsp';	# This is wrong FIXME
}

sub html_attribute_string
{
    my $self = shift;
    my $row = $self->{row};
    my $header = $self->{cell};
    my $data = $self->{row}->get_column($self->{cell});
    my $colspan = $self->{colspan};

    my $attributes = $row->cell_html_attributes($self);

    if ($colspan > 1) {
        $attributes->{colspan} = $colspan,
    }

    if (my $type = ref($data)) {
        if ({
	    HASH => 1,
	    ARRAY => 1,
	    CODE => 1,
	}->{$type}) {
	    if ($type eq 'HASH') {
		$attributes->{bgcolor} = $data->{bgcolor};
	    }
# don't do anything
	} else {
	    if ($data->can('attributes')) {
		$attributes = {
		    %$attributes,
		    %{$data->attributes()},
		}
	    } else {
warn 'no attributes';
	    }
	}
    }
    if ($self->{bgcolor}) {
        $attributes->{bgcolor} = $self->{bgcolor};
    }

    my $ret = '';  # FIXME
    for my $attribute (sort keys %$attributes) {
        next unless defined($attributes->{$attribute});
	$ret .= qq| $attribute="| . $attributes->{$attribute} . qq|"|;
    }

    $ret;
}

sub hdr
{
    my $self = shift;
    $self->{row}->hdr;
}

sub name
{
    my $self = shift;
    my $cell = $self->{cell};

    $cell;
}

sub xls_type
{
    my $self = shift;

    my $cell = $self->{row}->get_column($self->{cell});
    my $ret = 'text';
    if (my $type = ref($cell)) {
        if ($type eq 'HASH') {
        } elsif ($type eq 'ARRAY') {
	} else {
	    if ($cell->can('type')) {
                $ret = $cell->type;
	    } else {
# we just use it;
	    }
	}
    }
    $ret;
}

sub xls_string
{
    my $self = shift;

    my $ret = $self->{row}->get_column($self->{cell});
    if (my $type = ref($ret)) {
        if ($type eq 'HASH') {
	    $ret = $ret->{html} || $ret->{text};
        } elsif ($type eq 'ARRAY') {
die 'XXXXX';
	} else {
	    if ($ret->can('xls_data')) {
# we just use it;
                $ret = $ret->xls_data();
	    } else {
# we just use it;
	    }
	}
    }
    $ret;
}

sub xls_align
{
    my $self = shift;

    my $ret = $self->{row}->xls_align($self);
    $ret;
}

sub raw_string
{
    my $self = shift;

    my $ret = $self->{row}->get_column($self->{cell});
    if (my $type = ref($ret)) {
        if ($type eq 'HASH') {
	    $ret = $ret->{html} || $ret->{text};
        } elsif ($type eq 'ARRAY') {
die 'XXXXX';
	} else {
	    if ($ret->can('xls_data')) {
# we just use it;
                $ret = $ret->xls_data();
	    } else {
# we just use it;
	    }
	}
    }
    defined $ret ? $ret : 'N/A';
}


1;
__END__

=head1 NAME

Data::Tabular::Cell - This object holds the information needed by a cell.

=head1 SYNOPSIS

The Data::Tabular::Cell object is normally only used intenally by the
Data::Tabular package.

=head1 DESCRIPTION

=cut
