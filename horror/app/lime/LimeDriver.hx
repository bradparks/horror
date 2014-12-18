package horror.app.lime;

import lime.graphics.Renderer;
import haxe.Timer;

import lime.ui.Window;
import lime.ui.TouchEventManager;
import lime.ui.MouseEventManager;
import lime.ui.KeyEventManager;
import lime.app.Application;

import horror.input.KeyboardEventType;
import horror.input.MouseEventButton;
import horror.input.MouseEventType;

class LimeDriver {

	public var resized:Void->Void;
	public var updated:Void->Void;
	public var render:Void->Void;
	public var mouse:Int->Int->MouseEventType->MouseEventButton->Void;
	public var keys:UInt->KeyboardEventType->Void;

	var _app:Application;

	public function new() {
		_app = untyped Application.__instance;
		initScreen();
		initInput();
		initLoop();
	}

	inline public function getScreenDPI():Int {
// TODO:
		return 0;
	}

	inline public function getTimeStamp():Float {
		return Timer.stamp();
	}

	inline public function getWidth():Int {
		return _app.window.width;
	}

	inline public function getHeight():Int {
		return _app.window.height;
	}

	inline public function setFrameRate(v:Int):Void {
// TODO:
	}

	inline public function getFrameRate():Int {
// TODO:
		return 60;
	}

	public function dispose():Void {
		termLoop();
		termInput();
		termScreen();
		_app = null;
	}

	function initLoop():Void {
		Application.onUpdate.add(onUpdate);
		Renderer.onRender.add(onRender);
	}

	function termLoop():Void {
		Application.onUpdate.remove(onUpdate);
		Renderer.onRender.remove(onRender);
	}

	function initInput():Void {
		KeyEventManager.onKeyDown.add(onKeyDown);
		KeyEventManager.onKeyUp.add(onKeyUp);

		MouseEventManager.onMouseDown.add(onMouseDown);
		MouseEventManager.onMouseMove.add(onMouseMove);
		MouseEventManager.onMouseUp.add(onMouseUp);
		MouseEventManager.onMouseWheel.add(onMouseWheel);

		TouchEventManager.onTouchStart.add(onTouchStart);
		TouchEventManager.onTouchMove.add(onTouchMove);
		TouchEventManager.onTouchEnd.add(onTouchEnd);
	}

	function termInput():Void {
		KeyEventManager.onKeyDown.remove(onKeyDown);
		KeyEventManager.onKeyUp.remove(onKeyUp);

		MouseEventManager.onMouseDown.remove(onMouseDown);
		MouseEventManager.onMouseMove.remove(onMouseMove);
		MouseEventManager.onMouseUp.remove(onMouseUp);
		MouseEventManager.onMouseWheel.remove(onMouseWheel);

		TouchEventManager.onTouchStart.remove(onTouchStart);
		TouchEventManager.onTouchMove.remove(onTouchMove);
		TouchEventManager.onTouchEnd.remove(onTouchEnd);
	}

	function initScreen():Void {
		Window.onWindowResize.add (onWindowResize);
	}

	function termScreen():Void {
		Window.onWindowResize.remove (onWindowResize);
	}

	function onUpdate(args):Void {
		updated();
	}

	function onRender(context):Void {
		render();
	}

	function onWindowResize(width:Int, height:Int) {
		resized();
	}

	public function onKeyDown (keyCode:Int, modifier:Int):Void {
		keys(keyCode, KeyboardEventType.DOWN);
	}

	public function onKeyUp (keyCode:Int, modifier:Int):Void {
		keys(keyCode, KeyboardEventType.UP);
	}

	public function onMouseDown (x:Float, y:Float, button:Int):Void {
		mouse(Std.int(x), Std.int(y), MouseEventType.DOWN, button);
	}

	public function onMouseMove (x:Float, y:Float, button:Int):Void {
		mouse(Std.int(x), Std.int(y), MouseEventType.MOVE, 0);
	}

	public function onMouseUp (x:Float, y:Float, button:Int):Void {
		mouse(Std.int(x), Std.int(y), MouseEventType.UP, button);
	}

	public function onMouseWheel (deltaX:Float, deltaY:Float):Void {
//mouse(x, y, MouseEventType.DOWN, button);
	}

	public function onTouchEnd (x:Float, y:Float, id:Int):Void { }
	public function onTouchMove (x:Float, y:Float, id:Int):Void { }
	public function onTouchStart (x:Float, y:Float, id:Int):Void { }
}