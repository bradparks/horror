package horror.render;

import haxe.io.Bytes;

import horror.render.RenderContext;
import horror.std.Debug;

class Texture {

	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;

	@:allow(horror.render.RenderContext)
	var __data:TextureData = null;

	public function new() {
	}

	public function loadFromBytes(width:Int, height:Int, pixels:Bytes) {
		dispose();
		__checkSize(width, height);
		this.width = width;
		this.height = height;
		__data = RenderContext.__driver.createTextureFromBytes(width, height, pixels.getData());
	}

	public function dispose() {
		if(__data != null) {
			RenderContext.__driver.disposeTexture(__data);
			__data = null;
			width = 0;
			height = 0;
		}
	}

	public static function createFromBytes(width:Int, height:Int, pixels:Bytes):Texture {
		__checkSize(width, height);
		var t = new Texture();
		t.loadFromBytes(width, height, pixels);
		return t;
	}

	public static function createWhiteBlank(width:Int = 1, height:Int = 1):Texture {
		__checkSize(width, height);
		var len = width*height*4;
		var whiteBytes = Bytes.alloc(len);
		whiteBytes.fill(0, len, 0xFF);
		return createFromBytes(width, height, whiteBytes);
	}

	static function __checkSize(w:Int, h:Int) {
		Debug.assert(w > 0 && h > 0 && w <= 4096 && h <= 4096);
	}

}
