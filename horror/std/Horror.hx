package horror.std;

import haxe.PosInfos;

class Horror {

	static var _modules:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static function get<T:IModule>(cls:Class<T>):T {
		var name = Type.getClassName(cls);
		var module = _modules.get(name);
		if(module == null) {
			trace('[HORROR] Module $name not found');
		}
		return cast module;
	}

	public static function register<T:IModule>(module:T):Bool {
		var name = Type.getClassName(Type.getClass(module));
		if(_modules.get(name) != null) {
			trace('[HORROR] Module $name have registered already');
			return false;
		}
		_modules.set(name, module);
		trace('[HORROR] Module $name has been added');
		return true;
	}

	public static function drop<T:IModule>(module:T):Bool {
		var name = Type.getClassName(Type.getClass(module));
		if(_modules.get(name) == null) {
			trace('[HORROR] Module $name have dropped already');
			return false;
		}
		_modules.set(name, null);
		trace('[HORROR] Module $name has been removed');
		return true;
	}

	public static function exit():Void {
		// TODO: add air
		#if (cpp || neko || php)
		Sys.exit(0);
		#end
	}

	/*** LOGGING ***/

	public inline static function log(message:String):Void {
		trace(message);
	}

	public inline static function warning(message:String):Void {
		trace('[W] $message');
	}

	public inline static function error(message:String):Void {
		throw '[ERROR] $message';
	}

	#if (debug || keep_assert || display || dox)

	public static function assert(conditionIsTrue:Bool, ?message:String, ?position:PosInfos):Void {
		if(conditionIsTrue) {
			return;
		}
		if (message == null) {
			message = 'true expected';
		}
		var text = '[ASSERT] $message at ${position.fileName}:${position.lineNumber}';
		log(text);
		throw text;
	}

	#else

	public static inline function assert(a:Bool, ?b:String = null, ?c:PosInfos = null):Void { }

	#end

	/*** UTILITIES ***/

	// I don't use IDisposable pattern, cuz it's waste of time. Just implement dispose yourself
	// and generate inlined dispose-pattern code-block. It's haxe advantages, let's use them!
	// On the other side - it's harder to track and read all IDisposable objects with modern IDEs,
	// but there is simple FIND IN PATH functions in your browser.

	// thanks to @deep (Dima Granetchi)
	macro public static function dispose(val:haxe.macro.Expr, ?force:Bool) {
		return macro {
			if($val != null) {
				$val.dispose($a{ if (force == null) [] else [macro $v{force}] });
				$val = null;
			}
		};
	}

}
