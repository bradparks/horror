package horror.utils;

import haxe.io.Bytes;

import horror.std.Horror;

class BitMask {
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var bytes(default, null):Bytes;
	public var outerFlag:Bool = false;

	public function new(width:Int, height:Int, bytes:Bytes = null) {
		this.width = width;
		this.height = height;

		var minBytesLength = calcBytesLength(width, height);
		if(bytes != null) {
			Horror.assert(bytes.length <= minBytesLength);
			this.bytes = bytes;
		}
		else {
			this.bytes = Bytes.alloc(minBytesLength);
			// TODO: check allocated memory filled by zeros?
		}
	}

	public function get(x:Int, y:Int):Bool {
		if (x >= 0 && x < width && y >= 0 && y < height) {
			var addres = (y*width + x);
			var offset = addres >> 3;
			var mask = 1 << (addres & 0x7);
			return (bytes.get(offset) & mask) > 0;
		}
		return outerFlag;
	}

	public function set(x:Int, y:Int, flag:Bool):Bool {
		if (x >= 0 && x < width && y >= 0 && y < height) {
			var addres = (y*width + x);
			var offset = addres >> 3;
			var mask = 1 << (addres & 0x7);
			bytes.set(offset, flag ? (bytes.get(offset) | mask) : (bytes.get(offset) & (~mask)));
			return flag;
		}
		return outerFlag;
	}

	static function calcBytesLength(width:Int, height:Int):Int {
		return Math.ceil(width*height/8.0);
	}
}


