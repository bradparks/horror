package horror.loaders;

import horror.std.Module;

#if hrr_snow
import horror.app.snow.SnowAppDelegate;
import snow.types.Types.AssetInfo;
#end

class Assets extends Module {

	public function new() {
		super();
	}

	public function list():Array<String> {
		var result:Array<String>;

		#if hrr_snow

		result = new Array<String>();
		var appDelegate = untyped SnowAppDelegate.__instance;
		var map:Map<String, AssetInfo> = appDelegate.app.assets.list;
		for(v in map) {
			result.push(v.id);
		}

		#elseif hrr_lime

		result = lime.Assets.list(null);

		#elseif hrr_openfl

		result = openfl.Assets.list(null);

		#end

		return result;
	}

}
