package horror.app;

import horror.std.Horror;

#if hrr_flash

private typedef AppDelegateBase = horror.app.flash.FlashAppDelegate;

#elseif hrr_lime

private typedef AppDelegateBase = horror.app.lime.LimeAppDelegate;

#elseif hrr_snow

private typedef AppDelegateBase = horror.app.snow.SnowAppDelegate;

#end

class AppDelegate extends AppDelegateBase {

	var __clientFactory:Void->Dynamic;
	var __clientInstance:Dynamic;

	public function new(factory:Void->Dynamic) {
		__clientFactory = factory;
		Horror.log("Application delegate created...");
		super();
	}

	override function __startHorrorApp():Void {
		Horror.log("Create client application");
		//Timer.delay(
		//	function ():Void {
			__createHorrorApp();
		//	}, 1);
	}

	function __createHorrorApp():Void {
		if(__clientFactory != null) {
			__clientInstance = __clientFactory();
		}
		else {
			Horror.error("Bad application factory!");
		}
	}
}