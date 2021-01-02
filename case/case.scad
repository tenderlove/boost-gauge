GAUGE_FACE_X   = 48;
GAUGE_FACE_Y   = 48;
GAUGE_X_BUFFER = 2;
GAUGE_Y_BUFFER = 2;
GAUGE_X        = GAUGE_FACE_X + GAUGE_X_BUFFER;
GAUGE_Y        = GAUGE_FACE_Y + GAUGE_Y_BUFFER;
GAUGE_LEN      = 31; // Measured from the back to behind the ridge
GAUGE_DIAMETER = 45.5;
GAUGE_RADIUS   = GAUGE_DIAMETER / 2;
SCREW_DIAMETER = 5;
SCREW_RADIUS   = SCREW_DIAMETER / 2;
SCREW_OFFSET_X = (32 / 2) + SCREW_RADIUS;
SCREW_OFFSET_Y = (32 / 2) + SCREW_RADIUS;

FRONT_PLATE_DEPTH = 2;
TAB_DEPTH = 2;
GAUGE_TAB_DEPTH = 4;

GAUGE_MOUNT_ANGLE = 35;

module Gauge() {
  difference() {
    linear_extrude(FRONT_PLATE_DEPTH)
      square(size = [GAUGE_X, GAUGE_Y], center=true);

    $fn = 90;
    for(j = [-1, 1]) {
      for(i = [-1, 1]) {
        translate([i * SCREW_OFFSET_X, j * SCREW_OFFSET_Y, -1])
          linear_extrude(4)
          circle(r = SCREW_RADIUS);
      }
    }

    translate([0, 0, -1])
      linear_extrude(4)
      circle(d = GAUGE_DIAMETER);
  }
}

module FrontPlate() {
  translate([-100, 0, 0])
    for(i = [1, 2, 3, 4]) {
      translate([(i * GAUGE_X) - (GAUGE_X / 2), 0, 0])
        Gauge();
    }
}

module FrontBottomPlate() {
  gauge_side_z = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + TAB_DEPTH;
  radius       = gauge_side_z / sin(90 - GAUGE_MOUNT_ANGLE);
  foot_l = (GAUGE_LEN * cos(GAUGE_MOUNT_ANGLE)) +
    radius +
    (45 * cos(180 - 90 - GAUGE_MOUNT_ANGLE));

  angle = 90 - GAUGE_MOUNT_ANGLE;
  front_leg_z = (GAUGE_LEN * sin(angle)) + 5;

  hole_diameter = 3.5;
  tab_ring = 2;

  difference() {
    linear_extrude(FRONT_PLATE_DEPTH)
      square([GAUGE_X * 4,  front_leg_z]);

    h = FRONT_PLATE_DEPTH / sin(angle);
    o = FRONT_PLATE_DEPTH * sin(90 - angle);
    color("blue")
      translate([-1, 0, 0])
      rotate([angle, 0, 0])
      linear_extrude(o)
      square([(GAUGE_X * 4) + 2,  h]);
  }


  $fn = 90;

  translate([(hole_diameter + tab_ring) / 2, front_leg_z / 2])
    linear_extrude(FRONT_PLATE_DEPTH + 3)
    circle(d = (hole_diameter - 0.3));

  translate([(GAUGE_X * 4) - ((hole_diameter + tab_ring) / 2), front_leg_z / 2])
    linear_extrude(FRONT_PLATE_DEPTH + 3)
    circle(d = hole_diameter);
}

module TopPlate() {
}

module Tab(gauge_x) {
  $fn = 90;

  // Radius length to center of screw
  c = sqrt(pow(SCREW_OFFSET_X, 2) + pow(SCREW_OFFSET_Y, 2));

  tab_radius = c - GAUGE_RADIUS;

  difference() {
    linear_extrude(TAB_DEPTH)
      union() {
        circle(r = tab_radius);
        translate([0, -tab_radius])
          square(size = [gauge_x - SCREW_OFFSET_X, tab_radius * 2]);
      }

    translate([0, 0, -1])
      linear_extrude(5)
      circle(r = SCREW_RADIUS);
  }
}

