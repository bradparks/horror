package horror.render;

abstract Color32(Int) to Int {

	public var a(get, set):Int;
	public var r(get, set):Int;
	public var g(get, set):Int;
	public var b(get, set):Int;
	public var argb(get, set):Int;

	public inline function new(abgr:Int) {
		this = abgr;
	}

	inline function get_a():Int { return (this >> 24) & 0xFF; }
	inline function get_b():Int { return (this >> 16) & 0xFF; }
	inline function get_g():Int { return (this >> 8) & 0xFF; }
	inline function get_r():Int { return this & 0xFF; }

	inline function set_a(value:Int):Int { return this = ((value & 0xFF) << 24) | (this & 0x00FFFFFF); }
	inline function set_b(value:Int):Int { return this = ((value & 0xFF) << 16) | (this & 0xFF00FFFF); }
	inline function set_g(value:Int):Int { return this = ((value & 0xFF) << 8 ) | (this & 0xFFFF00FF); }
	inline function set_r(value:Int):Int { return this = ( value & 0xFF       ) | (this & 0xFFFFFF00); }

	inline function get_argb():Int { return swapRB(this); }
	inline function set_argb(value:Int):Int { return this = swapRB(value); }

	@:from
	inline public static function fromARGB(argb:Int):Color32 {
		// swap to ABGR
		return new Color32(swapRB(argb));
	}

	inline public static function fromBytes(r:Int, g:Int, b:Int, a:Int):Color32 {
		return new Color32((a << 24) | (b << 16) | (g << 8) | r);
	}

	inline public static function fromFloats(r:Float, g:Float, b:Float, a:Float):Color32 {
		return fromBytes(Std.int(r*255), Std.int(g*255), Std.int(b*255), Std.int(a*255));
	}

	inline static function swapRB(color:Int):Int {
		return (color & 0xFF00FF00) | ((color >> 16) & 0xFF) | ((color & 0xFF) << 16);
	}

	inline public static var WHITE:Color32 = 0xFFFFFFFF;
	inline public static var ZERO:Color32 = 0x00000000;
}
