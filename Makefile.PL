use lib 'lib'; # bootstrap
use inc::Module::Install;
all_from 'lib/Module/Install/CPANfile.pm';
readme_from('lib/Module/Install/CPANfile.pm');
build_requires 'Test::More', 0.88;
test_requires 'Test::Requires';
auto_set_repository();
auto_provides;
cpanfile;
WriteAll;
