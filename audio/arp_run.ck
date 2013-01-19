

fun void echo(Launchpad @ lp) {
    while(true) {
        lp.e => now;
        lp.setGridLight(lp.e);
    }
}

Launchpad.Launchpad(1) @=> Launchpad lp;
spork ~ echo(lp);
while(true) {
    100::ms => now;
}


