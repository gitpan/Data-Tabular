
use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Data::Tabular',
     license => 'perl',
     requires => {
                  'perl'           => '5.6.0',
                 },
    );
$build->create_build_script;
