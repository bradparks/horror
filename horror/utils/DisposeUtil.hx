package horror.utils;

class DisposeUtil {

	public static function dispose<T:IDisposable>(target:T):T {
		if(target != null) {
			target.dispose();
		}
		return null;
	}
}
