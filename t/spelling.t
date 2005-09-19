use Test::More;

eval 'use Test::Spelling 0.10'; plan( skip_all => 'Test::Spelling 0.10 required for this test' ) if $@;

add_stopwords(<DATA>);
all_pod_files_spelling_ok();
__DATA__
API
HTML
html
txt
xls
xml
csv
