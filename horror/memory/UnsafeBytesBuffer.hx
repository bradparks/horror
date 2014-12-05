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
class UnsafeBytesBuffer {

    public var length(get, null):Int = 0;
    public var position:Int = 0;
    public var data(default, null):ByteArrayData;
#if html5
	var jsIO:JSFastBytesData;
#end

    public function new(?data:ByteArrayData) {
        this.data = data != null ? data : new ByteArrayData();
        this.data.endian = cast Endian.LITTLE_ENDIAN;

#if html5
        jsIO = new JSFastBytesData();
        jsIO.data = data.byteView;
#end
    }

    public static function fromSize(length:Int):UnsafeBytesBuffer {
        return new UnsafeBytesBuffer(ByteArray.bufferFromSize(length));
    }

    public static function fromBytes(bytes:Bytes):UnsafeBytesBuffer {
        return new UnsafeBytesBuffer(ByteArray.bufferFromBytes(bytes));
    }

    public function clear():Void {
        data.clear();
    }

    inline function get_length():Int {
        return data.length;
    }

#if flash_memory_domain
    static var prevMemoryDomainData:ByteArrayData;
    static var appDomain:ApplicationDomain = ApplicationDomain.currentDomain;
    static inline function setMemoryDomainData(data:ByteArrayData):Void {
        if(prevMemoryDomainData != data) {
            prevMemoryDomainData = data;
			var minLength = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
			if(data.length < minLength) {
				data.length = minLength;
			}
            appDomain.domainMemory = data;
        }
    }
#end

    public inline function grow(bytesCount:Int):Void {
#if (html5 || flash)
		var newSize = position + bytesCount;
        var len = length;
        if(len < newSize) {
            while(len < newSize) len *= 2;
            data.length = len;
            #if html5
            jsIO.data = data.byteView;
            #end
        }
#else
        untyped data.ensureElem(position + bytesCount - 1, true);
#end
    }

    public inline function getUnsafeBytes():UnsafeBytes {

#if html5
        return jsIO;

#elseif flash_memory_domain
        setMemoryDomainData(data);
        return 0;

#elseif cpp
        return untyped data.b;

#else
        return data;

#end
    }



}
