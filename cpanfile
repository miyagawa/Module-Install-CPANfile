requires 'Module::Install';
requires 'Module::CPANfile', '0.9005';

on develop => sub {
    requires 'CPAN::Meta::Check'; # can't bootstrap this but a warning will be given
};
