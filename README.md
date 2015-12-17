# NAME

MooX::Role::Parameterized - roles with composition parameters

# SYNOPSYS
```perl
    package My::Role;

    use Moo::Role;
    use MooX::Role::Parameterized;

    role {
        my $params = shift;

        hasp $params->{attr} => ( is => 'rw' );

        method $params->{method} => sub {
            1024;
        };
    };

    package My::Class;

    use Moo;
    # experimental way of add roles
    use MooX::Role::Parameterized::With My::Role => {
        attr => 'baz',
        method => 'run'
    };

    package My::OldClass;

    use Moo;
    use My::Role;

    My::Role->apply({    # original way of add this role
        attr => 'baz',   # add attribute read-write called 'baz' 
        method => 'run'  # add method called 'run' and return 1024 
    });
```
# DESCRIPTION

It is an **experimental** port of [MooseX::Role::Parameterized](https://metacpan.org/pod/MooseX::Role::Parameterized) to [Moo](https://metacpan.org/pod/Moo).

# FUNCTIONS

This package exports four subroutines: `hasp`, `apply`, `role` and `method`.

## hasp

IMPORTANT: until the version 0.06 we have a terrible bug when you try to add the same role in two or more different classes.
To avoid this we should not call the `has` method to specify attributes but the method `hasp` (means 'has parameterized').


## apply

When called, will apply the ["role"](#role) on the current package. The behavior depends of the parameter list.

This will install the role in the target package. Does not need call `with`.

## role

This function accepts one code block. Will execute this code then we apply the Role in the 
target class, and will receive the parameter list.

## method

Add one method based on the parameter list, for example.

# MooX::Role::Parameterized::With

See [MooX::Role::Parameterized::With](https://metacpan.org/pod/MooX::Role::Parameterized::With) package to easily load and apply roles.

# SEE ALSO

[MooseX::Role::Parameterized](https://metacpan.org/pod/MooseX::Role::Parameterized) - Moose version

# LICENSE
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

# AUTHOR

Tiago Peczenyj <tiago (dot) peczenyj (at) gmail (dot) com>

# BUGS

Please report any bugs or feature requests on the bugtracker website
