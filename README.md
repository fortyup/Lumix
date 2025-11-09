# ✨ Lumix Shader 🌅

---

![GLSL Badge](https://img.shields.io/badge/Made%20with-GLSL-blue)

Lumix is a shader pack for Minecraft designed to deliver a unique and immersive visual experience. It enhances the game's graphics with custom shaders, effects, and lighting adjustments to make the world feel more vibrant and dynamic.

## ⚙️ Installation and Usage

### ⚠️ Prerequisites
- Make sure you have [OptiFine](https://optifine.net/downloads) installed for your Minecraft version.

### 🛠️ Steps to install
1. Download the Lumix Shader `.zip` file from the [Releases](https://github.com/fortyup/lumix-shader/releases) section of this repository.
2. Open Minecraft and go to the **Options** menu.
3. Navigate to **Video Settings** > **Shaders**.
4. Click the **Shaders Folder** button. This will open the `shaderpacks` folder.
5. Place the downloaded Lumix Shader `.zip` file into the `shaderpacks` folder.
6. Close the folder and return to Minecraft. The Lumix Shader should appear in the list of available shaders.
7. Select Lumix and click **Done** to apply it.

### ▶️ How to use
- Once the shader is applied, load or create a Minecraft world and enjoy the enhanced visuals.

## ✨ What Lumix provides

- 🌑 Shadows (of course)
- 🌈 Colored shadows (cast by translucent blocks such as stained glass)
- ⚖️ Shadow bias (prevents "shadow acne")
- 🔍 Shadow distortion (higher shadow detail near the player)
- 🔧 An example showing how to prevent certain blocks from casting shadows

🚫 Does NOT include:
- ❌ PCSS
- 🌫️ Volumetric lighting
- 🎨 Custom light colors (it uses the vanilla lightmap)
- 🧱 Block shading

## 🗺️ How shadows work (technical explanation)

### 🗺️ The shadow map

The core concept is the shadow map: an image of the world rendered from the sun's point of view rather than the player's. During the shadow pass the engine renders the scene using `shadow.fsh`/`shadow.vsh`. `shadow.fsh` writes data into the shadow map when needed. After the shadow pass completes, the normal rendering pass runs (starting with the `gbuffers_*` programs).

Most shaders (except `shadow`) can access the shadow map through up to four samplers:
- `shadowcolor0`: data written by `shadow.fsh` to `gl_FragData[0]`.
- `shadowcolor1`: data written by `shadow.fsh` to `gl_FragData[1]`.
- `shadowtex0`: like `depthtex0`, but for the shadow map — contains the distance to the nearest item from the sun.
- `shadowtex1`: like `depthtex1`; contains the distance to the nearest OPAQUE item from the sun.

The primary sampler used by later passes is `shadowtex0`. Since `shadowtex0` contains the distance to the nearest object from the sun, other programs can use it to decide whether a surface is visible to the sun. If it is not visible, the surface should receive a shadow. If it is visible, the shader may increase the surface brightness regardless of a low skylight value.

### 🎯 Sampling the shadow map

The shadow map uses a different camera (the sun). You cannot sample `shadowtex0` using screen-space texture coordinates directly — you must transform the current position into shadow space. OptiFine provides `shadowModelView` and `shadowProjection` (both `mat4` uniforms) for that transformation. Screen-space coordinates range from -1 to +1, while textures are sampled from 0 to 1, so you must convert ranges before sampling `shadowtex0`. Once you have the position in shadow space, compare the fragment depth with the depth stored in `shadowtex0`.

Depending on your rendering pipeline, you may perform the shadow test in `gbuffers` (as in this pack, in `gbuffers_textured`) or later in the `composite` stage for a more deferred approach.

### 🌈 Colored shadows

Colored shadows are handled like regular shadows, but with an additional test using `shadowtex1`. Because `shadowtex1` stores distances only for opaque geometry, sampling it lets you decide whether to apply a normal (non-colored) shadow or a colored one. `shadowcolor0` and `shadowcolor1` provide the color information to tint the shadow, which can then be blended or multiplied with the base albedo.

### ⚖️ Shadow bias

Shadow bias compensates for floating-point precision differences between the computed fragment depth and the shadow map depth. Without bias, artifacts known as "shadow acne" appear. The common fix is to consider a fragment in shadow only if its depth passes the shadow map depth check with a small bias applied.

This pack computes a dynamic bias based on surface normals and the distortion factor. Surfaces tangent to the sun vector are more prone to shadow acne. There is also an option named `NORMAL_BIAS` to choose whether to offset along the sun direction or along the surface normal; offsetting along the normal reduces "peter panning" near edges.

### 🔄 Shadow distortion

Rendering the shadow map means rendering the world a second time, which is expensive. Lowering the shadow map resolution helps performance but reduces detail. Shadow distortion solves this by making geometry larger near the center of the shadow map and smaller at the edges, effectively increasing local resolution around the player. `shadow.vsh` performs the geometric distortion; programs sampling the shadow map must apply the same distortion to `shadowPos` when sampling. This improves shadow clarity near the player without significantly increasing cost.

Other techniques exist (PCSS, CSM), but distortion is simple and effective for this example pack.

## 📁 Important files

- The main shader folder is `shaders/` (for example `shaders/gbuffers_textured.fsh`, `shadow.fsh`, `shadow.vsh`, etc.).
- Utilities live in `shaders/lib/` and language files in `shaders/lang/`.

---

## 👤 Author

Created by [@fortyup](https://github.com/fortyup).

## 📜 License

See the `LICENSE` file in the repository for license details.

