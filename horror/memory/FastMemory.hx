package horror.memory;

import openfl.utils.Endian;
import haxe.io.Bytes;
import horror.memory.ByteArray;

#if flash_memory_domain
import flash.system.ApplicationDomain;
#elseif html5
import horror.memory.JSFastBytesData;
#end

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
	var jsIO:JSFastBytesData;
#end

    public function new(?data:ByteArrayData) {
        this.data = data != null ? data : new ByteArrayData();
        this.data.endian = openfl.utils.Endian.LITTLE_ENDIAN;

#if html5
        jsIO = new JSFastBytesData();
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

    public function clear():Void {
        data.clear();
    }

    inline function get_length():Int {
        return data.length;
    }

#if flash
    static var appDomain:ApplicationDomain = ApplicationDomain.currentDomain;
#end

    @:extern inline function select():FastIO {
#if html5
        return jsIO;
#elseif flash
		if(data.length < 1024) {
			data.length = 1024;
		}
		appDomain.domainMemory = data;
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

	static var _stack:Array<FastMemory> = new Array<FastMemory>();
	static var _current:FastMemory;

	public function unlock():Void {
		_current = _stack.pop();
		if(_current != null) {
			_current.select();
		}
	}
}
