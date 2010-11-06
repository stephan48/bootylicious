package Bootylicious;

use strict;
use warnings;

our $VERSION = '1.000000';

use Bootylicious::Article;
use Bootylicious::ArticleArchive;
use Bootylicious::ArticleArchiveSimple;
use Bootylicious::ArticleByQueryIterator;
use Bootylicious::ArticleByTagIterator;
use Bootylicious::ArticleIteratorFinder;
use Bootylicious::ArticleIteratorLoader;
use Bootylicious::ArticlePager;
use Bootylicious::CommentIteratorLoader;
use Bootylicious::Draft;
use Bootylicious::DraftIteratorFinder;
use Bootylicious::DraftIteratorLoader;
use Bootylicious::IteratorSearchable;
use Bootylicious::Page;
use Bootylicious::PageIteratorFinder;
use Bootylicious::PageIteratorLoader;
use Bootylicious::TagCloud;

use Bootylicious::Config;
use Bootylicious::Helpers;
use Bootylicious::Renderer;
use Bootylicious::Url;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {@_};
    bless $self, $class;

    my $config = Bootylicious::Config->new(%{delete $self->{config}});
    $self->{config} = $config;

    $self->{helpers}
      ||= Bootylicious::Helpers->new(config => $self->{config});

    $self->{url} ||= Bootylicious::Url->new;

    $self->{renderer} ||= Bootylicious::Renderer->new(
        config  => $self->{config},
        parsers => $self->{parsers}
    );

    return $self;
}

sub root   { shift->{root} }
sub config   { shift->{config} }
sub helpers  { shift->{helpers} }
sub url      { shift->{url} }
sub renderer { shift->{renderer} }

sub articles_root { File::Spec->catfile(shift->root, 'articles') }
sub drafts_root   { File::Spec->catfile(shift->root, 'drafts') }
sub pages_root    { File::Spec->catfile(shift->root, 'pages') }

sub pagelimit { shift->config->{pagelimit} }

sub get_pager {
    my $self     = shift;
    my $iterator = shift;

    Bootylicious::ArticlePager->new(
        limit    => $self->pagelimit,
        iterator => $iterator,
        @_
    );
}

sub get_articles {
    my $self = shift;

    Bootylicious::ArticlePager->new(
        iterator => Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load,
        limit => $self->pagelimit,
        @_
    );
}

sub get_recent_articles {
    my ($self, $limit) = @_;

    return Bootylicious::ArticleIteratorLoader->new(
        root => $self->articles_root)->load->next($limit || 5);
}

sub get_recent_comments {
    my ($self, $limit) = @_;

    Bootylicious::CommentIteratorLoader->new(root => $self->articles_root)
      ->load->reverse->next($limit || 5);
}

sub get_archive {
    my $self = shift;

    Bootylicious::ArticleArchive->new(
        articles => Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load,
        @_
    );
}

sub get_archive_simple {
    my $self = shift;

    Bootylicious::ArticleArchiveSimple->new(
        articles => Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load
    );
}

sub get_articles_by_tag {
    my $self = shift;
    my $tag  = shift;

    Bootylicious::ArticlePager->new(
        iterator => Bootylicious::ArticleByTagIterator->new(
            Bootylicious::ArticleIteratorLoader->new(
                root => $self->articles_root
              )->load,
            tag => $tag
        ),
        limit => $self->pagelimit,
        @_
    );
}

sub get_articles_by_query {
    my $self  = shift;
    my $query = shift;

    return Bootylicious::ArticleByQueryIterator->new(
        Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load,
        query => $query
    );
}

sub get_tag_cloud {
    my $self = shift;

    Bootylicious::TagCloud->new(
        articles => Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load
    );
}

sub get_tags {
    my $self = shift;

    Bootylicious::TagCloud->new(
        articles => Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load
    );
}

sub get_article {
    my $self = shift;

    Bootylicious::ArticleIteratorFinder->new(
        iterator => Bootylicious::ArticleIteratorLoader->new(
            root => $self->articles_root
          )->load
    )->find(@_);
}

sub get_page {
    my $self = shift;
    my $name = shift;

    Bootylicious::PageIteratorFinder->new(iterator =>
          Bootylicious::PageIteratorLoader->new(root => $self->pages_root)
          ->load)->find($name);
}

sub get_draft {
    my $self = shift;
    my $name = shift;

    Bootylicious::DraftIteratorFinder->new(iterator =>
          Bootylicious::DraftIteratorLoader->new(root => $self->drafts_root)
          ->load)->find($name);
}

sub _default_config {
    {   author      => 'whoami',
        email       => '',
        title       => 'Just another blog',
        about       => 'Perl hacker',
        description => 'I do not know if I need this',

        cuttag    => '[cut]',
        cuttext   => 'Keep reading',
        pagelimit => 10,
        datefmt   => '%a, %d %b %Y',

        menu => [
            index   => '/',
            tags    => '/tags.html',
            archive => '/articles.html'
        ],
        footer =>
          'Powered by <a href="http://getbootylicious.org">Bootylicious</a>',
        theme => '',

        comments_enabled => 1,

        meta => [],
        css  => [],
        js   => [],

        strings => {
            'archive'             => 'Archive',
            'archive-description' => 'Articles index',
            'tags'                => 'Tags',
            'tags-description'    => 'Tags overview',
            'tag'                 => 'Tag',
            'tag-description'     => 'Articles with tag [_1]',
            'draft'               => 'Draft',
            'permalink-to'        => 'Permalink to',
            'later'               => 'Later',
            'earlier'             => 'Earlier',
            'not-found' => 'The page you are looking for was not found',
            'error'     => 'Internal error occuried :('
        },

        perl5lib => '',
        loglevel => 'error',

        articles_directory  => 'articles',
        pages_directory     => 'pages',
        drafts_directory    => 'drafts',
        public_directory    => 'public',
        templates_directory => 'templates',
    };
}

1;
