package horror.memory;

import haxe.io.BytesData;
import haxe.io.Bytes;

import openfl.utils.Endian;

typedef ByteArrayData = openfl.utils.ByteArray;

class ByteArray {

	public var data(default, null):ByteArrayData;

    public var bigEndian(get, set):Bool;
    public var length(get, null):Int;
    public var position(get, set):Int;

	public function new(?data:ByteArrayData) {
		this.data = data != null ? data : new ByteArrayData();
		this.data.endian = Endian.LITTLE_ENDIAN;
	}

    inline static function bufferFromSize(length:Int):ByteArrayData {
#if (flash || html5)
        var data = new ByteArrayData();
        data.length = length;
        return data;
#else
		return new ByteArrayData(length);
#end
    }

    inline static function bufferFromBytes(bytes:Bytes):ByteArrayData {
#if flash
        return untyped bytes.b;
#else
        return ByteArrayData.fromBytes(bytes);
#end
    }

    public static function fromSize(length:Int):ByteArray {
        return new ByteArray(bufferFromSize(length));
    }

    public static function fromBytes(bytes:Bytes):ByteArray {
        return new ByteArray(bufferFromBytes(bytes));
    }

	public inline function readBytes(outData:ByteArray, offset:Int, length:Int):Void {
		data.readBytes(outData.data, offset, length);
	}

	public inline function readString():String {
		return data.readUTF();
	}

	public inline function readFloat32():Float {
		return data.readFloat();
	}

	public inline function readFloat64():Float {
		return data.readDouble();
	}

	public inline function readUInt8():Int {
		return data.readUnsignedByte();
	}

	public inline function readUInt16():Int {
		return data.readUnsignedShort();
	}

	public inline function readUInt32():Int {
		return data.readUnsignedInt();
	}

	public inline function readInt8():Int {
		return data.readByte();
	}

	public inline function readInt16():Int {
		return data.readShort();
	}

	public inline function readInt32():Int {
		return data.readInt();
	}

	public inline function writeString(value:String):Void {
		data.writeUTF(value);
	}

	public inline function writeFloat32(value:Float):Void {
		data.writeFloat(value);
	}

	public inline function writeFloat64(value:Float):Void {
		data.writeDouble(value);
	}

	public inline function writeUInt8(value:Int):Void {
		data.writeByte(value);
	}

	public inline function writeUInt16(value:Int):Void {
		data.writeShort(value);
	}

	public inline function writeUInt32(value:Int):Void {
		data.writeUnsignedInt(value);
	}

	public inline function writeInt8(value:Int):Void {
		data.writeByte(value);
	}

	public inline function writeInt16(value:Int):Void {
		data.writeShort(value);
	}

	public inline function writeInt32(value:Int):Void {
		data.writeInt(value);
	}

    inline function get_bigEndian():Bool {
        return data.endian == Endian.BIG_ENDIAN;
    }

    inline function set_bigEndian(value:Bool):Bool {
        data.endian = cast (value ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN);
        return value;
    }

    inline function get_length():Int {
        return data.length;
    }

    public function clear():Void {
        data.clear();
    }

    inline function get_position():Int {
        return data.position;
    }

    inline function set_position(value:Int):Int {
        return data.position = value;
    }

	public inline function getBytes():Bytes {
		// HTML5: very expensive :(
		#if html5
			var bytesData:BytesData = new BytesData();
			for(i in 0 ... data.byteView.length) {
				bytesData.push(data.byteView[i]);
			}
			return Bytes.ofData(bytesData);
			//return Bytes.ofData(data.byteView);
		#elseif flash
		return Bytes.ofData(data);
		#else
		return data;
		#end
	}

    public inline function getBytesData():BytesData {
        #if flash
		return data;
        #else
        return getBytes().getData();
        #end
    }




}
