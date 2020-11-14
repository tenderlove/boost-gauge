ALL = left_side.stl right_side.stl middle.stl front_plate.stl

%.stl: case.scad
	openscad -D 'file="$@"' -o $@ $<

all: $(ALL)
