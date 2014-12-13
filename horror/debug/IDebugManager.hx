package horror.debug;

interface IDebugManager {

	public function log(message:String, level:LogLevel):Void;

	public function beginProfile(sample:String):Void;
	public function endProfile(sample:String):Void;
	public function addFunction(alias:String, func:Dynamic):Void;

	public function nextFrame():Void;
	public var isPlaying:Bool;

	public function dispose():Void;
}