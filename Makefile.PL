
package Data::Tabular;

use ExtUtils::MakeMaker;

WriteMakefile(
    'DISTNAME'          => 'Data-Tabular',
    'NAME'              => __PACKAGE__,
    'VERSION_FROM'      => 'Tabular.pm',
    'ABSTRACT_FROM'     => 'Tabular.pm',
    'AUTHOR'            => '"G. Allen Morris III" <gam3@gam3.net>',
    'PMLIBDIRS' => [
        'Tabular',
    ],
#    'PM' => {
#        'Tabular.pm' => '$(INST_LIBDIR)/Tabular.pm',
#        'Group.pm' => '$(INST_LIBDIR)/Tabular/Group.pm',
#        'Row.pm' => '$(INST_LIBDIR)/Tabular/Row.pm',
#        'Extra.pm' => '$(INST_LIBDIR)/Tabular/Extra.pm',
#        'Output.pm' => '$(INST_LIBDIR)/Tabular/Output.pm',
#        'HTML.pm' => '$(INST_LIBDIR)/Tabular/HTML/Table.pm',
#        'Type.pm' => '$(INST_LIBDIR)/Type.pm',
#    },
);
