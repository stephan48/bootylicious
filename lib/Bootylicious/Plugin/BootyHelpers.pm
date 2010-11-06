package Bootylicious::Plugin::BootyHelpers;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream 'b';

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    my $booty = $conf->{booty};

    $app->helper(
        link_to_article => sub {
            my $self    = shift;
            my $article = shift;

            my $href = $self->booty->url->article($article);

            my $cb = ref $_[-1] eq 'CODE' ? pop : undef;

            if ($article->link) {
                my $string = '';

                $string
                  .= $self->link_to($href => $cb || sub { $article->title });
                $string .= '&nbsp;';
                $string .= $self->link_to($article->link => sub {"&raquo;"});

                return Mojo::ByteStream->new($string);
            }

            return $self->link_to($href => $cb || sub { $article->title });
        }
    );
    $app->helper(
        link_to_full_content => sub {
            my $self = shift;
            my ($article, $preview_link) = @_;

            my $href = $self->booty->url->article($article);
            $href->fragment('cut');

            return $self->link_to($href => sub {$preview_link});
        }
    );
    $app->helper(
        link_to_tag => sub {
            my $self = shift;
            my $tag  = shift;

            my $name = ref $tag ? $tag->name : $tag;

            my $cb = ref $_[-1] eq 'CODE' ? $_[-1] : sub {$name};
            my $args = ref $_[0] eq 'HASH' ? $_[0] : {};

            return $self->link_to(
                tag => {tag => $name, format => 'html', %$args} => $cb);
        }
    );
    $app->helper(
        tags_links => sub {
            my $self    = shift;
            my $article = shift;

            my @links = map { $self->link_to_tag($_) } @{$article->tags};

            my $string = '';
            $string .= join ', ' => @links;

            return Mojo::ByteStream->new($string);
        }
    );
    $app->helper(
        link_to_page => sub {
            my $self = shift;
            my $name = shift;

            my %args = ref $_[0] eq 'HASH' ? %{shift @_} : ();

            my $timestamp = shift;

            my $query = delete $args{query} || {};

            if ($timestamp) {
                return $self->link_to(
                    $self->url_for($name, %args, format => 'html')
                      ->query(timestamp => $timestamp, %$query) => @_);
            }
            else {
                return $self->tag('span' => @_);
            }
        }
    );
    $app->helper(
        link_to_author => sub {
            my $self   = shift;
            my $author = shift;

            return $author || $self->config('author');
        }
    );

    $app->helper(
        permalink_to => sub {
            my $self = shift;
            my $link = shift;

            return $self->link_to($link => sub {'&#x2605;'});
        }
    );

    $app->helper(
        link_to_rss => sub {
            my $self = shift;

            return $self->link_to($self->href_to_rss => @_);
        }
    );

    $app->helper(
        link_to_comments_rss => sub {
            my $self = shift;

            return $self->link_to($self->href_to_comments_rss => @_);
        }
    );

    $app->helper(
        link_to_home => sub {
            my $self = shift;

            return $self->link_to(
                'root' => {format => undef},
                title  => $self->booty->config->title,
                rel => 'home' => sub { $self->booty->config->title }
            );
        }
    );

    $app->helper(
        link_to_bootylicious => sub {
            my $self = shift;

            return $self->link_to('http://getbootylicious.org' => title =>
                  'Powered by Bootylicious!' => sub {'Bootylicious'});
        }
    );

    $app->helper(
        powered_by => sub {
            my $self = shift;

            return $self->link_to('http://getbootylicious.org' =>
                  sub {'Powered by Bootylicious'});

        }
    );

    $app->helper(
        link_to_archive => sub {
            my $self = shift;
            my ($year, $month) = @_;

            my @months = (
                qw/January February March April May July June August September October November December/
            );
            my $title = $months[$month - 1] . ' ' . $year;
            return $self->link_to(
                'articles',
                {   year  => $year,
                    month => $month
                } => sub {$title}
            );
        }
    );

    $app->helper(
        link_to_comment => sub {
            my $self    = shift;
            my $comment = shift;

            return $self->link_to($self->href_to_comment($comment) =>
                  sub { $comment->article->title });
        }
    );

    $app->helper(
        link_to_comments => sub {
            my $self    = shift;
            my $article = shift;

            my $href = $self->booty->url->article($article);

            return $self->link_to( $href => sub {'No comments'})
              unless $article->comments->size;

            return $self->link_to($href =>
                  sub { 'Comments (' . $article->comments->size . ') '; });
        }
    );
}

1;
