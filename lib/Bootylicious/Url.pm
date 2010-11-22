package Bootylicious::Url;

use strict;
use warnings;

use overload 'bool' => sub {1}, fallback => 1;
use overload '""' => sub { shift->to_string }, fallback => 1;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {@_};
    bless $self, $class;

    $self->{base} = '' unless defined $self->{base};
    $self->{url}  = '' unless defined $self->{url};

    return $self;
}

sub to_abs {
    my $self = shift;

    return $self->{base} . $self->{url};
}

sub to_string {
    my $self = shift;

    return $self->{url};
}

1;
