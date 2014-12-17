package ;

import horror.app.ScreenManager;
import horror.app.LoopManager;
import horror.std.Horror;
import horror.render.RenderContext;
import horror.audio.AudioManager;
import horror.input.InputManager;

class Application {

	public var context(default, null):RenderContext;
	public var input(default, null):InputManager;
	public var audio(default, null):AudioManager;
	public var loop(default, null):LoopManager;
	public var screen(default, null):ScreenManager;

	public function new():Void {

		screen = new ScreenManager();
		input = new InputManager();
		loop = new LoopManager();
		audio = new AudioManager();
		context = new RenderContext();

		context.initialize(onRenderInitialized);
	}

	public function initialize():Void { }

	public function start():Void {
		loop.updated.add(onLoopUpdated);
	}

	public function update(dt:Float):Void { }

	public function dispose():Void {
		Horror.dispose(screen);
		Horror.dispose(input);
		Horror.dispose(loop);
		Horror.dispose(context);
		Horror.dispose(audio);
	}

	function onRenderInitialized():Void {
		screen.resized.add(onScreenResized);
		onScreenResized(screen);

		initialize();
	}

	function onScreenResized(screen:ScreenManager):Void {
		context.resize(screen.width, screen.height);
		context.setOrtho2D(0, 0, screen.width, screen.height);
		trace('resized: ${screen.width}x${screen.height}');
	}

	function onLoopUpdated(loop:LoopManager):Void {
		update(loop.deltaTime);
	}

}
