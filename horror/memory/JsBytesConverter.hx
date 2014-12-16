package horror.memory;

#if js

import horror.std.Debug;

import js.html.DataView;
import js.html.Float32Array;
import js.html.Uint32Array;
import js.html.Int16Array;
import js.html.Uint16Array;
import js.html.Uint8Array;
import js.html.ArrayBuffer;

class JsBytesConverter
{
    public var data:Uint8Array;
    var _buffer: ArrayBuffer;
    var _ui8 : Uint8Array;
    var _ui16: Uint16Array;
    var _ui32: Uint32Array;
    var _f32: Float32Array;

    public function new() {
        _buffer = new ArrayBuffer(4);
        _ui8 = new Uint8Array(_buffer);
        _ui16 = new Uint16Array(_buffer);
        _ui32 = new Uint32Array(_buffer);
        _f32 = new Float32Array(_buffer);
    }

	@:extern inline public function getUInt8(pos:Int):Int {
        return data[pos];
    }

	@:extern inline public function getFloat32(pos:Int) : Float {
        _ui32[0] = getUInt32(pos);
        return _f32[0];
    }

	@:extern inline public function getUInt16(pos:Int) : Int {
        _ui8[0] = getUInt8(pos);
        _ui8[1] = getUInt8(pos + 1);
        return _ui16[0];
    }

	@:extern inline public function getUInt32(pos:Int):Int {
        _ui8[0] = getUInt8(pos);
        _ui8[1] = getUInt8(pos + 1);
        _ui8[2] = getUInt8(pos + 2);
        _ui8[3] = getUInt8(pos + 3);
        return _ui32[0];
    }

	@:extern inline public function setUInt8(pos:Int, v:Int):Void {
        data[pos] = v;
    }

	@:extern inline public function setFloat32(pos:Int, v:Float) : Void
    {
        _f32[0] = v;
        setUInt8(pos    , _ui8[0]);
        setUInt8(pos + 1, _ui8[1]);
        setUInt8(pos + 2, _ui8[2]);
        setUInt8(pos + 3, _ui8[3]);
    }

	@:extern inline public function setUInt16(pos:Int, v:Int) : Void
    {
        _ui16[0] = v;
        setUInt8(pos    , _ui8[0]);
        setUInt8(pos + 1, _ui8[1]);
    }

	@:extern inline public function setUInt32(pos:Int, v:Int) : Void
    {
        _ui32[0] = v;
        setUInt8(pos    , _ui8[0]);
        setUInt8(pos + 1, _ui8[1]);
        setUInt8(pos + 2, _ui8[2]);
        setUInt8(pos + 3, _ui8[3]);
    }

	static function isLittleEndian() {
		var buffer = new ArrayBuffer(2);
		new DataView(buffer).setInt16(0, 256, true);
		return new Int16Array(buffer)[0] == 256;
	}

	public static function isAvailable():Bool {
		if(!isLittleEndian()) {
			Debug.warning("Hey! This is big-endian commons. Could we run correctly? Just delete me if it works!");
			return false;
		}
		return true;
	}
}
#end
