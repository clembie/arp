24 => int midilower;
time times[64];

time timezero;

// Jordan's Visuals
"192.168.1.151" => string hostname;
12000 => int port;
OscSend xmit;
xmit.setHost(hostname, port);

// OSC Receive
OscRecv recv;
12001 => recv.port;
recv.listen();
recv.event("/visynth", "if") @=> OscEvent oe;

// MIDI Out
0 => int SEND_MIDI;
MIDIsender sender;
if(SEND_MIDI) {
    sender.open(2);
}

fun void sendtovis(int index, float charge) {
    xmit.startMsg("/note", "if");
    xmit.addInt(index);
    xmit.addFloat(charge);
}

fun void echo(Launchpad @ lp) {
    while(true) {
        lp.e => now;
        lp.setGridLight(lp.e);
        
        //<<< lp.e.column, lp.e.row, lp.e.velocity >>>;

        // Who?
        if(lp.e.column > 7 || lp.e.row > 7) { continue; }
        (lp.e.column + (lp.e.row*8)) => int noteindex;
        Std.mtof(noteindex - 1 + midilower) => float notefreq;
        
        // What?
        if(lp.e.velocity == 127) {
            <<< "noteon:", noteindex, notefreq >>>;
            now => times[noteindex];
            sendtovis(noteindex, 0);
            if(SEND_MIDI) {
                sender.noteon(noteindex + 1 + midilower, 100);
            }
        } else {
            if(times[noteindex] != timezero) {
                now - times[noteindex] => dur duration;
                sendtovis(noteindex, duration/1::ms);
                if(SEND_MIDI) {
                    sender.noteoff(noteindex + 1 + midilower);
                }
                <<< "noteoff:", noteindex, notefreq , duration/1::ms >>>;
                timezero => times[noteindex];
            } else {
                <<< "detected a rip in the spacetime continuum..." >>>;
                if(SEND_MIDI) {
                    sender.stop_hanging_notes(-1);
                }
            }
        }


    }
}

Launchpad lp;
if(me.args() > 0) {
    <<< "HAZ AN ARG" >>>;
    Launchpad.Launchpad(Std.atoi(me.arg(0))) @=> lp;
} else {
    <<< "FUCK FUCK FUCK" >>>;
    Launchpad.Launchpad(1) @=> lp;
}

spork ~ echo(lp);
while(true) {
    100::ms => now;
}
