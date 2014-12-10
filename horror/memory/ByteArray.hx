package horror.memory;

import haxe.io.BytesData;
import haxe.io.Bytes;

import openfl.utils.Endian;

typedef ByteArrayData = openfl.utils.ByteArray;

class ByteArray {

	public var data(default, null):ByteArrayData;
    public var bigEndian(get, set):Bool;
    public var length(get, set):Int;
    public var position(get, set):Int;

	public function new(size:Int = 0) {
		if(size >= 0) {
#if flash
			setData(new ByteArrayData());
			data.length = size;
#else
			setData(new ByteArrayData(size));
#end
		}
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

	inline function set_length(value:Int):Int {
		#if (flash || js)
		data.length = value;
		#else
		data.setLength(value);
		#end
		return value;
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

	function setData(data:ByteArrayData):Void {
		this.data = data;
		this.data.endian = Endian.LITTLE_ENDIAN;
	}

	public inline static function fromData(data:ByteArrayData):ByteArray {
		var ba = new ByteArray(-1);
		ba.setData(data);
		return ba;
	}

	public inline static function fromBytes(bytes:Bytes):ByteArray {
		#if flash
		return ByteArray.fromData(untyped bytes.b);
		#else
		return ByteArray.fromData(ByteArrayData.fromBytes(bytes));
		#end
	}

	public inline function toBytes():Bytes {
		// HTML5: very expensive :(
		#if html5
			var bytesData:BytesData = new BytesData();
			var byteView = data.byteView;
			for(i in 0 ... byteView.length) {
				bytesData.push(byteView[i]);
			}
			return Bytes.ofData(bytesData);
			//return Bytes.ofData(data.byteView);
		#elseif flash
		return Bytes.ofData(data);
		#else
		return data;
		#end
	}

    public inline function toBytesData():BytesData {
        #if flash
		return data;
        #else
        return toBytes().getData();
        #end
    }
}
