// include instead of use, so we get the pitch
include <gridfinity_constants.scad>
include <module_gridfinity.scad>

iAllowConnectorsFront = 0;
iAllowConnectorsBack = 1;
iAllowConnectorsLeft = 2;
iAllowConnectorsRight = 3;

show_frame_connector_demo = false;
if(show_frame_connector_demo){
  $fn = 64;
  translate([0,0,0]) {
    ClippedWall(fullIntersection = true);
    translate([15,0,0])
    ClipConnector(fullIntersection=true);
    translate([30,0,0])
    ClipCutter(fullIntersection=true);
   }

  translate([0,15,0]) {
    ClippedWall(straightIntersection = true);
    translate([15,0,0])
    ClipConnector(straightIntersection = true);
    translate([30,0,0])
    ClipCutter(straightIntersection = true);
   }

  translate([0,30,0]) {
    ClippedWall(cornerIntersection = true);
    //translate([15,0,0])
    //ClipConnector(cornerIntersection = true);
    translate([30,0,0])
    ClipCutter(cornerIntersection = true);
  }

  translate([0,45,0]) {
    ClippedWall(straightWall = true);
    translate([15,0,0])
    ClipConnector(straightWall = true);
    translate([30,0,0])
    ClipCutter(straightWall = true);
   }
  
  translate([0,-15,0])
  ButterFlyConnector();
  
  translate([0,-30,0])
  wall_snaps_cavity();
  
  translate([10,-30,0])
  wall_snaps_additive();
  
  translate([20,-30,0])
  sample(size = [10,10,4]){
    wall_snaps_cavity(lock_height = 2, style = ConnectorSnapsStyle_larger);
    wall_snaps_additive(lock_height = 2, style = ConnectorSnapsStyle_larger);
  }
  
  translate([20,-50,0])
  sample(size = [10,10,4]){
    wall_snaps_cavity(lock_height = 2, style = ConnectorSnapsStyle_smaller);
    wall_snaps_additive(lock_height = 2, style = ConnectorSnapsStyle_smaller);
  }
  
  translate([20,-70,0])
  sample(size = [15,2,4]){
    wall_snaps_cavity(lock_height = 2, style = ConnectorSnapsStyle_wall);
    wall_snaps_additive(lock_height = 2, style = ConnectorSnapsStyle_wall);
  }
  
  difference(){
    union(){
    
      translate([-5,0,0])
      cube([10,10,2]);
      
      rotate([0,0,180])
      wall_snaps_additive();
    }
    
    wall_snaps_cavity();
  }
 
}

module sample(
  size = [10,10,2]){
  
  difference(){
    union(){
    
      translate([-size.x/2,0,0])
      cube(size);
      
      if($children >=2) {
        rotate([0,0,180])
        children(1);
      }
    }
  
    if($children >=1) children(0); 
  }
}

iFrameConnectors_ConnectorOnly=0;
iFrameConnectors_Position=1;

iFrameConnectors_ClipEnabled=2;
iFrameConnectors_ClipSize=3;
iFrameConnectors_ClipTolerance=4;

iFrameConnectors_ButterflyEnabled=5;
iFrameConnectors_ButterflySize=6;
iFrameConnectors_ButterflyRadius=7;
iFrameConnectors_ButterflyTolerance=8;

iFrameConnectors_FilamentEnabled=9;
iFrameConnectors_FilamentDiameter=10;
iFrameConnectors_FilamentLength=11;

iFrameConnectors_SnapsStyle=12;
iFrameConnectors_SnapsClearance=13;
iFrameConnectors_ClipSnapEnabled=14;
iFrameConnectors_ClipSnapFrictionFit=15;
iFrameConnectors_ClipSnapZAxisFit=16;
iFrameConnectors_ClipSnapFlex=17;
iFrameConnectors_ClipBaseplatePreview=18;

FrameConnectorsPosition_disabled = "disabled";
FrameConnectorsPosition_centerwall = "center_wall";
FrameConnectorsPosition_intersection = "intersection";
FrameConnectorsPosition_both = "both";

FrameConnectorsPosition_values = [FrameConnectorsPosition_disabled, FrameConnectorsPosition_centerwall, FrameConnectorsPosition_intersection, FrameConnectorsPosition_both];
function validateFrameConnectorsPosition(value) = 
  assert(list_contains(FrameConnectorsPosition_values, value), typeerror("FrameConnectorsPosition", value))
  value;

ConnectorSnapsStyle_disabled = "disabled";
ConnectorSnapsStyle_larger = "larger";
ConnectorSnapsStyle_smaller = "smaller";
ConnectorSnapsStyle_wall = "wall";
ConnectorSnapsStyle_values = [ConnectorSnapsStyle_disabled,ConnectorSnapsStyle_larger,ConnectorSnapsStyle_smaller, ConnectorSnapsStyle_wall];
function validateConnectorSnapsStyle(value) = 
  assert(list_contains(ConnectorSnapsStyle_values, value), typeerror("ConnectorSnapsStyle", value))
  value;

function FrameConnectorSettings(
  connectorOnly = false, 
  connectorPosition = FrameConnectorsPosition_centerwall, 
  
  connectorClipEnabled = false,
  connectorClipSize = 10,
  connectorClipTolerance = 0.1, 
  
  connectorButterflyEnabled = false,
  connectorButterflySize = [5,4,1.5],
  connectorButterflyRadius = 0.1,
  connectorButterflyTolerance = 0.1,

  connectorFilamentEnabled = false,
  connectorFilamentDiameter = 2,
  connectorFilamentLength = 8,

  connectorSnapsStyle = ConnectorSnapsStyle_disabled,
  connectorSnapsClearance = 0.5,

  connectorClipSnapEnabled = false,
  connectorClipSnapFrictionFit = _clip_connector_snap_top_friction_fit(),
  connectorClipSnapZAxisFit = _clip_connector_snap_top_z_axis_fit(),
  connectorClipSnapFlex = _clip_connector_snap_top_snap_flex(),
  connectorClipBaseplatePreview = false) =
  let(
    result = [
      connectorOnly,
      connectorPosition,
      connectorClipEnabled,
      connectorClipSize,
      connectorClipTolerance,
      connectorButterflyEnabled,
      connectorButterflySize,
      connectorButterflyRadius,
      connectorButterflyTolerance,
      connectorFilamentEnabled,
      connectorFilamentDiameter,
      connectorFilamentLength,
      connectorSnapsStyle,
      connectorSnapsClearance,
      connectorClipSnapEnabled,
      connectorClipSnapFrictionFit,
      connectorClipSnapZAxisFit,
      connectorClipSnapFlex,
      connectorClipBaseplatePreview
      ],
    validatedResult = ValidateFrameConnectorSettings(result)
  ) validatedResult;

function ValidateFrameConnectorSettings(settings) =
  assert(is_list(settings), "FrameConnector Settings must be a list")
  assert(len(settings)==19, "FrameConnector Settings must length 19")
  
    [settings[iFrameConnectors_ConnectorOnly],
      validateFrameConnectorsPosition(settings[iFrameConnectors_Position]),
      settings[iFrameConnectors_ClipEnabled],
      settings[iFrameConnectors_ClipSize],
      settings[iFrameConnectors_ClipTolerance],
      settings[iFrameConnectors_ButterflyEnabled],
      settings[iFrameConnectors_ButterflySize],
      settings[iFrameConnectors_ButterflyRadius],
      settings[iFrameConnectors_ButterflyTolerance],
      settings[iFrameConnectors_FilamentEnabled],
      settings[iFrameConnectors_FilamentDiameter],
      settings[iFrameConnectors_FilamentLength],
      validateConnectorSnapsStyle(settings[iFrameConnectors_SnapsStyle]),
      settings[iFrameConnectors_SnapsClearance],
      settings[iFrameConnectors_ClipSnapEnabled],
      settings[iFrameConnectors_ClipSnapFrictionFit],
      settings[iFrameConnectors_ClipSnapZAxisFit],
      settings[iFrameConnectors_ClipSnapFlex],
      settings[iFrameConnectors_ClipBaseplatePreview]];
      
module wall_snaps_additive(
lock_height = 2,
clearance = 0,
hollow = 0.75,
style = ConnectorSnapsStyle_larger) {
  linear_extrude(height=lock_height+clearance*2)
  difference(){
    wall_snaps(lock_height = lock_height, style = style);
    
    offset(r=-hollow)
    wall_snaps(lock_height = lock_height, style = style);
  }
}

