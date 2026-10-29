# LUMEN LITE — Shaderpack prototype (Minecraft Java 1.21.1 / Iris)

A standalone Vanilla+ shaderpack focused on low overhead, restrained color grading, a lightweight shadow-map pass, and shader settings exposed through Iris.

## Install
1. Install Minecraft Java 1.21.1 and a matching Iris Shaders installation (Fabric is the common route; Sodium is recommended).
2. Copy `LUMEN-LITE.zip` into `.minecraft/shaderpacks/`.
3. In Options → Video Settings → Shader Packs, select **LUMEN LITE**.
4. Open Shader Pack Settings to select Performance, Balanced, or Quality.

## What this source implements
- Iris shader-pack structure with terrain, water, entity, shadow, composite, and final programs.
- A shadow pass and a basic shadow-map sampling pass. Actual visual correctness depends on Iris version, GPU, dimension, and renderer interactions; test in-game.
- A lightweight lightmap-based warm/cool color approximation. This is **not true per-block dynamic lighting**.
- Water tint and final color grading settings.
- Performance / Balanced / Quality option profiles.

## Explicit limitations
- **Dynamic light:** no true moving-source illumination is implemented. GLSL shaders do not receive a universal list of nearby torch/lava/item light positions. For actual held-item and moving light sources, use a compatible dynamic-lights mod alongside a shaderpack, if supported by the chosen Minecraft/Iris setup.
- **Player reflection:** there is no true SSR reflection implementation in this first build. Screen-space reflection needs ray marching against scene depth and cannot reflect a player that is not present in the sampled scene buffers.
- **Transparent ice:** a shaderpack cannot reliably change vanilla block render layers and sorting on its own. Use a resource pack or compatible mod if fully transparent ice is required.
- **Water:** this build changes water tint; it does not claim full environment reflections or animated geometric waves.
- **Player shadows:** the shadow pass can render entities when Iris sends them to that pass, but entity shadow participation varies with renderer and shader configuration. Verify in a test world.
- **Soft shadows:** the current filter is intentionally small and lightweight, not high-quality PCF.

## Troubleshooting
- If the pack fails to compile, press `Ctrl+D` on the Shader Packs screen to enable Iris debug information, then check `latest.log` for the first shader compile error.
- Confirm the Minecraft version and Iris build match, and temporarily disable other rendering mods that alter shaders.
- If the screen is black or shadows look incorrect, switch to Performance profile, disable SHADOWS, and retry. This helps isolate shader pipeline compatibility.
- Report the exact Iris version, GPU, Minecraft version, and first compile error when diagnosing a failure.

## Development status
This is a source-complete initial implementation, but it has **not been launched inside a Minecraft client in this environment**. Treat it as a test build until validated in-game. No claim is made that every feature in the original target specification is complete.
