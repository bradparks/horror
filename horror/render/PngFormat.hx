package horror.render;

import haxe.io.BytesInput;
import haxe.io.Bytes;

import format.png.Reader;
import format.png.Tools;

import horror.memory.ByteArray;
import horror.memory.FastMemory;

class PngFormat {

	public var imageBytes:ByteArray;
	public var width:Int;
	public var height:Int;

	var _pngBytes:Bytes;

	public function new() {}

	public function decode(bytes:ByteArray):Bool {
		readInfo(bytes);

		#if flash
		imageBytes = ByteArray.fromBytes(_pngBytes);
		#else
		imageBytes = ByteArray.fromData(convertARGB_ABGR(_pngBytes));
		#end

		_pngBytes = null;
		return true;
	}

	function convertARGB_ABGR(bytes:Bytes):ByteArrayData {
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
		return pixelsMemory.data;
	}

	/*function convertToPMA():Void {
		var pixelsMemory = FastMemory.fromBytes(_pngBytes);
		var pixels = pixelsMemory.lock();
		var len = pixelsMemory.length;
		var i = 0;
		while (i < len) {
			var a:Int = pixels[i + 3];
			var k:Float = a / 255.0;
			var r:Int = Std.int(k*pixels[i + 2]);
			var g:Int = Std.int(k*pixels[i + 1]);
			var b:Int = Std.int(k*pixels[i    ]);
			#if flash
			pixels[i    ] = b;
			pixels[i + 1] = g;
			pixels[i + 2] = r;
			pixels[i + 3] = a;
			#else
			pixels[i    ] = r;
			pixels[i + 1] = g;
			pixels[i + 2] = b;
			pixels[i + 3] = a;
			#end

			i+= 4;
		}

		pixelsMemory.unlock();
	}*/

	public function readInfo(bytes:ByteArray):Void {
		var byteInput = new BytesInput (bytes.toBytes(), 0, bytes.length);
		var d = new Reader(byteInput).read();
		var hdr = Tools.getHeader(d);
		_pngBytes = Tools.extract32(d);
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
		_pngBytes = null;
	}
}
