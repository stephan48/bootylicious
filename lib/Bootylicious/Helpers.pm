package Bootylicious::Helpers;

use strict;
use warnings;

use Encode;
use Digest::MD5 'md5_hex';

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub config { shift->{config} }

sub article_author {
    my $self = shift;
    my $article = shift;

    return $article->author || $self->config->author;
}

sub comment_author {
    my $self = shift;
    my $comment = shift;

    return $comment->author;
}

sub date {
    my $self = shift;
    my $date = shift;
    my $fmt  = shift;

    return '' unless $date;

    $fmt ||= $self->config->{'datefmt'};

    return Encode::decode_utf8($date->strftime($fmt));
}

sub tags_links {
    my $self    = shift;
    my $article = shift;

    my @links = map { $self->link_to_tag($_) } @{$article->tags};

    my $string = '';
    $string .= join ', ' => @links;

    return $string;
}

sub meta {
    my $self = shift;

    my $string = '';

    my $meta_from_config = $self->config->{meta};
    $meta_from_config = [$meta_from_config]
      unless ref $meta_from_config eq 'ARRAY';

    foreach my $meta (@$meta_from_config) {
        $string .= $self->tag('meta' => %$meta);
    }

    return $string;
}

sub menu {
    my $self = shift;

    my @links;

    my $menu = $self->config->{menu};

    for (my $i = 0; $i < @$menu; $i += 2) {
        my $title = $menu->[$i];
        my $href  = $menu->[$i + 1];

        push @links, $self->tag('a', href => $href, sub {$title});
    }

    return join ' ' => @links;
}

sub generator {
    my $self = shift;

    return qq/Bootylicious $Bootylicious::VERSION/;
}

sub gravatar {
    my $self  = shift;
    my $email = shift;

    my %attrs = (
        class  => 'gravatar',
        width  => 40,
        height => 40
    );

    return $self->tag(
        'img',
        src =>
          'http://www.gravatar.com/avatar/00000000000000000000000000000000?s=40',
        %attrs
    ) unless $email;

    $email = lc $email;
    $email =~ s/^\s+//;
    $email =~ s/\s+$//;

    my $hash = md5_hex($email);

    my $url = "http://www.gravatar.com/avatar/$hash?s=40";

    return $self->tag(
        'img',
        src => $url,
        %attrs,
        @_
    );
}

sub tag {
    my $self = shift;
    my $name = shift;

    my $value = ref $_[-1] eq 'CODE' ? pop : undef;

    my %attrs = @_;

    my $attrs = '';
    while (my ($key, $value) = each %attrs) {
        $attrs .= qq/ $key="$value"/;
    }

    return "<$name$attrs"
      . (defined $value ? ">" . $value->() . "</$name>" : " />");
}

1;
