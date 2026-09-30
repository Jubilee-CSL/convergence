/* [PCB selection - NOT WORKING YET] */
your_pcb = "foo"; // [arduino_uno, arduino_mega, rp4]

////////////////////////////////////////////////////////////////////////////////
/* [Main parameters] */
grid_spacing = 40;

pcb_width_default = 39.6;
pcb_depth_default = 31.5;
pcb_height = 1.65;
swap_tabs = false;
swap_dimensions = false;
pcb_width = swap_dimensions ? pcb_depth_default : pcb_width_default;
pcb_depth = swap_dimensions ? pcb_width_default : pcb_depth_default;
external_Ltabs = false;
fixed_L_tab = false;
fixed_L_tab_length = 5;
L_tabs_offset = 0; // [-20:0.5:20]

////////////////////////////////////////////////////////////////////////////////
/* [Secondary parameters] */
hole_diam = 3; // for screw
nut_min_diam = 5.4; // for nuts
tolerance = 0.2; // used fo 3D printing
min_border = 1.5; // minimal dist. from nut to the outter border of the board
pcb_offset = 0.7; // protruding border below the pcb

////////////////////////////////////////////////////////////////////////////////
/* [Change at your own risks] */
fillet_radius = 5;
nut_max_diam = nut_min_diam * 2 / sqrt(3);
board_height = 3;
board_width_min = ceil(pcb_width + (nut_max_diam + tolerance * 2 + min_border) * 2 + min_border * 2);
echo(board_width_min);
board_width = ceil(board_width_min / grid_spacing) * grid_spacing/1.5 - tolerance;
holes_dist_width_min = ceil(pcb_width + (nut_max_diam + tolerance * 2) + min_border * 2);
holes_dist_width = ceil(holes_dist_width_min / grid_spacing) * grid_spacing;
board_depth_min = ceil(pcb_width + (nut_max_diam + tolerance * 2 + min_border) * 2 + min_border * 2);
board_depth = ceil(board_depth_min / grid_spacing) * grid_spacing/1.5 - tolerance;
holes_dist_depth_min = floor(pcb_depth - (nut_max_diam + tolerance * 2) / 2 - min_border * 2);
holes_dist_depth = ceil(holes_dist_depth_min / grid_spacing) * grid_spacing;
L_tab_hook_length = 1.5;
simple_tabs_width = 1.5;


xtab_length = swap_tabs ? pcb_depth/2 : pcb_width / 3; //tabs along x axis
ytab_length = swap_tabs ? (fixed_L_tab ? fixed_L_tab_length : pcb_width / 3) : (fixed_L_tab ? fixed_L_tab_length : pcb_depth / 3); //tabs along y axis

L_hook = 1;

////////////////////////////////////////////////////////////////////////////////
/*Code*/

// Module for symmetry
module mirror_copy(v = [1, 0, 0]) {
  children();
  mirror(v) children();
}

// Board with holes
difference() {
  // Create the board
  linear_extrude(height=board_height) {
    difference() {
      offset($fn=50, r=fillet_radius) {
        square([board_width - fillet_radius * 2, board_depth - fillet_radius * 2], center=true);
      }
      square([pcb_width - pcb_offset * 2, pcb_depth - pcb_offset * 2], center=true);
    }
  }
  // holes
  mirror_copy([0, 1, 0]) mirror_copy() translate([holes_dist_width / 2, holes_dist_depth / 2, 0]) {
        cylinder($fn=50, h=board_height * 2, r=hole_diam / 2 + tolerance);
      }
  // nut holes
  mirror_copy([0, 1, 0]) mirror_copy() translate([holes_dist_width / 2, holes_dist_depth / 2, board_height / 2]) {
        cylinder($fn=6, h=board_height * 2, r=(nut_max_diam / 2 + tolerance));
      }
}

if (swap_tabs) {
  //Swapped tabs
  // L tabs
  if (external_Ltabs){
  mirror([1, 0, 0])
  mirror_copy([0, 1, 0]) translate([pcb_width/2-ytab_length+ L_tabs_offset, pcb_depth / 2 + tolerance, board_height]) {
      cube([ytab_length, simple_tabs_width, pcb_height + tolerance * 2], center=false);
      // translate([0,0,pcb_height+tolerance*2]){
      translate([0, -L_hook, pcb_height + tolerance * 2]) {
        cube([ytab_length, simple_tabs_width + L_hook, 2]);
      }
    }
      mirror_copy([0, 1, 0]) translate([pcb_width/2-ytab_length+ L_tabs_offset, pcb_depth / 2 + tolerance, board_height]) {
      cube([ytab_length, simple_tabs_width, pcb_height + tolerance * 2], center=false);
      // translate([0,0,pcb_height+tolerance*2]){
      translate([0, -L_hook, pcb_height + tolerance * 2]) {
        cube([ytab_length, simple_tabs_width + L_hook, 2]);
      }
    }
  }
  else {
  mirror_copy([0, 1, 0]) translate([-ytab_length / 2 + L_tabs_offset, pcb_depth / 2 + tolerance, board_height]) {
      cube([ytab_length, simple_tabs_width, pcb_height + tolerance * 2], center=false);
      // translate([0,0,pcb_height+tolerance*2]){
      translate([0, -L_hook, pcb_height + tolerance * 2]) {
        cube([ytab_length, simple_tabs_width + L_hook, 2]);
      }
    }
  }
  // simple tabs
  mirror_copy([1, 0, 0]) translate([-pcb_width / 2 - tolerance - simple_tabs_width, -xtab_length / 2, board_height]) {
      cube([L_tab_hook_length, xtab_length, pcb_height]);
    }
} else // Default tabs positionning
{
  // simple tabs, along x
  mirror_copy([0, 1, 0]) translate([-xtab_length / 2, pcb_depth / 2 + tolerance, board_height]) {
      cube([xtab_length, simple_tabs_width, pcb_height], center=false);
    }
  // L tabs, along y
  if (external_Ltabs){
  mirror([0, 1, 0])
    mirror_copy([1, 0, 0]) translate([-pcb_width / 2 - tolerance - simple_tabs_width, pcb_depth/2-ytab_length- L_tabs_offset, board_height]) {
      cube([simple_tabs_width, ytab_length, pcb_height + tolerance * 2]);
      translate([0, 0, pcb_height + tolerance * 2]) {
        cube([L_tab_hook_length + L_hook, ytab_length, 2]);
      }
    }
        mirror_copy([1, 0, 0]) translate([-pcb_width / 2 - tolerance - simple_tabs_width, pcb_depth/2-ytab_length- L_tabs_offset, board_height]) {
      cube([simple_tabs_width, ytab_length, pcb_height + tolerance * 2]);
      translate([0, 0, pcb_height + tolerance * 2]) {
        cube([L_tab_hook_length + L_hook, ytab_length, 2]);
      }
    }
  }
  else{
  mirror_copy([1, 0, 0]) translate([-pcb_width / 2 - tolerance - simple_tabs_width, -ytab_length / 2 + L_tabs_offset, board_height]) {
      cube([simple_tabs_width, ytab_length, pcb_height + tolerance * 2]);
      translate([0, 0, pcb_height + tolerance * 2]) {
        cube([L_tab_hook_length + L_hook, ytab_length, 2]);
      }
    }
  }
  
}
// THE END
