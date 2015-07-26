# NAME

MooX::Role::Parameterized - roles with composition parameters

# SYNOPSYS
```perl
    package My::Role;

    use Moo::Role;
    use MooX::Role::Parameterized;

    role {
        my $params = shift;

        has $params->{attr} => ( is => 'rw' );

        method $params->{method} => sub {
            1024;
        };
    };

    package My::Class;

    use Moo;
    use My::Role;

    My::Role->apply({ 
        attr => 'baz',   # add attribute read-write called 'baz' 
        method => 'run'  # add method called 'run' and return 1024 
    });

    with 'My::Role';
```
# DESCRIPTION

It is a very **experimental** version of [MooseX::Role::Parameterized](https://metacpan.org/pod/MooseX::Role::Parameterized).

# FUNCTIONS

This package exports three subroutines `apply`, `role` and `method`.

## apply

When called, will apply the ["role"](#role) on the current package. The behavior depends of the parameter list.

## role

This function accepts one code block. Will execute this code then we apply the Role in the 
target class, and will receive the parameter list.

## method

Add one method based on the parameter list, for example.

# TODO

I don't know yet how to substute this three statements in just one:
```perl
    use My::Role;

    My::Role->apply({ 
        attr => 'baz',   # add attribute read-write called 'baz' 
        method => 'run'  # add method called 'run' and return 1024 
    });

    with 'My::Role';
```
I am open to ideas. I try to play with the `import` but the final result was ugly...

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
