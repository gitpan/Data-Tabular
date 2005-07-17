use strict;
package Data::Tabular::Config::Output;

sub new
{
    my $caller = shift;
    my $class = ref($caller) || $caller;

    my $self = bless { @_ }, $class;
    $self->{caller} = join(':', caller) ;

    $self->{xls} ||= {};
    $self->{html} ||= {};

    die 'No column list' unless $self->column_list;
    $self;
}

sub column_list
{
    my $self = shift;
    wantarray ? @{$self->{headers}} : $self->{headers};
}

sub title
{
    my $self = shift;
    my $column_name = shift;
    $self->{columns}->{$column_name}->{title} || $column_name;
}

sub html_column_attributes
{
    my $self = shift;
    my $column_name = shift;
    my $ret = {
	%{$self->{columns}->{$column_name}->{html_attributes} || {}},
    };
    $ret->{align} = 'right';
    if (my $width = $self->{columns}->{$column_name}->{width}) {
        die if defined $ret->{width};
	$ret->{width} = $width;
    }
    return $ret;
}

sub xls_width
{
    my $self = shift;
    my $column_name = shift;
    $self->{columns}->{$column_name}->{xls}->{width} || $self->{xls}->{width} || 10;
}

sub xls_title_format
{
    my $self = shift;
    my $column_name = shift;

    $self->{columns}->{$column_name}->{xls}->{title_format};
}

sub align
{
    my $self = shift;
    my $column_name = shift;
    $self->{columns}->{$column_name}->{align};
}

sub headers
{
    my $self = shift;

    @{$self->{headers}};
}

sub html_attribute_string
{
    my $self = shift;
    my $attributes = {
        border => 1,
	empty => '<br>',
    };
    my $na = $self->{html}->{attributes};
    for my $attribute (sort keys %$na) {
	$attributes->{$attribute} = $na->{$attribute};
    }

    my $ret = '';
    for my $attribute (sort keys %$attributes) {
        next unless $attributes->{$attribute};
	if ($attributes->{$attribute} =~ m|^\d*$|) {
	    $ret .= qq| $attribute=| . $attributes->{$attribute} . qq||;
	} else {
	    $ret .= qq| $attribute="| . $attributes->{$attribute} . qq|"|;
	}
    }

    $ret;
}

sub test_xls_attribute
{
    my $self = shift;
    my $attribute = shift;
    return $self->{xls}->{$attribute};
}

1;
__END__

This parses and stores the output infomation.