module wall_snaps_cavity(
  lock_height = 2,
  clearance = 0.2,
  style = ConnectorSnapsStyle_larger) {
  fudge_factor = 0.01;
  translate([0,0,-clearance])
  linear_extrude(height=lock_height+clearance*2)
  union(){
    wall_snaps(
      lock_height = lock_height,
      clearance = clearance,
      style = style);

    translate([1.25,0])
    rotate(45)
    square([1.5,1.5], center=true);
  }
}


module wall_snaps(
lock_height = 2,
clearance = 0,
style = ConnectorSnapsStyle_larger) {
  fudge_factor = 0.01;
 
  if(style == ConnectorSnapsStyle_larger){
    base_width = 1.5;
    long_nub_size = 2;
    long_nub_position = [-0.5,2.5]; 
    short_nub = 1;
    short_nub_position = [1.1,1.5];
    base_size = [base_width, 0.1];

    hull(){
      translate([0, -fudge_factor])
      square(base_size);
      
      translate(long_nub_position)
      circle(d=long_nub_size+clearance);
      
      translate(short_nub_position)
      circle(d=short_nub);
    }
  } else if (style == ConnectorSnapsStyle_smaller) {
    base_width = 1.5;
    long_nub_size = 2;
    long_nub_position = [0.5,1.5]; 
    short_nub = 1;
    short_nub_position = [1.1,1.5];
    base_size = [base_width, 0.1];
    
    hull(){
      translate([0, -fudge_factor])
      square(base_size);
      
      translate(long_nub_position)
      circle(d=long_nub_size+clearance);
      
      translate(short_nub_position)
      circle(d=short_nub);
    }
  } else if (style == ConnectorSnapsStyle_wall) {
    base_width = 1.5;
    long_nub_size = 2;
    long_nub_position = [0.5,1]; 
    short_nub = 1.5;
    short_nub_position = [0.95,1];
    base_size = [base_width, 0.1];
    
    hull(){
      translate([0, -fudge_factor])
      square(base_size);
      
      translate(long_nub_position)
      circle(d=long_nub_size+clearance);
      
      translate(short_nub_position)
      circle(d=short_nub);
    }
  }
}

module frame_connector_cavities(
  width = 1, 
  depth = 1,
  frameConnectorSettings = []) {

  assert(is_list(frameConnectorSettings), "frameConnectorSettings must be a list");
  
  connectorPosition = frameConnectorSettings[iFrameConnectors_Position];
  connectorClipEnabled = frameConnectorSettings[iFrameConnectors_ClipEnabled];
  connectorClipSize = frameConnectorSettings[iFrameConnectors_ClipSize];
  connectorClipTolerance = frameConnectorSettings[iFrameConnectors_ClipTolerance];
  connectorFrameHeight = is_undef($frameConnectorFrameHeight)
    ? 4
    : $frameConnectorFrameHeight;
  connectorClipSnapEnabled = frameConnectorSettings[iFrameConnectors_ClipSnapEnabled];
  connectorClipSnapFrictionFit =
    frameConnectorSettings[iFrameConnectors_ClipSnapFrictionFit];
  connectorClipSnapZAxisFit =
    frameConnectorSettings[iFrameConnectors_ClipSnapZAxisFit];
  connectorClipSnapFlex =
    frameConnectorSettings[iFrameConnectors_ClipSnapFlex];
  connectorButterflyEnabled = frameConnectorSettings[iFrameConnectors_ButterflyEnabled];
  connectorButterflySize = frameConnectorSettings[iFrameConnectors_ButterflySize];
  connectorButterflyRadius = frameConnectorSettings[iFrameConnectors_ButterflyRadius];
  connectorButterflyTolerance = frameConnectorSettings[iFrameConnectors_ButterflyTolerance];
  connectorSnapsStyle = frameConnectorSettings[iFrameConnectors_SnapsStyle];
  connectorSnapsClearance = frameConnectorSettings[iFrameConnectors_SnapsClearance];
  connectorFilamentEnabled = frameConnectorSettings[iFrameConnectors_FilamentEnabled];
  connectorFilamentLength = frameConnectorSettings[iFrameConnectors_FilamentLength];
  connectorFilamentDiameter = frameConnectorSettings[iFrameConnectors_FilamentDiameter];

  if(connectorButterflyEnabled || connectorFilamentEnabled || connectorClipEnabled || connectorSnapsStyle != ConnectorSnapsStyle_disabled){
    union(){
      if(env_help_enabled("debug")) echo("frame_connector_cavities", gci=$gci, gc_size=$gc_size, gc_is_corner=$gc_is_corner, gc_position=$gc_position, width=width, depth=depth, connectorButterflyEnabled  = connectorButterflyEnabled, connectorFilamentEnabled = connectorFilamentEnabled, connectorClipEnabled = connectorClipEnabled, connectorClipSnapEnabled = connectorClipSnapEnabled, connectorSnapsStyle = connectorSnapsStyle);
        
      if(connectorPosition == "center_wall" || connectorPosition == "both")
      PositionCellCenterConnector(
        left=$gci.x==0&&$gc_size.x==1&&$gc_size.y==1 && $allowConnectors[iAllowConnectorsLeft],
        right=$gci.x>=$gc_count.x-1&&$gc_size.x==1&&$gc_size.y==1 && $allowConnectors[iAllowConnectorsRight],
        front=$gci.y==0&&$gc_size.x==1&&$gc_size.y==1 && $allowConnectors[iAllowConnectorsFront],
        back=$gci.y>=$gc_count.y-1&&$gc_size.x==1&&$gc_size.y==1&& $allowConnectors[iAllowConnectorsBack]) {
          if($preview)
            *rotate([0,0,90])
            cylinder_printable(h=10,r=1);

          if(connectorClipEnabled)
            ClipCutter(size=connectorClipSize,
              height= 0.8, //height of bevel1_top
              frameHeight = connectorFrameHeight,
              clearance = connectorClipTolerance,
              cornerRadius = env_corner_radius(),
              clipSnapEnabled = connectorClipSnapEnabled,
              clipSnapFrictionFit = connectorClipSnapFrictionFit,
              clipSnapZAxisFit = connectorClipSnapZAxisFit,
              clipSnapFlex = connectorClipSnapFlex,
              straightWall=true);
        
          if(connectorButterflyEnabled)
            translate([0,0,-$frameBaseHeight])
            rotate([0,0,90])
            ButterFlyConnector(
              size=connectorButterflySize,
              r=connectorButterflyRadius,
              clearance = connectorButterflyTolerance,
              taper=false,half=false);

          if(connectorFilamentEnabled)
            translate([0,0,-$frameBaseHeight/2])
            FilamentCutter(
              l=connectorFilamentLength,
              d=connectorFilamentDiameter);
          
          if(connectorSnapsStyle != ConnectorSnapsStyle_disabled)
            translate([0,0,-$frameBaseHeight])
            rotate([0,0,270])
            wall_snaps_cavity(
              lock_height = 2,
              clearance = connectorSnapsClearance,
              style = ConnectorSnapsStyle_wall);
          }

        if(connectorPosition == "intersection" || connectorPosition == "both")
        PositionCellCornerConnector(
        left=$gci.x==0&&$gc_size.x==1&&$gc_size.y==1,
        right=$gci.x>=$gc_count.x-1 && $gc_size.x==1&&$gc_size.y==1,
        front=$gci.y==0&&$gc_size.x==1&&$gc_size.y==1,
        back=$gci.y>=$gc_count.y-1&&$gc_size.x==1&&$gc_size.y==1) {
       
          if($preview)
            *rotate([0,0,90])
            cylinder_printable(h=$corner ? 20 : 15,r=2);

          if(connectorClipEnabled)
            rotate([0,0,270])
            ClipCutter(size=connectorClipSize,
              height= 0.8, //height of bevel1_top
              frameHeight = connectorFrameHeight,
              clearance = connectorClipTolerance,
              cornerRadius = env_corner_radius(),
              clipSnapEnabled = connectorClipSnapEnabled,
              clipSnapFrictionFit = connectorClipSnapFrictionFit,
              clipSnapZAxisFit = connectorClipSnapZAxisFit,
              clipSnapFlex = connectorClipSnapFlex,
              straightIntersection = !$corner,
              cornerIntersection = $corner);
        
          if(connectorButterflyEnabled && !$corner)
            translate([0,0,-$frameBaseHeight])
            rotate([0,0,90])
            ButterFlyConnector(
              size=connectorButterflySize,
              r=connectorButterflyRadius,
              clearance = connectorButterflyTolerance,
              taper=false,half=false);

         if(connectorSnapsStyle != ConnectorSnapsStyle_disabled && !$corner)
            translate([0,0,-$frameBaseHeight])
            rotate([0,0,270])
            wall_snaps_cavity(
              lock_height = 2,
              clearance = connectorSnapsClearance,
              style = connectorSnapsStyle);
  
          if(connectorFilamentEnabled && !$corner)
            translate([0,0,-$frameBaseHeight/2])
            FilamentCutter(
              l=connectorFilamentLength,
              d=connectorFilamentDiameter);
        }
    }
  }
}

