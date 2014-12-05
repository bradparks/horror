package horror.debug;

import horror.utils.IDisposable;

interface IDebugManager extends IDisposable {
	
	public function log(message:String, level:LogLevel):Void;

	public function beginProfile(sample:String):Void;
	public function endProfile(sample:String):Void;
	public function addFunction(alias:String, func:Dynamic):Void;

	public function nextFrame():Void;
	public var isPlaying:Bool;

}