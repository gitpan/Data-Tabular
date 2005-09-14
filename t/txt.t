use strict;

use Test::More tests => 1;

use Data::Tabular;

my $table;
$table = Data::Tabular->new(
    headers => ['one', 'two'],
    data    => [
         ['a', 'b'],
         ['c', 'd']
    ],
    extra_headers => [ 'three' ],
    extra => {
        'three' => sub {
	    my $self = shift;
	    $self->get('one') . $self->get('two');
        },
    },
    group_by => {
	groups => [
	    {
		pre => sub { my $self = shift; ($self->header(text => "First"), $self->titles() ) },
		post => sub { my $self = shift; $self->header(text => "Last"); },
	    },
	],
    },
    output => {
	headers => [ 'three', 'one', 'two' ],
	columns => {
	   three => {
	      title => "Three",
	   },
	   one => {
	      title => "One (1)",
	   },
	   two => {
	      title => "Two (2)",
	   },
	},
    },
);

our $new = $table->txt . '';
our $old = <<EOP;

First               
Three               One (1)             Two (2)             
ab                  a                   b                   
cd                  c                   d                   
Last                
EOP

ok($new eq $old);