module frame_connectors_additives(
  width = 1, 
  depth = 1,
  frameConnectorSettings = []) {

  assert(is_list(frameConnectorSettings), "frameConnectorSettings must be a list");
  
  connectorPosition = frameConnectorSettings[iFrameConnectors_Position];
  connectorClipEnabled = frameConnectorSettings[iFrameConnectors_ClipEnabled];
  connectorClipSize = frameConnectorSettings[iFrameConnectors_ClipSize];
  connectorClipTolerance = frameConnectorSettings[iFrameConnectors_ClipTolerance];
  connectorButterflyEnabled = frameConnectorSettings[iFrameConnectors_ButterflyEnabled];
  connectorButterflySize = frameConnectorSettings[iFrameConnectors_ButterflySize];
  connectorButterflyRadius = frameConnectorSettings[iFrameConnectors_ButterflyRadius];
  connectorButterflyTolerance = frameConnectorSettings[iFrameConnectors_ButterflyTolerance];
  connectorSnapsStyle = frameConnectorSettings[iFrameConnectors_SnapsStyle];
  connectorSnapsClearance = frameConnectorSettings[iFrameConnectors_SnapsClearance];
  connectorFilamentEnabled = frameConnectorSettings[iFrameConnectors_FilamentEnabled];
  connectorFilamentLength = frameConnectorSettings[iFrameConnectors_FilamentLength];
  connectorFilamentDiameter = frameConnectorSettings[iFrameConnectors_FilamentDiameter];

  if(connectorButterflyEnabled || connectorFilamentEnabled || connectorClipEnabled || connectorSnapsStyle != ConnectorSnapsStyle_disabled){
    union(){
      if(env_help_enabled("debug")) echo("frame_connectors_additives", gci=$gci, gc_size=$gc_size, gc_is_corner=$gc_is_corner, gc_position=$gc_position, width=width, depth=depth, connectorButterflyEnabled  = connectorButterflyEnabled, connectorFilamentEnabled = connectorFilamentEnabled, connectorClipEnabled = connectorClipEnabled, connectorSnapsStyle = connectorSnapsStyle);

      if(connectorPosition == "center_wall" || connectorPosition == "both")
      PositionCellCenterConnector(
      left=$gci.x==0&&$gc_size.x==1&&$gc_size.y==1 && $allowConnectors[iAllowConnectorsLeft],
      right=$gci.x>=$gc_count.x-1&&$gc_size.x==1&&$gc_size.y==1 && $allowConnectors[iAllowConnectorsRight],
      front=$gci.y==0&&$gc_size.x==1&&$gc_size.y==1 && $allowConnectors[iAllowConnectorsFront],
      back=$gci.y>=$gc_count.y-1&&$gc_size.x==1&&$gc_size.y==1&& $allowConnectors[iAllowConnectorsBack]) {
        
        if(connectorSnapsStyle != ConnectorSnapsStyle_disabled)
          #translate([0,0,-$frameBaseHeight])
          rotate([0,0,90])
          wall_snaps_additive(
            lock_height = 2,
            clearance = connectorSnapsClearance,
            style = ConnectorSnapsStyle_wall);
      }

          
      if(connectorPosition == "intersection" || connectorPosition == "both")
      PositionCellCornerConnector(
      left=$gci.x==0&&$gc_size.x==1&&$gc_size.y==1,
      right=$gci.x>=$gc_count.x-1 && $gc_size.x==1&&$gc_size.y==1,
      front=$gci.y==0&&$gc_size.x==1&&$gc_size.y==1,
      back=$gci.y>=$gc_count.y-1&&$gc_size.x==1&&$gc_size.y==1) {
   
       if(connectorSnapsStyle != ConnectorSnapsStyle_disabled && !$corner)
          translate([0,0,-$frameBaseHeight])
          rotate([0,0,90])
          wall_snaps_additive(
            lock_height = 2,
            style = connectorSnapsStyle);
      }
    }
  }
}

module frame_connector_clip_baseplate_previews(
  width = 1,
  depth = 1,
  frameHeight = 4,
  frameConnectorSettings = []) {

  assert(is_list(frameConnectorSettings), "frameConnectorSettings must be a list");

  connectorPosition = frameConnectorSettings[iFrameConnectors_Position];
  connectorClipEnabled = frameConnectorSettings[iFrameConnectors_ClipEnabled];
  connectorClipBaseplatePreview =
    frameConnectorSettings[iFrameConnectors_ClipBaseplatePreview];

  if(connectorClipEnabled && connectorClipBaseplatePreview) {
    canPreviewStraight =
      connectorPosition == "center_wall" || connectorPosition == "both";
    canPreviewIntersection =
      connectorPosition == "intersection" || connectorPosition == "both";

    color("lightgray")
    union(){
      if(canPreviewStraight)
        _frame_connector_clip_baseplate_preview_straight(
          width=width,
          depth=depth,
          frameHeight=frameHeight,
          frameConnectorSettings=frameConnectorSettings);

      if(canPreviewIntersection) {
        _frame_connector_clip_baseplate_preview_tee(
          width=width,
          depth=depth,
          frameHeight=frameHeight,
          frameConnectorSettings=frameConnectorSettings);
        _frame_connector_clip_baseplate_preview_cross(
          width=width,
          depth=depth,
          frameHeight=frameHeight,
          frameConnectorSettings=frameConnectorSettings);
      }
    }
  }
}

module _frame_connector_clip_baseplate_preview_straight(
  width,
  depth,
  frameHeight,
  frameConnectorSettings) {

  if(_frame_connector_side_allowed(iAllowConnectorsFront)) {
    translate([env_pitch().x/2,0,0])
    rotate([0,0,90])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightWall=true);
  } else if(_frame_connector_side_allowed(iAllowConnectorsLeft)) {
    translate([0,env_pitch().y/2,0])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightWall=true);
  } else if(_frame_connector_side_allowed(iAllowConnectorsBack)) {
    translate([env_pitch().x/2,depth*env_pitch().y,0])
    rotate([0,0,270])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightWall=true);
  } else if(_frame_connector_side_allowed(iAllowConnectorsRight)) {
    translate([width*env_pitch().x,env_pitch().y/2,0])
    rotate([0,0,180])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightWall=true);
  }
}

module _frame_connector_clip_baseplate_preview_tee(
  width,
  depth,
  frameHeight,
  frameConnectorSettings) {

  if(width >= 2 && _frame_connector_side_allowed(iAllowConnectorsFront)) {
    translate([env_pitch().x,0,0])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightIntersection=true);
  } else if(depth >= 2 && _frame_connector_side_allowed(iAllowConnectorsLeft)) {
    translate([0,env_pitch().y,0])
    rotate([0,0,270])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightIntersection=true);
  } else if(width >= 2 && _frame_connector_side_allowed(iAllowConnectorsBack)) {
    translate([env_pitch().x,depth*env_pitch().y,0])
    rotate([0,0,180])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightIntersection=true);
  } else if(depth >= 2 && _frame_connector_side_allowed(iAllowConnectorsRight)) {
    translate([width*env_pitch().x,env_pitch().y,0])
    rotate([0,0,90])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        straightIntersection=true);
  }
}

