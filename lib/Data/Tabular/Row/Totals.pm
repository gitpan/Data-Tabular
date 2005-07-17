use strict;
package Data::Tabular::Row::Totals;

use base 'Data::Tabular::Row';

use Carp qw(croak carp);

use overload '@{}' => \&array,
             '""'  => \&str;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    die unless $self->table;

    $self;
}

sub str
{
    my $self = shift;
    'Row::Total';
}

sub _headers
{
    my $self = shift;
die;
    ('_description', @{$self->{sum_list} || []}, @{$self->{extra}->{headers} || []});
}

sub cells
{
    my $self = shift;
    my @ret = ();
    my @headers = $self->headers;
    my $offset = 0;
    my $hash;
    for my $x ( @{$self->{extra}->{headers} || []} ) {
        $hash->{$x} = { extra => 1 };
    }
    for my $x ( @{$self->{sum_list} || []} ) {
        $hash->{$x} = { sum => 1 };
    }

    my $start = 0;
    for ($start = 0; $start <= $#headers; $start++) {
        my $column_name = $headers[$start];
	last unless $hash->{$column_name}->{sum};
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
	$colspan = $hash->{$column_name}->{span} || 1;
        push(@ret, 
	    Data::Tabular::Cell->new(
		row => $self,
		cell => $column_name,
		colspan => $colspan, 
		id => $x,
	    ),
	); 
	$x += $colspan;
    }
    @ret;
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
	$ret = $self->table->sum($column_name);
    } elsif (grep(m|$reg|, @{$self->{extra}->{headers} || []})) {
       $ret = $self->extra_column($self, $column_name);
    } else {
        $ret = 'N/A';
        $ret = join(' ', caller(3)) . ' ' . $column_name;
    }
    $ret;
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

sub hdr
{
    1;
}

sub data
{
    my $self = shift;
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

1;
__END__

