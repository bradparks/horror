package horror.memory;

/**
*   Underliying data for efficiently data access
**/

#if html5
typedef FastIOInner = horror.memory.JsBytesWrapper;

#elseif flash
typedef FastIOInner = Int;

#elseif cpp
typedef FastIOInner = haxe.io.BytesData;

#else
typedef FastIOInner = horror.memory.ByteArray.ByteArrayData;

#end

/**
*   Class provides efficiently typed access in fixed memory snapshot
**/
abstract FastIO(FastIOInner) from FastIOInner {

    inline public function new(data:FastIOInner) {
        this = data;
    }

    public inline function set(pos:Int, x:Int):Void {
        setUInt8(pos, x);
    }

    @:arrayAccess
    public inline function get(pos:Int):Int {
        return getUInt8(pos);
    }

    @:arrayAccess @:noCompletion
    public inline function arrayWrite(pos:Int, x:Int):Int {
        setUInt8(pos, x);
        return x;
    }

    public inline function setFloat32(pos:Int, x:Float):Void {
#if cpp
		untyped __global__.__hxcpp_memory_set_float(this, pos, x);
#elseif html5
        this.setFloat32(pos, x);
#elseif flash
		flash.Memory.setFloat(pos, x);
#else
        this.position = pos;
        this.writeFloat(x);
#end
    }

    public inline function setUInt32(pos:Int, x:Int):Void {
#if cpp
		untyped __global__.__hxcpp_memory_set_ui32(this, pos, x);
#elseif html5
        this.setUInt32(pos, x);
#elseif flash
		flash.Memory.setI32(pos, x);
#else
        this.position = pos;
        this.writeUnsignedInt(x);
#end
    }

    public inline function setUInt16(pos:Int, x:Int):Void {
#if cpp
		untyped __global__.__hxcpp_memory_set_ui16(this, pos, x);
#elseif html5
        this.setUInt16(pos, x);
#elseif flash
		flash.Memory.setI16(pos, x);
#else
        this.position = pos;
        this.writeShort(x);
#end
    }

    public inline function setUInt8(pos:Int, x:Int):Void {
#if cpp
		untyped this[pos] = x;
#elseif html5
        this.setUInt8(pos, x);
#elseif flash
		flash.Memory.setByte(pos, x);
#else
        this.position = pos;
        this.writeByte(x);
#end
    }

    public inline function getFloat32(pos:Int):Float {
#if cpp
		return untyped __global__.__hxcpp_memory_get_float(this, pos);
#elseif html5
        return this.getFloat32(pos);
#elseif flash
	    return flash.Memory.getFloat(pos);
#else
        this.position = pos;
        return this.readFloat();
#end
    }

    public inline function getUInt32(pos:Int):Int {
#if cpp
		return untyped __global__.__hxcpp_memory_get_ui32(this, pos);
#elseif html5
        return this.getUInt32(pos);
#elseif flash
	    return flash.Memory.getI32(pos);
#else
        this.position = pos;
        return this.readUnsignedInt();
#end
    }

    public inline function getUInt16(pos:Int):Int {
#if cpp
		return untyped __global__.__hxcpp_memory_get_ui16(this, pos);
#elseif html5
        return this.getUInt16(pos);
#elseif flash
	    return flash.Memory.getUI16(pos);
#else
        this.position = pos;
        return this.readShort();
#end
    }

    public inline function getUInt8(pos:Int):Int {
#if cpp
		return untyped this[pos];
#elseif html5
        return this.getUInt8(pos);
#elseif flash
	    return flash.Memory.getByte(pos);
#else
        this.position = pos;
        return this.readUnsignedByte();
#end
    }

    public inline function setFloat32_aligned(pos:Int, x:Float):Void {
#if html5
		this.setFloat32_aligned(pos, x);
#else
        setFloat32(pos, x);
#end
    }


    public inline function setUInt32_aligned(pos:Int, x:Int):Void {
#if html5
		this.setUInt32_aligned(pos, x);
#else
        setUInt32(pos, x);
#end
    }

    public inline function setUInt16_aligned(pos:Int, x:Int):Void {
#if html5
		this.setUInt16_aligned(pos, x);
#else
        setUInt16(pos, x);
#end
    }

    public inline function getFloat32_aligned(pos:Int):Float {
#if html5
		return this.getFloat32_aligned(pos);
#else
        return getFloat32(pos);
#end
    }

    public inline function getUInt32_aligned(pos:Int):Int {
#if html5
		return this.getUInt32_aligned(pos);
#else
        return getUInt32(pos);
#end
    }

    public inline function getUInt16_aligned(pos:Int):Int {
#if html5
		return this.getUInt16_aligned(pos);
#else
        return getUInt16(pos);
#end
    }
}
