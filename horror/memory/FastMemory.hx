package horror.memory;

import haxe.io.BytesData;
import haxe.io.Bytes;

import openfl.utils.Endian;

#if flash
import flash.system.ApplicationDomain;
#end

import horror.std.Debug;

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
    public var data(default, null):BytesData;
#if js
	var _jsIO:JsBytesWrapper;
#end

    public function new(bytesData:BytesData) {
#if debug
		if(!_availabilityChecked) {
			Debug.assert(isAvailable, "FastMemory is not available.");
			_availabilityChecked = true;
		}
#end
		Debug.assert(bytesData != null);

        data = bytesData;

#if flash
		data.endian = flash.utils.Endian.LITTLE_ENDIAN;
#end

#if js
		_jsIO = new JsBytesWrapper();
		_jsIO.data = data;
#end
    }

    public static function fromSize(length:Int):FastMemory {
		return fromBytes(Bytes.alloc(length));
    }

    public static function fromBytes(bytes:Bytes):FastMemory {
        return new FastMemory(bytes.getData());
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

		#elseif js

		_jsIO.data = null;
		_jsIO = null;

		#end

		if(clearBuffer) {
			// TODO: investigate
			/*#if flash
			data.clear();
			#elseif js
			//data.splice()
			#else
			// setLength(0)
			#end*/
		}
		data = null;
	}

	@:extern inline function get_length():Int {
        return data.length;
    }

    @:extern inline function select():FastIO {
#if js
        return _jsIO;
#elseif flash
		if(data.length < 1024) {
			data.length = 1024;
		}
		APPLICATION_DOMAIN.domainMemory = data;
        return FastIO.NULL;
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

	// fast memory stack
	static var _stack:Array<FastMemory> = new Array<FastMemory>();
	static var _current:FastMemory;

	#if flash
	static var APPLICATION_DOMAIN:ApplicationDomain = ApplicationDomain.currentDomain;
	#end

	static var _availabilityChecked:Bool = false;
	public static var isAvailable(get, never):Bool;
	static function get_isAvailable():Bool {
	#if js
		return JsBytesConverter.isAvailable();
	#else
		return true;
	#end
	}
}
