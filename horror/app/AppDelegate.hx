package horror.app;

#if ((flash || openfl) && !lime)
private typedef AppDelegateBase = horror.app.flash.FlashAppDelegate;
#elseif lime
private typedef AppDelegateBase = horror.app.lime.LimeAppDelegate;
#elseif snow
private typedef AppDelegateBase = horror.app.snow.SnowAppDelegate;
#end

class AppDelegate extends AppDelegateBase {

	var __clientFactory:Void->Dynamic;
	var __clientInstance:Dynamic;

	public function new(factory:Void->Dynamic) {
		__clientFactory = factory;
		super();
	}

	override function __startHorrorApp():Void {
		//Timer.delay(
		//	function ():Void {
				__clientInstance = __clientFactory();
		//	}, 1);
	}
}