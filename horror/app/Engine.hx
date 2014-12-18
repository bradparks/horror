package horror.app;

import horror.std.Signal0;
import horror.audio.AudioManager;
import horror.input.InputManager;
import horror.render.RenderContext;

import horror.std.Horror;
import horror.std.Signal1;
import horror.std.Module;

#if (flash || openfl)
private typedef ApplicationDriver = horror.app.flash.FlashDriver;
#elseif lime
private typedef ApplicationDriver = horror.app.lime.LimeDriver;
#elseif snow
private typedef ApplicationDriver = horror.app.snow.SnowDriver;
#end

class Engine extends Module {

	// Screen managment
	public var width(default, null):Int = 1;
	public var height(default, null):Int = 1;
	public var dpi(default, null):Int = 0;

	// Loop managment
	public var timeStamp(default, null):Float = 0.0;
	public var deltaTime(default, null):Float = 0.001;
	public var targetFrameRate(get, set):Int;

	// Events
	public var onUpdate(default, null):Signal1<Float> = new Signal1<Float>("Update Event");
	public var onRender(default, null):Signal0 = new Signal0("Render Event");
	public var onResize(default, null):Signal0 = new Signal0("Resize Event");

	// Managers
	public var input(default, null):InputManager;
	public var render(default, null):RenderContext;
	public var audio(default, null):AudioManager;

	var _driver:ApplicationDriver;
	var _cbReady:Void->Void;

	public function new() {
		super();
	}

	public function initialize(completed:Void->Void) {
		_cbReady = completed;

		render = new RenderContext();
		input = new InputManager();
		audio = new AudioManager();

		_driver = new ApplicationDriver();
		_driver.updated = handleUpdate;
		_driver.resized = handleResize;
		_driver.render = handleRender;
		_driver.mouse = input.handleMouseEvent;
		_driver.keys = input.handleKeyboardEvent;

		render.initialize(onRenderContextReady);
	}

	public override function dispose() {
		Horror.dispose(_driver);

		Horror.dispose(onUpdate);
		Horror.dispose(onResize);
		Horror.dispose(onRender);

		Horror.dispose(audio);
		Horror.dispose(render);
		Horror.dispose(input);
	}

	public inline function time():Float {
		return _driver.getTimeStamp();
	}

	inline function get_targetFrameRate():Int {
		return _driver.getFrameRate();
	}

	inline function set_targetFrameRate(v:Int):Int {
		_driver.setFrameRate(v);
		return v;
	}

	function onRenderContextReady():Void {
		timeStamp = time();
		handleResize();

		if(_cbReady != null) {
			_cbReady();
			_cbReady = null;
		}
	}

	function handleUpdate():Void {
		var now:Float = time();
		deltaTime = now - timeStamp;
		timeStamp = now;

		input.update();

		onUpdate.dispatch(deltaTime);
	}

	function handleRender():Void {
		onRender.dispatch();
	}

	function handleResize():Void {
		width = _driver.getWidth();
		height = _driver.getHeight();
		if(render.isInitialized) {
			render.resize(width, height);
			render.setOrtho2D(0, 0, width, height);
		}
		onResize.dispatch();
		trace('resized: $width x $height');
	}

}
