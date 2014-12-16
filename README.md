Horror
======

### About

Horror is a low-level _gpu-accelerated_ framework for 2D games development in Haxe, which hides all complex underlying API.

Horror provides low-level GPU render API based on classic dynamic batching and applicable mostly for 2D games. High performance is provided by filling mesh buffers up with optimized `horror.memory` package. FastMemory implementation is based on TypedArrays for HTML5, MemoryDomain for Flash, and HXCPP magic for native targets.

### Platforms

Now based on OpenFL and support all his targets, but will be switched to Lime in the near future (when Lime will provide all needed API and it's architecture will be stable). Plan implement other backends (for example `snow`).

- Flash (Stage3D)
- HTML5 (WebGL)
- Mac/Windows/Linux (OpenGL)
- iOS/Android (OpenGL ES)

__WARNING!__ There is NO canvas/displaylists fallbacks! While Horror is a GPU framework, it's running on Stage3D / WebGL / GL / GLES platforms only.

I do regulary tests on targets: `flash`, `html5`, `mac`.

### Quick start

#### Prerequisites

Horror is developing with the latest Haxe Toolkit version, cuz no right BytesData support for `js` target in stable 3.1.3 version.

- Haxe & Neko & Haxelib (the latest from git)
- `hxcpp` (the latest from git)
- `openfl`, `lime2.0.1` (the latest)
- `format`

#### Install
```
git clone https://github.com/eliasku/horror.git
haxelib dev horror horror
```

#### Run Sample
```
cd horror/samples/HorrorDemo
lime test flash
lime test html5
lime test mac
```
Happy coding with Haxe!

### TODO
- [x] ImageBytes wrapper for fast image pixels manipulation by FastMemory API
- [ ] BitMask
- [x] Solidify filter (non-premultiplied alpha troubles: fix png color channel in 0 alpha, fix halo on borders, etc)
- [ ] Auto/Manual lost context handling
- [ ] Native images (textures and loading)
- [ ] Material/Global uniform constants
- [ ] RenderTexture
- [ ] StaticMesh
- [ ] Multitexturing
