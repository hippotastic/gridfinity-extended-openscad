# AGENTS.md

## Searching And Call Sites

- Before changing functions or parameters in shared modules, search all SCAD call sites, especially top-level files and baseplate/lid modules.
- For example, geometry tweaks in `pad_oversize()` can affect bin bottoms, lip notches, baseplate cavities, and connector geometry unless explicitly gated.

## OpenSCAD Execution

- Do not run sandboxed OpenSCAD. It can crash and show a GUI error popup. Only run OpenSCAD outside the sandbox, either the ARM or x86 version depending on your system.

## SCAD Geometry Guidelines

- Verify visually when changing geometry. Render from multiple perspectives to check for unintended consequences.
- Compare dimensions, volumes and faces before and after changes to ensure they are as expected.
- Include both the before and after images as well as the comparison metrics in your handoff message.
