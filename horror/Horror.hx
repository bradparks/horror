package horror;

import horror.utils.DisposeUtil;
import horror.debug.Debug;
import horror.audio.AudioManager;
import horror.input.InputManager;
import horror.app.LoopManager;
import horror.app.ScreenManager;
import horror.render.RenderManager;

class Horror {

	public static var render(default, null):RenderManager;
	public static var input(default, null):InputManager;
	public static var audio(default, null):AudioManager;
	public static var loop(default, null):LoopManager;
	public static var screen(default, null):ScreenManager;

	static var _cbOnReady:Void->Void;

	public static function initialize(onReady:Void->Void):Void {
		Debug.assert(loop == null);
		_cbOnReady = onReady;

		screen = new ScreenManager();
		input = new InputManager();
		loop = new LoopManager();
		audio = new AudioManager();
		render = new RenderManager();
		render.initialize(onRenderInitialized);
	}

	static function onRenderInitialized():Void {
		if(_cbOnReady != null) {
			_cbOnReady();
			_cbOnReady = null;
		}
		screen.resized.add(onScreenResized);
		onScreenResized(screen);
	}

	static function onScreenResized(screen:ScreenManager):Void {
		render.resize(screen.width, screen.height);
	}

	public static function dispose():Void {
		Debug.assert(loop != null);

		DisposeUtil.dispose(screen);
		DisposeUtil.dispose(input);
		DisposeUtil.dispose(loop);
		DisposeUtil.dispose(render);
		DisposeUtil.dispose(audio);

		screen = null;
		input = null;
		loop = null;
		render = null;
		audio = null;

		_cbOnReady = null;
	}
}