module _frame_connector_clip_baseplate_preview_cross(
  width,
  depth,
  frameHeight,
  frameConnectorSettings) {

  if(_frame_connector_side_allowed(iAllowConnectorsFront)
      && _frame_connector_side_allowed(iAllowConnectorsLeft)) {
    _frame_connector_clip_baseplate_preview_connector(
      frameHeight=frameHeight,
      frameConnectorSettings=frameConnectorSettings,
      fullIntersection=true);
  } else if(_frame_connector_side_allowed(iAllowConnectorsFront)
      && _frame_connector_side_allowed(iAllowConnectorsRight)) {
    translate([width*env_pitch().x,0,0])
    rotate([0,0,90])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        fullIntersection=true);
  } else if(_frame_connector_side_allowed(iAllowConnectorsBack)
      && _frame_connector_side_allowed(iAllowConnectorsRight)) {
    translate([width*env_pitch().x,depth*env_pitch().y,0])
    rotate([0,0,180])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        fullIntersection=true);
  } else if(_frame_connector_side_allowed(iAllowConnectorsBack)
      && _frame_connector_side_allowed(iAllowConnectorsLeft)) {
    translate([0,depth*env_pitch().y,0])
    rotate([0,0,270])
      _frame_connector_clip_baseplate_preview_connector(
        frameHeight=frameHeight,
        frameConnectorSettings=frameConnectorSettings,
        fullIntersection=true);
  }
}

module _frame_connector_clip_baseplate_preview_connector(
  frameHeight,
  frameConnectorSettings,
  straightWall = false,
  straightIntersection = false,
  fullIntersection = false) {

  connectorClipSize = frameConnectorSettings[iFrameConnectors_ClipSize];
  connectorClipTolerance = frameConnectorSettings[iFrameConnectors_ClipTolerance];
  connectorClipSnapEnabled =
    frameConnectorSettings[iFrameConnectors_ClipSnapEnabled];
  connectorClipSnapFrictionFit =
    frameConnectorSettings[iFrameConnectors_ClipSnapFrictionFit];
  connectorClipSnapZAxisFit =
    frameConnectorSettings[iFrameConnectors_ClipSnapZAxisFit];
  connectorClipSnapFlex =
    frameConnectorSettings[iFrameConnectors_ClipSnapFlex];

  translate([0, 0, _clip_cutter_insert_z(height=0.8, clearance=connectorClipTolerance)])
  ClipConnector(
    size=connectorClipSize,
    height=0.8,
    frameHeight=frameHeight,
    clearance=connectorClipTolerance,
    cornerRadius=env_corner_radius(),
    clipSnapEnabled=connectorClipSnapEnabled,
    clipSnapFrictionFit=connectorClipSnapFrictionFit,
    clipSnapZAxisFit=connectorClipSnapZAxisFit,
    clipSnapFlex=connectorClipSnapFlex,
    straightWall=straightWall,
    straightIntersection=straightIntersection,
    fullIntersection=fullIntersection);
}

function _frame_connector_side_allowed(index) =
  !is_undef($allowConnectors)
    && is_list($allowConnectors)
    && len($allowConnectors) > index
    && $allowConnectors[index];

module PositionCellCenterConnector(left, right,front,back){
    if(left)
      translate([0,env_pitch().y/2,0])
      children();
    if(right)
      translate([env_pitch().x,env_pitch().y/2,0])
      rotate([0,0,180])
      children();
    if(front)
      translate([env_pitch().x/2,0,0])
      rotate([0,0,90])
      children();
    if(back)
      translate([env_pitch().x/2,env_pitch().y,0])
      rotate([0,0,270])
      children();
}

module PositionCellCornerConnector(left, right, front, back){
  if(left || right || front || back)
  {
    if(left && front) {
      if($allowConnectors[iAllowConnectorsLeft] && $allowConnectors[iAllowConnectorsFront])
        let($corner = true)
        rotate([0,0,90])
        children();

      let($corner = false){
        if($allowConnectors[iAllowConnectorsFront])
        translate([env_pitch().x,0,0])
        rotate([0,0,90])
        children();
        
        if($allowConnectors[iAllowConnectorsLeft])
        translate([0,env_pitch().y,0])
        children();
      }
    }

    if(left && back) {
      if($allowConnectors[iAllowConnectorsLeft] && $allowConnectors[iAllowConnectorsBack])
        let($corner = true)
        translate([0,env_pitch().y,0])
        children();

      let($corner = false) {
        if($allowConnectors[iAllowConnectorsLeft])
        children();
        
        if($allowConnectors[iAllowConnectorsBack])
        translate([env_pitch().x,env_pitch().y,0])
        rotate([0,0,270])
        children();
      }
    }

    if(right && front){
      if($allowConnectors[iAllowConnectorsRight] && $allowConnectors[iAllowConnectorsFront])
        let($corner = true)
        translate([env_pitch().x,0,0])
        rotate([0,0,180])
        children();

      let($corner = false) {
        if($allowConnectors[iAllowConnectorsFront])
        rotate([0,0,90])
        children();
        
        if($allowConnectors[iAllowConnectorsRight])
        translate([env_pitch().x,env_pitch().y,0])
        rotate([0,0,180])
        children();
      }
    }

    if(right && back){
      if($allowConnectors[iAllowConnectorsRight] && $allowConnectors[iAllowConnectorsBack])
        let($corner = true)
        translate([env_pitch().x,env_pitch().y,0])
        rotate([0,0,270])
        children();

      let($corner = false) {
        if($allowConnectors[iAllowConnectorsRight])
        translate([env_pitch().x,0,0])
        rotate([0,0,180])
        children();

        if($allowConnectors[iAllowConnectorsBack])
        translate([0,env_pitch().y,0])
        rotate([0,0,270])
        children();
      }
    }

    if(left && !back && !front && !front && $gci.y<=$gc_count.y-3 && $allowConnectors[iAllowConnectorsLeft]){
      $corner = false;
      translate([0,env_pitch().y,0])
      children();
    }
    if(front && !left && !right && $gci.x<=$gc_count.x-3 && $allowConnectors[iAllowConnectorsFront]){
      $corner = false;
      translate([env_pitch().x,0,0])
      rotate([0,0,90])
      children();
    }
    if(right && !back && !front && $gci.y<=$gc_count.y-3 && $allowConnectors[iAllowConnectorsRight]){
      $corner = false;
      translate([env_pitch().x,env_pitch().y,0])
      rotate([0,0,180])
      children();
    }

    if(back && !left && !right && $gci.x<=$gc_count.x-3 && $allowConnectors[iAllowConnectorsBack]){
      $corner = false;
      translate([env_pitch().x,env_pitch().y,0])
      rotate([0,0,270])
      children();
    }
  }
}

module FilamentCutter(
    l = 5, 
    d = 1.75){
  translate([-fudgeFactor, 0,0])
  rotate([90,0,90])
  cylinder_printable(h=l,d=d);
}

module cylinder_printable(h=10,r=1,d,center=false){
  r = is_num(d) ? d/2 : r;
  d=2*r;

  flat_top_width = d/2.5;
  flat_top_height = d/2+0.5;

  translate(center ? [0,0,0] : [0,0,h/2])
  hull(){
    //Printable Cylinder
    cylinder(h=h,d=d, center=true);
    translate([-flat_top_width/2,d/2-flat_top_height,-h/2])
      cube([flat_top_width,flat_top_height,h]); 
  }
}

function _clip_cutter_insert_z(height=0.8, clearance=0.1) =
  height - clearance/2 + fudgeFactor;

// Cutout geometry in the same local coordinate system as ClipConnector().
module ClipCutterShape(
  size=10,
  height= 0.8, //height of bevel1_top
  frameHeight = 4,
  clippedWallThickness = 2,
  clippedWallHeight = 1.6,
  clearance = 0.1,
  cornerRadius = gf_cup_corner_radius,
  clipSnapEnabled = false,
  clipSnapFrictionFit = _clip_connector_snap_top_friction_fit(),
  clipSnapZAxisFit = _clip_connector_snap_top_z_axis_fit(),
  clipSnapFlex = _clip_connector_snap_top_snap_flex(),
  clipSnapPreview = false,
  straightWall = false,
  straightIntersection = false,
  cornerIntersection = false,
  fullIntersection = false){

  effectiveHeight = height-clearance/2;
  if(clipSnapEnabled) {
    render(convexity=8)
    ClipConnectorSnapProfileSwept(
      size=size+clearance*2,
      height=height,
      frameHeight=frameHeight,
      clearance=clearance,
      cornerRadius=cornerRadius,
      cutout=true,
      frictionFit=clipSnapFrictionFit,
      zAxisFit=clipSnapZAxisFit,
      snapFlex=clipSnapFlex,
      preview=clipSnapPreview,
      straightWall=straightWall,
      straightIntersection=straightIntersection,
      cornerIntersection=cornerIntersection);
  } else {
    difference(){
      if(straightIntersection) {
        translate([-size/2-clearance,-fudgeFactor,0])
          cube(size=[size+clearance*2,size/2+clearance+fudgeFactor,frameHeight-effectiveHeight+fudgeFactor]);
      } else if(cornerIntersection) {
        translate([-fudgeFactor,-fudgeFactor,0])
          cube(size=[size/2+fudgeFactor+clearance,size/2+clearance+fudgeFactor,frameHeight-effectiveHeight+fudgeFactor]);
      } else {
        translate([-size/2-clearance,-size/2-clearance,0])
          cube(size=[size+clearance*2,size+clearance*2,frameHeight-effectiveHeight+fudgeFactor]);
      }
      //clipped inner wall
      translate([0,0,-fudgeFactor])
      ClippedWall(
        clipSize=size+clearance*2,
        cornerRadius = cornerRadius,
        clippedWallThickness = clippedWallThickness,
        clippedWallHeight = clippedWallHeight-clearance,
        straightWall = straightWall,
        straightIntersection = straightIntersection,
        cornerIntersection = cornerIntersection,
        fullIntersection = fullIntersection);
    }
  }
}

