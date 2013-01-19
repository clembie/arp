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
1 => int SEND_MIDI;
MIDIsender sender;
MIDIsender vissender;
if(SEND_MIDI) {
    sender.set_channel(1);
    sender.open(2);
    vissender.set_channel(2);
    vissender.open(2);
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
                duration/1::ms => float fdur;
                if(fdur > 5000) { 5000.0 => fdur; }
                fdur/5000.0 => float normdur;
                sendtovis(noteindex, normdur);
                if(SEND_MIDI) {
                    sender.noteoff(noteindex + 1 + midilower);
                }
                <<< "noteoff:", noteindex, notefreq , normdur >>>;
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

fun void vismidinote(int n, int v) {    
    vissender.noteon(n, v);
    300::ms => now;
    vissender.noteoff(n);
    100::ms => now;
    me.yield();
}


fun void vislistener(OscEvent @ oe, MIDIsender sender) {
    while(true) {
        oe => now;

        while(oe.nextMsg() != 0) {
            oe.getInt() => int note;
            oe.getFloat() => float velocity;
            (velocity * 127.0) $ int => int midivel;
            spork ~ vismidinote(note, midivel);
            me.yield();
        }
    }
}


Launchpad lp;
if(me.args() > 0) {
    Launchpad.Launchpad(Std.atoi(me.arg(0))) @=> lp;
} else {
    Launchpad.Launchpad(1) @=> lp;
}

spork ~ echo(lp);
while(true) {
    1000::ms => now;

    // test
    //spork ~ vismidinote(64, 80);
    //me.yield();
}
