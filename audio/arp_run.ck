48 => int midilower;
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
        (lp.e.column + (lp.e.row*8)) => int noteindex;
        Std.mtof(noteindex - 1 + midilower) => float notefreq;
        
        // What?
        if(lp.e.velocity == 127) {
            <<< "noteon:", noteindex, notefreq >>>;
            now => times[noteindex];
            sendtovis(noteindex, 0);
        } else {
            <<< "noteoff:", noteindex, notefreq >>>;
            if(times[noteindex] != timezero) {
                now - times[noteindex] => dur duration;
                sendtovis(noteindex, duration/1::ms);
                timezero => times[noteindex];
            }
        }


    }
}




Launchpad.Launchpad(1) @=> Launchpad lp;
spork ~ echo(lp);
while(true) {
    100::ms => now;
}


