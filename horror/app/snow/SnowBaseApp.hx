package horror.app.snow;

import snow.App;
import snow.types.Types;

@:allow(horror.app.snow.SnowDriver)
class SnowBaseApp extends App {

	static var __instance:SnowBaseApp;

	static var __keyDown:Int->Void;
	static var __keyUp:Int->Void;

	static var __mouseDown:Int->Int->Int->Void;
	static var __mouseUp:Int->Int->Int->Void;
	static var __mouseMove:Int->Int->Int->Void;

	static var __render:Void->Void;
	static var __update:Void->Void;
	static var __resize:Void->Void;

	public function new() {
		super();
		__instance = this;
	}

	override function ready() {
		super.ready();

		app.window.onevent = handleWindowEvent;
		app.window.onrender = __onRender;
	}

	override function update( delta:Float ) {
		if(__update == null) return;
		__update();
		app.window.onrender = __onRender;
	}

	function __onRender( window:snow.window.Window ) {
		if(__render == null) return;
		__render();
	}

	override public function onkeydown( keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int ) {
		if(__keyDown == null) return;
		__keyDown(keycode);
	}

	override public function onkeyup( keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int ) {
		if(__keyUp == null) return;
		__keyUp(keycode);
	}

	override public function ontextinput( text:String, start:Int, length:Int, type:TextEventType, timestamp:Float, window_id:Int ) {

	}

	override public function onmousedown( x:Int, y:Int, button:Int, timestamp:Float, window_id:Int ) {
		if(__mouseDown == null) return;
		__mouseDown(x, y, button);
	}

	override public function onmouseup( x:Int, y:Int, button:Int, timestamp:Float, window_id:Int ) {
		if(__mouseUp == null) return;
		__mouseUp(x, y, button);
	}

	override public function onmousewheel( x:Int, y:Int, timestamp:Float, window_id:Int ) {}

	override public function onmousemove( x:Int, y:Int, xrel:Int, yrel:Int, timestamp:Float, window_id:Int ) {
		if(__mouseMove == null) return;
		__mouseMove(x, y, 0);
	}

	function handleWindowEvent(e:WindowEvent):Void {
		if(e.type == WindowEventType.resized) {
			if(__resize != null) {
				__resize();
			}
		}
	}
}
