# Palette Notes

Confirmed readings from Tammer's colorblindness tests. Use this to pick colors that will actually convey meaning in diagrams. Update when new pairs are tested.

## Safe pairs (use these to convey meaning)

These hues are clearly distinguishable. Shade variation within each hue is also distinguishable.

| Pair | Light/Dark of A | Light/Dark of B | Hex samples |
|------|----------------|----------------|-------------|
| Blue vs Orange | yes | yes | `#1565c0` / `#ef6c00` |
| Blue vs Yellow | yes | yes | `#1565c0` / `#fbc02d` |
| Purple vs Yellow | yes | yes | `#6a1b9a` / `#fbc02d` |

Blue+orange is the default - safe, professional, plenty of contrast.

## Usable but caveated

The two hues are distinguishable, but Tammer cannot tell light vs dark *within* either hue. So you can use the pair to mark two categories, but don't lean on shade variation to convey a third dimension.

| Pair | Hue distinguishable? | Shade distinguishable? | Hex samples |
|------|---------------------|----------------------|-------------|
| Orange vs Red | yes (though he can't name which is which) | no | `#ef6c00` / `#c62828` |
| Green vs Brown | yes | no | `#2e7d32` / `#5d4037` |

## Unsafe (do NOT use to convey meaning)

These look identical or near-identical to Tammer. Pair color with shape/label/line-style instead, or pick a different palette.

- **Red vs Green** - the classic case. Never use for yes/no, success/failure, valid/invalid edges or fills.
- **Blue vs Purple** - indistinguishable.
- **Teal vs Grey** - too subtle.

## Rules of thumb

- **Prefer icons or emoji over color whenever possible.** A shield icon, a database cylinder, an AWS service glyph, or even a leading emoji in the node label conveys category instantly without depending on hue at all. D2 accepts any SVG via `icon:` and Terrastruct hosts a free pack at `https://icons.terrastruct.com/` (see the parent SKILL.md). Use color as secondary reinforcement, not the primary signal.
- For yes/no or success/failure: use blue (success) + orange (warning/failure), or pair color with line style (`stroke-dash`) or shape (oval vs diamond).
- For state ramps (cold→hot, low→high): pick a single-hue sequential ramp from a known-safe color (blue, orange, or yellow). Don't use red→green diverging ramps.
- For categorical fills (3+ groups): blue + orange + yellow + purple gives 4 distinguishable categories. Add shape variation before reaching for a 5th color.
- When in doubt, render a quick PNG swatch and ask Tammer before committing the diagram.

## Test history

- 2026-05-27: Initial pairwise tests (8 pairs). Source files in `/tmp/colortest/`.