//What is to be removed from the baseplate, to make room for the corner clip
module ClipCutter(
  size=10, 
  height= 0.8, //height of bevel1_top
  frameHeight = 4,
  clippedWallThickness = 2,
  clippedWallHeight = 1.6,
  clearance = 0.1,
  cornerRadius = gf_cup_corner_radius,
  clipSnapEnabled = false,
  clipSnapFrictionFit = _clip_connector_snap_top_friction_fit(),
  clipSnapZAxisFit = _clip_connector_snap_top_z_axis_fit(),
  clipSnapFlex = _clip_connector_snap_top_snap_flex(),
  straightWall = false,
  straightIntersection = false,
  cornerIntersection = false,
  fullIntersection = false){

  translate([0,0,_clip_cutter_insert_z(height=height, clearance=clearance)])
  ClipCutterShape(
    size=size,
    height=height,
    frameHeight=frameHeight,
    clippedWallThickness=clippedWallThickness,
    clippedWallHeight=clippedWallHeight,
    clearance=clearance,
    cornerRadius=cornerRadius,
    clipSnapEnabled=clipSnapEnabled,
    clipSnapFrictionFit=clipSnapFrictionFit,
    clipSnapZAxisFit=clipSnapZAxisFit,
    clipSnapFlex=clipSnapFlex,
    straightWall=straightWall,
    straightIntersection=straightIntersection,
    cornerIntersection=cornerIntersection,
    fullIntersection=fullIntersection);
}

module ClipConnector(
  size=10, 
  height= 0.8, //height of bevel1_top
  frameHeight = 4,
  clippedWallThickness = 2,
  clippedWallHeight = 1.6,
  clearance = 0.1,
  cornerRadius = gf_cup_corner_radius,
  clipSnapEnabled = false,
  clipSnapFrictionFit = _clip_connector_snap_top_friction_fit(),
  clipSnapZAxisFit = _clip_connector_snap_top_z_axis_fit(),
  clipSnapFlex = _clip_connector_snap_top_snap_flex(),
  straightWall = false,
  straightIntersection = false,
  fullIntersection = false){
 
  render()
  if(clipSnapEnabled) {
    ClipConnectorSnapProfileSwept(
      size=size,
      height=height,
      frameHeight=frameHeight,
      clearance=clearance,
      cornerRadius=cornerRadius,
      cutout=false,
      frictionFit=clipSnapFrictionFit,
      zAxisFit=clipSnapZAxisFit,
      snapFlex=clipSnapFlex,
      straightWall=straightWall,
      straightIntersection=straightIntersection);
  } else {
    difference(){
      translate([
          -size/2,
          straightIntersection ? 0 : -size/2,
          0])
        cube(size=[size,
            straightIntersection ? size/2 : size,
            frameHeight-height]);

      if(!straightWall) {
        translate([-env_pitch().x,-env_pitch().y,-height])
          frame_cavity(
            num_x=2,
            num_y=2);
      } else {
        translate([-env_pitch().x,-env_pitch().y/2,-height])
          frame_cavity(
            num_x=2,
            num_y=1);
      }

      //clipped inner wall
      translate([0,0,-fudgeFactor])
      ClippedWall(
        clipSize=size,
        cornerRadius = cornerRadius,
        clippedWallThickness = clippedWallThickness+clearance,
        clippedWallHeight = clippedWallHeight+clearance,
        straightWall = straightWall,
        straightIntersection = straightIntersection,
        fullIntersection = fullIntersection);
    }
  }
}

module ClipConnectorSnapProfileSwept(
  size=10,
  height=0.8,
  frameHeight=4,
  clearance=0.1,
  cornerRadius=gf_cup_corner_radius,
  cutout=false,
  frictionFit=_clip_connector_snap_top_friction_fit(),
  zAxisFit=_clip_connector_snap_top_z_axis_fit(),
  snapFlex=_clip_connector_snap_top_snap_flex(),
  preview=false,
  straightWall=false,
  straightIntersection=false,
  cornerIntersection=false) {

  profilePoints = _clip_connector_snap_top_profile_points(
    cutout=cutout,
    height=height,
    frameHeight=frameHeight,
    clearance=clearance,
    cornerRadius=cornerRadius,
    frictionFit=frictionFit,
    zAxisFit=zAxisFit,
    snapFlex=snapFlex,
    centerOverlap=_clip_connector_snap_top_center_overlap(
      cutout=cutout,
      preview=preview));
  profileOuterHalf = cutout
    ? _clip_connector_snap_top_sketch_mirror_x()
    : _clip_connector_snap_top_connector_outer_half_width(
        frictionFit=frictionFit,
        cornerRadius=cornerRadius);
  profileTopZ = _clip_connector_snap_top_profile_top_z(
    cutout=cutout,
    frameHeight=frameHeight,
    height=height,
    clearance=clearance);
  cutoutBoundaryOverlap = cutout
    ? _clip_connector_snap_top_boundary_overlap(preview=preview)
    : 0;
  // The star fill intentionally uses a radius reduced by fudgeFactor so it
  // overlaps the swept corner bodies. When the same cross fill is clipped into
  // a T or corner connector, the clipping plane needs the same tiny allowance
  // or the radius-to-straight tangency can leave a hairline gap.
  boundsBoundaryOverlap = max(
    cutoutBoundaryOverlap,
    !straightWall && (straightIntersection || cornerIntersection)
      ? fudgeFactor
      : 0);
  buildFullCrossBeforeClipping =
    !straightWall && (straightIntersection || cornerIntersection);

  intersection(){
    _clip_connector_snap_profile_bounds(
      size=size,
      profileTopZ=profileTopZ,
      straightIntersection=straightIntersection,
      cornerIntersection=cornerIntersection,
      boundaryOverlap=boundsBoundaryOverlap,
      topOverlap=cutoutBoundaryOverlap);

    union() {
      _clip_connector_profile_sweep(
        size=size,
        profileOuterHalf=profileOuterHalf,
        cornerRadius=cornerRadius,
        straightWall=straightWall,
        straightIntersection=buildFullCrossBeforeClipping ? false : straightIntersection,
        cornerIntersection=buildFullCrossBeforeClipping ? false : cornerIntersection)
        polygon(profilePoints);

      _clip_connector_snap_profile_top_fill(
        cornerRadius=cornerRadius,
        sweepProfileOuterHalf=profileOuterHalf,
        p9X=profileOuterHalf + cutoutBoundaryOverlap,
        bottomZ=_clip_connector_snap_top_fill_bottom_z(
          cutout=cutout,
          zAxisFit=zAxisFit,
          snapFlex=snapFlex),
        topZ=profileTopZ,
        straightWall=straightWall);
    }
  }
}

