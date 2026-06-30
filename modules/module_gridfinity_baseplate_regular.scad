// include instead of use, so we get the pitch
include <gridfinity_constants.scad>
use <module_gridfinity_block.scad>
use <module_gridfinity_baseplate_common.scad>
use <module_gridfinity_baseplate_bottom_padding.scad>
use <module_gridfinity_frame_connectors.scad>

debug_baseplate_regular = false;
if(debug_baseplate_regular){
  $fn = 64;
  echo("debug_baseplate_regular is enabled");
  translate([-50,0,0])
  baseplate_regular(
    grid_num_x = 1, 
    grid_num_y = 2);
    
  translate([-100,0,0])
  baseplate_regular(
    grid_num_x = 1, 
    grid_num_y = 2,
    remove_bottom_taper = true);
}

function _baseplate_regular_bottom_padding_corner_radius(
  ix,
  iy,
  cornerRadius,
  secondaryCornerRadius,
  cornerRoles,
  roundedCorners) =
  let(
    targetCornerRadius = cornerRoles[ix*2 + iy] == 1 ? cornerRadius : secondaryCornerRadius,
    isRounded = bitwise_and(roundedCorners, decimaltobitwise(ix, iy)) > 0)
  max(isRounded ? targetCornerRadius : 0.01, 0.01);

function _baseplate_regular_bottom_padding_corner_radii(
  cornerRadius,
  secondaryCornerRadius,
  cornerRoles,
  roundedCorners) =
  let(resolvedSecondaryCornerRadius = secondaryCornerRadius == -1 ? cornerRadius : secondaryCornerRadius)
  [
    _baseplate_regular_bottom_padding_corner_radius(0, 1, cornerRadius, resolvedSecondaryCornerRadius, cornerRoles, roundedCorners),
    _baseplate_regular_bottom_padding_corner_radius(1, 1, cornerRadius, resolvedSecondaryCornerRadius, cornerRoles, roundedCorners),
    _baseplate_regular_bottom_padding_corner_radius(1, 0, cornerRadius, resolvedSecondaryCornerRadius, cornerRoles, roundedCorners),
    _baseplate_regular_bottom_padding_corner_radius(0, 0, cornerRadius, resolvedSecondaryCornerRadius, cornerRoles, roundedCorners)
  ];

