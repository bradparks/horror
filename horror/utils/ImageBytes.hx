package horror.utils;

import haxe.io.Bytes;

import horror.memory.FastMemory;
import horror.memory.FastIO;
import horror.std.DisposeUtil;
import horror.std.Debug;

class ImageBytes {

	public var bytes(default, null):Bytes;
	public var width(default, null):Int;
	public var height(default, null):Int;

	var _stride:Int;
	var _fastMem:FastMemory;
	var _fastIO:FastIO;

	public function new(width:Int, height:Int, bytes:Bytes) {
		Debug.assert(width > 0 && height > 0);
		Debug.assert(bytes != null && bytes.length >= width*height*4);

		this.width = width;
		this.height = height;
		this.bytes = bytes;
		_stride = width * 4;
	}

	public function lock():FastIO {
		if(_fastMem == null) {
			_fastMem = new FastMemory(bytes.getData());
		}
		return _fastIO = _fastMem.lock();
	}

	public function unlock():Void {
		_fastMem.unlock();
		_fastIO = FastIO.NULL;
	}

	public function dispose():Void {
		DisposeUtil.dispose(_fastMem);
	}

	@:extern inline function _addr(x:Int, y:Int):Int {
		return (x + width*y) << 2;
	}

	@:extern inline public function b(x:Int, y:Int):Int { return _fastIO[_addr(x, y)    ]; }
	@:extern inline public function g(x:Int, y:Int):Int { return _fastIO[_addr(x, y) + 1]; }
	@:extern inline public function r(x:Int, y:Int):Int { return _fastIO[_addr(x, y) + 2]; }
	@:extern inline public function a(x:Int, y:Int):Int { return _fastIO[_addr(x, y) + 3]; }

	@:extern inline public function setPixel(x:Int, y:Int, r:Int, g:Int, b:Int, a:Int):Void {
		_fastIO.setUInt32_aligned(_addr(x, y), makeColor32(r, g, b, a));
	}

	@:extern inline static function makeColor32(r:Int, g:Int, b:Int, a:Int):Int {
		return (a << 24) | (r << 16) | (g << 8) | b;
	}

	@:extern inline public function color24(x:Int, y:Int):Int {
		return _fastIO.getUInt32_aligned(_addr(x, y)) & 0xFFFFFF;
	}

	@:extern inline public function setColor24(x:Int, y:Int, v:Int):Void {
		var pos = _addr(x, y);
		var shiftedAlpha = _fastIO[pos + 3] << 24;
		_fastIO.setUInt32_aligned(pos, shiftedAlpha | (v & 0xFFFFFF));
	}
}