package Bootylicious::Plugin::BootyConfig;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojolicious::Controller;

sub register {
    my ($self, $app, $conf) = @_;

    my $c = Mojolicious::Controller->new(app => $app);

    $conf ||= {};

    my $booty = delete $conf->{booty};

    $app->helper(booty => sub {$booty});

    $app->log->level('error');

    # Default plugins
    $app->plugin('charset' => {charset => 'utf-8'});
    $app->plugin('pod_renderer');
    $app->plugin('tag_helpers');
    $app->plugin(
        validator => {
            messages => {
                REQUIRED                => 'Required',
                EMAIL_CONSTRAINT_FAILED => "Doesn't look like an email to me",
                URL_CONSTRAINT_FAILED   => "Doesn't look like an url to me"
            }
        }
    );
    $app->plugin('bot_protection');

    $app->secret($conf->{secret});

    # Set appropriate log level
    $app->log->level($conf->{loglevel} || 'debug');

    # Additional Perl modules
    $self->_setup_inc($conf->{perl5lib});

    # CGI hack
    $ENV{SCRIPT_NAME} = $conf->{base} if defined $conf->{base};

    # Don't use set locale unless it is explicitly specified via a config file
    $ENV{LC_ALL} = 'C';

    # set proper templates base dir, if defined
    $app->renderer->root($app->home->rel_dir($conf->{templates_directory}))
      if defined $conf->{templates_directory};

    # set proper public base dir, if defined
    $app->static->root($app->home->rel_dir($conf->{public_directory}))
      if defined $conf->{public_directory};

    $app->defaults(
        booty       => $booty,
        title       => '',
        description => '',
        layout      => 'wrapper'
    );

    $app->plugin('booty_helpers');

    if (my $theme = $conf->{theme}) {
        my $theme_class = join '::' => 'Bootylicious::Theme',
          Mojo::ByteStream->new($theme)->camelize;

        $app->renderer->default_template_class($theme_class);
        $app->static->default_static_class($theme_class);

        $app->plugin($theme_class);
    }

    # Load additional plugins
    $self->_load_plugins($app, $conf->{plugins});
}

sub _setup_inc {
    my $self     = shift;
    my $perl5lib = shift;

    return unless $perl5lib;

    push @INC, $_ for (ref $perl5lib eq 'ARRAY' ? @{$perl5lib} : $perl5lib);
}

sub _load_plugins {
    my $self = shift;
    my ($app, $plugins_arrayref) = @_;

    return unless $plugins_arrayref;
    $plugins_arrayref = [$plugins_arrayref]
      unless ref $plugins_arrayref eq 'ARRAY';

    my @plugins;

    my $prev;
    while (my $plugin = shift @{$plugins_arrayref}) {
        if (ref($plugin) eq 'HASH') {
            next unless $plugins[-1];

            $plugins[-1]->{args} = $plugin;
        }
        else {
            push @plugins, {name => $plugin, args => {}};
        }
    }

    foreach my $plugin (@plugins) {
        $app->log->debug('Loading plugin ' . $plugin->{name});
        $app->plugin($plugin->{name} => $plugin->{args});
    }
}

1;
