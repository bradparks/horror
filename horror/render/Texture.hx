package horror.render;

import horror.utils.IDisposable;
import horror.render.RenderManager;
import horror.memory.ByteArray;

class Texture implements IDisposable {

	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;

	@:allow(horror.render.RenderManager)
	var _rawData:RawTexture = null;

	public function new() {
	}

	public function loadFromBytes(width:Int, height:Int, pixels:ByteArrayData) {
		dispose();
		this.width = width;
		this.height = height;
		_rawData = RenderManager.driver.createTextureFromByteArray(width, height, pixels);
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
		if(_rawData != null) {
			RenderManager.driver.disposeTexture(_rawData);
			_rawData = null;
			width = 0;
			height = 0;
		}
	}

	public static function createFromColor(width:Int, height:Int, color:Int):Texture {
		var texture = new Texture();
		var bytes = new ByteArray();
		for(i in 0...width*height) {
			bytes.writeUInt32(color);
		}
		texture.loadFromBytes(1, 1, bytes.data);
		bytes.clear();
		return texture;
	}


}