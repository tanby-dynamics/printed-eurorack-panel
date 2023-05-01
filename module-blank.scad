// Parameterised Eurorack module blank
// (C) 2023 Rebecca Scott (me@becdetat.com) / Tanby Dynamics (tanbydynamics.co)
// MIT license

// Globals
wallThickness = 1;
erHeight = 128.5;   // 3U
erHorizontalPitch = 5.08;   //1/2"
erPanelClearance = 6;   // width of the rails
erPanelScrewDiam = 3.2;   // 1/16"
pcbPlateScrewDiam = 2;   // 2 = M2
enablePCBPlateSupports = true;  // Small supports on the PCB plate
enablePCBPlateScrewHoles = true;
labelDepth = 0.3;

eurorack_module_blank(units = 4) {
    // This is applied in a `difference` block, so
    // any geometries added here will be subtracted
    // from the front panel.
    
    // Add custom holes here. Remember that the
    // rail will cover `erPanelClearance` on the
    // top and bottom.
    
    // make some example 6mm and 3mm holes
    centerX = 20;
    centerY = erHorizontalPitch*4/2;

    makeHole(x=centerX,     y=centerY, d=3);
    makeHole(x=centerX*2,   y=centerY, d=3);
    makeHole(x=centerX*3,   y=centerY, d=3);
    makeHole(x=centerX*4,   y=centerY, d=3);
    makeHole(x=centerX*4.5, y=centerY, d=4);
    makeHole(x=centerX*5,   y=centerY, d=4);
    makeHole(x=centerX*5.5, y=centerY, d=4);
    
    makeLabel(x=1.0, y=5, size=1.5, label="TANBY DYNAMICS");
    makeLabel(x=7.0, y=centerX+2, size=1.5, label="Label 1");
    makeLabel(x=7.0, y=centerX*2+2, size=1.5, label="Label 2");
    makeLabel(x=7.0, y=centerX*3+2, size=1.5, label="Label 3");
};

module makeHole(x, y, d) {
    translate([x, y, -0.5])
    cylinder(h=wallThickness + 1, d=d);
}

module makeLabel(x, y, size, label) {
    rotate([180, 0, 270])
    translate([
        -erHorizontalPitch*4 + x,
        -erPanelClearance - y,
        -labelDepth
    ])
    linear_extrude(1)
    text(label, size=size);
}


module eurorack_module_blank(units) {
    translate([-erHeight/2,-erHorizontalPitch*units/2,0]) {
        difference() {
            front_panel(units);
            children(); // children should be cylinders and other geometries that cut through the front panel
        }
        pcb_plate(width = 30, units = units);
    }
}

module front_panel(units) {
    width = erHorizontalPitch*units;
    
    difference() {
        cube([erHeight, width, wallThickness]);
        // top screw hole
        translate([erPanelClearance/2,width/2,-0.5])
        cylinder(h=wallThickness+1, d=erPanelScrewDiam);
        // bottom screw hole
        translate([
            erHeight - erPanelClearance/2,
            width/2,
            -0.5
        ])
        cylinder(h=wallThickness+1, d=erPanelScrewDiam);
    }
}

module pcb_plate(width, units) {
    lengthTolerance = 1;    // trim a millimetre to clear the rails
    length = erHeight-erPanelClearance*2 - lengthTolerance;
    
    rotate([90, 0, 0])
    translate([erPanelClearance + lengthTolerance/2, wallThickness, -wallThickness])
    difference() {
         {
             union() {
                // The plate
                cube([length, width+wallThickness, wallThickness]);
                
                if (enablePCBPlateSupports) {
                    pcb_plate_support(units);
                    translate([length-wallThickness, 0, 0])
                    pcb_plate_support(units);
                }
            }
        }
        
        if (enablePCBPlateScrewHoles) {
            pcb_plate_screw_holes(width, length);
        }
    }

}

// Increase widthRatio for larger supports
module pcb_plate_support(units, widthRatio = 0.25) {
    width = erHorizontalPitch*units*widthRatio;
    
    translate([wallThickness,0,-width])
    rotate([0,270,0])
    linear_extrude(height=wallThickness)
    polygon([
        [0,0],
        [width,0],
        [width,width]
    ]);
}

// offset is the distance in from the corner
module pcb_plate_screw_holes(pcbWidth, pcbLength, offset = 5) {
    module hole() {
        cylinder(h = wallThickness + 1, d = pcbPlateScrewDiam);
    }
    zOffset = -wallThickness+0.5;
    
    translate([offset, offset, zOffset])
    hole();
    translate([pcbLength-offset, offset, zOffset])
    hole();
    translate([offset, pcbWidth-offset, zOffset])
    hole();
    translate([pcbLength-offset, pcbWidth-offset, zOffset])
    hole();
    
}