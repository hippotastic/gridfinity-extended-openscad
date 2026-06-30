// Internal helpers for adding optional material below regular baseplates.
include <gridfinity_constants.scad>
use <module_gridfinity.scad>

module _baseplate_bottom_padding(
  bottomPadding = 0,
  efficientBottomPadding = false,
  removeBottomTaper = false,
  outerStart = [0, 0, 0],
  outerSize = [0, 0, 0],
  cornerRadii = [gf_cup_corner_radius, gf_cup_corner_radius, gf_cup_corner_radius, gf_cup_corner_radius],
  edgeSlopes = [0, 0, 0, 0],
  gridNumX = 0,
  gridNumY = 0,
  gridOrigin = [0, 0, 0],
  positionFillGridX = "near",
  positionFillGridY = "near",
  pitch = [gf_pitch, gf_pitch, gf_zpitch]) {

  assert(is_num(bottomPadding), "bottomPadding must be a number");
  assert(bottomPadding >= 0, "bottomPadding may not be negative");
  assert(is_bool(efficientBottomPadding), "efficientBottomPadding must be true or false");
  assert(is_bool(removeBottomTaper), "removeBottomTaper must be true or false");
  assert(is_list(outerStart) && len(outerStart) == 3, "outerStart must be a 3d list");
  assert(is_list(outerSize) && len(outerSize) == 3, "outerSize must be a 3d list");
  assert(outerSize.x > 0 && outerSize.y > 0, "outerSize must have positive x/y dimensions");
  assert(is_list(cornerRadii) && len(cornerRadii) == 4, "cornerRadii must be a 4 item list");
  assert(min(cornerRadii) >= 0, "cornerRadii may not contain negative values");
  assert(is_list(edgeSlopes) && len(edgeSlopes) == 4, "edgeSlopes must be a 4 item list");
  assert(min(edgeSlopes) >= 0, "edgeSlopes may not contain negative values");
  assert(is_num(gridNumX) && gridNumX >= 0, "gridNumX must be a non-negative number");
  assert(is_num(gridNumY) && gridNumY >= 0, "gridNumY must be a non-negative number");
  assert(is_list(gridOrigin) && len(gridOrigin) == 3, "gridOrigin must be a 3d list");
  assert(is_string(positionFillGridX), "positionFillGridX must be a string");
  assert(is_string(positionFillGridY), "positionFillGridY must be a string");
  assert(is_list(pitch) && len(pitch) == 3, "pitch must be a 3d list");

  if (bottomPadding > 0) {
    translate([0, 0, bottomPadding])
    children();

    _baseplate_bottom_padding_volume(
      bottomPadding = bottomPadding,
      efficientBottomPadding = efficientBottomPadding,
      removeBottomTaper = removeBottomTaper,
      outerStart = outerStart,
      outerSize = outerSize,
      cornerRadii = cornerRadii,
      edgeSlopes = edgeSlopes,
      gridNumX = gridNumX,
      gridNumY = gridNumY,
      gridOrigin = gridOrigin,
      positionFillGridX = positionFillGridX,
      positionFillGridY = positionFillGridY,
      pitch = pitch);
  } else {
    children();
  }
}

module _baseplate_bottom_padding_volume(
  bottomPadding,
  efficientBottomPadding,
  removeBottomTaper,
  outerStart,
  outerSize,
  cornerRadii,
  edgeSlopes,
  gridNumX,
  gridNumY,
  gridOrigin,
  positionFillGridX,
  positionFillGridY,
  pitch) {

  if (_baseplate_bottom_padding_has_edge_slopes(edgeSlopes)) {
    echo(str(
      "Bottom padding edge slope angles (top/right/bottom/left in degrees): ",
      _baseplate_bottom_padding_edge_slope_angles(edgeSlopes, bottomPadding)));
  }

  color(color_cup)
  render()
  difference() {
    _baseplate_bottom_padding_outer_volume(
      bottomPadding = bottomPadding,
      outerStart = outerStart,
      outerSize = outerSize,
      cornerRadii = cornerRadii,
      edgeSlopes = edgeSlopes);

    _baseplate_bottom_padding_grid_hole_cutters(
      bottomPadding = bottomPadding,
      efficientBottomPadding = efficientBottomPadding,
      removeBottomTaper = removeBottomTaper,
      outerStart = outerStart,
      outerSize = outerSize,
      cornerRadii = cornerRadii,
      edgeSlopes = edgeSlopes,
      gridNumX = gridNumX,
      gridNumY = gridNumY,
      gridOrigin = gridOrigin,
      positionFillGridX = positionFillGridX,
      positionFillGridY = positionFillGridY,
      pitch = pitch);
  }
}

