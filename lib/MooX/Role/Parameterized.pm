package MooX::Role::Parameterized;

use strict;
use warnings;

# ABSTRACT: MooX::Role::Parameterized - roles with composition parameters

use Module::Runtime qw(use_module);
use Carp            qw(carp croak);
use Exporter        qw(import);

use MooX::Role::Parameterized::Proxy;

our $VERSION = "0.200";

our @EXPORT = qw(role apply apply_roles_to_target);

our $VERBOSE = 0;

my %code_for;

sub apply {
    carp "apply method is deprecated, please use 'apply_roles_to_target'"
      if $VERBOSE;

    goto &apply_roles_to_target;
}

sub apply_roles_to_target {
    my ( $role, $args, %extra ) = @_;

    return if !exists $code_for{$role};

    $args = [$args] if ref($args) ne ref( [] );

    my $target = defined( $extra{target} ) ? $extra{target} : caller;

    {
        no strict 'refs';
        no warnings 'redefine';

        *{ $role . '::hasp' } = sub {
            croak 'hasp deprecated, use $mop->has instead.';
        };
        *{ $role . '::method' } = sub {
            croak 'method deprecated, use $mop->method instead.';
        };
    }

    my $p = MooX::Role::Parameterized::Proxy->new(
        target => $target,
        role   => $role
    );

    $code_for{$role}->( $_, $p ) foreach ( @{$args} );

    Moo::Role->apply_roles_to_package( $target, $role );
}

sub role(&) {    ##no critic (Subroutines::ProhibitSubroutinePrototypes)
    my $package = (caller)[0];

    $code_for{$package} = shift;
}

sub build_apply_roles_to_package {
    my ( $klass, $orig ) = @_;

    return sub {
        my $target = caller;

        while (@_) {
            my $role = shift;

            eval { use_module($role) };

            if ( $role->can("apply_roles_to_target") ) {
                my $params = ( @_ && ref $_[0] eq 'HASH' ) ? shift : {};

                $role->apply_roles_to_target( $params, target => $target );

                next;
            }

            if ( defined $orig && ref $orig eq 'CODE' ) {
                $orig->($role);
            }

            if ( Moo::Role->is_role($role) ) {
                Moo::Role->apply_roles_to_package( $target, $role );
                eval {
                    Moo::Role->_maybe_reset_handlemoose($target);    ##no critic(Subroutines::ProtectPrivateSubs)
                };

                next;
            }

            croak "Can't apply role to '${target}' - '${role}' is neither a "
              . "MooX::Role::Parameterized, Moo::Role or Role::Tiny role";
        }
    };
}

1;
__END__

=head1 NAME

MooX::Role::Parameterized - roles with composition parameters

=head1 SYNOPSIS

    package My::Role;

    use Moo::Role;
    use MooX::Role::Parameterized;

    role {
        my ($params, $mop) = @_;

        $mop->has( $params->{attr} => ( is => 'rw' ));

        $mop->method($params->{method} => sub {
            1024;
        });
    };

    package My::Class;

    use Moo;

    use MooX::Role::Parameterized::With;

    with 'My::Role' => {
        attr   => 'baz',
        method => 'run'
    };

    package My::OldClass;

    use Moo;
    use My::Role;

    My::Role->apply_roles_to_target([{ # original way of add this role
        attr   => 'baz',               # add attribute read-write called 'baz' 
        method => 'run'                # add method called 'run' and return 1024 
    }
     ,                                 # and if the apply receives one arrayref
    {   attr   => 'bam',               # will call the role block multiple times.
        method => 'jump'               # PLEASE CALL apply once
    }]);      

=head1 DESCRIPTION

It is an B<experimental> port of L<MooseX::Role::Parameterized> to L<Moo>.

=head1 FUNCTIONS

This package exports the following subroutines: C<role>, C<apply_roles_to_target> and C<apply>.

=head2 role

This function accepts just B<one> code block. Will execute this code then we apply the Role in the 
target class, and will receive the parameter list + one B<mop> object.

The B<mop> object is a proxy to the target class. It offer a better way to call C<has>, C<requires> or C<after> without side effects. 

Please do

  my ($p, $mop) = @_;
  ...
  $mop->has($p->{attribute} =>(...));


=head2 apply

Alias to C<apply_roles_to_target>

=head2 apply_roles_to_target

When called, will apply the C</role> on the current package. The behavior depends of the parameter list.

This will install the role in the target package. Does not need call C<with>.

Important, if you want to apply the role multiple times, like to create multiple attributes, please pass an B<arrayref>.

=head1 DEPRECATED FUNCTIONS

=head2 hasp

Removed

=head2 method

Removed

=head1 VARIABLES

=head2 MooX::Role::Parameterized::VERBOSE

By setting C<$MooX::Role::Parameterized::VERBOSE> with some true value we will carp on certain conditions 
(method override, unable to load package, etc).

Default is false.

=head1 MooX::Role::Parameterized::With

See L<MooX::Role::Parameterized::With> package to easily load and apply roles.

=head1 SEE ALSO

L<MooseX::Role::Parameterized> - Moose version

=head1 THANKS

=over

=item *

FGA <fabrice.gabolde@gmail.com>

=item *

PERLANCAR <perlancar@gmail.com>

=item *

CHOROBA <choroba@cpan.org>

=item *

Ed J <mohawk2@users.noreply.github.com>

=back

=head1 LICENSE

The MIT License
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to
 whom the Software is furnished to do so, subject to the
 following conditions:
  
  The above copyright notice and this permission notice shall
  be included in all copies or substantial portions of the
  Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
   WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR
   PURPOSE AND NONINFRINGEMENT. IN NO EVENT
   SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR
   OTHER DEALINGS IN THE SOFTWARE.

=head1 AUTHOR

Tiago Peczenyj <tiago (dot) peczenyj (at) gmail (dot) com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
