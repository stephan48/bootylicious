package Bootylicious::Url;

use strict;
use warnings;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {@_};
    bless $self, $class;

    $self->{base} = '/' unless defined $self->{base};

    return $self;
}

sub base { shift->{base} }

sub home { shift->base }

sub article {
    my $self = shift;
    my $article = shift;

    my $created = $article->created;
    return $self->base . join '/' => 'articles', $created->year, $created->month, $article->name;
}

sub article_more {
    my $self = shift;
    my $article = shift;

    return $self->article($article) . '#cut';
}

sub articles {
    my $self = shift;

    return $self->base;
}

sub articles_rss {
    my $self = shift;

    return $self->base . 'index.rss';
}

sub tags {
    my $self = shift;

    return $self->base . 'tags';
}

sub tag {
    my $self = shift;
    my $tag = shift;

    return $self->base . join '/' => 'tags', $tag->name;
}

sub archive {
    my $self = shift;

    return $self->base . 'articles';
}

sub comment {
    my $self = shift;
    my $comment = shift;

    return join '/' => $self->base,
      'articles', $comment->article->year, $comment->article->month,
      $comment->article->name . '#' . $comment->count;
}

sub comments {
    my $self = shift;
    my $article = shift;

    my $created = $article->created;
    return $self->base . join '/' => 'articles',
      $created->year, $created->month, $article->name . '#comments';
}

sub comments_rss {
    my $self = shift;

    return $self->base . '/comments.rss';
}

1;
