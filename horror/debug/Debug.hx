package horror.debug;

import horror.utils.DisposeUtil;
import haxe.PosInfos;

/**
	Debug provides assertion, logging, profiling and play control APIs.
	By design Debug is a static Service Locator over the IDebugManager implementation.
**/
class Debug
{
 	public static var currentDebugManager(default, set):IDebugManager = new StdDebugManager();
	
	public static function getDebugManager<T:IDebugManager>(type:Class<T>):T {
		return cast currentDebugManager;
	}
	
	public inline static function log(message:String, level:LogLevel = LogLevel.INFO):Void {
		currentDebugManager.log(message, level);
	}

    public inline static function logWarning(message:String):Void {
        log(message, LogLevel.WARNING);
    }

    public inline static function logError(message:String):Void {
        log(message, LogLevel.ERROR);
    }

	public inline static function beginProfile(sample:String):Void {
		currentDebugManager.beginProfile(sample);
	}

	public inline static function endProfile(sample:String):Void {
		currentDebugManager.endProfile(sample);
	}

	public static function addFunction(alias:String, func:Dynamic):Void {
		currentDebugManager.addFunction(alias, func);
	}

	public static var isPlaying(get, never):Bool;
	
	public static function play():Void {
		currentDebugManager.isPlaying = true;
	}

	public static function stop():Void {
		currentDebugManager.isPlaying = false;
	}

	public static function nextFrame():Void {
		currentDebugManager.nextFrame();
	}

	static var msgCountMap:Map<String, Int> = new Map<String, Int>();
	public static function logOnce(text:String, level:LogLevel = LogLevel.INFO):Void {
		var m = msgCountMap;
		var count = (m.exists(text) ? m[text] : 0) + 1;
		m[text] = count;
		if(count == 1) {
			log(text, level);
		}
	}
	

#if (debug || keep_assert || display || dox)
	public static function assert(conditionIsTrue:Bool, ?message:String, ?position:PosInfos):Void {
		if(!conditionIsTrue) {
			if (message == null) {
				message = "true expected";
			}
			logError('[Assert] $message at ${position.fileName}:${position.lineNumber}');			
		}
	}

#else

	public static inline function assert(a:Bool, ?b:String = null, ?c:PosInfos = null):Void {
		// empty inline method allow fully strip assertion call 		
	}

#end

	static function get_isPlaying():Bool {
		return currentDebugManager.isPlaying;
	}
	
	static function set_currentDebugManager(value:IDebugManager):IDebugManager {
		DisposeUtil.dispose(currentDebugManager);

		currentDebugManager = value;
		if (currentDebugManager == null) {
			currentDebugManager = new StdDebugManager();
		}
		return currentDebugManager;
	}

}