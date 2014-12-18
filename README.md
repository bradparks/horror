Horror
======

### About

Horror is a low-level _gpu-accelerated_ framework for 2D games development in Haxe, which hides all complex underlying API.

Horror provides low-level GPU render API based on classic dynamic batching and applicable mostly for 2D games. High performance is provided by filling mesh buffers up with optimized `horror.memory` package. FastMemory implementation is based on TypedArrays for HTML5, MemoryDomain for Flash, and HXCPP magic for native targets.

### Platforms

- Flash (Stage3D)
- HTML5 (WebGL)
- Mac/Windows/Linux (OpenGL)
- iOS/Android (OpenGL ES)

Now implemented for OpenFL/Lime/Snow libraries and supports all his targets + clean Flash!

__Native__ and __Web__ builds are compiled with `snow` or `lime` or `openfl`.

__Flash__ build is compiled with `flash` or `lime` or `openfl`

I regulary test `flash`, `html5` and `mac` builds produced from different libraries.

__WARNING!__ There is NO canvas/displaylists fallbacks! While Horror is a GPU framework, it's running on Stage3D / WebGL / GL / GLES platforms only.

### Quick start

#### Prerequisites

Horror is developing with the latest Haxe Toolkit version, cuz no right BytesData support for `js` target in stable 3.1.3 version.

- Haxe & Neko & Haxelib (the latest from git)
- `hxcpp` (the latest from git)
- `format`

Optional:
- `openfl`, `lime2.0.1` (the latest)
- `snow`, `flow`


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

lime test html5 -Dhorror_lime

flow run
flow run web
```
Happy coding with Haxe!

### TODO
- [x] ImageBytes wrapper for fast image pixels manipulation by FastMemory API
- [x] BitMask
- [x] Solidify filter (non-premultiplied alpha troubles: fix png color channel in 0 alpha, fix halo on borders, etc)
- [ ] Auto/Manual lost context handling
- [ ] Native images (textures and loading)
- [ ] Material/Global uniform constants
- [ ] RenderTexture
- [ ] StaticMesh
- [ ] Multitexturing
