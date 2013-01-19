class Note {
  float x;
  float y; 
  float diameter;
  float maxDiameter;
  float opacity;
  int age;
  int maxAge;
  int state;

  Note(int i) {
    state = NOTE_DOWN;
    float l = min(width, height) / 8.0;
    int col = i % 8;
    int row = 8 - i / 8;
    x = l * col;
    y = l * row;
  }

  void update() {
    switch(state) {
      case NOTE_DOWN:
        update_living();
        return;
      case NOTE_DECAY:
        update_dying();
        return;
    }
  }

  void update_living() {
    noFill();
    strokeWeight(20);
    stroke(100);
    ellipse(x, y, diameter, diameter);
  }

  void update_dying() {
    age++;
    noFill();
    opacity = pow(norm(age, maxAge, 0), 3) * 100;
    diameter = (1 - pow(1 - norm(age, 0, maxAge), 3)) * maxDiameter;
    strokeWeight(20);
    stroke(100);
    ellipse(x, y, diameter, diameter);
    if(age >= maxAge) {
      state = NOTE_DEAD;
    }
  }

  void release(float velocity) {
    switch(state) {
      case NOTE_DOWN:
        println(velocity);
        maxDiameter = width * velocity * 0.4;
        maxAge = floor(20.0 * velocity);
        state = NOTE_DECAY;
        return;
    }
  }

  // checks to see if this note collides wth another note.  That is, if the
  // distance between their origins is greater than the max of their diameters.
  boolean collide(Note other) {
    return false;
  }

  boolean isDead() {
    return state == NOTE_DEAD;
  }
}
