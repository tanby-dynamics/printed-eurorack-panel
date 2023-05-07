// Parameterised Eurorack module blank
// (C) 2023 Rebecca Scott (me@becdetat.com) / Tanby Dynamics (tanbydynamics.co)
// MIT license

// Globals
frontPanelThickness = 2;
pcbPlateThickness = 1.5;
erHeight = 128.5;   // 3U
erHorizontalPitch = 5.08;   //1/2"
erPanelClearance = 6;   // width of the rails
erPanelScrewDiam = 3.2 + 0.5;   // 1/16" plus 0.5mm
pcbPlateScrewDiam = 3.0;   // 3 = M3
enablePCBPlate = true;
enablePCBPlateSupports = true;  // Small supports on the PCB plate
enablePCBPlateScrewHoles = true;
enablePCBPlateCutouts = true;   // only works with pcbPlateWidth of 80...
pcbPlateCutoutType = 2;    // 1 = triangles, 2 = rectangle
labelDepth = 0.6;

erUnits = 6;
pcbPlateWidth = 80;

//comment the following rotate and translate out to print the front panel on the bed (not recommended)
rotate([90, 0, 0])
translate([0, erUnits*erHorizontalPitch/2, -erUnits*erHorizontalPitch/2])
eurorack_module_blank() {
    // This is applied in a `difference` block, so
    // any geometries added here will be subtracted
    // from the front panel.
    
    // Add custom holes here. Remember that the
    // rail will cover `erPanelClearance` on the
    // top and bottom.
    
    // make some example 6mm and 3mm holes
    centerX = 20;
    centerY = erHorizontalPitch*6/2;

    makeHole(x=centerX,     y=centerY, d=7.2);    // pot
    makeHole(x=centerX*2.5,   y=centerY, d=6.5);  // switch
    makeHole(x=centerX*3.5,   y=centerY, d=6.5);  // 1/8" jack
    makeHole(x=centerX*4.4, y=centerY, d=3.6);    // 3mm led
    makeHole(x=centerX*4.9,   y=centerY, d=3.6);  // 3mm led
    
    makeLabel(x=-1.0, y=5, size=4, label="VCO");
    makeLabel(x=1.0, y=centerX+5, size=4, label="pot");
    makeLabel(x=-3.0, y=centerX*2.5+2, size=4, label="switch");
    makeLabel(x=-0.5, y=centerX*3.5+2, size=4, label="jack");
    makeLabel(x=-2.0, y=105, size=4, label="tanby");
    makeLabel(x=-7.5, y=110, size=4, label="dynamics");
};

module makeHole(x, y, d) {
    translate([x, y, -0.5])
    cylinder(h=frontPanelThickness + 1, d=d);
}

module makeLabel(x, y, size, label, font="Liberation Sans:style=Bold") {
    rotate([180, 0, 270])
    translate([
        -erHorizontalPitch*4 + x,
        -erPanelClearance - y,
        -labelDepth
    ])
    linear_extrude(1)
    text(label, size=size, font=font);
}


module eurorack_module_blank() {
    translate([-erHeight/2,-erHorizontalPitch*erUnits/2,0]) {
        difference() {
            front_panel();
            children(); // children should be cylinders and other geometries that cut through the front panel
        }
        if (enablePCBPlate) {
            pcb_plate();
        }
    }
}

module front_panel() {
    width = erHorizontalPitch*erUnits;
    
    difference() {
        cube([erHeight, width, frontPanelThickness]);
        // top screw hole
        translate([erPanelClearance/2,width/2,-0.5])
        cylinder(h=frontPanelThickness+1, d=erPanelScrewDiam);
        // bottom screw hole
        translate([
            erHeight - erPanelClearance/2,
            width/2,
            -0.5
        ])
        cylinder(h=frontPanelThickness+1, d=erPanelScrewDiam);
    }
}

module pcb_plate() {
    lengthTolerance = 2;    // trim 2mm to clear the rails
    length = erHeight-erPanelClearance*2 - lengthTolerance;
    
    rotate([90, 0, 0])
    translate([erPanelClearance + lengthTolerance/2, pcbPlateThickness, -pcbPlateThickness])
    difference() {
         {
             union() {
                // The plate
                cube([length, pcbPlateWidth+pcbPlateThickness, pcbPlateThickness]);
                
                if (enablePCBPlateSupports) {
                    pcb_plate_support();
                    translate([length-pcbPlateThickness, 0, 0])
                    pcb_plate_support();
                }
            }
        }
        
        if (enablePCBPlateScrewHoles) {
            pcb_plate_screw_holes(pcbPlateWidth, length);
        }
        if (enablePCBPlateCutouts) {
            if (pcbPlateCutoutType == 1) {
                pcb_plate_triangle_cutouts(pcbPlateWidth, length);
            } else if (pcbPlateCutoutType == 2) {
                pcb_plate_rectangle_cutout(pcbPlateWidth, length);
            }
        }
    }
}

// Increase widthRatio for larger supports
module pcb_plate_support(widthRatio = 2/5) {
    width = erHorizontalPitch*erUnits*widthRatio;
    
    translate([pcbPlateThickness,0,-width])
    rotate([0,270,0])
    linear_extrude(height=pcbPlateThickness)
    polygon([
        [0,0],
        [width,0],
        [width,width]
    ]);
}

// offset is the distance in from the corner
module pcb_plate_screw_holes(pcbWidth, pcbLength, offset = 7) {
    module hole() {
        cylinder(h = pcbPlateThickness + 1, d = pcbPlateScrewDiam);
    }
    
    panelOffset = 20;
    zOffset = -pcbPlateThickness + 0.6;
    
    translate([offset, panelOffset, zOffset])
    hole();
    translate([pcbLength-offset, panelOffset, zOffset])
    hole();
    translate([offset, pcbWidth-offset, zOffset])
    hole();
    translate([pcbLength-offset, pcbWidth-offset, zOffset])
    hole();
}

module pcb_plate_triangle_cutouts(pcbWidth, pcbLength, offset = 10) {
    cutoutLength = (pcbWidth - offset*3)/2;
    
    module cutout() {
        translate([0, 0, -0.5])
        linear_extrude(height = pcbPlateThickness + 1)
        polygon([
            [0, 0],
            [cutoutLength, 0],
            [cutoutLength, cutoutLength]
        ]);
    }
    
    module cutoutPair() {
        translate([offset*1.5, offset, 0])
        cutout();
        
        translate([offset*4, offset*1.5+cutoutLength, 0])
        rotate([0, 0, 180])
        cutout();
    }
    
    translate([0, 0, 0])
    cutoutPair();
    translate([offset*3, 0, 0])
    cutoutPair();
    translate([offset*6, 0, 0])
    cutoutPair();
    
    translate([0, offset*3.5, 0])
    cutoutPair();
    translate([offset*3, offset*3.5, 0])
    cutoutPair();
    translate([offset*6, offset*3.5, 0])
    cutoutPair();
}

module pcb_plate_rectangle_cutout(pcbWidth, pcbLength, offset = 10) {
    translate([offset*1.5, offset*1.0, -0.5])
    cube([
        pcbLength - offset*3.0,
        pcbWidth - offset*2.0,
        pcbPlateThickness + 1
    ]);
}