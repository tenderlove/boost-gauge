PCB_X = 32;
PCB_Y = 33;
PCB_THICKNESS = 1.6;

module PCBBase(wall_thickness, pcb_side_padding = 1, radius = 2) {
  // Add padding on all sides of the PCB, plus the wall thickness
  pcb_x = PCB_X + (pcb_side_padding * 2) + (wall_thickness * 2);
  pcb_y = PCB_Y + (pcb_side_padding * 2) + (wall_thickness * 2);

  translate([0, 0, -wall_thickness])
    linear_extrude(wall_thickness)
    minkowski() {
      square(size = [pcb_x - (radius * 2), pcb_y - (radius * 2)], center = true);
      circle(r = radius, $fn = 90);
    }
}

module PCBPegs(below_pcb, pin_diameter = 2.3) {
  pcb_thickness = PCB_THICKNESS;

  for(i = [-1, 1]) {
    for(j = [-1, 1]) {
      translate([i * ((PCB_X / 2) - 3), j * ((PCB_Y / 2) - 3), 0]) {
        linear_extrude(below_pcb)
          circle(r = 2.5, $fn = 90);
        linear_extrude(below_pcb + pcb_thickness)
          circle(d = pin_diameter, $fn = 90);
      }
    }
  }
}

module PCBWalls(wall_thickness, below_pcb, above_pcb, pcb_side_padding = 1, radius = 2) {
  pcb_thickness = PCB_THICKNESS;

  // Add padding on all sides of the PCB, plus the wall thickness
  pcb_od_x = PCB_X + (pcb_side_padding * 2) + (wall_thickness * 2);
  pcb_od_y = PCB_Y + (pcb_side_padding * 2) + (wall_thickness * 2);

  pcb_id_x = PCB_X + (pcb_side_padding * 2);
  pcb_id_y = PCB_Y + (pcb_side_padding * 2);

  difference() {
    linear_extrude(below_pcb + pcb_thickness + above_pcb)
      minkowski() {
        square(size = [pcb_od_x - (radius * 2), pcb_od_y - (radius * 2)], center = true);
        circle(r = radius, $fn = 90);
      }

    translate([0, 0, -1])
    linear_extrude(below_pcb + pcb_thickness + above_pcb + 2)
      minkowski() {
        square(size = [pcb_id_x - (radius * 2), pcb_id_y - (radius * 2)], center = true);
        circle(r = radius, $fn = 90);
      }
  }
}

// z is the bottom of the USB plug
// x is the offset from center (0 = center)
module USBHole(x, z, height, width, wall_thickness, pcb_side_padding = 1, padding = 0.5) {
  y = wall_thickness + 2;
  color("red")
  translate([x, (PCB_Y / 2) + pcb_side_padding + (wall_thickness / 2), z])
    linear_extrude(height + (padding * 2))
    square(size = [width + (padding * 2), y], center = true);
}

wall_thickness = 1;
below_pcb = 2;
above_pcb = 10;

PCBBase(wall_thickness);
PCBPegs(below_pcb);

usb_height = 4;
usb_width = 9;

difference() {
  PCBWalls(wall_thickness, below_pcb, above_pcb);
  USBHole(0, below_pcb + PCB_THICKNESS, usb_height, usb_width, wall_thickness);
}

linear_extrude(1)
  text("1", halign="center", valign="center");
