use Test::Modern -author;

BEGIN {
    eval { require Test::Compile };
    if ($@) { plan 'skip_all' => 'Test::Compile not found' }
    else    { import Test::Compile }
}

all_pm_files_ok();
