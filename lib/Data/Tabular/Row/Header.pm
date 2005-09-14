use strict;
package Data::Tabular::Row::Header;

use base 'Data::Tabular::Row::Group';

use Carp qw(croak);

use overload '@{}' => \&array,
             '""'  => \&str;

sub str
{
    my $self = shift;
    __PACKAGE__;
}

sub headers
{
    my $self = shift;
    qw ( _header );
}

sub colspan
{
    my $self = shift;
    my $header = shift;
    die 'unknown column ' . $header unless $header eq '_header';

    scalar($self->output_headers);
}

sub table
{
    my $self = shift;
    $self->{table};
}

sub get_column
{
    my $self = shift;
    my $column_name = shift;
    die 'unknown column ' . $column_name unless $column_name eq '_header';
    $self->{text};
}

sub hdr
{
    my $self = shift;
    defined $self->{header} ? $self->{header} : 1;
}

sub cell_html_attributes
{
    my $self = shift;
    my $cell = shift;
    {
        align => 'left',
    };
}

1;
__END__

