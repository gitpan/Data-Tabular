use strict;
package Data::Tabular::Row::Averages;

use base 'Data::Tabular::Row::Group';

use Carp qw(croak);

use overload '@{}' => \&array,
             '""'  => \&str;

sub new
{
    my $class = shift;

    my $inargs = { @_ };
    my $outargs = { };
    for my $arg  (qw( count text table sum_list extra )) {
        die "$arg is required." unless defined $inargs->{$arg};
	$outargs->{arg} = $inargs->{$arg};
	delete $inargs->{$arg};
    }
    die 'Unknown arguments: ' . join(', ', keys(%{$inargs})) if keys(%{$inargs});

    my $self = $class->SUPER::new(@_);


    die unless $self->table;

    $self;
}

sub str
{
    my $self = shift;
    'Row::Averages';
}

sub _headers
{
    my $self = shift;

    ('_description', @{$self->{sum_list} || []}, @{$self->{extra}->{headers} || []});
}

sub colspan
{
    my $self = shift;
    my $col = shift;

    if ($col eq '_description') {
        1;
    } else {
	1;
    }
}

sub cells
{
    my $self = shift;
    my @ret = ();
    my @headers = $self->headers;
    my $offset = 0;
    my $hash;
    for my $x ( @{$self->{extra}->{headers} || []} ) {
        $hash->{$x} = { type => 'extra' };
    }
    for my $x ( @{$self->{sum_list} || []} ) {
        $hash->{$x} = { type => 'sum' };
    }

    my $start = 0;
    for ($start = 0; $start <= $#headers; $start++) {
        my $column_name = $headers[$start];
	last unless $hash->{$column_name};
    }
    my $colspan = 1;
    for (my $col = $start + 1; $col <= $#headers; $col++) {
        my $column_name = $headers[$col];
	last if $hash->{$column_name};
        $colspan++;
	if ($colspan > 1) {
	    delete $headers[$col];
	}
    }

    $headers[$start] = '_description';
    $hash->{'_description'} = {
       span => $colspan,
    };

    my $colspan = 1;
    my $x = 0;
    for (my $col = 0; $col <= $#headers; $col += $colspan || 1) {
        my $column_name = $headers[$col];
	$colspan = $hash->{$column_name}->{span};
        push(@ret, 
	    Data::Tabular::Cell->new(
		row => $self,
		cell => $column_name,
		colspan => $colspan,
		id => $x,
		hdr => 1,
		align => 'right',
	    ),
	); 
	$x += $colspan || 1;
    }
    @ret;
}

sub hdr {
    1;
}

sub sum_list
{
    my $self = shift;
    $self->{sum_list};
}

sub get_column
{
    my $self = shift;
    my $column_name = shift;
    my $ret;
    my $reg = qr|^$column_name$|;

    if ($column_name eq '_description') {
        $ret = $self->{text};
    } elsif (grep(m|$reg|, @{$self->sum_list})) {
	$ret = 0;
	my $count = 0;
	for my $row ($self->table->raw_rows) {
	   $ret += $row->get($column_name);
	   $count++;
	}
	$ret /= $count;
	$ret = sprintf('%3.2f', $ret);
    } elsif (grep(m|$reg|, @{$self->{extra}->{headers} || []})) {

       #$ret = join(':', keys %{$self}). ' -> '. $self->{table}->group->get_column($column_name);
       $ret = $self->extra_column($self, $column_name);

    } else {
        $ret = 'N/A';
    }
    $ret;
}

sub count
{
    my $self = shift;

    $self->{count};
}

sub extra_package
{
    require Data::Tabular::Extra;
    'Data::Tabular::Extra';
}

sub extra_column
{
    my $self = shift;
    my $row = shift;
    my $key = shift;

    my $extra = $self->{extra}->{columns};

    my $ret = undef;

    my $x = $self->extra_package->new(row => $row, table => $self);

    if (ref($extra->{$key}) eq 'CODE') {
        eval {
            $ret = $extra->{$key}->($x);
        };
        if ($@) {
            die $@;
        }
    } else {
        die 'only know how to deal with code';
    }
    
    $ret;
}

sub attributes
{
    my $self = shift;
    $self->[0];
}

sub data
{
    my $self = shift;
die;
    wantarray ? @{$self->[1]} : $self->[1];
}

sub id
{
    my $self = shift;
    $self->{row_id} || 'No ID available';
}

sub cell_html_attributes
{
    my $self = shift;
    my $cell = shift;
    {
        align => ($cell->name() eq '_description' ? 'left' : 'right'),
    };
}

sub xls_align
{
    my $self = shift;
    my $cell = shift;
    $cell->name() eq '_description' ? 'left' : 'right';
}

sub type {
    'averages';
}

1;
__END__

