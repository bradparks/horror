package horror.loaders;

import horror.utils.IDisposable;
import horror.debug.Debug;
import horror.signals.Signal1;

class BaseLoader implements IDisposable {

	public var url(default, null):String;
	public var content(default, null):Dynamic;
	public var progress(get, null):Float;
	public var loaded(default, null):Signal1<BaseLoader> = new Signal1<BaseLoader>();
	public var error:String = null;
	public var completed(default, null):Bool = false;
	public var loading(default, null):Bool = false;

	var _progress:Float = 0.0;

	public function new(url:String = null) {
		this.url = url;
	}

	public function dispose():Void {
		loaded = null;
		content = null;
	}

	public function load():Void {
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
			Debug.logWarning('"$url" has ${Type.getClass(content)}, but $type requested');
			return null;
		}

		return cast content;
	}
}
