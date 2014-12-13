package horror.render;

abstract Color32(Int) to Int {

	public var a(get, set):Int;
	public var r(get, set):Int;
	public var g(get, set):Int;
	public var b(get, set):Int;

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

	@:from
	inline public static function fromARGB(argb:Int):Color32 {
		// swap to ABGR
		return new Color32((argb & 0xFF00FF00) | ((argb >> 16) & 0xFF) | ((argb & 0xFF) << 16));
	}
}