module GaugeMount(distance_to_back, bar_x) {
  buffer_len = (cos(90 - GAUGE_MOUNT_ANGLE) * distance_to_back) / cos(GAUGE_MOUNT_ANGLE);
  base = sqrt(pow(distance_to_back, 2) + pow(buffer_len, 2));

  module EndCap(distance_to_back, buffer_len, base) {
    angle = GAUGE_MOUNT_ANGLE;
    o = sin(angle) * base;
    m =  sin(angle) * distance_to_back;
    color("red")
      translate([-(distance_to_back / 2), ((GAUGE_Y + buffer_len) / 2) - o, 0])
      rotate([0, 0, angle])
      // Make it slightly longer and taller for rendering issues
      square(size = [base + 1, m + 1]);
  }

  translate([0, 0, (distance_to_back / 2)])
    rotate([0, 90, 0])
    translate([0, 0, -(bar_x / 2)])
    linear_extrude(bar_x)
    difference() {
      color("green")
        square(size = [distance_to_back, GAUGE_Y + buffer_len], center = true);

      EndCap(distance_to_back, buffer_len, base);

      mirror([1, 0, 0])
        mirror([0, 1, 0])
        EndCap(distance_to_back, buffer_len, base);
    }

  gauge_x = GAUGE_X;

  color("blue")
  translate([0, -(buffer_len / 2), 0])
  translate([-((gauge_x + bar_x) / 2), 0, 0]) {
    translate([SCREW_OFFSET_X, SCREW_OFFSET_Y, 0])
      Tab(gauge_x / 2);
    translate([SCREW_OFFSET_X, -SCREW_OFFSET_Y, 0])
      Tab(gauge_x / 2);
  }
}

module TopTab(d, t, z) {
  $fn = 90;
  difference() {
    union() {
      linear_extrude(z)
        circle(d = d + t);
      translate([0, -((d + t) / 4), 0])
      linear_extrude(z)
        square(size = [d + t, (d + t) / 2], center = true);
    }
    translate([0, 0, -0.5])
      linear_extrude(z + 1)
      circle(d = d);
  }
}

module SideBar(gauge_side_z, wall) {
  gauge_side_x = 2;
  gauge_side_y = (GAUGE_Y - (gauge_side_z * tan(GAUGE_MOUNT_ANGLE)));
  radius       = gauge_side_z / sin(90 - GAUGE_MOUNT_ANGLE);

  foot_z = 2;

  front_leg_z = (GAUGE_LEN * sin(GAUGE_MOUNT_ANGLE)) + 5;

  foot_l = (GAUGE_LEN * cos(GAUGE_MOUNT_ANGLE)) +
    radius +
    (45 * cos(180 - 90 - GAUGE_MOUNT_ANGLE));

  translate([0, radius / 2, gauge_side_x / 2])
  rotate([0, 90, 0]) {
    translate([0, 0, 2]) {
      translate([0,
          (radius / 2) + ((gauge_side_y / 2) * cos(90 - GAUGE_MOUNT_ANGLE)),
          ((gauge_side_y / 2) * sin(90 - GAUGE_MOUNT_ANGLE)) + front_leg_z,
      ])
        rotate([90 - GAUGE_MOUNT_ANGLE, 0, 0])
        GaugeMount(gauge_side_z, gauge_side_x);
    }

      // Vertical Bar
      color("blue")
        translate([0, 0, foot_z])
        linear_extrude(front_leg_z)
        square(size = [gauge_side_x, radius], center = true);
    // Foot
    translate([-(gauge_side_x / 2) - 5, -(radius / 2), 0])
      linear_extrude(foot_z)
      square(size = [gauge_side_x + 5, foot_l]);
  }

  square_corner_rad = sqrt(pow(GAUGE_X / 2, 2) + pow(GAUGE_Y / 2, 2));
  y = square_corner_rad * sin(135 + GAUGE_MOUNT_ANGLE);
  x = square_corner_rad * cos(135 + GAUGE_MOUNT_ANGLE);

