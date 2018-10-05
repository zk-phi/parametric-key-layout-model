// ---- KEYBOARD OPTIONS

// キーピッチ (mm)
KEY_PITCH = 18.8;

// 横ズレの設定 (row staggering)
// * 上から数えて i 行目が STAGGERING[i] u だけ内側にずれる
// * 負はダメ
//
// 例: 行方向のずれなし (縦ズレ or 格子配列)
LEFT_STAGGERING  = [0.00, 0.00, 0.00, 0.00];
RIGHT_STAGGERING = [0.00, 0.00, 0.00, 0.00];
//
// 例: 一般的なキーボードの横ズレ (row staggered)
// LEFT_STAGGERING  = [0.00, 0.25, 0.75, 0.25];
// RIGHT_STAGGERING = [0.75, 0.50, 0.00, 0.25];
//
// 例: 左右対称の横ズレ (symmetrical)
// LEFT_STAGGERING  = [0.75, 0.50, 0.00, 0.25];
// RIGHT_STAGGERING = [0.75, 0.50, 0.00, 0.25];

// 縦ズレの設定 (columnar staggering)
// * 外側から数えて i 列目が OFFSET_Y[i] mm だけ上にズレる。負でも良い
//
// 例: 縦ズレなし
OFFSET_Y = [0, 0, 0, 0, 0, 0, 0, 0];
//
// 例: 縦ズレあり
// OFFSET_Y = [-10, -10, -6, -3, 0, -3, -6, -10];

// カーブの設定。TRON キーボードみたいにグニってする。
// * 外側から数えて i 列目以降が ROTATION[i]°だけめりこむ
// * 0.75u 以上横ズレしている行は、 ROTATION[i + 1]°だけめりこむ
// * 縦ズレと併用するとだいたい壊れる
//
// 例: グニなし
ROTATION = [0, 0, 0, 0, 0, 0, 0, 0];
//
// 例: グニあり
// ROTATION = [0, 3, 3, 3, 3, 3, 3, 3];

// レイアウトの設定。
// * 1 にしたところにキーが出る
//
// 例: 4x6 (40%)
KEY_EXISTENCE_TABLE = [
  [[1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1]],
  [[1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1]],
  [[1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1]],
  [[1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1]],
];
//
// 例: Helix 風
// KEY_EXISTENCE_TABLE = [
//   [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
//   [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
//   [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
//   [[1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1]],
// ];
//
// 例: 3x6 (30%) + 親指キー
// KEY_EXISTENCE_TABLE = [
//   [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
//   [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
//   [[1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]],
//   [[0, 0, 0, 1, 1, 1, 1], [1, 1, 1, 1, 0, 0, 0]],
// ];


// ---- RENDERING OPTIONS

// キーキャップの底面の一辺 (mm)
KEY_SIZE = 18.415;

// キーキャップの上面の一辺 (mm)
KEY_TOP_SIZE = 15.000;

// キーキャップの高さ (mm)
KEY_TOP_HEIGHT = 2;

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
