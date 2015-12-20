package MooX::Role::Parameterized::Proxy;
use strict;
use warnings;
use Carp qw(croak);

sub new {
	my ($klass, %args) = @_;

	return bless { target => $args{target}, role => $args{role} }, $klass;
}

sub has       {
	my $self = shift;
	goto &{$self->{target} . '::has'}; 
}

sub with      {
	my $self = shift;
	goto &{$self->{target} . '::with'}; 	
}
sub before    {
	my $self = shift;
	goto &{$self->{target} . '::before'}; 
}
sub around    {
	my $self = shift;
	goto &{$self->{target} . '::around'}; 

}
sub after     {
	my $self = shift;
	goto &{$self->{target} . '::after'}; 	
}
sub requires  {
	my ($self, $required_method) = @_;
	my $target = $self->{target};
	my $role   = $self->{role};
	croak "Can't apply $role to $target - missing $required_method" if ! $target->can( $required_method );
}
sub method    {
    my ($self, $name, $code) = @_;
    my $target = $self->{target};
    
    carp("method ${target}\:\:${name} already exists, overriding...") if $target->can($name);

    no strict 'refs';
    *{"${target}\:\:${name}"} = $code;
}

1;