  gauge_top_x = foot_z + front_leg_z + (GAUGE_Y * cos(GAUGE_MOUNT_ANGLE));

  difference() {
    union() {
      if (wall) {
        color("green")
          linear_extrude(2)
          square(size = [gauge_top_x, foot_l]);
      }

      h = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + GAUGE_LEN;
      a = h * cos(GAUGE_MOUNT_ANGLE);

      // Top
      color("red")
      translate([gauge_top_x - gauge_side_x, foot_l - a - gauge_side_x, 0])
        linear_extrude(gauge_side_x)
        square(size = [2, a]);
    }

    color("green")
    translate([front_leg_z - x, -y, -1])
      linear_extrude(gauge_side_x + 5)
      rotate(GAUGE_MOUNT_ANGLE)
      square(size = [GAUGE_X + 5, GAUGE_Y], center = true);
  }

  top_bar_z = foot_z;

  // Back
  translate([gauge_top_x / 2, foot_l - (foot_z / 2), 0])
    linear_extrude(gauge_side_x)
    square(size = [gauge_top_x, top_bar_z], center = true);

  // Top mount
  tab_hole = 3.5;
  tab_ring = 2;
  tab_size = tab_hole + tab_ring;
  translate([gauge_top_x - top_bar_z, foot_l - top_bar_z - (tab_size / 2), (tab_size / 2) + gauge_side_x])
    color("pink")
    rotate([90, 0, 90])
    TopTab(tab_hole, tab_ring, top_bar_z);
}

module Middle() {
  gauge_side_z = GAUGE_TAB_DEPTH + TAB_DEPTH;
  SideBar(gauge_side_z, false);
}

module RightSide() {
  gauge_side_z = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + TAB_DEPTH;
  SideBar(gauge_side_z, true);
}

module LeftSide() {
  gauge_side_z = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + TAB_DEPTH;
  mirror([1, 0, 0])
    SideBar(gauge_side_z, true);
}

module TopPlate() {
  h = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + GAUGE_LEN;
  a = h * cos(GAUGE_MOUNT_ANGLE);

  linear_extrude(FRONT_PLATE_DEPTH)
    square(size = [(GAUGE_X * 4) + (FRONT_PLATE_DEPTH * 2), a + FRONT_PLATE_DEPTH]);

  $fn = 90;
  hole_diameter = 3.5;
  tab_ring = 2;
  shift = FRONT_PLATE_DEPTH + ((hole_diameter + tab_ring) / 2);
  shift_y = (a + FRONT_PLATE_DEPTH) - shift;

  translate([shift, shift_y])
    color("red")
    linear_extrude(FRONT_PLATE_DEPTH + 3)
    circle(d = (hole_diameter - 0.3));

  translate([((GAUGE_X * 4) + (FRONT_PLATE_DEPTH * 2)) - shift, shift_y])
    color("red")
    linear_extrude(FRONT_PLATE_DEPTH + 3)
    circle(d = (hole_diameter - 0.3));

  //rotate(GAUGE_MOUNT_ANGLE)
      //square(size = [GAUGE_X + 5, GAUGE_Y], center = true);
}

use <pcb-case.scad>;

file = 0;

if (file == "left_side.stl") { LeftSide(); }
if (file == "right_side.stl") { RightSide(); }
if (file == "middle.stl") { Middle(); }
if (file == "front_plate.stl") { FrontPlate(); }
if (file == "front_bottom_plate.stl") { FrontBottomPlate(); }
if (file == "top_plate.stl") { TopPlate(); }
if (file == "pcb_lid.stl") { PCBLid(32, 32, 1.5, 1.5); }
if (file == "pcb_case.stl") { PCBCase(32, 32, 1.5, 1.5, peg_height = 2); }

//Gauge();
RightSide();
//LeftSide();
//Middle();
//SideBar();
//FrontPlate();
//FrontBottomPlate();
//TopPlate();
//PCBLid(32, 32, 1.5, 1.5);
//PCBCase(32, 32, 1.5, 1.5, peg_height = 2);
