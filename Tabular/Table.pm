
use strict;

package Data::Tabular::Table;

use Data::Tabular::Column;
use Carp qw (croak);

use Data::Tabular::Config::Output;

sub new
{
    my $caller = shift;
    my $class = ref($caller) || $caller;
    my $self = {};
    my $args = { @_ };
    my $old = {};

    if (my $table = $args->{table}) {
        for my $key (keys %$table) {
	   $old->{$key} = $table->{$key};
	}
	delete $args->{table};
    }

    if (ref($caller)) {
        for my $key (keys %$caller) {
	   $old->{$key} = $caller->{$key};
	}
    }
    $self = { %$old, %$args };
    bless $self, $class;
    unless ($self->output_config) {
        $self->output_config(Data::Tabular::Config::Output->new(headers => [ $self->all_headers ]));
    }

    die 'Need output' unless $self->output_config;

    die unless $self->{data};

    $self;
}

sub output_config
{
    my $self = shift;
    my $ret = $self->{output};
    die 'Usage: output_config(output_congif)' if @_ > 1;
    if (@_) {
	$self->{output} = shift;
    }
    $ret;
}

sub output
{
    shift->{output};
}

sub extra
{
    shift->{extra};
}


sub headers
{
    my $self = shift;

    $self->output_config->headers;
}

sub columns
{
    my $self = shift;

    my @headers = $self->output_config->headers;

    my $x = 0;
    map({
	Data::Tabular::Column->new(
	    offset => $x++,
	    name => $_,
	    output => $self->output, 
	    );
	} @headers);
}

sub title
{
    my $self = shift;
    my $column_name = shift;
    my $title = q|/|. $column_name . q|/|;

    if (my $output = $self->output_config) {
        $title = $output->title($column_name);
    }
    $title;
}

sub header_offset
{
    my $self = shift;
    my $column = shift;
    my $count = 0;
    unless ($self->{_header_off}) {
	for my $header ($self->headers) {
	    $self->{_header_off}->{$header} = $count++;
	} 
    }
    my $ret = $self->{_header_off}->{$column};
    croak "column '$column' not found in [",
          join(" ",
	      sort keys(%{$self->{_header_off}})
	  ), ']' unless defined $ret;
    $ret;
}

sub html
{
    my $self = shift;

    require Data::Tabular::Output::HTML;

    return Data::Tabular::Output::HTML->new(table => $self, @_);
}

sub xls
{
    my $self = shift;
    require Data::Tabular::Output::XLS;
    my $args = {
        row_offset => 0,
        column_offset => 0,
	table => $self,
	output => $self->output,
    };
    if (my $ref = ref($_[0])) {
        $args->{workbook} = shift;
        $args->{worksheet} = shift;
        $args->{row_offset} = shift;
        $args->{column_offset} = shift;
    } else {
        die ref($_[0]);
    }

    return Data::Tabular::Output::XLS->new(%$args);
}

sub xml
{
    my $self = shift;
    require Data::Tabular::Output::XML;

    return Data::Tabular::Output::XML->new(@_);
}

1;
__END__

=head1 NAME

Data::Tabular::Table;

=head1 SYNOPSIS

This object is used by Data::Tabular to hold a table.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=cut
