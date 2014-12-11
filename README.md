# Horror
## About

Horror is a low-level _gpu-accelerated_ framework for 2D games development in Haxe, which hides all complex underlying API. Now based on OpenFL, but will be switched to Lime in the near future (when Lime will provide all needed API and it's architecture will be stable).

Horror provides low-level GPU render API based on classic dynamic batching and applicable mostly for 2D games. High performance is provided by filling mesh buffers up with optimized `horror.memory` package. FastMemory implementation is based on TypedArrays for HTML5, MemoryDomain for Flash, and HXCPP magic for native targets. 

__WARNING!__ There is NO canvas/displaylists fallbacks! While Horror is a GPU framework, it's running on Stage3D / WebGL / GL / GLES platforms only.

Supports all OpenFL targets. I do regulary tests on targets: `flash`, `html5`, `mac`.

Includes essential utilities: `debug` and `singals`

## Install
```
git clone https://github.com/eliasku/horror.git
haxelib dev horror horror
```

## Run Sample
```
cd horror/samples/HorrorDemo
aether test flash
aether test html5
aether test mac
```

Happy coding with Haxe!
