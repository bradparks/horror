package horror.renderex;

import haxe.io.BytesInput;
import haxe.io.Bytes;

import format.png.Reader;
import format.png.Tools;

import horror.memory.FastMemory;

class PngFormat {

	public var imageBytes:Bytes;
	public var width:Int;
	public var height:Int;

	public function new() {}

	public function decode(bytes:Bytes):Bool {
		readInfo(bytes);

		#if !flash
		convertARGB_ABGR(imageBytes);
		#end

		return true;
	}

	function convertARGB_ABGR(bytes:Bytes):Void {
		var pixelsMemory = FastMemory.fromBytes(bytes);
		var pixels = pixelsMemory.lock();
		var len = pixelsMemory.length;
		var i = 0;
		while (i < len) {
			var r:Int = pixels[i + 2];
			var b:Int = pixels[i    ];
			pixels[i    ] = r;
			pixels[i + 2] = b;
			i += 4;
		}
		pixelsMemory.unlock();
		pixelsMemory.dispose(false);
	}

	public function readInfo(bytes:Bytes):Void {
		var byteInput = new BytesInput(bytes, 0, bytes.length);
		var reader = new Reader(byteInput);
		reader.checkCRC = false;
		var d = reader.read();
		var hdr = Tools.getHeader(d);
		imageBytes = Tools.extract32(d);
		width = hdr.width;
		height = hdr.height;
	}

	public function dispose():Void {
		if(imageBytes != null) {
			//imageBytes.clear();
			imageBytes = null;
		}
		width = 0;
		height = 0;
	}
}