module _baseplate_bottom_padding_outer_volume(
  bottomPadding,
  outerStart,
  outerSize,
  cornerRadii,
  edgeSlopes) {

  if (_baseplate_bottom_padding_has_edge_slopes(edgeSlopes)) {
    hull() {
      linear_extrude(fudgeFactor)
      _baseplate_bottom_padding_outer_footprint(
        outerStart = outerStart,
        outerSize = outerSize,
        cornerRadii = cornerRadii,
        edgeOffsets = edgeSlopes);

      translate([0, 0, bottomPadding])
      linear_extrude(fudgeFactor)
      _baseplate_bottom_padding_outer_footprint(
        outerStart = outerStart,
        outerSize = outerSize,
        cornerRadii = cornerRadii);
    }
  } else {
    linear_extrude(bottomPadding + fudgeFactor)
    _baseplate_bottom_padding_outer_footprint(
      outerStart = outerStart,
      outerSize = outerSize,
      cornerRadii = cornerRadii);
  }
}

module _baseplate_bottom_padding_outer_footprint(
  outerStart,
  outerSize,
  cornerRadii,
  edgeOffsets = [0, 0, 0, 0]) {

  footprintSize = [
    outerSize.x - edgeOffsets[1] - edgeOffsets[3],
    outerSize.y - edgeOffsets[0] - edgeOffsets[2]
  ];
  footprintCenter = [
    outerStart.x + outerSize.x/2 + (edgeOffsets[3] - edgeOffsets[1]) / 2,
    outerStart.y + outerSize.y/2 + (edgeOffsets[2] - edgeOffsets[0]) / 2
  ];

  assert(footprintSize.x > 0 && footprintSize.y > 0,
    "edgeSlopes are too large for the bottom padding footprint");

  translate(footprintCenter)
  polygon(_baseplate_bottom_padding_rounded_rect_points(
    footprintSize,
    _baseplate_bottom_padding_corner_radii_for_footprint(cornerRadii)));
}

module _baseplate_bottom_padding_grid_hole_cutters(
  bottomPadding,
  efficientBottomPadding,
  removeBottomTaper,
  outerStart,
  outerSize,
  cornerRadii,
  edgeSlopes,
  gridNumX,
  gridNumY,
  gridOrigin,
  positionFillGridX,
  positionFillGridY,
  pitch) {

  baseplateCavityRadialGap = _pad_oversize_radial_gap(1);
  baseplateCavityCornerCenter = _pad_oversize_corner_center().x;
  topCornerRadius = max(0.01,
    _pad_oversize_small_bottom_radius(removeBottomTaper, baseplateCavityRadialGap));
  topInset = max(0.01, baseplateCavityCornerCenter - topCornerRadius);
  efficientRibWidth = 1.2;
  targetRibWidth = efficientBottomPadding ? efficientRibWidth : topInset;
  targetInset = targetRibWidth / 2;
  maxChamferHeight = efficientBottomPadding ? max(0, topInset - targetInset) : 0;
  chamferHeight = efficientBottomPadding ? min(maxChamferHeight, bottomPadding) : 0;
  depths = _baseplate_bottom_padding_transition_depths(bottomPadding, chamferHeight);

  translate(gridOrigin)
  gridcopy(
    gridNumX,
    gridNumY,
    pitch = pitch,
    positionGridx = positionFillGridX,
    positionGridy = positionFillGridY) {

    if ($gc_size.x > 0.2 && $gc_size.y > 0.2) {
      for (i = [0:len(depths)-2]) {
        hull() {
          _baseplate_bottom_padding_grid_hole_layer(
            depth = depths[i],
            bottomPadding = bottomPadding,
            outerStart = outerStart,
            outerSize = outerSize,
            edgeSlopes = edgeSlopes,
            gridOrigin = gridOrigin,
            pitch = pitch,
            cornerRadii = cornerRadii,
            topInset = topInset,
            targetRibWidth = targetRibWidth,
            baseplateCavityCornerCenter = baseplateCavityCornerCenter,
            baseplateCavityRadialGap = baseplateCavityRadialGap,
            maxChamferHeight = maxChamferHeight,
            topCornerRadius = topCornerRadius);

          _baseplate_bottom_padding_grid_hole_layer(
            depth = depths[i+1],
            bottomPadding = bottomPadding,
            outerStart = outerStart,
            outerSize = outerSize,
            edgeSlopes = edgeSlopes,
            gridOrigin = gridOrigin,
            pitch = pitch,
            cornerRadii = cornerRadii,
            topInset = topInset,
            targetRibWidth = targetRibWidth,
            baseplateCavityCornerCenter = baseplateCavityCornerCenter,
            baseplateCavityRadialGap = baseplateCavityRadialGap,
            maxChamferHeight = maxChamferHeight,
            topCornerRadius = topCornerRadius);
        }
      }
    }
  }
}

