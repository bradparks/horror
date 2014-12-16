package horror.loaders;

import horror.std.Signal1;
import horror.std.Debug;

class BatchLoader {

	public var progress(get, never):Float;
	public var loaded(default, null):Signal1<BatchLoader> = new Signal1<BatchLoader>();

	var loaders:Array<BaseLoader> = new Array<BaseLoader>();
	var lookup:Map<String, BaseLoader> = new Map<String, BaseLoader>();

	var loadersTotal:Int = 0;
	var loadersCompleted:Int = 0;
	var isCompleted:Bool = false;
	var isLoading:Bool = false;

	public function new() {

	}

	public function dispose():Void {
		for(loader in loaders) {
			loader.dispose();
		}
		loaders = null;
		lookup = null;
	}

	public function add(loader:BaseLoader):Void {
		loaders.push(loader);
		lookup[loader.url] = loader;
	}

	public function load():Void {
		isCompleted = false;
		isLoading = true;
		loadersTotal = loaders.length;
		loadersCompleted = 0;
		for(loader in loaders) {
			loader.loaded.addOnce(loaderLoaded);
			loader.load();
		}
		checkComplete();
	}

	function loaderLoaded(sender:BaseLoader):Void {
		++loadersCompleted;
		checkComplete();
	}

	function checkComplete():Void {
		if(isLoading && !isCompleted && loadersCompleted >= loadersTotal) {
			isCompleted = true;
			isLoading = false;
			loaded.dispatch(this);
		}
	}

	function get_progress():Float {
		if(isCompleted) {
			return 1;
		}
		if(isLoading) {
			var count:Int = 0;
			var progress:Float = 0.0;
			for(loader in loaders) {
				progress += loader.progress;
				// here we must check non-progress loaders
				++count;
			}
			return count > 0 ? (progress / count) : 1.0;
		}
		return 0;
	}

	public function get<T>(url:String, type:Class<T>):T {
		if(url == null || !lookup.exists(url)) {
			Debug.warning('"$url" not found');
			return null;
		}

		var loader = lookup.get(url);
		if(loader == null) {
			Debug.warning('"$url" loader not found');
			return null;
		}

		var content = loader.getContent(type);
		if(content == null) {
			Debug.warning('"$url" has empty content');
			return null;
		}

		return content;
	}
}
