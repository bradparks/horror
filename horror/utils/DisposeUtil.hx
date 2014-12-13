package horror.utils;

private typedef TDisposable = {
	function dispose():Void;
}

class DisposeUtil {

	// TODO: dispose macro
	// TODO: move to Std.dispose(); API ???
	// I don't use IDisposable pattern, cuz it's waste of time. Just implement dispose yourself
	// and generate inlined dispose-pattern code-block. It's haxe advantages, let's use them!
	// On the other side - it's harder to track and read all IDisposable objects with modern IDEs,
	// but there is simple FIND IN PATH functions in your browser.
	public static function dispose<T:TDisposable>(target:T):T {
		if(target != null) {
			target.dispose();
		}
		return null;
	}
}
