package horror.app;

import horror.render.RenderContext;
import horror.audio.AudioManager;
import horror.input.InputManager;
import horror.utils.DisposeUtil;
import horror.utils.Debug;

class Application {

	public static var current(default, null):Application;

	public var context(default, null):RenderContext;
	public var input(default, null):InputManager;
	public var audio(default, null):AudioManager;
	public var loop(default, null):LoopManager;
	public var screen(default, null):ScreenManager;

	public function new():Void {
		Debug.assert(current == null);

		current = this;

		screen = new ScreenManager();
		input = new InputManager();
		loop = new LoopManager();
		audio = new AudioManager();
		context = new RenderContext();

		context.initialize(onRenderInitialized);
	}

	public function start():Void { }

	public function dispose():Void {
		Debug.assert(current != null);

		DisposeUtil.dispose(screen);
		DisposeUtil.dispose(input);
		DisposeUtil.dispose(loop);
		DisposeUtil.dispose(context);
		DisposeUtil.dispose(audio);

		current = null;
	}

	function onRenderInitialized():Void {
		screen.resized.add(onScreenResized);
		onScreenResized(screen);

		start();
	}

	function onScreenResized(screen:ScreenManager):Void {
		context.resize(screen.width, screen.height);
		context.setOrtho2D(0, 0, screen.width, screen.height);
		trace('resized: ${screen.width}x${screen.height}');
	}


}
