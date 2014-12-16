package horror.renderex;

import horror.render.Texture;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class TextureUtil {

	public static function createFromPng(bytes:Bytes):Texture {
		var texture:Texture = null;
		var png = new PngFormat();
		if(png.decode(bytes)) {
			texture = new Texture();
			texture.loadFromBytes(png.width, png.height, png.imageBytes);
		}
		else {
			trace("[TextureUtil.createFromPNG] Cant decode PNG bytes");
		}
		png.dispose();
		return texture;
	}

	// TODO: color correction?
	public static function createFromColor(width:Int, height:Int, color:Int):Texture {
		var texture = new Texture();
		var output = new BytesOutput();
		for(i in 0...width*height) {
			output.writeInt32(color);
		}
		texture.loadFromBytes(1, 1, output.getBytes());
		return texture;
	}
}