function _clip_connector_snap_top_profile_points(
  cutout=false,
  height=0.8,
  frameHeight=4,
  clearance=0.1,
  cornerRadius=gf_cup_corner_radius,
  frictionFit=_clip_connector_snap_top_friction_fit(),
  zAxisFit=_clip_connector_snap_top_z_axis_fit(),
  snapFlex=_clip_connector_snap_top_snap_flex(),
  centerOverlap=0) =
  assert(is_bool(cutout))
  let(
    outerHalf = cutout
      ? _clip_connector_snap_top_sketch_mirror_x()
      : _clip_connector_snap_top_connector_outer_half_width(
          frictionFit=frictionFit,
          cornerRadius=cornerRadius),
    bottomZ = cutout
      ? _clip_connector_snap_top_cutout_bottom_z()
      : _clip_connector_snap_top_connector_bottom_z(zAxisFit=zAxisFit),
    lowerProfileDrop = _clip_connector_snap_top_lower_profile_drop(),
    profileBottomZ = bottomZ - lowerProfileDrop,
    topZ = _clip_connector_snap_top_profile_top_z(
      cutout=cutout,
      frameHeight=frameHeight,
      height=height,
      clearance=clearance),
    lowerZ = cutout
      ? _clip_connector_snap_top_cutout_opening_lower_z()
      : _clip_connector_snap_top_connector_opening_lower_z(
          frictionFit=frictionFit,
          zAxisFit=zAxisFit),
    profileLowerZ = lowerZ - lowerProfileDrop,
    openingTopZ = cutout
      ? _clip_connector_snap_top_cutout_opening_top_z(snapFlex=snapFlex)
      : _clip_connector_snap_top_connector_opening_top_z(
          zAxisFit=zAxisFit,
          snapFlex=snapFlex),
    profileOpeningTopZ = openingTopZ - lowerProfileDrop,
    bottomHalfWidth = cutout
      ? _clip_connector_snap_top_cutout_opening_half_width()
      : _clip_connector_snap_top_connector_opening_half_width(
          frictionFit=frictionFit),
    lowerSnapHalfWidth = cutout
      ? _clip_connector_snap_top_cutout_opening_snap_half_width(
          snapFlex=snapFlex)
      : _clip_connector_snap_top_connector_opening_snap_half_width(
          frictionFit=frictionFit,
          snapFlex=snapFlex),
    upperSnapHalfWidth = lowerSnapHalfWidth,
    topHalfWidth = cutout
      ? _clip_connector_snap_top_cutout_opening_half_width()
      : _clip_connector_snap_top_connector_opening_top_half_width(
          zAxisFit=zAxisFit,
          frictionFit=frictionFit),
    lowerSnapZ = profileLowerZ + lowerSnapHalfWidth - bottomHalfWidth,
    upperSnapZ = profileOpeningTopZ - (upperSnapHalfWidth - topHalfWidth),
    innerBottomX = outerHalf - bottomHalfWidth,
    lowerSnapX = outerHalf - lowerSnapHalfWidth,
    upperSnapX = outerHalf - upperSnapHalfWidth,
    topInnerX = outerHalf - topHalfWidth,
    rawFootChamfer = cutout ? 0 : _clip_connector_snap_top_connector_foot_chamfer(),
    // The outside foot chamfer is a fixed connector profile feature. Clamp the
    // shared bottom chamfer size before it can cross into the snap contour and
    // create a self-intersecting polygon.
    maxFootChamfer = max(0, profileLowerZ - profileBottomZ - _clip_connector_snap_top_tolerance()),
    footChamfer = min(max(0, rawFootChamfer), maxFootChamfer),
    rawConnectorTopChamfer = cutout
      ? 0
      : _clip_connector_snap_top_outer_chamfer_size(
          height=height,
          clearance=clearance,
          topZ=topZ),
    maxOuterTopChamfer = min(
      outerHalf,
      max(0, topZ - bottomZ - _clip_connector_snap_top_tolerance())),
    connectorTopChamfer = min(max(0, rawConnectorTopChamfer), maxOuterTopChamfer))
  // Final sweep half-profile in the same X direction as the point list below:
  // left is the outside sweep edge (x=0), right is the opening/center side
  // (x=outerHalf). The rendered right-hand connector side appears mirrored
  // relative to this profile.
  //
  //                     P10 -------- P9
  //                    /             |
  //                   /              |
  //                  /       P7 ---- P8
  //                 /       /
  //                /      P6
  //              P11      |
  //              |        P5
  //              |         \
  //              |          P4
  //              |          |
  //              P0         P3
  //               \        /
  //                P1 -- P2
  //
  // The numbered sketch describes the connector profile. P0-P1 is the fixed
  // connector foot chamfer. P2-P5 is the lower snap contour. P6-P8 is the
  // inner opening. P10-P11 is the fixed connector top outside chamfer that
  // follows the Gridfinity baseplate taper. Cutouts use the same point builder
  // but substitute plain outer bottom/top edges instead of connector chamfers.
  concat(
    cutout || footChamfer <= 0
      ? [
          // Plain bottom fallback: cutouts and zero chamfers keep a straight edge
          [0, profileBottomZ], // P0/P1 collapsed to the plain cutout bottom
          [innerBottomX, profileBottomZ] // P2/P3 collapsed to the plain cutout bottom
        ]
      : footChamfer*2 <= innerBottomX
        ? [
            // Full connector foot: outside chamfer, bottom ledge, snap entry chamfer
            [0, profileBottomZ + footChamfer], // P0 outside foot wall
            [footChamfer, profileBottomZ], // P1 foot chamfer
            [innerBottomX - footChamfer, profileBottomZ], // P2 snap bottom ledge
            [innerBottomX, profileBottomZ + footChamfer] // P3 snap entry chamfer
          ]
        : [
            // Compressed connector foot: merge P1/P2 before the chamfer can cross
            [0, profileBottomZ + footChamfer], // P0 outside foot wall
            [innerBottomX/2, profileBottomZ + footChamfer - innerBottomX/2], // P1/P2 merged
            [innerBottomX, profileBottomZ + footChamfer] // P3 snap entry chamfer
          ],
    [
      [innerBottomX, profileLowerZ], // P4 lower snap wall
      [lowerSnapX, lowerSnapZ], // P5 snap nose
      [upperSnapX, upperSnapZ], // P6 inner opening lower shoulder
      [topInnerX, profileOpeningTopZ], // P7 inner opening upper shoulder
      [outerHalf + centerOverlap, profileOpeningTopZ], // P8 inner opening top
      [outerHalf + centerOverlap, topZ] // P9 center/top
    ],
    cutout || connectorTopChamfer <= 0
      ? [
          // Plain top fallback: cutouts and zero chamfers keep a square top edge
          [0, topZ] // P10/P11 collapsed to the plain cutout top
        ]
      : [
          // Gridfinity top chamfer: match the baseplate upper taper
          [connectorTopChamfer, topZ], // P10 top outside chamfer
          [0, topZ - connectorTopChamfer] // P11 outside top wall
        ]);

function _clip_connector_snap_top_outer_chamfer_size(
  height=0.8,
  clearance=0.1,
  topZ) =
  let(
    taperStartZ = _clip_connector_snap_top_gridfinity_upper_taper_start_z(
      height=height,
      clearance=clearance),
    chamfer = topZ - taperStartZ)
  min(max(0, chamfer), gf_baseplate_upper_taper_height);

function _clip_connector_snap_top_gridfinity_upper_taper_start_z(
  height=0.8,
  clearance=0.1) =
  // pad_oversize(margins=1) starts the upper cavity taper at its local
  // bevel2_bottom before ClipCutter() applies its insertion offset.
  _clip_connector_frame_cavity_upper_taper_start_z()
    - _clip_cutter_insert_z(height=height, clearance=clearance)
    - fudgeFactor;
function _clip_connector_frame_cavity_upper_taper_start_z() =
  // Mirrors pad_oversize()'s local bevel2_bottom.
  2.6;
// The legacy non-snap connector and ClipCutterShape both start at local z=0.
function _clip_connector_legacy_profile_bottom_z() = 0;
function _clip_connector_snap_top_lower_profile_drop() =
  _clip_connector_snap_top_cutout_bottom_z()
    - _clip_connector_legacy_profile_bottom_z();

function _clip_connector_snap_top_fill_bottom_z(
  cutout=false,
  zAxisFit=_clip_connector_snap_top_z_axis_fit(),
  snapFlex=_clip_connector_snap_top_snap_flex()) =
  let(
    lowerProfileDrop = _clip_connector_snap_top_lower_profile_drop(),
    openingTopZ = cutout
      ? _clip_connector_snap_top_cutout_opening_top_z(snapFlex=snapFlex)
      : _clip_connector_snap_top_connector_opening_top_z(
          zAxisFit=zAxisFit,
          snapFlex=snapFlex))
  openingTopZ - lowerProfileDrop;

