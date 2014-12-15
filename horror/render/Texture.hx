package horror.render;

import horror.render.RenderContext;
import horror.memory.ByteArray;

class Texture {

	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;

	@:allow(horror.render.RenderContext)
	var __data:TextureData = null;

	public function new() {
	}

	public function loadFromBytes(width:Int, height:Int, pixels:ByteArray) {
		dispose();
		this.width = width;
		this.height = height;
		__data = RenderContext.__driver.createTextureFromByteArray(width, height, pixels.data);
	}

	public function loadPngFromBytes(bytes:ByteArray) {
		dispose();

		var png:PngFormat = new PngFormat();
		if(png.decode(bytes)) {
			loadFromBytes(png.width, png.height, png.imageBytes);
		}
		else {
			trace("[Texture.loadPngFromBytes] Cant decode PNG bytes");
		}
		png.dispose();
	}

	public function dispose() {
		if(__data != null) {
			RenderContext.__driver.disposeTexture(__data);
			__data = null;
			width = 0;
			height = 0;
		}
	}

	public static function createFromColor(width:Int, height:Int, color:Int):Texture {
		var texture = new Texture();
		var bytes = new ByteArray(width*height*4);
		for(i in 0...width*height) {
			bytes.writeUInt32(color);
		}
		texture.loadFromBytes(1, 1, bytes);
		bytes.clear();
		return texture;
	}


}
