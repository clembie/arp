import oscP5.*;
import netP5.*;

static final int FRAME_RATE = 30;
static final int NOTE_DOWN = 0;
static final int NOTE_DECAY = 1;
static final int NOTE_DEAD = 2;
static final int NOTE_COLLIDED = 3;

float gutter;
float cellWidth;

// inbound OSC messages (from ChucK)
OscP5 oscP5;

// 192 168 1 113 : 9000
// outbound OSC receiver (to Chuck)
NetAddress outbound;

ArrayList notes;

void setup() {
  gutter = (height - width) / 2.0;
  cellWidth = width / 8.0;
  translate(gutter, 0);

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
  collide();
  bringOutYourDead();
}

// update all the living notes
void updateNotes() {
  for(int i = notes.size() - 1; i >=0; i--) {
    Note note = (Note)notes.get(i);
    note.update();
  }
}

void collide() {
  for(int i = notes.size() - 1; i >= 0; i--) {
    for(int j = i-1; j >= 0; j--) {
      Note n1 = (Note)notes.get(i);
      Note n2 = (Note)notes.get(j);
      if(n1.collide(n2)) {
        PVector p = n1.collisionPoint(n2);
        notes.add(new Note(
              p.x,
              p.y,
              (n1.diameter + n2.diameter) / 2.0,
              (n1.maxDiameter + n2.maxDiameter) / 2.0,
              (n1.age + n2.age) / 2,
              (n1.maxAge + n2.maxAge) / 2
        ));
      }
    }
  }
}

// remove all the dead notes
void bringOutYourDead() {
  for(int i = notes.size() - 1; i >=0; i--) {
    Note note = (Note)notes.get(i);
    if(note.isDead()) {
      println("remove " + i);
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

int getNearestIndex(PVector p) {
  return floor(p.x / cellWidth) + 8 * floor(p.y / cellWidth);
}

PVector getOrigin(int i) {
  int col = i % 8;
  int row = i / 8;

  float x = col * cellWidth;
  x += 0.5 * cellWidth;

  float y = (8 - row) * cellWidth;
  y += 0.5 * cellWidth;
  return new PVector(x, y);
}

public void note(int noteIndex, float vel) {
  println("note " + noteIndex + " " + vel);
  if(vel == 0) {
    notes.add(new Note(noteIndex));
  } else {
    for(int i = notes.size() - 1; i >= 0; i--) {
      Note note = (Note)notes.get(i);
      if(note.noteIndex == noteIndex) {
        note.release(vel);
      }
    }
  }
}
