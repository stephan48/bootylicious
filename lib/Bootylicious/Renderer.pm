package Bootylicious::Renderer;

use strict;
use warnings;

use Pod::Simple::HTML;
use Bootylicious::UrlBuilder;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {@_};
    bless $self, $class;

    $self->{parsers} ||= {
        pod => sub {
            my $pod = shift;

            my $parser = Pod::Simple::HTML->new;
            $parser->force_title('');
            $parser->html_header_before_title('');
            $parser->html_header_after_title('');
            $parser->html_footer('');

            my $output;
            $parser->output_string(\$output);
            eval { $parser->parse_string_document("=pod\n\n$pod") };
            return $@ if $@;

            $output
              =~ s/<a name='___top' class='dummyTopAnchor'\s*?><\/a>\n//g;
            $output =~ s/<a class='u'.*?name=".*?"\s*>(.*?)<\/a>/$1/sg;

            return $output;
          }
    };

    return $self;
}

sub config  { shift->{config} }
sub parsers { shift->{parsers} }

sub formats { keys %{shift->parsers} }

sub render_preview {
    my $self    = shift;
    my $article = shift;

    my $parser = $self->parsers->{$article->format};
    $parser ||= sub { $_[0] };

    my $cuttag = quotemeta $self->config->{cuttag};

    my $content = $article->content;

    my ($preview, $preview_link);
    if ($content =~ s{^(.*?)\n$cuttag(?: (.*?))?(?:\n|\r|\n\r)}{}s) {
        $preview      = $1;
        $preview_link = $2 || $self->config->{cuttext};
        $content      = $3;
    }

    if ($preview) {
        my $output = $parser->($preview);

        my $url = Bootylicious::UrlBuilder->new;
        $url = $url->article_more($article);

        $output .= qq{<a href="$url" class="more">$preview_link</a>};

        return $output;
    }
    return $parser->($preview) . $self->tag(
        div => class => 'more' => sub {
            '&rarr; ' . $self->link_to_full_content($article, $preview_link);
        }
    ) if $preview;

    return $parser->($content);
}

sub render_content {
    my $self    = shift;
    my $article = shift;

    my $parser = $self->parsers->{$article->format};
    $parser ||= sub { $_[0] };

    my $cuttag = quotemeta $self->config->{cuttag};

    my $head = $article->content;
    my $tail = '';
    if ($head =~ s{(.*?)\n$cuttag.*?\n(.*)}{$1}s) {
        $tail = $2;
    }

    my $cuttag_anchor = '<a name="cut"></a>';

    my $string;
    $string = $parser->($head);
    $string .= $cuttag_anchor . $parser->($tail) if $tail;

    return $string;
}

1;
