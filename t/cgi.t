#!/usr/bin/perl
use strict;

print "content-type: text/html\n\n";

use Data::Tabular;

our $t1;

use Test::More;

BEGIN { plan tests => 1 };

eval {
    $t1 = Data::Tabular->new(
	headers => [ 'animal', 'color', 'owner', 'jan', 'feb', 'amount', 'date' ],
	data => [
	    [ 'cat', 'black', 'jane', 1, 2, 1.01, 'jan 1 2002' ],
	    [ 'cat', 'black', 'joey', 2, 3, 1.01, 'jan 1 2002' ],
	    [ 'cat', 'white', 'jack', 3, 4, 1.01, 'jan 1 2002' ],
	    [ 'cat', 'white', 'john', 4, 5, 1.01, 'mar 2 2002' ],
	    [ 'bat', 'gray',  'john', 4, 5, -99999.99999999, 'mar 4 2003' ],
	    [ 'dog', 'white', 'john', 5, 6, 1.01, 'mar 4 2003' ],
	    [ 'dog', 'white', 'joey', 6, 7, 1.01, 'mar 4 2003' ],
	    [ 'dog', 'black', 'jack', 7, 8, 1.01, 'mar 4 2003' ],
	    [ 'dog', 'black', 'jane', 8, 90900, 100007.01, 'mar 4 2003' ],
	    [ 'rabbit', 'black', 'jane', 8, 9, 1.01, 'mar 4 2003' ],
	],
	extra_headers => [ qw ( extra1 extra2 extra3) ],
	extra => {
	    extra1 => sub { 'extra column 1' },
	    extra2 => sub { 'extra column 2' },
	    extra3 => sub { 1 },
	},
	group_by => {
	    sum_list => ['jan', 'feb', 'extra3', 'amount'],
	    groups => [
		{
		    pre => sub { my $self = shift; $self->titles(); },
		    post => sub { my $self = shift; $self->header(text => "This is a footer 1"); },
		},
		{
		    column => 'animal',
		    pre => sub { my $self = shift; $self->header(text => "This is a header 2"); },
		    post => sub { my $self = shift; $self->sum(title => 'sum title');},
		},
		{
		    column => 'color',
		    pre => sub { my $self = shift; $self->header(text => "This is a header 3"); },
		    post => sub { my $self = shift; $self->header(text => "This is a footer 3"); },
		},
	    ],
	},
	output => {
	},
    );
};
if ($@) {
    die($@);
}

$t1->html;

ok(1);
 
