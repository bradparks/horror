package horror.loaders;

import horror.std.Horror;
import horror.std.Signal1;

class BaseLoader {

	public var url(default, null):String;
	public var content(default, null):Dynamic;
	public var progress(get, null):Float;
	public var loaded(default, null):Signal1<BaseLoader> = new Signal1<BaseLoader>();
	public var error:String = null;
	public var completed(default, null):Bool = false;
	public var loading(default, null):Bool = false;

	var _progress:Float = 0.0;

	var _startTime:Float;

	public function new(url:String = null) {
		this.url = url;
	}

	public function dispose():Void {
		loaded = null;
		content = null;
	}

	public function load():Void {
		_startTime = haxe.Timer.stamp();
		error = null;
		completed = false;
		loading = true;
		performLoad();
	}

	public function cancel():Void {
		error = "cancelled";
		completed = true;
		loading = false;
		performCancel();
	}

	function performCancel():Void {

	}

	function performLoad():Void {

	}

	function performComplete():Void {
		var sec = haxe.Timer.stamp() - _startTime;
		Horror.log('"$url" completed: $sec');

		completed = true;
		loading = false;
		loaded.dispatch(this);
	}

	function performFail(msg:String):Void {
		trace('Loader $url failed: $msg');
		error = msg;
		performComplete();
	}

	function setProgress(pr:Float):Void {
		_progress = pr;
		trace('pr $url : $pr');
	}

	function resolveProgress():Float {
		return _progress;
	}

	function get_progress():Float {
		if(completed) {
			return 1;
		}
		if(loading)	{
			return resolveProgress();
		}
		return 0;
	}

	public function getContent<T>(type:Class<T>):T {
		if(!Std.is(content, type)) {
			Horror.warning('"$url" has ${Type.getClass(content)}, but $type requested');
			return null;
		}

		return cast content;
	}
}