function _clip_connector_snap_top_boundary_overlap(preview=false) =
  preview ? _clip_connector_snap_top_tolerance()
    : max(fudgeFactor, _clip_connector_snap_top_tolerance());
function _clip_connector_snap_top_center_overlap(cutout=false, preview=false) =
  cutout ? _clip_connector_snap_top_boundary_overlap(preview=preview) : 0;

function _clip_connector_snap_top_profile_top_z(
  cutout=false,
  frameHeight=4,
  height=0.8,
  clearance=0.1) =
  cutout
    ? _clip_connector_snap_top_cutout_top_z(
        frameHeight=frameHeight,
        height=height,
        clearance=clearance)
    : _clip_connector_snap_top_connector_top_z(
        frameHeight=frameHeight,
        height=height,
        clearance=clearance);

function _clip_connector_snap_top_sketch_width() = 5.30;
function _clip_connector_snap_top_sketch_mirror_x() =
  _clip_connector_snap_top_sketch_width()/2;
function _clip_connector_snap_top_sketch_top_z() = 4.15;
function _clip_connector_snap_top_cutout_bottom_z() = 0.60;
function _clip_connector_snap_top_cutout_opening_lower_z() =
  _clip_connector_snap_top_cutout_bottom_z() + 0.80;
function _clip_connector_snap_top_cutout_opening_top_z(
  snapFlex=_clip_connector_snap_top_snap_flex()) =
  _clip_connector_snap_top_cutout_opening_lower_z() + 0.50 + snapFlex*2;
function _clip_connector_snap_top_cutout_opening_half_width() = 0.90;
function _clip_connector_snap_top_cutout_opening_snap_half_width(
  snapFlex=_clip_connector_snap_top_snap_flex()) =
  _clip_connector_snap_top_cutout_opening_half_width() + snapFlex;

function _clip_connector_snap_top_connector_bottom_z(
  zAxisFit=_clip_connector_snap_top_z_axis_fit()) =
  _clip_connector_snap_top_cutout_bottom_z() + zAxisFit;
function _clip_connector_snap_top_connector_top_z(
  frameHeight=4,
  height=0.8,
  clearance=0.1) =
  // P9/P10 land on the baseplate top once the connector is shown at the same
  // insert Z as its cutout preview.
  frameHeight - _clip_cutter_insert_z(height=height, clearance=clearance);
function _clip_connector_snap_top_cutout_top_z(
  frameHeight=4,
  height=0.8,
  clearance=0.1) =
  max(
    _clip_connector_snap_top_sketch_top_z(),
    frameHeight - _clip_cutter_insert_z(height=height, clearance=clearance)
      + fudgeFactor);
function _clip_connector_snap_top_connector_outer_side_x(
  frictionFit=_clip_connector_snap_top_friction_fit()) =
  // Snap flex only needs room because the cutout profile flexes with it. The
  // connector cutouts span the whole baseplate rib here, so the outside body
  // width must stay independent from snapFlex.
  frictionFit;
function _clip_connector_snap_top_connector_outer_half_width(
  frictionFit=_clip_connector_snap_top_friction_fit(),
  cornerRadius=gf_cup_corner_radius) =
  let(
    sketchOuterHalf = _clip_connector_snap_top_sketch_mirror_x()
      - _clip_connector_snap_top_connector_outer_side_x(
          frictionFit=frictionFit),
    baseplateInnerHalf = _clip_connector_sweep_profile_outer_half_width(
      cornerRadius=cornerRadius))
  min(sketchOuterHalf, baseplateInnerHalf);
function _clip_connector_snap_top_diagonal_fit(
  frictionFit=_clip_connector_snap_top_friction_fit(),
  zAxisFit=_clip_connector_snap_top_z_axis_fit()) =
  max(frictionFit, zAxisFit);
function _clip_connector_snap_top_connector_opening_lower_z(
  frictionFit=_clip_connector_snap_top_friction_fit(),
  zAxisFit=_clip_connector_snap_top_z_axis_fit()) =
  _clip_connector_snap_top_cutout_opening_lower_z()
    - _clip_connector_snap_top_diagonal_fit(
      frictionFit=frictionFit,
      zAxisFit=zAxisFit)
    + frictionFit;
function _clip_connector_snap_top_connector_opening_half_width(
  frictionFit=_clip_connector_snap_top_friction_fit()) =
  _clip_connector_snap_top_cutout_opening_half_width() + frictionFit;
function _clip_connector_snap_top_connector_opening_top_z(
  zAxisFit=_clip_connector_snap_top_z_axis_fit(),
  snapFlex=_clip_connector_snap_top_snap_flex()) =
  _clip_connector_snap_top_cutout_opening_top_z(snapFlex=snapFlex) + zAxisFit;
function _clip_connector_snap_top_connector_opening_top_half_width(
  frictionFit=_clip_connector_snap_top_friction_fit(),
  zAxisFit=_clip_connector_snap_top_z_axis_fit()) =
  _clip_connector_snap_top_cutout_opening_half_width()
    + _clip_connector_snap_top_diagonal_fit(
      frictionFit=frictionFit,
      zAxisFit=zAxisFit)
    - zAxisFit;
function _clip_connector_snap_top_connector_opening_snap_half_width(
  frictionFit=_clip_connector_snap_top_friction_fit(),
  snapFlex=_clip_connector_snap_top_snap_flex()) =
  _clip_connector_snap_top_connector_opening_half_width(
    frictionFit=frictionFit)
    + snapFlex;
function _clip_connector_snap_top_tolerance() = 0.02;
function _clip_connector_snap_top_friction_fit() = 0.10;
function _clip_connector_snap_top_z_axis_fit() = 0.20;
function _clip_connector_snap_top_snap_flex() = 0.30;
function _clip_connector_snap_top_connector_foot_chamfer() = 0.20;

module _clip_connector_profile_sweep(
  size=10,
  profileOuterHalf,
  cornerRadius=gf_cup_corner_radius,
  straightWall=false,
  straightIntersection=false,
  cornerIntersection=false) {
  centerOffset = cornerRadius+env_clearance().x/2;
  pathRadius = centerOffset - profileOuterHalf;

  if(straightWall) {
    _clip_connector_sweep_y_boundary_segment(
      x=-profileOuterHalf,
      y0=-size/2,
      y1=size/2,
      normalSignX=1)
      children();
    _clip_connector_sweep_y_boundary_segment(
      x=profileOuterHalf,
      y0=-size/2,
      y1=size/2,
      normalSignX=-1)
      children();
  } else {
    for(corner=_clip_connector_cavity_path_corners(
      centerOffset=centerOffset,
      straightIntersection=straightIntersection,
      cornerIntersection=cornerIntersection)) {
      center = corner[0];
      sideX = corner[1];
      sideY = corner[2];

      _clip_connector_sweep_corner_boundary(
        center=center,
        sideX=sideX,
        sideY=sideY,
        size=size,
        radius=pathRadius)
        children();
    }
  }
}

module _clip_connector_sweep_y_boundary_segment(x, y0, y1, normalSignX=1) {
  translate([x, (y0+y1)/2, 0])
  mirror([normalSignX < 0 ? 1 : 0, 0, 0])
  rotate([90,0,0])
  linear_extrude(height=abs(y1-y0), center=true, convexity=8)
    children();
}

module _clip_connector_sweep_x_boundary_segment(y, x0, x1, normalSignY=1) {
  translate([(x0+x1)/2, y, 0])
  rotate([0,0,90])
  mirror([normalSignY < 0 ? 1 : 0, 0, 0])
  rotate([90,0,0])
  linear_extrude(height=abs(x1-x0), center=true, convexity=8)
    children();
}

module _clip_connector_sweep_corner_boundary(
  center,
  sideX,
  sideY,
  size,
  radius) {
  _clip_connector_sweep_arc(
    center=center,
    radius=radius,
    startAngle=_clip_connector_corner_arc_start_angle(sideX, sideY),
    angle=90)
    children();

  _clip_connector_sweep_y_boundary_segment(
    x=center.x-sideX*radius,
    // Extend the straight sweep legs a hair into the rotated corner sweep so
    // the tangent handoff is a real overlap instead of an exact edge contact.
    y0=center.y-sideY*fudgeFactor,
    y1=sideY*size/2,
    normalSignX=-sideX)
    children();

  _clip_connector_sweep_x_boundary_segment(
    y=center.y-sideY*radius,
    x0=center.x-sideX*fudgeFactor,
    x1=sideX*size/2,
    normalSignY=-sideY)
    children();
}

