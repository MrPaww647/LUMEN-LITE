# LUMEN LITE 2.0 — Minecraft Java 1.21.1 / Iris

Lightweight Vanilla+ shaderpack prototype focused on restrained lighting, filtered shadows, and experimental screen-space reflections (SSR).

## Install
1. Use Minecraft Java 1.21.1 with a compatible Iris Shaders installation.
2. Download the repository as ZIP, or use the shaderpack ZIP from Releases when one is published.
3. Place the ZIP in `.minecraft/shaderpacks/`.
4. Select **LUMEN LITE** in Options → Video Settings → Shader Packs.
5. Start with the **Balanced** profile; use **Performance** on low-end systems.

## 2.0 changes
- Reduced colored-light tint so torch-lit blocks should not look overexposed or overly saturated.
- Added configurable shadow contrast and a small percentage-closer filtering (PCF) kernel.
- Added an experimental SSR pass that traces against the opaque depth buffer and samples scene color. A player model may reflect only if the renderer includes it in the scene buffers and the reflection ray finds it.
- Separated the water mask/normal buffer and composite output buffer to avoid sampling from the same render target being written.
- Added Performance, Balanced, and Quality profiles with different shadow and reflection costs.

## Important limitations
- SSR is a screen-space approximation: it cannot reflect objects outside the screen, hidden behind other geometry, or absent from the sampled scene color. Depending on Iris/renderer pass ordering, player reflections may be incomplete. This needs in-game validation.
- This is not full dynamic lighting. A shaderpack does not receive a universal list of nearby torch, lava, or dropped-item light sources. Use a compatible dynamic-lights mod for moving light sources if desired.
- Soft shadows and SSR depend on shader compiler, Iris version, GPU, and render target behavior. This source has not been tested in a running Minecraft client here.
- Ice transparency and true volumetric lighting are not implemented in this build.
- The current water treatment is screen-space and lightweight; it is not physically based ray-traced reflection or geometric wave simulation.

## Tuning
- **Performance:** 512 shadow map, shorter distance, no SSR.
- **Balanced:** 1024 shadow map, 12 SSR steps, modest filtering.
- **Quality:** 1536 shadow map, longer distance, stronger filtering and more SSR steps.

If the pack fails to compile, check `.minecraft/logs/latest.log` for the first shader compilation error and report the Iris version, GPU, and the exact error. This is an experimental update and should be validated in-game before treating the effects as production-ready.
