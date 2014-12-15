package horror.memory;

import haxe.io.Bytes;

import openfl.utils.Endian;

#if flash
import flash.system.ApplicationDomain;
#end

import horror.memory.ByteArray;
import horror.utils.Debug;

/**
*
*  Manages:
*  - UnsafeBytes access
*  - Growing underliying buffer
*
*  Used for heavy sequential write typed bytes each frame (ex. writing buffers for gpu)
*  Used for make tons of modifications with UnsafeBytes (ex. image processing)
*
*  It's very common patterns indeed, but no bounds checking:
*  1) grow, write/mod, grow, write/mod
*  2) fixed size, fast read/write/mod
*
**/

@:access(horror.memory.ByteArray)
class FastMemory {

    public var length(get, never):Int;
    public var data(default, null):ByteArrayData;
#if html5
	var jsIO:JsBytesWrapper;
#end

    public function new(bufferData:ByteArrayData) {
		Debug.assert(bufferData != null);

        data = bufferData;
		data.endian = openfl.utils.Endian.LITTLE_ENDIAN;

#if html5
        jsIO = new JsBytesWrapper();
        jsIO.data = data.byteView;
#end
    }

    public static function fromSize(length:Int):FastMemory {
		var ba = new ByteArray(length);
        return new FastMemory(ba.data);
    }

    public static function fromBytes(bytes:Bytes):FastMemory {
		var ba = ByteArray.fromBytes(bytes);
        return new FastMemory(ba.data);
    }

	// unlock, deselect memory
	public function dispose(clearBuffer:Bool = false):Void {
		Debug.assert(data != null);

		if(_current == this) {
			unlock();
		}

		#if flash

		if(APPLICATION_DOMAIN.domainMemory == data) {
			APPLICATION_DOMAIN.domainMemory == null;
		}

		#elseif html5

		jsIO.data = null;
		jsIO = null;

		#end

		if(clearBuffer) {
			data.clear();
		}
		data = null;
	}

	@:extern inline function get_length():Int {
        return data.length;
    }

    @:extern inline function select():FastIO {
#if html5
        return jsIO;
#elseif flash
		if(data.length < 1024) {
			data.length = 1024;
		}
		APPLICATION_DOMAIN.domainMemory = data;
        return 0;
#elseif cpp
        return untyped data.b;
#else
        return data;
#end
    }

	public function lock():FastIO {
		if(_current != null) {
			_stack.push(_current);
		}
		_current = this;
		return select();
	}

	public function unlock():Void {
		_current = _stack.pop();
		if(_current != null) {
			_current.select();
		}
	}

	static var _stack:Array<FastMemory> = new Array<FastMemory>();
	static var _current:FastMemory;

	#if flash
	static var APPLICATION_DOMAIN:ApplicationDomain = ApplicationDomain.currentDomain;
	#end
}
