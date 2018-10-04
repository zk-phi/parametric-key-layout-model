// KEYBOARD CONFIGS
KEY_PITCH = 18.8;

// normal row staggered
// LEFT_STAGGERING  = [0.50, 0.75, 0.25, 0.25];
// RIGHT_STAGGERING = [0.00, 0.75, 0.25, 0.25];

// ortho or column staggered
LEFT_STAGGERING  = [0.00, 0.00, 0.00, 0.00];
RIGHT_STAGGERING = [0.00, 0.00, 0.00, 0.00];

// curly
// ROTATION = [0, 3, 3, 3, 3, 3, 3, 3];
// OFFSET_Y = [0, 0, 0, 0, 0 ,0, 0, 0];

// straight
ROTATION = [0, 0, 0, 0, 0, 0, 0, 0];
OFFSET_Y = [0, 0, 0, 0, 0, 0, 0, 0];

// column staggered
// ROTATION = [0, 0, 0, 0, 0, 0, 0, 0];
// OFFSET_Y = [-10, -10, -6, -3, 0, -3, -6, -10];

// helix-like layut
KEY_EXISTENCE_TABLE = [
  [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
  [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
  [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
  [[1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1]],
];

// KEYCAP CONFIGS
KEY_SIZE       = 18.415;
KEY_TOP_SIZE   = 15.000;
KEY_TOP_HEIGHT = 10;

// ---- keycap

module keycap_internal (size = 1) {
    offset = (KEY_SIZE - KEY_TOP_SIZE) / 2;
    difference () {
        polyhedron([
            [0, 0, 0],
            [KEY_SIZE * size, 0, 0],
            [KEY_SIZE * size, KEY_SIZE, 0],
            [0, KEY_SIZE, 0],
            [offset, offset, KEY_TOP_HEIGHT],
            [(offset + KEY_TOP_SIZE) * size, offset, KEY_TOP_HEIGHT],
            [(offset + KEY_TOP_SIZE) * size, offset + KEY_TOP_SIZE, KEY_TOP_HEIGHT],
            [offset, offset + KEY_TOP_SIZE, KEY_TOP_HEIGHT]
        ], [
            [0, 1, 2, 3],
            [4, 5, 1, 0],
            [7, 6, 5, 4],
            [5, 6, 2, 1],
            [6, 7, 3, 2],
            [7, 4, 0, 3]
        ]);
    }
}

module keycap (right = false, size = 1) {
    translate([right ? - KEY_SIZE : - (size - 1) * KEY_SIZE, 0, 0])
      keycap_internal(size);
}

module keycap_v (right = false, size = 1) {
  translate([right ? 0 : KEY_SIZE, 0, 0])
    rotate([0, 0, 90])
        keycap_internal(size);
}

// ---- keyboard

NUMBER_OF_LEFT_COLS  = len(KEY_EXISTENCE_TABLE[0][0]);
NUMBER_OF_RIGHT_COLS = len(KEY_EXISTENCE_TABLE[0][0]);
NUMBER_OF_ROWS       = len(KEY_EXISTENCE_TABLE);

module column (right = false, index = 0) {
    d = right ? 1 : -1;
    staggering = right ? RIGHT_STAGGERING : LEFT_STAGGERING;
    bottom_stag = staggering[NUMBER_OF_ROWS - 1];
    for (i = [0 : NUMBER_OF_ROWS - 1])
      if (KEY_EXISTENCE_TABLE[i][right ? 1 : 0][right ? NUMBER_OF_RIGHT_COLS - index - 1 : index])
        translate([d * (bottom_stag - staggering[i]) * KEY_PITCH, (NUMBER_OF_ROWS - 1 - i) * KEY_PITCH, 0])
          keycap(right, !index ? 1 + staggering[i] : 1);
}

module keyboard (right = false, from = 0) {
  d = right ? 1 : -1;
  rotate([0, 0, d * ROTATION[from]]) {
    translate([0, OFFSET_Y[from], 0])
        column(right, from);
    if (from < (right ? NUMBER_OF_RIGHT_COLS : NUMBER_OF_LEFT_COLS))
      translate([- d * KEY_PITCH,  0, 0])
        keyboard(right, from + 1);
  }
}


//-----

keyboard();
translate([320, 0, 0]) keyboard(true);
