package horror.debug;

class StdDebugManager implements IDebugManager
{

	public function new() {}

	public function log(message:String, level:LogLevel):Void {
		trace(message);
        if(level == LogLevel.ERROR) {
            throw(message);
        }
	}

	public function beginProfile(sample:String):Void {}
	public function endProfile(sample:String):Void {}
	public function addFunction(alias:String, func:Dynamic):Void {}

	public function nextFrame():Void {
		isPlaying = false;
	}
	
	public var isPlaying:Bool = true;
	
	public function dispose():Void {}
}