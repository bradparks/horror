package horror.utils;

import horror.utils.ImageBytes;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import sys.io.File;

using horror.utils.ImageTools;

// https://github.com/fgenesis/pngrim
class PngRim {

	public static function processFile(path:String):Void {
		var img = load(path + ".png");
		img.makeOpaque();
		save(img, path + "_original_color.png");

		img = load(path + ".png");
		img.solidify(4);
		save(img, path + "_processed.png");
		img.makeOpaque();
		save(img, path + "_processed_color.png");
	}

	static function load(path:String):ImageBytes {
		var bytes = File.getBytes(path);
		var byteInput = new BytesInput (bytes, 0, bytes.length);
		var reader = new format.png.Reader(byteInput);
		var d = reader.read();
		var hdr = format.png.Tools.getHeader(d);
		var pixels = format.png.Tools.extract32(d);
		return new ImageBytes(hdr.width, hdr.height, pixels);
	}

	static function save(image:ImageBytes, path:String) {
		var d = format.png.Tools.build32BGRA(image.width, image.height, image.bytes);
		var byteOut = new BytesOutput();
		var writer = new format.png.Writer(byteOut);
		writer.write(d);
		File.saveBytes(path, byteOut.getBytes());
	}

}
