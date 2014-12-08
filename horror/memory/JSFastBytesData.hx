package horror.memory;

#if html5

import js.html.Uint8Array;
import js.html.Float32Array;
import js.html.Uint32Array;
import js.html.Uint16Array;
import js.html.ArrayBuffer;

@:extern
class JSFastBytesData
{
    public var data(default, set):Uint8Array;

    var arrayUShort: Uint16Array;
    var arrayUInt: Uint32Array;
    var arrayFloat: Float32Array;
    var io:JSFastBytesIO = new JSFastBytesIO();

    public function new() {}

    inline function set_data(value:Uint8Array):Uint8Array {
        if(data != value) {
            data = value;
            var buffer:ArrayBuffer = value.buffer;
            arrayUShort = new Uint16Array(buffer);
            arrayUInt = new Uint32Array(buffer);
            arrayFloat = new Float32Array(buffer);
            io.data = value;
        }
        return value;
    }

    public inline function getUInt8(pos:Int):Int {
        return data[pos];
    }

    public inline function getFloat32(pos:Int) : Float {
        return io.getFloat32(pos);
    }

    public inline function getUInt16(pos:Int) : Int {
        return io.getUInt16(pos);
    }

    public inline function getUInt32(pos:Int):Int {
        return io.getUInt32(pos);
    }

    public inline function setUInt8(pos:Int, v:Int):Void {
        data[pos] = v;
    }

    public inline function setFloat32(pos:Int, v:Float):Void {
        io.setFloat32(pos, v);
    }

    public inline function setUInt16(pos:Int, v:Int):Void {
        io.setUInt16(pos, v);
    }

    public inline function setUInt32(pos:Int, v:Int):Void {
        io.setUInt32(pos, v);
    }

    public inline function getFloat32_aligned(pos:Int):Float {
        return arrayFloat[pos>>2];
    }

    public inline function getUInt16_aligned(pos:Int):Int {
        return arrayUShort[pos>>1];
    }

    public inline function getUInt32_aligned(pos:Int):Int {
        return arrayUInt[pos>>2];
    }

    public inline function setFloat32_aligned(pos:Int, v:Float):Void {
        arrayFloat[pos>>2] = v;
    }

    public inline function setUInt16_aligned(pos:Int, v:Int):Void {
        arrayUShort[pos>>1] = v;
    }

    public inline function setUInt32_aligned(pos:Int, v:Int):Void {
        arrayUInt[pos>>2] = v;
    }
}

#end
