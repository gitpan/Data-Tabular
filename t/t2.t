
use strict;
use Test;

BEGIN { plan tests => 2, todo => [] }

use Data::Tabular;

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
		       output => {
			   headers  => [ 'owner', 'jan', 'feb', 'amount', 'date' ],
			   columns => {
			       owner => {
				   title => "Color",
                                   align => 'left',
                                   type => 'text',
			       },
			       jan => {
				   title => "January",
                                   align => 'right',
                                   type => 'number',
			       },
			       feb => {
				   title => "February",
                                   align => 'right',
                                   type => 'number',
			       },
			       amount => {
				   title => "Amount",
                                   align => 'right',
                                   type => 'dollar',
			       },
			       date => {
				   title => "Amount",
                                   align => 'right',
                                   type => 'date',
			       },
			   },
		       },
		       group_by => {
		          columns => ['animal', 'color'],
		       },
);

use Spreadsheet::WriteExcel;
eval {
    {
	package Test::WriteExcel;

	use base 'Spreadsheet::WriteExcel';

	sub new
	{
	    my $class = shift;
	    my $output = shift;
	    die "Usage: ". __PACKAGE__. "->new(SCALAR)" if @_;
	    {
		package ApacheX;
		sub TIEHANDLE
		{
		    my $class = shift;
		    my $data = shift;
		    die 'Bad usage' if @_;
		    bless $data, $class;
		}
		sub PRINT
		{
		    my $self = shift;
		    $$self .= join('', @_);
		}
	    }
	    tie *XLS, 'ApacheX', $output;

	    my $self = $class->SUPER::new(\*XLS);
	    $self->{_____ouput} = $output;
	    $self;
	}
    }
};
if ($@) { die "$@"; }

my $ok = 1;
my $data;

if ($@) {
    printf('xxx: %s', $@);
    my $ok = 0; # true
}

my $skip = !$ok;

if ($ok) {
    my $wb = Test::WriteExcel->new(\$data);
    my $ws = $wb->addworksheet('Test_1');
    $ws->write(0, 0, 'Test Report');
    $t1->xls($wb, $ws, 0, 1);
    $ws->write(0, 1, '(done)');
    $wb->close;
}

my $digest = md5_base64($data);
skip($skip, $digest, '6ErEu0BYhD8jG1YAeTigtg', 'Incorrect data returned from Spreadsheet::WriteExcel');

if ($ok) {
    my $wb = Test::WriteExcel->new(\$data);
    my $ws = $wb->addworksheet('Test_1');
    $ws->write(0, 0, 'Test Report');
    $t1->xls($wb, $ws, 0, 1);
    $ws->write(0, 1, '(done)');
    $wb->close;
}

if ($ok) {
    my $wb =  Spreadsheet::WriteExcel->new('./test.xls');
    my $ws = $wb->addworksheet('Test_1');
    $ws->write(0, 0, 'Test Report');
    $t1->xls($wb, $ws, 0, 1);
    $ws->write(0, 1, '(done)');
    $wb->close;
}

my $digest = md5_base64($data);
skip($skip, $digest, '6ErEu0BYhD8jG1YAeTigtg', 'Incorrect data returned from Spreadsheet::WriteExcel');
