class Note {
  float x;
  float y; 
  float diameter;
  float maxDiameter;
  float opacity;
  int noteIndex;
  int age;
  int maxAge;
  int state;
  boolean reaction;
  int reactionLvl;

  Note(int i) {
    noteIndex = i;
    state = NOTE_DOWN;
    PVector v = getOrigin(i);
    x = v.x;
    y = v.y;
    diameter = 10;
    reaction = false;
    reactionLvl = 0;
  }

  Note(float _x, float _y, float _diameter, float _maxDiameter, int _age, int _maxAge) {
    noteIndex = getNearestIndex(new PVector(_x, _y));
    state = NOTE_DECAY;
    x = _x;
    y = _y;
    diameter = _diameter;
    maxDiameter = _maxDiameter;
    age = _age;
    maxAge = _maxAge;
    reaction = true;
  }

  void update() {
    switch(state) {
      case NOTE_DOWN:
        update_living();
        return;
      case NOTE_DECAY:
      case NOTE_COLLIDED:
        update_dying();
        return;
    }
  }

  void update_living() {
    noFill();
    strokeWeight(14);
    if(reaction) {
      stroke(255, 0, 0, 255);
    } else {
      stroke(255, 255);
    }

    ellipse(x, y, diameter, diameter);
  }

  void update_dying() {
    age++;
    noFill();
    opacity = pow(norm(age, maxAge, 0), 1.1) * 100;
    diameter = 10 + (1 - pow(1 - norm(age, 0, maxAge), 1.1)) * maxDiameter;
    strokeWeight(14);
    if(reaction) {
      stroke(255, 0, 0, opacity);
    } else {
      stroke(255, opacity);
    }
    ellipse(x, y, diameter, diameter);
    if(age >= maxAge) {
      state = NOTE_DEAD;
    }
  }

  void release(float velocity) {
    if(velocity > 1.0) {
      velocity = velocity / 5000.0;
    }
    velocity = max(velocity, 0.1);
    switch(state) {
      case NOTE_DOWN:
        maxDiameter = 4 * width * velocity;
        maxAge = floor(100.0 * velocity);
        state = NOTE_DECAY;
        return;
    }
  }

  // checks to see if this note collides wth another note.  That is, if the
  // distance between their origins is greater than the max of their diameters.
  boolean collide(Note other) {
    if(state != NOTE_DECAY || other.state != NOTE_DECAY) {
      return false;
    }

    PVector p1 = new PVector(x, y);
    PVector p2 = new PVector(other.x, other.y);
    if(diameter * 0.5 + other.diameter * 0.5 > p1.dist(p2)) {
      state = NOTE_COLLIDED;
      other.state = NOTE_COLLIDED;
      return true;
    }
    return false;
  }

  PVector collisionPoint(Note other) {
    PVector p1 = new PVector(x, y);
    PVector p2 = new PVector(other.x, other.y);

    float ang = PVector.angleBetween(p1, p2);
    p1.add(new PVector(diameter * 0.5, 0));
    p1.rotate(ang);

    state = NOTE_COLLIDED;
    other.state = NOTE_COLLIDED;
    return p1;
  }

  boolean isDead() {
    return state == NOTE_DEAD;
  }
}
