package horror.render;

import format.png.Reader;
import haxe.io.BytesInput;
import format.png.Tools;
import haxe.io.Bytes;
import horror.memory.ByteArray;
import horror.memory.UnsafeBytesBuffer;

class PngFormat {

	public var imageBytes:ByteArrayData;
	public var width:Int;
	public var height:Int;

	var _pngBytes:Bytes;

	public function new() {}

	public function decode(bytes:ByteArray):Bool {
		readInfo(bytes);
		var pixelData = UnsafeBytesBuffer.fromBytes(_pngBytes);
		var unsafeBytes = pixelData.getUnsafeBytes();
		var len:Int = pixelData.length;
		var i:Int = 0;
		while (i < len) {
			var a:Int = unsafeBytes[i + 3];
			var k:Float = a / 255.0;
			var r:Int = Std.int(k*unsafeBytes[i + 2]);
			var g:Int = Std.int(k*unsafeBytes[i + 1]);
			var b:Int = Std.int(k*unsafeBytes[i    ]);
			#if flash
			unsafeBytes[i    ] = b;
			unsafeBytes[i + 1] = g;
			unsafeBytes[i + 2] = r;
			unsafeBytes[i + 3] = a;
			#else
			unsafeBytes[i    ] = r;
			unsafeBytes[i + 1] = g;
			unsafeBytes[i + 2] = b;
			unsafeBytes[i + 3] = a;
			#end

			i+= 4;
		}

		imageBytes = pixelData.data;
		_pngBytes = null;

		return true;
	}

	public function readInfo(bytes:ByteArray):Void {
		var byteInput = new BytesInput (bytes.getBytes(), 0, bytes.length);
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
