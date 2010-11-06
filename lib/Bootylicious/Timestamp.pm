package Bootylicious::Timestamp;

use strict;
use warnings;

use base 'Mojo::Base';

require Time::Local;
require Time::Piece;

__PACKAGE__->attr('epoch');

my $TIMESTAMP_RE = qr/(\d\d\d\d)(\d?\d)(\d?\d)(?:T(\d\d):?(\d\d):?(\d\d))?/;
my @DAYS         = qw/Sun Mon Tue Wed Thu Fri Sat/;
my @MONTHS       = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;

sub new {
    my $self   = shift->SUPER::new;
    my %params = @_;

    if (exists $params{epoch}) {
        $self->epoch($params{epoch});
    }
    else {
        my $epoch = $self->_to_epoch($params{timestamp});
        $self->epoch($epoch);
    }

    return $self;
}

sub _to_epoch {
    my $self      = shift;
    my $timestamp = shift;

    return unless $timestamp =~ qr/^$TIMESTAMP_RE$/;

    my ($year, $month, $day, $hour, $minute, $second) =
      ($1, $2, $3, ($4 || 0), ($5 || 0), ($6 || 0));

    my $epoch = 0;
    eval {
        $epoch =
          Time::Local::timegm($second, $minute, $hour, $day, $month - 1,
            $year - 1900);
    };

    return if $@ || $epoch < 0;

    return $epoch;
}

sub year {
    my $self = shift;

    return Time::Piece->gmtime($self->epoch)->year;
}

sub month {
    my $self = shift;

    return Time::Piece->gmtime($self->epoch)->mon;
}

sub timestamp {
    my $self = shift;

    my $t = Time::Piece->gmtime($self->epoch);

    return $t->strftime('%Y%m%dT%H:%M:%S');
}

sub strftime {
    my $self = shift;
    my $fmt  = shift;

    my $t = Time::Piece->gmtime($self->epoch);

    return $t->strftime($fmt);
}

sub is_timestamp {
    my $self      = shift;
    my $timestamp = shift;

    return $timestamp =~ qr/^$TIMESTAMP_RE$/ ? 1 : 0;
}

sub to_string {
    my $self = shift;

    my ($second, $minute, $hour, $mday, $month, $year, $wday) =
      gmtime $self->epoch;

    return sprintf(
        "%s, %02d %s %04d %02d:%02d:%02d GMT",
        $DAYS[$wday], $mday, $MONTHS[$month], $year + 1900,
        $hour, $minute, $second
    );
}

1;
