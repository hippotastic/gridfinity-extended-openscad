# AGENTS.md

## Requirement Fidelity

- Treat the user's stated implementation approach as a hard requirement, not just a suggestion.
- Do not replace a requested approach with a shortcut, workaround, CSG-equivalent, or different architecture just because it appears easier to match numerically.
- If the requested approach seems impossible, contradictory, underspecified, or likely to miss an edge case, stop and explain the issue to the user before implementing an alternative.
- When proposing a correction, clearly distinguish between the user's original requirement, the blocking fact, and the suggested adjustment.
- Do not continue with an unapproved reinterpretation after discovering that exact implementation is harder than expected.

## Searching And Call Sites

- Before changing functions or parameters in shared modules, search all SCAD call sites, especially top-level files and baseplate/lid modules.
- For example, geometry tweaks in `pad_oversize()` can affect bin bottoms, lip notches, baseplate cavities, and connector geometry unless explicitly gated.

## OpenSCAD Execution

- Do not run sandboxed OpenSCAD. It can crash and show a GUI error popup. Only run OpenSCAD outside the sandbox, either the ARM or x86 version depending on your system.

## SCAD Geometry Guidelines

- Verify visually when changing geometry. Render from multiple perspectives to check for unintended consequences.
- Compare dimensions, volumes and faces before and after changes to ensure they are as expected.
- Include both the before and after images as well as the comparison metrics in your handoff message.