module _baseplate_bottom_padding_grid_hole_layer(
  depth,
  bottomPadding,
  outerStart,
  outerSize,
  edgeSlopes,
  gridOrigin,
  pitch,
  cornerRadii,
  topInset,
  targetRibWidth,
  baseplateCavityCornerCenter,
  baseplateCavityRadialGap,
  maxChamferHeight,
  topCornerRadius) {

  overlap = fudgeFactor*3;

  translate([0, 0, bottomPadding - depth - overlap])
  linear_extrude(overlap*2)
  _baseplate_bottom_padding_grid_hole_at_depth(
    depth = depth,
    bottomPadding = bottomPadding,
    outerStart = outerStart,
    outerSize = outerSize,
    edgeSlopes = edgeSlopes,
    gridOrigin = gridOrigin,
    pitch = pitch,
    cornerRadii = cornerRadii,
    topInset = topInset,
    targetRibWidth = targetRibWidth,
    baseplateCavityCornerCenter = baseplateCavityCornerCenter,
    baseplateCavityRadialGap = baseplateCavityRadialGap,
    maxChamferHeight = maxChamferHeight,
    topCornerRadius = topCornerRadius);
}

module _baseplate_bottom_padding_grid_hole_at_depth(
  depth,
  bottomPadding,
  outerStart,
  outerSize,
  edgeSlopes,
  gridOrigin,
  pitch,
  cornerRadii,
  topInset,
  targetRibWidth,
  baseplateCavityCornerCenter,
  baseplateCavityRadialGap,
  maxChamferHeight,
  topCornerRadius) {

  cellSize = [$gc_size.x * pitch.x, $gc_size.y * pitch.y];
  cellOrigin = [
    gridOrigin.x + $gc_position.x * pitch.x,
    gridOrigin.y + $gc_position.y * pitch.y,
    0
  ];
  edgeOffsets = _baseplate_bottom_padding_edge_offsets_at_depth(
    edgeSlopes,
    depth,
    bottomPadding);
  // Move edge-cell hole bounds with the sloped outer bounds to preserve wall thickness.
  localOuterMin = [
    outerStart.x + edgeOffsets[3] - cellOrigin.x,
    outerStart.y + edgeOffsets[2] - cellOrigin.y
  ];
  localOuterMax = [
    outerStart.x + outerSize.x - edgeOffsets[1] - cellOrigin.x,
    outerStart.y + outerSize.y - edgeOffsets[0] - cellOrigin.y
  ];
  chamferDepth = min(depth, maxChamferHeight);
  inset = max(targetRibWidth/2, topInset - chamferDepth);
  holeMin = [
    max(inset, localOuterMin.x + targetRibWidth),
    max(inset, localOuterMin.y + targetRibWidth)
  ];
  holeMax = [
    min(cellSize.x - inset, localOuterMax.x - targetRibWidth),
    min(cellSize.y - inset, localOuterMax.y - targetRibWidth)
  ];
  holeSize = holeMax - holeMin;
  holeCenter = (holeMin + holeMax) / 2;
  defaultRadius = maxChamferHeight > 0 && chamferDepth > 0
    ? max(0.01, baseplateCavityCornerCenter - inset)
    : topCornerRadius;
  outerSideInset = max(targetRibWidth, inset);
  radius = maxChamferHeight > 0 && chamferDepth > 0
    ? _baseplate_bottom_padding_cell_corner_radii(
        [$gci.x, $gci.y],
        [$gc_count.x, $gc_count.y],
        defaultRadius,
        outerSideInset,
        baseplateCavityCornerCenter,
        baseplateCavityRadialGap,
        cornerRadii)
    : topCornerRadius;

  if (holeSize.x > targetRibWidth && holeSize.y > targetRibWidth) {
    translate(holeCenter)
    polygon(_baseplate_bottom_padding_rounded_rect_points(holeSize, radius));
  }
}

function _baseplate_bottom_padding_has_edge_slopes(edgeSlopes) =
  max(edgeSlopes) > 0;

