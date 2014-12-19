package horror.utils;

import horror.std.Horror;

class ArrayUtil {
	public static function shuffle<T>(a:Array<T>):Void
	{
		Horror.assert(a != null);

		var s = a.length;
		var m = Math;
		while (--s > 1)
		{
			var i = Std.int(m.random() * s);
			var t = a[s];
			a[s] = a[i];
			a[i] = t;
		}
	}


	public inline static function unsafeGet<T>(a:Array<T>, index:Int):T {
		#if cpp
		return untyped a.__unsafe_get(index);
		#else
		return a[index];
		#end
	}

	public inline static function unsafeSet<T>(a:Array<T>, index:Int, value:T):Void {
#if cpp
		untyped a.__unsafe_set(index, value);
		#else
		a[index] = value;
#end
	}

    // for some platforms where Array.join too much native (like js)
    public static function join<T:Stringable>(a:Array<T>, separator:String = "\n"):String {
		Horror.assert(a != null && separator != null);

        var str = "";
        for(i in 0...a.length) {
            str += a[i];
            if(i + 1 < a.length) {
                str += separator;
            }
        }
        return str;
    }
}

private typedef Stringable = {
	function toString():String;
}