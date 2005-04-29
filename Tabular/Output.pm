use strict;

package Data::Tabular::Output;

use Carp qw (croak);

sub new
{
    my $caller = shift;
    my $class = ref($caller) || $caller;

    my $self = bless { @_ }, $class;

    $self;
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