function _baseplate_bottom_padding_edge_slope_angles(edgeSlopes, bottomPadding) = [
  for (edgeSlope = edgeSlopes) atan(edgeSlope / bottomPadding)
];

function _baseplate_bottom_padding_transition_depths(bottomPadding, chamferHeight) =
  chamferHeight > 0 && chamferHeight < bottomPadding
    ? [0, chamferHeight, bottomPadding]
    : [0, bottomPadding];

function _baseplate_bottom_padding_edge_offsets_at_depth(edgeSlopes, depth, bottomPadding) =
  edgeSlopes * (depth / bottomPadding);

function _baseplate_bottom_padding_outer_corner_hole_radius(
  outerRadius,
  sideInset,
  defaultRadius,
  baseplateCavityCornerCenter,
  baseplateCavityRadialGap) =
  outerRadius > sideInset
    ? max(0.01, min(baseplateCavityCornerCenter, outerRadius + baseplateCavityRadialGap) - sideInset)
    : defaultRadius;

function _baseplate_bottom_padding_cell_corner_radii(
  index,
  gridCount,
  defaultRadius,
  outerSideInset,
  baseplateCavityCornerCenter,
  baseplateCavityRadialGap,
  cornerRadii) =
  [
    index.x == gridCount.x - 1 && index.y == 0
      ? _baseplate_bottom_padding_outer_corner_hole_radius(
          cornerRadii[2], outerSideInset, defaultRadius, baseplateCavityCornerCenter, baseplateCavityRadialGap)
      : defaultRadius,
    index.x == gridCount.x - 1 && index.y == gridCount.y - 1
      ? _baseplate_bottom_padding_outer_corner_hole_radius(
          cornerRadii[1], outerSideInset, defaultRadius, baseplateCavityCornerCenter, baseplateCavityRadialGap)
      : defaultRadius,
    index.x == 0 && index.y == gridCount.y - 1
      ? _baseplate_bottom_padding_outer_corner_hole_radius(
          cornerRadii[0], outerSideInset, defaultRadius, baseplateCavityCornerCenter, baseplateCavityRadialGap)
      : defaultRadius,
    index.x == 0 && index.y == 0
      ? _baseplate_bottom_padding_outer_corner_hole_radius(
          cornerRadii[3], outerSideInset, defaultRadius, baseplateCavityCornerCenter, baseplateCavityRadialGap)
      : defaultRadius
  ];

function _baseplate_bottom_padding_corner_radii_for_footprint(cornerRadii) = [
  cornerRadii[2],
  cornerRadii[1],
  cornerRadii[0],
  cornerRadii[3]
];

function _baseplate_bottom_padding_corner_arc(center, radius, startAngle, endAngle, steps) =
  radius <= 0
    ? [center]
    : _baseplate_bottom_padding_arc_points(center, radius, startAngle, endAngle, steps);

function _baseplate_bottom_padding_rounded_rect_points(size, radius) =
  let(
    rawRadii = is_list(radius) ? radius : [radius, radius, radius, radius],
    maxRadius = max(0, min(size) / 2 - fudgeFactor),
    r = [for (cornerRadius = rawRadii) min(cornerRadius, maxRadius)],
    arcSteps = [for (cornerRadius = r) _baseplate_bottom_padding_quarter_arc_steps(cornerRadius)],
    hw = size.x / 2,
    hh = size.y / 2
  )
  concat(
    _baseplate_bottom_padding_corner_arc([hw - r[0], -hh + r[0]], r[0], -90, 0, arcSteps[0]),
    _baseplate_bottom_padding_corner_arc([hw - r[1], hh - r[1]], r[1], 0, 90, arcSteps[1]),
    _baseplate_bottom_padding_corner_arc([-hw + r[2], hh - r[2]], r[2], 90, 180, arcSteps[2]),
    _baseplate_bottom_padding_corner_arc([-hw + r[3], -hh + r[3]], r[3], 180, 270, arcSteps[3]));

function _baseplate_bottom_padding_arc_points(center, radius, startAngle, endAngle, steps) = [
  for (i = [0:steps])
  let(angle = startAngle + (endAngle - startAngle) * i / steps)
  center + radius * [cos(angle), sin(angle)]
];

function _baseplate_bottom_padding_quarter_arc_steps(radius) =
  max(1, ceil(_baseplate_bottom_padding_circle_fragments(radius) / 4));

function _baseplate_bottom_padding_circle_fragments(radius) =
  $fn > 0 ? max($fn, 3)
  : ceil(max(5, min(360 / max($fa, 0.01), 2 * 3.14159 * radius / max($fs, 0.01))));
