package horror.std;

// I don't use IDisposable pattern, cuz it's waste of time. Just implement dispose yourself
// and generate inlined dispose-pattern code-block. It's haxe advantages, let's use them!
// On the other side - it's harder to track and read all IDisposable objects with modern IDEs,
// but there is simple FIND IN PATH functions in your browser.

// TODO: move to Std.dispose(); API ???

class DisposeUtil {

	// thanks to @deep (Dima Granetchi)
	macro public static function dispose(val:haxe.macro.Expr, ?force:Bool) {
		return macro {
			if($val != null) {
				$val.dispose($a{ if (force == null) [] else [macro $v{force}] });
				$val = null;
			}
		};
	}

	/*
	macro public static function dispose(val:haxe.macro.Expr, args:Array<Expr>) {
		return macro {
			if($val != null) {
				$val.dispose($a{args});
				$val = null;
			}
		};
	}
	*/
}
