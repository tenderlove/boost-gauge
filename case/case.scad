GAUGE_FACE_X   = 48;
GAUGE_FACE_Y   = 48;
GAUGE_X_BUFFER = 2;
GAUGE_Y_BUFFER = 2;
GAUGE_X        = GAUGE_FACE_X + GAUGE_X_BUFFER;
GAUGE_Y        = GAUGE_FACE_Y + GAUGE_Y_BUFFER;
GAUGE_LEN      = 31;
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

module prism(l, w, h){
  polyhedron(
      points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
      faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
      );
}


module GaugeMount(gauge_x, bar_x, bar_y, bar_z) {
  radius          = bar_z * tan(GAUGE_MOUNT_ANGLE);

  translate([0, -(radius / 2), 0]) {
    translate([-(gauge_x + (bar_x / 2)), radius / 2, 0]) {
      translate([gauge_x + (bar_x / 2), 0, 0])
        linear_extrude(bar_z)
        square(size = [bar_x, bar_y], center = true);

      translate([gauge_x + bar_x, -((bar_y / 2) + radius), bar_z])
        rotate([0, 180, 0])
        prism(bar_x, radius, bar_z);

      translate([bar_x + gauge_x, (bar_y / 2) + radius, 0])
        rotate([0, 0, 180])
        prism(bar_x, radius, bar_z);
    }

    translate([-(gauge_x + (bar_x / 2)), 0, 0]) {
      translate([SCREW_OFFSET_X, SCREW_OFFSET_Y, 0])
        Tab(gauge_x);
      translate([SCREW_OFFSET_X, -SCREW_OFFSET_Y, 0])
        Tab(gauge_x);
    }
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

module SideBar(wall) {
  gauge_side_x = 2;
  gauge_side_z = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + TAB_DEPTH;
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
        if (wall) {
          GaugeMount(GAUGE_X / 2, gauge_side_x, gauge_side_y, gauge_side_z);
        } else {
          GaugeMount(GAUGE_FACE_X / 2, gauge_side_x, gauge_side_y, gauge_side_z);
        }

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

      // Top
      translate([gauge_top_x - (foot_z / 2), foot_l / 2, 0])
        linear_extrude(gauge_side_x)
        square(size = [foot_z, foot_l], center = true);
    }

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
    rotate([90, 0, 90])
    TopTab(tab_hole, tab_ring, top_bar_z);

  translate([(front_leg_z / 2) + foot_z, top_bar_z + FRONT_PLATE_DEPTH, (tab_size / 2) + gauge_side_x])
  rotate([90, 0, 0])
    TopTab(tab_hole, tab_ring, top_bar_z);
}

module Middle() {
  SideBar(false);
}

module RightSide() {
  SideBar(true);
}

module LeftSide() {
  mirror([1, 0, 0])
    SideBar(true);
}

file = 0;

if (file == "left_side.stl") { LeftSide(); }
if (file == "right_side.stl") { RightSide(); }
if (file == "middle.stl") { Middle(); }
if (file == "front_plate.stl") { FrontPlate(); }
//Gauge();
//RightSide();
//LeftSide();
//Middle();
//SideBar();
//FrontPlate();
