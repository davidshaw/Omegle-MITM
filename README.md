#Omegle-MITM
## An Omegle Proxy

This is a simple perl script using the open source [New::Omegle](https://github.com/cooper/new-omegle/) perl module to connect and relay messages from two strangers on the anonymous chat site Omegle.

By connecting to two people and relaying their actions and messages, omegle-mitm.pl allows you to watch ongoing conversations in real-time. Sometimes it can be gross, sometimes it can be hilarious, but most of the time it is a mildly entertaining social experiment. Very fun to watch people who think no one is listening!

Usage is really simple, just: `perl omegle-mitm.pl`. I like to run in an infinite bash loop and `^c` when I am finished listening, which can easily be accomplished with the command `while true; do perl omegle-mitm.pl ; sleep 5; done`.

Conversations are automatically appended to a file called LOGFILE. I will add in an option to disable this at some point in the future!
