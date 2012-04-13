package Module::Install::CPANfile;

use strict;
use 5.008_001;
our $VERSION = '0.04';

use Module::CPANfile;
use base qw(Module::Install::Base);

sub cpanfile {
    my $self = shift;
    $self->include("Module::CPANfile");

    my $specs = Module::CPANfile->load->prereq_specs;

    while (my($phase, $requirements) = each %$specs) {
        while (my($type, $requirement) = each %$requirements) {
            if (my $command = $self->command_for($phase, $type)) {
                while (my($mod, $ver) = each %$requirement) {
                    $self->$command($mod, $self->_fix_version($ver));
                }
            }
        }
    }
}

sub _fix_version {
    my($self, $ver) = @_;

    return $ver unless $ver;

    $ver =~ /(?:^|>=?)\s*([\d\.\_]+)/
      and return $1;

    $ver;
}

sub command_for {
    my($self, $phase, $type) = @_;

    if ($type eq 'conflicts') {
        warn 'conflicts is not supported';
        return;
    }

    if ($phase eq 'develop') {
        if ($INC{"Module/Install/AuthorRequires.pm"}) {
            return 'author_requires';
        } elsif ($Module::Install::AUTHOR) {
            warn "develop phase is ignored unless Module::Install::AuthorRequires is installed.\n";
            return;
        } else {
            return;
        }
    }

    if ($type eq 'recommends' or $type eq 'suggests') {
        return 'recommends';
    }

    if ($phase eq 'runtime') {
        return 'requires';
    }

    return "${phase}_requires";
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Module::Install::CPANfile - Include cpanfile

=head1 SYNOPSIS

  # cpanfile
  requires 'Plack', 0.9;
  on test => sub {
      requires 'Test::Warn';
  };

  # Makefile.PL
  use Module::Install;
  cpanfile;

=head1 DESCRIPTION

Module::Install::CPANfile is a plugin for Module::Install to include
dependencies from L<cpanfile>.

Development requirement can only be checked if the developers has
installed L<Module::Install::AuthorRequires>.

=head1 WHY?

If you have read L<cpanfile> and L<cpanfile-faq> you might wonder why
this plugin is necessary, since I<cpanfile> is meant to be used by
Perl applications and not distributions.

Well, for a couple reasons.

=head2 Co-exist as a Github project and CPAN distribution

One particular use case is a script or web application that you
develop on github, and you start with writing dependencies in
I<cpanfile>. Other users or developers pull the code from git, use
L<carton> to bundle dependencies. So far, so good.

One day you decide to release the script or application to CPAN as a
CPAN distribtuion, and that means you have to duplicate I<cpanfile>
into I<Makefile.PL> or I<Build.PL>, and that's not DRY! This plugin
will allow you to have just one I<cpanfile> and reuse it from
I<Makefile.PL> for CPAN client use.

=head2 CPAN Meta Spec 2.0 support.

The other, kind of unfortunate reason is that as of this writing,
L<Module::Install> and L<ExtUtils::MakeMaker> don't have a complete
support for expressing L<CPAN::Meta::Spec> version 2.0
vocabularies.

There are many of known issues that the metadata you specify with
L<Module::Install> are somehow discarded or down converted, and
eventually lost in I<MYMETA> files. The examples of those issues are
that test dependencies gets merged with build dependencies, and that
I<recommends> is not saved into MYMETA files.

This plugin lets you write prerequisites in I<cpanfile> which is more
powerful and has a complete support for L<CPAN::Meta::Spec> 2.0 and
makes your application forward compatible.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 COPYRIGHT

Copyright 2012- Tatsuhiko Miyagawa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<cpanfile> L<Module::CPANfile> L<Module::Install>

=cut
