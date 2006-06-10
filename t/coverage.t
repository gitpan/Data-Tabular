use Test::More;

eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;

plan tests => 7;
pod_coverage_ok("Data::Tabular");
pod_coverage_ok("Data::Tabular::Extra");
pod_coverage_ok("Data::Tabular::Group::Interface");
pod_coverage_ok("Data::Tabular::Output::HTML");
pod_coverage_ok("Data::Tabular::Output::XLS");
pod_coverage_ok("Data::Tabular::Output::TXT");
pod_coverage_ok("Data::Tabular::Table");
