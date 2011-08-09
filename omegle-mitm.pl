#!/usr/bin/perl

# omegle-spy.pl by dshaw -- FreeBSD license
############################################
# July 28, 2011 -- early morning hours
# curiosity got the best of me, but human
# interaction, especially "strangers," is
# too interesting to pass up.
############################################

use warnings;
use strict;

use New::Omegle;

logmsg("------------------- ".`date`."\n");

my $om = New::Omegle->new(
    on_chat       => \&chat_cb,
    on_type       => \&type_cb,
    on_stoptype   => \&stoptype_cb,
    on_disconnect => \&disconnect_cb,
    on_connect    => \&connect_cb
);

my $om2 =  New::Omegle->new(
    on_chat       => \&chat_cb2,
    on_type       => \&type_cb2,
    on_stoptype   => \&stoptype_cb2,
    on_disconnect => \&disconnect_cb2,
    on_connect    => \&connect_cb2
);

$om->start();
$om2->start();

while (1) {
    $om->go();
    $om2->go();

    sleep 1
}

sub logmsg {
	open my $fh, '>>', 'LOGFILE' or die "error opening file: $!";
	print $fh "@_\n";
	close $fh or die "can't close file: $!";
}

# connect callback:
# called when the stranger connects
sub connect_cb {
    my $om = shift;
    print "Connected to $$om{id}.\n"
}

# chat callback:
# called when the stranger chats with you
sub chat_cb {
    my ($om, $message) = @_;
    print "$$om{id} says: $message\n";
    $om2->say($message); 
    logmsg("$$om{id} says: ".$message);
}

# type callback:
# called when the stranger begins to type
sub type_cb {
    my $om = shift;
    print "$$om{id} is typing...\n";
    $om2->type();
}

# stoptype callback:
# called when the stranger stops typing
sub stoptype_cb {
    my $om = shift;
    print "$$om{id} has stopped typing.\n";
    $om2->stoptype();
}

# disconnect callback:
# called when the stranger disconnects
sub disconnect_cb {
    my $om = shift;
    print "$$om{id} has disconnected.\n";
    logmsg("------------------- ".`date`."\n");
    die
}

#############
#############
#############

sub connect_cb2 {
    my $om2 = shift;
    print "Connected to $$om2{id}.\n"
}

# chat callback:
# called when the stranger chats with you
sub chat_cb2 {
    my ($om2, $message) = @_;
    print "$$om2{id} says: $message\n";
    $om->say($message);
    logmsg("$$om2{id} says: ".$message);
}

# type callback:
# called when the stranger begins to type
sub type_cb2 {
    my $om = shift;
    print "$$om2{id} is typing...\n";
    $om->type();
}

# stoptype callback:
# called when the stranger stops typing
sub stoptype_cb2 {
    my $om2 = shift;
    print "$$om2{id} has stopped typing.\n";
    $om->stoptype();
}

# disconnect callback:
# called when the stranger disconnects
sub disconnect_cb2 {
    my $om2 = shift;
    print "$$om2{id} has disconnected.\n";
    logmsg("------------------- ".`date`."\n");
    die
}

