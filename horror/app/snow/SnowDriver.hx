package horror.app.snow;

import snow.App;
import snow.window.Window;

import haxe.Timer;

import horror.input.KeyboardEventType;
import horror.input.MouseEventButton;
import horror.input.MouseEventType;

class SnowDriver {

	public var resized:Void->Void;
	public var updated:Void->Void;
	public var render:Void->Void;
	public var mouse:Int->Int->MouseEventType->MouseEventButton->Void;
	public var keys:UInt->KeyboardEventType->Void;

	var _app:App;
	var _window:Window;

	public function new() {
		_app = untyped SnowAppDelegate.__instance;
		_window = _app.app.window;
		init();
	}

	inline public function getScreenDPI():Int {
		// TODO:
		return 0;
	}

	inline public function getTimeStamp():Float {
		return Timer.stamp();
	}

	inline public function getWidth():Int {
		return _window.width;
	}

	inline public function getHeight():Int {
		return _window.height;
	}

	inline public function setFrameRate(v:Int):Void {
		_app.render_rate = 1.0 / v;
	}

	inline public function getFrameRate():Int {
		return _app.render_rate > 0 ? Std.int(1.0 / _app.render_rate) : 0;
	}

	public function dispose():Void {
		term();
		_app = null;
		_window = null;
	}

	function init():Void {
		SnowAppDelegate.__resize = onWindowResize;
		SnowAppDelegate.__update = onUpdate;
		SnowAppDelegate.__render = onRender;
		SnowAppDelegate.__keyDown = onKeyDown;
		SnowAppDelegate.__keyUp = onKeyUp;
		SnowAppDelegate.__mouseDown = onMouseDown;
		SnowAppDelegate.__mouseUp = onMouseUp;
		SnowAppDelegate.__mouseMove = onMouseMove;
	}

	function term():Void {
		SnowAppDelegate.__resize = null;
		SnowAppDelegate.__update = null;
		SnowAppDelegate.__render = null;
		SnowAppDelegate.__keyDown = null;
		SnowAppDelegate.__keyUp = null;
		SnowAppDelegate.__mouseDown = null;
		SnowAppDelegate.__mouseUp = null;
		SnowAppDelegate.__mouseMove = null;
	}

	function onUpdate():Void {
		updated();
	}

	function onWindowResize() {
		resized();
	}

	public function onRender ():Void {
		render();
	}


	public function onKeyDown (keyCode:Int):Void {
		keys(keyCode, KeyboardEventType.DOWN);
	}

	public function onKeyUp (keyCode:Int):Void {
		keys(keyCode, KeyboardEventType.UP);
	}

	public function onMouseDown (x:Int, y:Int, button:Int):Void {
		mouse(x, y, MouseEventType.DOWN, button);
	}

	public function onMouseMove (x:Int, y:Int, button:Int):Void {
		mouse(x, y, MouseEventType.MOVE, 0);
	}

	public function onMouseUp (x:Int, y:Int, button:Int):Void {
		mouse(x, y, MouseEventType.UP, button);
	}

	public function onMouseWheel (deltaX:Float, deltaY:Float):Void {
		//mouse(x, y, MouseEventType.DOWN, button);
	}

	public function onTouchEnd (x:Float, y:Float, id:Int):Void { }
	public function onTouchMove (x:Float, y:Float, id:Int):Void { }
	public function onTouchStart (x:Float, y:Float, id:Int):Void { }
}