module baseplate_regular(
  grid_num_x,
  grid_num_y,
  outer_num_x = 0,
  outer_num_y = 0,
  outer_height = 0,
  position_fill_grid_x = "near",
  position_fill_grid_y = "near",
  position_grid_in_outer_x = "center",
  position_grid_in_outer_y = "center",
  magnetSize = [0,0],
  magnetZOffset=0,
  magnetTopCover=0,
  magnetReleaseMethod="none",
  reducedWallHeight=-1,
  reduceWallTaper = false,
  centerScrewEnabled = false,
  cornerScrewEnabled = false,
  weightHolder = false,
  cornerRadius = gf_cup_corner_radius,
  secondaryCornerRadius = -1,
  cornerRoles = [1,1,1,1],
  roundedCorners = 15,
  frameConnectorSettings = [],
  remove_bottom_taper = false,
  bottomPadding = 0,
  efficientBottomPadding = false,
  bottomPaddingEdgeSlopes = [0, 0, 0, 0]) {

  if(env_help_enabled("debug")) echo("baseplate_regular", children=$children);
  assert(is_num(bottomPadding), "bottomPadding must be a number");
  assert(bottomPadding >= 0, "bottomPadding may not be negative");
  assert(is_bool(efficientBottomPadding), "efficientBottomPadding must be true or false");
  assert(is_list(bottomPaddingEdgeSlopes) && len(bottomPaddingEdgeSlopes) == 4,
    "bottomPaddingEdgeSlopes must be a 4 item list");
  assert(min(bottomPaddingEdgeSlopes) >= 0, "bottomPaddingEdgeSlopes may not contain negative values");

  //These should be base constants
  minFloorThickness = 1;
  counterSinkDepth = 2.5;
  screwDepth = counterSinkDepth+3.9;
  weightDepth = 4;
  
  frameBaseHeight = max(
    centerScrewEnabled ? screwDepth : 0, 
    centerScrewEnabled ? counterSinkDepth + weightDepth + minFloorThickness : 0, 
    cornerScrewEnabled ? screwDepth : 0,
    cornerScrewEnabled ? magnetSize[1] + counterSinkDepth + minFloorThickness : 0,
    weightHolder ? weightDepth + minFloorThickness : 0,
    magnetSize.y + magnetZOffset + magnetTopCover);
  frameConnectorFrameHeight = _frame_plain_connector_height(
    outer_height = outer_height,
    extra_down = frameBaseHeight,
    height = 4);
  $frameBaseHeight = frameBaseHeight;
  centerGridPosition = [
    position_grid_in_outer_x == "near" || grid_num_x >= outer_num_x ? 0
      : position_grid_in_outer_x == "far"
        ? (outer_num_x-grid_num_x)*env_pitch().x
        : (outer_num_x-grid_num_x)/2*env_pitch().x,
    position_grid_in_outer_y == "near" || grid_num_y >= outer_num_y ? 0
      : position_grid_in_outer_y == "far"
        ? (outer_num_y-grid_num_y)*env_pitch().y
        : (outer_num_y-grid_num_y)/2*env_pitch().y,
    0];
  allowConnectors = [
    grid_num_y >= outer_num_y || position_grid_in_outer_y == "near",
    grid_num_y >= outer_num_y || position_grid_in_outer_y == "far",
    grid_num_x >= outer_num_x || position_grid_in_outer_x == "near",
    grid_num_x >= outer_num_x || position_grid_in_outer_x == "far"];

  bottomPaddingOuterSize = [
    max(grid_num_x, outer_num_x) * env_pitch().x,
    max(grid_num_y, outer_num_y) * env_pitch().y,
    frameBaseHeight + 4
  ];
  bottomPaddingCornerRadii = _baseplate_regular_bottom_padding_corner_radii(
    cornerRadius = cornerRadius,
    secondaryCornerRadius = secondaryCornerRadius,
    cornerRoles = cornerRoles,
    roundedCorners = roundedCorners);

  _baseplate_bottom_padding(
    bottomPadding = bottomPadding,
    efficientBottomPadding = efficientBottomPadding,
    removeBottomTaper = remove_bottom_taper,
    outerStart = [0, 0, 0],
    outerSize = bottomPaddingOuterSize,
    cornerRadii = bottomPaddingCornerRadii,
    edgeSlopes = bottomPaddingEdgeSlopes,
    gridNumX = grid_num_x,
    gridNumY = grid_num_y,
    gridOrigin = centerGridPosition,
    positionFillGridX = position_fill_grid_x,
    positionFillGridY = position_fill_grid_y,
    pitch = env_pitch()) {
    union() {
      translate([0,0,frameBaseHeight])
      frame_plain(
        grid_num_x = grid_num_x,
        grid_num_y = grid_num_y,
        outer_num_x = outer_num_x,
        outer_num_y = outer_num_y,
        outer_height = outer_height,
        position_fill_grid_x = position_fill_grid_x,
        position_fill_grid_y = position_fill_grid_y,
        position_grid_in_outer_x = position_grid_in_outer_x,
        position_grid_in_outer_y = position_grid_in_outer_y,
        extra_down=frameBaseHeight,
        remove_bottom_taper = remove_bottom_taper,
        cornerRadius = cornerRadius,
        secondaryCornerRadius = secondaryCornerRadius,
        cornerRoles = cornerRoles,
        reducedWallHeight=reducedWallHeight,
        reduceWallTaper=reduceWallTaper,
        roundedCorners = roundedCorners){
          //translate([0,0,-fudgeFactor])
          difference(){
            translate([fudgeFactor,fudgeFactor,fudgeFactor])
            cube([env_pitch().x-fudgeFactor*2,env_pitch().y-fudgeFactor*2,frameBaseHeight+fudgeFactor*2]);

            baseplate_cavities(
              num_x = $gc_size.x,
              num_y = $gc_size.y,
              baseCavityHeight=frameBaseHeight+fudgeFactor,
              magnetSize = magnetSize,
              magnetZOffset=magnetZOffset,
              magnetTopCover=magnetTopCover,
              magnetReleaseMethod=magnetReleaseMethod,
              centerScrewEnabled = centerScrewEnabled && $gc_is_corner.x && $gc_is_corner.y,
              cornerScrewEnabled = cornerScrewEnabled,
              weightHolder = weightHolder,
              cornerRadius = cornerRadius,
              roundedCorners = roundedCorners,
              reverseAlignment = [$gci.x == 0, $gci.y==0]);
          }
          //wall cavities
          if($children >=1) children(0); 
          //wall adatives
          if($children >=2) children(1);
        }

      let($allowConnectors = allowConnectors)
      translate([0,0,frameBaseHeight])
      translate(centerGridPosition)
      frame_connector_clip_baseplate_previews(
        width = grid_num_x,
        depth = grid_num_y,
        frameHeight = frameConnectorFrameHeight,
        frameConnectorSettings = frameConnectorSettings);
    }
  }
}
