import oscP5.*;
import netP5.*;

static final int FRAME_RATE = 30;
static final int NOTE_DOWN = 0;
static final int NOTE_DECAY = 1;
static final int NOTE_DEAD = 2;

// inbound OSC messages (from ChucK)
OscP5 oscP5;

// 192 168 1 113 : 9000
// outbound OSC receiver (to Chuck)
NetAddress outbound;

ArrayList notes;

void setup() {
  size(800, 600);
  frameRate(FRAME_RATE);
  smooth();
  background(0);

  notes = new ArrayList();

  oscP5 = new OscP5(this, 12000);
  oscP5.plug(this, "note", "/note");

  outbound = new NetAddress("192.168.1.113", 12001);
}

void draw() {
  background(0);
  updateNotes();
  bringOutYourDead();
}

// update all the living notes
void updateNotes() {
  for(int i = notes.size() - 1; i >=0; i--) {
    Note note = (Note)notes.get(i);
    note.update();
  }
}

// remove all the dead notes
void bringOutYourDead() {
  for(int i = notes.size() - 1; i >=0; i--) {
    Note note = (Note)notes.get(i);
    if(note.isDead()) {
      notes.remove(i);
    }
  }
}

void oscEvent(OscMessage m) {
  if(!m.isPlugged()){
    println("unknown message received at " + m.addrPattern() + " with type " + m.typetag());
  }
}

void sendNote(int i, float vel) {
  OscMessage m = new OscMessage("/visynth");
  m.add(i);
  m.add(vel);
  oscP5.send(m, outbound);
}

public void note(int noteIndex, float vel) {
  println("note " + noteIndex + " " + vel);
  if(vel == 0) {
    notes.add(new Note(noteIndex));
  } else {
    for(int i = notes.size() - 1; i >= 0; i--) {
      Note note = (Note)notes.get(i);
      note.release(vel);
    }
  }
}
