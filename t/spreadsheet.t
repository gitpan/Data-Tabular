use strict;

use Test::More tests => 2;

use_ok( 'Data::Tabular' );

use Digest::MD5  qw(md5 md5_hex md5_base64);

my $t1 = Data::Tabular->new(
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
    extra => {
        extra1 => sub { 'H' },
        extra2 => sub { 'I' },
    },
    group_by => {
	groups => [
	    {
		pre => sub { my $self = shift; ($self->header(text => "First"), $self->titles() ) },
		post => sub { my $self = shift; ($self->totals(sum_list => ['jan', 'feb']), $self->header(text => "Last")); },
	    },
	],
    },
);

use Data::Dumper;

my $xls;

SKIP: {
    my $skip;
    eval { require Spreadsheet::WriteExcel; };
    $skip++ if $@;
    skip 'Need Spreadsheet::WriteExcel', 1 if $skip;
    my $workbook = Spreadsheet::WriteExcel->new("/tmp/test2.xls");
    my $worksheet = $workbook->add_worksheet();

    $t1->xls(workbook => $workbook, worksheet => $worksheet);

    ok(1);
}