function _clip_connector_corner_arc_start_angle(sideX, sideY) =
  sideX < 0 && sideY > 0 ? 270
  : sideX > 0 && sideY > 0 ? 180
  : sideX < 0 && sideY < 0 ? 0
  : 90;

module _clip_connector_sweep_arc(center, radius, startAngle, angle) {
  translate([center.x, center.y, 0])
  rotate([0,0,startAngle])
  rotate_extrude(angle=angle, convexity=8)
    translate([radius,0,0])
    children();
}

module _clip_connector_snap_profile_top_fill(
  cornerRadius=gf_cup_corner_radius,
  sweepProfileOuterHalf,
  p9X,
  bottomZ,
  topZ,
  straightWall=false) {

  if(!straightWall && topZ > bottomZ + _clip_connector_snap_top_tolerance()) {
    centerOffset = cornerRadius+env_clearance().x/2;
    pathRadius = centerOffset - sweepProfileOuterHalf;
    gapRadius = pathRadius + p9X - fudgeFactor;

    translate([0,0,bottomZ])
    linear_extrude(height=topZ-bottomZ, convexity=8)
      polygon(_clip_connector_snap_cross_gap_points(
        centerOffset=centerOffset,
        radius=gapRadius));
  }
}

function _clip_connector_snap_cross_gap_points(
  centerOffset,
  radius) =
  let(
    arcSteps = _clip_connector_arc_steps(
      radius=radius,
      angle=90))
  concat(
    [[radius-centerOffset, centerOffset]],
    _clip_connector_arc_points(
      center=[-centerOffset, centerOffset],
      radius=radius,
      startAngle=0,
      endAngle=-90,
      steps=arcSteps,
      skipFirst=true),
    _clip_connector_arc_points(
      center=[-centerOffset, -centerOffset],
      radius=radius,
      startAngle=90,
      endAngle=0,
      steps=arcSteps,
      skipFirst=true),
    _clip_connector_arc_points(
      center=[centerOffset, -centerOffset],
      radius=radius,
      startAngle=180,
      endAngle=90,
      steps=arcSteps,
      skipFirst=true),
    _clip_connector_arc_points(
      center=[centerOffset, centerOffset],
      radius=radius,
      startAngle=270,
      endAngle=180,
      steps=arcSteps,
      skipFirst=true));

function _clip_connector_arc_points(
  center,
  radius,
  startAngle,
  endAngle,
  steps=undef,
  skipFirst=false) =
  let(
    angle = abs(endAngle-startAngle),
    resolvedSteps = is_undef(steps)
      ? _clip_connector_arc_steps(radius=radius, angle=angle)
      : steps)
  [
    for(i=[(skipFirst ? 1 : 0):resolvedSteps])
      let(angle = startAngle + (endAngle-startAngle)*i/resolvedSteps)
      [center.x + radius*cos(angle), center.y + radius*sin(angle)]
  ];

function _clip_connector_arc_steps(radius, angle) =
  $fn > 0
    ? max(1, ceil($fn * angle / 360))
    : max(
        1,
        ceil(angle / max($fa, 0.01)),
        ceil(2 * PI * radius * angle / 360 / max($fs, 0.001)));

function _clip_connector_cavity_path_corners(
  centerOffset,
  straightIntersection=false,
  cornerIntersection=false) =
  cornerIntersection
    ? [[[centerOffset, centerOffset], 1, 1]]
  : straightIntersection
    ? [[[-centerOffset, centerOffset], -1, 1], [[centerOffset, centerOffset], 1, 1]]
    : [[[-centerOffset, -centerOffset], -1, -1], [[centerOffset, -centerOffset], 1, -1],
       [[-centerOffset, centerOffset], -1, 1], [[centerOffset, centerOffset], 1, 1]];

module _clip_connector_snap_profile_bounds(
  size=10,
  profileTopZ,
  straightIntersection=false,
  cornerIntersection=false,
  boundaryOverlap=0,
  topOverlap=0) {
  boundsHeight = profileTopZ + topOverlap;

  if(straightIntersection) {
    translate([-size/2, -boundaryOverlap, 0])
      cube([size, size/2 + boundaryOverlap, boundsHeight]);
  } else if(cornerIntersection) {
    translate([-boundaryOverlap, -boundaryOverlap, 0])
      cube([
        size/2 + boundaryOverlap,
        size/2 + boundaryOverlap,
        boundsHeight]);
  } else {
    translate([-size/2, -size/2, 0])
      cube([size, size, boundsHeight]);
  }
}

function _clip_connector_sweep_profile_outer_half_width(
  cornerRadius=gf_cup_corner_radius) =
  let(
    centerOffset = cornerRadius + env_clearance().x/2,
    bottomTaperRadius = _clip_connector_frame_cavity_bottom_taper_radius(
      cornerRadius=cornerRadius))
  centerOffset - bottomTaperRadius;
function _clip_connector_frame_cavity_bottom_taper_radius(
  cornerRadius=gf_cup_corner_radius) =
  cornerRadius
    - gf_baseplate_upper_taper_height
    + _clip_connector_frame_cavity_radial_gap();
function _clip_connector_frame_cavity_radial_gap() = 0.25;

//The wall that is ls left once the clip shape is removed
module ClippedWall(
  clipSize=10, 
  cornerRadius = gf_cup_corner_radius,
  clippedWallHeight = 2,
  clippedWallThickness = 1,
  frameWallHeight = 1.6,
  straightWall = false,
  straightIntersection = false,
  cornerIntersection = false,
  fullIntersection = false){
  corners = straightWall ? 0 
    : cornerIntersection ? 1 
    : straightIntersection ? 2 
    : 4;
  
    height = clippedWallHeight+fudgeFactor;
    clipRadius = cornerRadius - clippedWallThickness/2;

    xlength = straightWall ? 0
      : cornerIntersection ? clipSize/2+fudgeFactor
      : clipSize+fudgeFactor*2;

    ylength = cornerIntersection  || straightIntersection? clipSize/2+fudgeFactor
      : clipSize+fudgeFactor*2;

    union(){
      rotate([0,0,180])
      translate([-clippedWallThickness/2,-clipSize/2-fudgeFactor,0])
        cube(size=[clippedWallThickness,ylength,height]);
      rotate([0,0,180])
      translate([-clipSize/2-fudgeFactor,-clippedWallThickness/2,0])
        cube(size=[xlength,clippedWallThickness,height]);
    }

    if(corners > 0)
    difference(){
      if(cornerIntersection){
        translate([-(+clippedWallThickness)/2,-(clippedWallThickness)/2,0])
          cube(size=[clipRadius+clippedWallThickness,clipRadius+clippedWallThickness,height]);
      } else if (straightIntersection){
        translate([-(clipRadius*2+clippedWallThickness)/2,-(clippedWallThickness)/2,0])
          cube(size=[clipRadius*2+clippedWallThickness,clipRadius+clippedWallThickness,height]);
      } else {
        translate([-(clipRadius*2+clippedWallThickness)/2,-(clipRadius*2+clippedWallThickness)/2,0])
          cube(size=[clipRadius*2+clippedWallThickness,clipRadius*2+clippedWallThickness,height]);
      }
      for(i=[0:1:corners-1]){
        rotate([0,0,i*90])
        translate([clippedWallThickness/2+clipRadius,clippedWallThickness/2+clipRadius,-fudgeFactor])
          cylinder(r=clipRadius,h=height+fudgeFactor*2);
      }
  }
}


module ButterFlyConnector(
  size = [5,3,2],
  r = 0.5,
  clearance = 0,
  taper=false,
  half=false)
  {
  h = taper ? size.y/2+size.z : size.z;
  //render()
  intersection(){
    positions = [
      [-(size.x/2-r), size.y/2-r, h/2],
      [size.x/2-r, size.y/2-r, h/2],
      [0, -(size.y/2-r), h/2]];
    
    union()
    for(ri = [0:half?0:1]){
      mirror([0,1,0]*ri)
      hull(){
        for(pi = [0:len(positions)-1]){
          translate(positions[pi])
            cylinder(h=h,r=r,center=true);
        }
      }
    }
    
    if(taper)
    rotate([0,90,0])
    cylinder(h=size.x,r=size.y/2+size.z,$fn=4,center=true);
  }
}
