Machine.add("launchpadevent.ck");
Machine.add("launchpad.ck");
Machine.add("midisender.ck");
if(me.args() > 0) {
    Machine.add("arp_run:" + me.arg(0) + ".ck");
} else {
    Machine.add("arp_run.ck");
}
