package horror.utils;

import haxe.PosInfos;

class Debug
{
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

}