package Bootylicious::UrlBuilder;

use strict;
use warnings;

use Bootylicious::Url;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {@_};
    bless $self, $class;

    $self->{base}   = '' unless defined $self->{base};
    $self->{prefix} = '' unless defined $self->{prefix};

    return $self;
}

sub base   { @_ > 1 ? $_[0]->{base}   = $_[1] : $_[0]->{base} }
sub prefix { @_ > 1 ? $_[0]->{prefix} = $_[1] : $_[0]->{prefix} }

sub build {
    my $self  = shift;
    my @parts = @_;

    my $url = $self->prefix . '/' . join '/' => @parts;

    return Bootylicious::Url->new(base => $self->base, url => $url);
}

sub home {
    my $self = shift;

    return $self->build;
}

sub article {
    my $self    = shift;
    my $article = shift;

    my $created = $article->created;
    return $self->build('articles', $created->year, $created->month,
        $article->name);
}

sub article_more {
    my $self    = shift;
    my $article = shift;

    return $self->build($self->article($article) . '#cut');
}

sub articles {
    my $self = shift;

    return $self->build;
}

sub articles_rss {
    my $self = shift;

    return $self->build('index.rss')->to_abs;
}

sub tags {
    my $self = shift;

    return $self->build('tags');
}

sub tag {
    my $self = shift;
    my $tag  = shift;

    return $self->build('tags', $tag->name);
}

sub archive {
    my $self = shift;

    return $self->build('articles');
}

sub comment {
    my $self    = shift;
    my $comment = shift;

    return $self->build('articles', $comment->article->created->year,
        $comment->article->created->month,
        $comment->article->name . '#' . $comment->number);
}

sub comments {
    my $self    = shift;
    my $article = shift;

    my $created = $article->created;
    return $self->build('articles', $created->year, $created->month,
        $article->name . '#comments');
}

sub comments_rss {
    my $self = shift;

    return $self->build('comments.rss')->to_abs;
}

1;
