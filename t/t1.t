
use strict;
use Test;

use Data::Tabular;
use Data::Tabular::Group;
use Data::Type;

BEGIN { plan tests => 2 };

if (0) {
my $t1 = Data::Tabular->new(
       headers => [ 'animal', 'color', 'owner', 'jan', 'feb' ],
       output => {
	   headers => [ 'owner', 'animal', 'color', 'owner', 'jan', 'feb' ],
	   titles => {
	       'color'  => "Color",
	       'owner'  => "Owner",
	       'jan'    => "January",
	       'feb'    => "February",
	       'animal' => "Type of Animal",
	   },
       },
       data => [
	 [ 'cat', 'black', 'jane', 1, 2 ],
	 [ 'cat', 'black', 'joey', 2, 3 ],
	 [ 'cat', 'white', 'jack', 3, 4 ],
	 [ 'cat', 'white', 'john', 4, 5 ],
	 [ 'dog', 'white', 'john', 5, 6 ],
	 [ 'dog', 'white', 'joey', 6, 7 ],
	 [ 'dog', 'black', 'jack', 7, 8 ],
	 [ 'dog', 'black', 'jane', 8, 9 ],
       ],
       group_by => 'Data::Tabular::Group'->new(
	   columns => [
	       ['animal', 
		   [ 'jan', 'feb', 'months' ],
		   sub {
		       my ($old, $new, $cnt) = @_;
		       map({ $old->[$_] + $new->[$_] } (0..$cnt-1))
		   },
	       ],
	       ['color', 
		   [ 'jan', 'feb', 'months' ],
		   sub {
		       my ($old, $new, $cnt) = @_;
		       map({ $old->[$_] + $new->[$_] } (0..$cnt-1))
		   }
	       ],
	   ],
	   operate => [
	       [ 'jan', 'feb', 'months' ],
	       sub {
		   my ($old, $new, $cnt) = @_;
		   map({ $old->[$_] + $new->[$_]; } (0..$cnt-1))
	       },
	   ],
       ),
       extra_headers => [ 'months' ],
       extra => { 'months' => sub {
           my $self = shift; my $row = shift; $row->[-1] + $row->[-2];
	                          } 
       },
   );

print $t1->text();
}

my $t2 = Data::Tabular->new(
		       headers => [ 'animal', 'color', 'owner', 'jan', 'feb' ],
		       data => [
			 [ 'cat', 'black', 'jane', 1, 2 ],
			 [ 'cat', 'black', 'joey', 2, 3 ],
			 [ 'cat', 'white', 'jack', 3, 4 ],
			 [ 'cat', 'white', 'john', 4, 5 ],
			 [ 'bat', 'gray',  'john', 4, 5 ],
			 [ 'dog', 'white', 'john', 5, 6 ],
			 [ 'dog', 'white', 'joey', 6, 7 ],
			 [ 'dog', 'black', 'jack', 7, 8 ],
			 [ 'dog', 'black', 'jane', 8, 9 ],
			 [ 'rabbit', 'black', 'jane', 8, 9 ],
		       ],
		       output => {
			   headers  => [ 'owner', 'jan', 'feb' ],
			   columns => {
			       owner => {
				   title => "Color",
			       },
			       jan => {
				   title => "January",
			       },
			       feb => {
				   title => "February",
			       },
			   },
		       },
		       group_by => {
		          columns => ['animal', 'color'],
		       },
);

ok(1);

use Data::Tabular::Group;

{
package XXXX;
sub attributes { { } };
}

    my $t2 = Data::Tabular->new(
                       headers => [ 'animal', 'color', 'owner', 'xtr', 'jan', 'feb', 'mar' ],
                       data => [
                         [ 'cat', 'black', 'jane', 'xax', 1, 2, 3 ],
                         [ 'cat', 'black', 'joey',  undef, 2, 3 ],
                         [ 'cat', 'white', 'jack', 0, 3, 4 ],
                         [ 'cat', 'white', 'john', 'xxx', 4, 5 ],
                         [ 'bat', 'gray',  'john', 'xxx', 4, 5 ],
                         [ 'bat', 'gray',  'allen', 'xxx', 4, 5 ],
                         [ 'bat', 'gray',  'ann', 'xxx', 4, 5 ],
                         [ 'bat', 'gray',  'bill', 'xxx', 4, 5 ],
                         [ 'dog', 'white', 'john', 'xxx', 5, 6 ],
                         [ 'dog', 'white', 'joey', bless({}, 'XXXX'), 6, 7 ],
                         [ 'dog', 'black', 'jack', 'xxx', 7, 8 ],
                         [ 'dog', 'black', 'jane', 'xjx', 8, 9 ],
                         [ 'rabbit', 'black', 'jane', 'zxyx', 8, 9 ],
                       ],
                       output => {
#                           headers  => [ 'owner', 'xtr', 'jan', 'feb', 'mar', 'total', 'average' ],
			   title => 0,
			   totals => sub {
			      my $self = shift;
			      (
			        $self->blank(),
			        $self->totals(title => 'Grand Total'),
			      );
			   },
			   empty => '<b>--</b>',
                           columns => {
                               owner => {
                                   title => "Owner",
                               },
                               color => {
                                   title => "Color",
                               },
                               extra => {
                                   title => "info",
                                   width => 10,
                               },
                               jan => {
                                   title => "January",
                                   align => 'right',
                               },
                               feb => {
                                   title => "February",
                                   align => 'right',
                               },
                               total => {
                                   title => "Total",
                                   align => 'right',
                               },
                           },
                       },
		       extra_headers => [ 'total', 'average' ],
		       extra => {
		           'total' => sub {
			       my $self = shift;
			       my $row = shift;
			       ($row->[$self->header_offset('jan')]
			         + $row->[$self->header_offset('feb')]
			         + $row->[$self->header_offset('mar')]
			       ) / 1;
		           },
		           'average' => sub {
			       my $self = shift;
			       my $row = shift;
			       ($row->[$self->header_offset('jan')]
			         + $row->[$self->header_offset('feb')]
			         + $row->[$self->header_offset('mar')]
			       ) / 3;
		           },
		       },
                       group_by => {
                          columns => ['animal', 'color'],
			  sum => [ 'jan', 'feb', 'mar' ],
                          sub_title => sub {
			      my $self = shift;
			      (
			      $self->titles(),
			      $self->sub_title(title => $_->{color} . ' '. $_->{animal} . 's', ),
			      );
			  },
                          sub_total => sub {
			      my $self = shift;
			      (
			        $self->sum(title => 'Sub-totals'),
			        $self->avg(title => 'Averages ('. $self->count() . ')'),
			        $self->totals(title => 'Running Total'),
			      );
			  },
                       },
    );

ok(1);
