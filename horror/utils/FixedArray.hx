package horror.utils;

//typedef FixedArray<T> = haxe.ds.Vector<T>;

// TODO: one another patch

#if cpp
using cpp.NativeArray;
#end

private typedef FixedArrayData<T> =
#if flash
	flash.Vector<T>
#elseif neko
	neko.NativeArray<T>
#elseif cs
	cs.NativeArray<T>
#elseif java
	java.NativeArray<T>
#else
    Array<T>
#end ;

/**
	A Vector is a storage of fixed size. It can be faster than Array on some
	targets, and is never slower.
**/
abstract FixedArray<T>(FixedArrayData<T>) {
/**
		Creates a new Vector of length `length`.

		Initially `this` Vector contains `length` neutral elements:

		- always null on dynamic targets
		- 0, 0.0 or false for Int, Float and Bool respectively on static targets
		- null for other types on static targets

		If `length` is less than or equal to 0, the result is unspecified.
	**/
public inline function new(length:Int) {
        #if flash
			this = new flash.Vector<T>(length, true);
		#elseif neko
			this = untyped __dollar__amake(length);
		#elseif js
			this = untyped __new__(Array, length);
		#elseif cs
			this = new cs.NativeArray(length);
		#elseif java
			this = new java.NativeArray(length);
		#elseif cpp
			this = untyped (new Array<T>()).setSize(length);
		#else
            this = [];
            untyped this.length = length;
        #end
}

/**
		Returns the value at index `index`.

		If `index` is negative or exceeds `this.length`, the result is
		unspecified.
	**/
@:arrayAccess public inline function get(index:Int):Null<T> {
#if cpp
		return this.unsafeGet(index);
		#else
return this[index];
#end
}

/**
		Sets the value at index `index` to `val`.

		If `index` is negative or exceeds `this.length`, the result is
		unspecified.
	**/
@:arrayAccess public inline function set(index:Int, val:T):T {
#if cpp
		return this.unsafeSet(index,val);
		#else
return this[index] = val;
#end
}

/**
		Returns the length of `this` Vector.
	**/
public var length(get, never):Int;

inline function get_length():Int {
#if neko
			return untyped __dollar__asize(this);
		#elseif cs
			return this.Length;
		#elseif java
			return this.length;
		#else
return untyped this.length;
#end
}

/**
		Copies `length` of elements from `src` Vector, beginning at `srcPos` to
		`dest` Vector, beginning at `destPos`

		The results are unspecified if `length` results in out-of-bounds access,
		or if `src` or `dest` are null
	**/
public static #if (cs || java || neko || cpp) inline #end function blit<T>(src:FixedArray<T>, srcPos:Int, dest:FixedArray<T>, destPos:Int, len:Int):Void
{
#if neko
			untyped __dollar__ablit(dest,destPos,src,srcPos,len);
		#elseif java
			java.lang.System.arraycopy(src, srcPos, dest, destPos, len);
		#elseif cs
			cs.system.Array.Copy(cast src, srcPos,cast dest, destPos, len);
		#elseif cpp
			dest.toData().blit(destPos,src.toData(), srcPos,len);
		#else
for (i in 0...len)
{
dest[destPos + i] = src[srcPos + i];
}
#end
}

/**
		Creates a new Array, copy the content from the Vector to it, and returns it.
	**/
public #if (flash || cpp) inline #end function toArray():Array<T> {
#if cpp
			return this.copy();
		#else
var a = new Array();
var len = length;
#if (neko)
			// prealloc good size
			if( len > 0 ) a[len - 1] = get(0);
			#end
for( i in 0...len )
a[i] = get(i);
return a;
#end
}

/**
		Extracts the data of `this` Vector.

		This returns the internal representation type.
	**/
public inline function toData():FixedArrayData<T>
return cast this;

/**
		Initializes a new Vector from `data`.

		Since `data` is the internal representation of Vector, this is a no-op.

		If `data` is null, the corresponding Vector is also `null`.
	**/
static public inline function fromData<T>(data:FixedArrayData<T>):FixedArray<T>
return cast data;

/**
		Creates a new Vector by copying the elements of `array`.

		This always creates a copy, even on platforms where the internal
		representation is Array.

		The elements are not copied and retain their identity, so
		`a[i] == Vector.fromArrayCopy(a).get(i)` is true for any valid i.

		If `array` is null, the result is unspecified.
	**/
#if as3 @:extern #end
static public inline function fromArrayCopy<T>(array:Array<T>):FixedArray<T> {
// TODO: Optimize this for flash (and others?)
var vec = new FixedArray<T>(array.length);
for (i in 0...array.length)
vec.set(i, array[i]);
return vec;
}
}


