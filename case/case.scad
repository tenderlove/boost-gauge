GAUGE_X        = 50;
GAUGE_Y        = 50;
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

    $fn = 50;
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

module Tab() {
  $fn = 50;

  // Radius length to center of screw
  c = sqrt(pow(SCREW_OFFSET_X, 2) + pow(SCREW_OFFSET_Y, 2));

  tab_radius = c - GAUGE_RADIUS;

  difference() {
    linear_extrude(TAB_DEPTH)
      union() {
        circle(r = tab_radius);
        translate([0, -tab_radius])
          square(size = [(GAUGE_X / 2) - SCREW_OFFSET_X, tab_radius * 2]);
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

module GaugeSideMount(bar_x, bar_y, bar_z) {
  radius          = bar_z * tan(GAUGE_MOUNT_ANGLE);
  gauge_x         = GAUGE_X / 2;

  translate([-(gauge_x + (bar_x / 2)), 0, 0]) {
    translate([gauge_x + (bar_x / 2), 0, 0])
      linear_extrude(bar_z)
      square(size = [bar_x, bar_y], center = true);

    translate([gauge_x + bar_x, -((bar_y / 2) + radius), bar_z])
      rotate([0, 180, 0])
      prism(bar_x, radius, bar_z);

    translate([bar_x + gauge_x, (bar_y / 2) + radius, 0])
      rotate([0, 0, 180])
      prism(bar_x, radius, bar_z);

    translate([SCREW_OFFSET_X, SCREW_OFFSET_Y, 0])
      Tab();
    translate([SCREW_OFFSET_X, -SCREW_OFFSET_Y, 0])
      Tab();
  }
}
module SideBar() {
  gauge_side_x = 5;
  gauge_side_z = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + TAB_DEPTH;
  gauge_side_y = (GAUGE_Y - (gauge_side_z * tan(GAUGE_MOUNT_ANGLE)));
  radius       = gauge_side_z / sin(90 - GAUGE_MOUNT_ANGLE);

  front_leg_z = (GAUGE_LEN * sin(GAUGE_MOUNT_ANGLE)) + 5;

  rotate([0, 90, 0]) {
    translate([0, 0, 2]) {
      translate([0,
          (radius / 2) + ((gauge_side_y / 2) * cos(90 - GAUGE_MOUNT_ANGLE)),
          ((gauge_side_y / 2) * sin(90 - GAUGE_MOUNT_ANGLE)) + front_leg_z,
      ])
        rotate([90 - GAUGE_MOUNT_ANGLE, 0, 0])
        GaugeSideMount(gauge_side_x, gauge_side_y, gauge_side_z);

      color("blue")
        linear_extrude(front_leg_z)
        square(size = [gauge_side_x, radius], center = true);
    }

    // Foot
    l = (GAUGE_LEN * cos(GAUGE_MOUNT_ANGLE)) +
      radius +
      (45 * cos(180 - 90 - GAUGE_MOUNT_ANGLE));

    translate([-(gauge_side_x / 2) - 5, -(radius / 2), 0])
      linear_extrude(2)
      square(size = [gauge_side_x + 5, l]);
  }
}

module RightSide() {
  gauge_side_z = FRONT_PLATE_DEPTH + GAUGE_TAB_DEPTH + TAB_DEPTH;
  radius       = gauge_side_z / sin(90 - GAUGE_MOUNT_ANGLE);

  translate([0, radius / 2, 5 / 2])
    SideBar();
}

module LeftSide() {
  mirror([1, 0, 0])
  rotate([0, 90, 0])
    SideBar();
}

//Gauge();
RightSide();
//LeftSide();
//SideBar();
