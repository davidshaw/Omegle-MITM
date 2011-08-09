#!/usr/bin/perl
# Copyright (c) 2011, Mitchell Cooper
package New::Omegle;

use warnings;
use strict;
use feature 'switch';

use HTTP::Async;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;

our $VERSION    = '0.5';
my  @servers    = qw[bajor.omegle.com cardassia.omegle.com promenade.omegle.com quarks.omegle.com];
my  $lastserver = 2;

sub new {
    my ($class, %opts) = @_;
    bless my $om    = \%opts, $class;
    $om->{async}    = new HTTP::Async;
    $om->{ua}       = new LWP::UserAgent;
    $om->{json}     = new JSON;
    $om->{server}   = newserver() unless exists $om->{server};
    $om->{server}   = "http://$$om{server}";
    $om->{typing}   = 0;
    return $om
}

sub start {
    my $om = shift;
    my $res = $om->{ua}->post("$$om{server}/start");
    my $id = $res->content || '';
    $id =~ s/"//g;
    return undef unless $id;
    $om->{id} = $id;
    $om->request_next_event;
    return $id
}

sub newserver {
    if ($lastserver == $#servers) {
        $lastserver = 0;
        return $servers[0]
    }
    return $servers[++$lastserver]
}

sub request_next_event {
    my $om = shift;
    return unless $om->{id};
    $om->{async}->add(POST "$$om{server}/events", [ id => $om->{id} ])
}

sub get_next_events {
    my $om = shift;
    my @f = ();
    while (my $res = $om->{async}->next_response) {
        push @f, $res
    }
    return @f
}

sub handle_events {
    my ($om, $json) = @_;
    return unless $json =~ m/^\[/;
    my $events = $om->{json}->decode($json);

    foreach my $event (@$events) {
        $om->handle_event(@$event);
    }
}

sub callback {
    my ($om, $callback) = (shift, shift);
    if (exists $om->{$callback}) {
        my $call = $om->{$callback};
        return $call->($om, @_)
    }
    return
}

sub handle_event {
    my ($om, @event) = @_;
    given ($event[0]) {
        when ('connected') {
            $om->callback('on_connect')
        }
        when ('gotMessage') {
            $om->callback('on_chat', $event[1]);
            $om->{typing} = 0
        }
        when ('strangerDisconnected') {
            $om->callback('on_disconnect');
            delete $om->{id}
        }
        when ('typing') {
            $om->callback('on_type') unless $om->{typing};
            $om->{typing} = 1
        }
        when ('stoppedTyping') {
            $om->callback('on_stoptype') if $om->{typing};
            $om->{typing} = 0
        }
    }
    return 1
}

# request and handle events: put this in your main loop
sub go {
    my $om = shift;
	foreach my $res ($om->get_next_events) {
	    next unless $res;
        $om->handle_events($res->content);
    }
    $om->request_next_event
}

# send a message
sub say {
    my ($om, $msg) = @_;
    return unless $om->{id};
    $om->{async}->add(POST "$$om{server}/send", [ id => $om->{id}, msg => $msg ])
}

# make it appear that you are typing
sub type {
    my $om = shift;
    return unless $om->{id};
    $om->{async}->add(POST "$$om{server}/typing", [ id => $om->{id} ])
}

# make it appear that you have stopped typing
sub stoptype {
    my $om = shift;
    return unless $om->{id};
    $om->{async}->add(POST "$$om{server}/stoptyping", [ id => $om->{id} ])
}

# disconnect
sub disconnect {
    my $om = shift;
    return unless $om->{id};
    $om->{async}->add(POST "$$om{server}/disconnect", [ id => $om->{id} ])
}
