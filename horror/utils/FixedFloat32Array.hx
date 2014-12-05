package horror.utils;

#if cpp
using cpp.NativeArray;
#end

#if flash
typedef FixedFloat32ArrayData = flash.Vector<Float>;
#elseif js
typedef FixedFloat32ArrayData = js.html.Float32Array;
#else
typedef FixedFloat32ArrayData = Array<Float>;
#end

abstract FixedFloat32Array(FixedFloat32ArrayData) {
	inline public function new(length:Int) {
		#if flash
		this = new flash.Vector<Float>(length, true);
		#elseif js
		this = new js.html.Float32Array(length);
		#elseif cpp
		this = untyped (new Array<Float>()).setSize(length);
		#else
		this = new Array<Float>();
		this.length = length;
		#end
	}

	@:arrayAccess public inline function get(index:Int):Float {
		#if cpp
		return this.unsafeGet(index);
		#else
		return this[index];
		#end
	}

	@:arrayAccess public inline function set(index:Int, val:Float):Float {
		#if cpp
		return this.unsafeSet(index,val);
		#else
		return this[index] = val;
		#end
	}
}