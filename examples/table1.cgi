#!/usr/bin/perl
use strict;

use CGI;

use lib '../blib/lib/';

use Data::Tabular;

print "content-type: text/html\n\n";

our ($t1, $t2);

print "<html>\n<head></head>\n<body>\n";
eval {
    $t1 = Data::Tabular->new(
	headers => [ 'cnt', 'animal', 'color', 'owner', 'jan', 'feb', 'amount', 'date' ],
	data => [
	    [ 1, 'cat', 'black', 'jane', 1, 2, 1.01, 'jan 1 2002' ],
	    [ 1, 'cat', 'black', 'joey', 2, 3, 1.01, 'jan 1 2002' ],
	    [ 1, 'cat', 'white', 'jack', 3, 4, 1.01, 'jan 1 2002' ],
	    [ 1, 'cat', 'white', 'john', 4, 5, 1.01, 'mar 2 2002' ],
	    [ 1, 'bat', 'gray',  'john', 4, 5, -99999.99999999, 'mar 4 2003' ],
	    [ 1, 'dog', 'white', 'john', 5, 6, 1.01, 'mar 4 2003' ],
	    [ 1, 'dog', 'white', 'joey', 6, 7, 1.01, 'mar 4 2003' ],
	    [ 1, 'dog', 'black', 'jack', 7, 8, 1.01, 'mar 4 2003' ],
	    [ 1, 'dog', 'black', 'jane', 8, 90900, 100007.01, 'mar 4 2003' ],
	    [ 1, 'rabbit', 'black', 'jane', 8, 9, 1.01, 'mar 4 2003' ],
	],
	_extra_headers => [ qw ( extra1 extra2 extra3 extra4) ],
	_extra => {
	    extra1 => sub { 'extra column 1' },
	    extra2 => sub { 'extra column 2' },
	    extra3 => sub { 1 },
	    extra4 => sub { 2 },
	},
	_group_by => {
	    sum_list => ['cnt', 'jan', 'feb', 'extra3', 'amount', 'extra4'],
	    groups => [
		{
		    pre => sub { my $self = shift; $self->titles(); },
		    post => sub { my $self = shift; $self->header(text => "This is a footer 1"), $self->sum(title => 'Grand Total');},
		},
		{
		    column => 'animal',
		    pre => sub { my $self = shift; use Data::Dumper; $self->header(text => "This is a header animal (" . $self->get('animal') . ")"); },
		    post => sub { my $self = shift; $self->sum(title => 'sum animal (' . $self->get('animal') . ")");},
		},
		{
		    column => 'color',
		    pre => sub { my $self = shift; use Data::Dumper; $self->header(text => "This is a header color (" . $self->get('color') . ")"); },
		    post => sub { my $self = shift; $self->header(text => "This is a footer color (" . $self->get('color') . ")"); },
		},
	    ],
	},
	output => {
	   title => 1,
	},
    );
};
if ($@) {
    die($@);
}

print "hello";
eval {
    print $t1->html();
};
if ($@) {
    print '<pre>'. $@ . '</pre>';
}
eval {
    $t2 = Data::Tabular->new(
	headers => [ 'cnt', 'animal', 'color', 'owner', 'jan', 'feb', 'amount', 'date' ],
	data => [
	    [ 1, 'cat', 'black', 'jane', 1, 2, 1.01, 'jan 1 2002' ],
	    [ 1, 'cat', 'black', 'joey', 2, 3, 1.01, 'jan 1 2002' ],
	    [ 1, 'cat', 'white', 'jack', 3, 4, 1.01, 'jan 1 2002' ],
	    [ 1, 'cat', 'white', 'john', 4, 5, 1.01, 'mar 2 2002' ],
	    [ 1, 'bat', 'gray',  'john', 4, 5, -99999.99999999, 'mar 4 2003' ],
	    [ 1, 'dog', 'white', 'john', 5, 6, 1.01, 'mar 4 2003' ],
	    [ 1, 'dog', 'white', 'joey', 6, 7, 1.01, 'mar 4 2003' ],
	    [ 1, 'dog', 'black', 'jack', 7, 8, 1.01, 'mar 4 2003' ],
	    [ 1, 'dog', 'black', 'jane', 8, 90900, 100007.01, 'mar 4 2003' ],
	    [ 1, 'rabbit', 'black', 'jane', 8, 9, 1.01, 'mar 4 2003' ],
	],
	extra_headers => [ qw ( extra1 extra2 extra3 extra4) ],
	extra => {
	    extra1 => sub { 'extra column 1' },
	    extra2 => sub { 'extra column 2' },
	    extra3 => sub { 1 },
	    extra4 => sub { 2 },
	},
	group_by => {
	    sum_list => ['cnt', 'jan', 'feb', 'extra3', 'amount', 'extra4'],
	    groups => [
		{
		    pre => sub { my $self = shift; $self->titles(); },
		    post => sub { my $self = shift; $self->header(text => "This is a footer 1"), $self->sum(title => 'Grand Total');},
		},
		{
		    column => 'animal',
		    pre => sub { my $self = shift; use Data::Dumper; $self->header(text => "This is a header animal (" . $self->get('animal') . ")"); },
		    post => sub { my $self = shift; $self->sum(title => 'sum animal (' . $self->get('animal') . ")");},
		},
		{
		    column => 'color',
		    pre => sub { my $self = shift; use Data::Dumper; $self->header(text => "This is a header color (" . $self->get('color') . ")"); },
		    post => sub { my $self = shift; $self->header(text => "This is a footer color (" . $self->get('color') . ")"); },
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

print "hello";
eval {
    print $t2->html();
};
if ($@) {
    print '<pre>'. $@ . '</pre>';
}
print "</body>\n";

