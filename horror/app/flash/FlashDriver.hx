package horror.app.flash;

#if (flash || openfl)

import haxe.Timer;

import flash.Lib;

import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;

import flash.events.Event;
import flash.events.MouseEvent in FlashMouseEvent;
import flash.events.KeyboardEvent in FlashKeyboardEvent;
import flash.events.TouchEvent in FlashTouchEvent;

import flash.system.Capabilities;

#if openfl
import openfl.display.OpenGLView;
#end

import horror.std.Horror;

import horror.input.KeyboardEventType;
import horror.input.MouseEventButton;
import horror.input.MouseEventType;

class FlashDriver {

	public var resized:Void->Void;
	public var updated:Void->Void;
	public var mouse:Int->Int->MouseEventType->MouseEventButton->Void;
	public var keys:UInt->KeyboardEventType->Void;

	var _stage:Stage;

	public function new() {
		_stage = Lib.current.stage;
		initScreen();
		initInput();
		initLoop();
	}

	inline public function getScreenDPI():Int {
		return Std.int(Capabilities.screenDPI);
	}

	inline public function getTimeStamp():Float {
		return Timer.stamp();
	}

	inline public function getWidth():Int {
		return _stage.stageWidth;
	}

	inline public function getHeight():Int {
		return _stage.stageHeight;
	}

	inline public function setFrameRate(v:Int):Void {
		_stage.frameRate = v;
	}

	inline public function getFrameRate():Int {
		return Std.int(_stage.frameRate);
	}

	public function dispose():Void {
		termLoop();
		termInput();
		termScreen();
		_stage = null;
	}

	#if flash

	function initLoop():Void {
		_stage.addEventListener(Event.ENTER_FRAME, onUpdate);
	}

	function termLoop():Void {
		_stage.removeEventListener(Event.ENTER_FRAME, onUpdate);
	}

	#elseif openfl

	var _openGLView:OpenGLView;

	function initLoop():Void {
		if(OpenGLView.isSupported) {
			_openGLView = new OpenGLView();
			_openGLView.render = onUpdate;
			_stage.addChild(_openGLView);
		}
		else {
			#if html5
			Horror.warning("WebGL is not supported or use -dom flag in gl project file");
			#end
		}
	}

	function termLoop():Void {
		if(_openGLView != null) {
			_openGLView.render = null;
			_stage.removeChild(_openGLView);
			_openGLView = null;
		}
	}

	#end

	function initInput():Void {
		_stage.addEventListener(FlashMouseEvent.MOUSE_DOWN, onMouseEvent);
		_stage.addEventListener(FlashMouseEvent.MOUSE_UP, onMouseEvent);
		_stage.addEventListener(FlashMouseEvent.MOUSE_MOVE, onMouseEvent);

		_stage.addEventListener(FlashKeyboardEvent.KEY_DOWN, onKeyboardEvent);
		_stage.addEventListener(FlashKeyboardEvent.KEY_UP, onKeyboardEvent);
	}

	function termInput():Void {
		_stage.removeEventListener(FlashMouseEvent.MOUSE_DOWN, onMouseEvent);
		_stage.removeEventListener(FlashMouseEvent.MOUSE_UP, onMouseEvent);
		_stage.removeEventListener(FlashMouseEvent.MOUSE_MOVE, onMouseEvent);

		_stage.removeEventListener(FlashKeyboardEvent.KEY_DOWN, onKeyboardEvent);
		_stage.removeEventListener(FlashKeyboardEvent.KEY_UP, onKeyboardEvent);
	}

	function initScreen():Void {
		_stage.scaleMode = StageScaleMode.NO_SCALE;
		_stage.align = StageAlign.TOP_LEFT;
		_stage.addEventListener(Event.RESIZE, onStageResized);
	}

	function termScreen():Void {
		_stage.removeEventListener(Event.RESIZE, onStageResized);
	}

	function onUpdate(args):Void {
		updated();
	}

	function onStageResized(_) {
		resized();
	}

	function onMouseEvent(e:FlashMouseEvent):Void {
		var x = Std.int(e.stageX);
		var y = Std.int(e.stageY);
		var type:MouseEventType;
		var button:MouseEventButton;
		switch(e.type) {
			case FlashMouseEvent.MOUSE_MOVE:
				type = MouseEventType.MOVE;
				button = MouseEventButton.NONE;
			case FlashMouseEvent.MOUSE_DOWN:
				type = MouseEventType.DOWN;
				button = MouseEventButton.LEFT;
			case FlashMouseEvent.MOUSE_UP:
				type = MouseEventType.UP;
				button = MouseEventButton.LEFT;
			case FlashMouseEvent.MIDDLE_MOUSE_DOWN:
				type = MouseEventType.DOWN;
				button = MouseEventButton.MIDDLE;
			case FlashMouseEvent.MIDDLE_MOUSE_UP:
				type = MouseEventType.UP;
				button = MouseEventButton.MIDDLE;
			case FlashMouseEvent.RIGHT_MOUSE_DOWN:
				type = MouseEventType.DOWN;
				button = MouseEventButton.RIGHT;
			case FlashMouseEvent.RIGHT_MOUSE_UP:
				type = MouseEventType.UP;
				button = MouseEventButton.RIGHT;
			default:
				return;
		}
		mouse(x, y, type, button);
	}

	function onKeyboardEvent(e:FlashKeyboardEvent):Void {
		var code = e.keyCode;
		var type:KeyboardEventType;
		switch(e.type) {
			case FlashKeyboardEvent.KEY_DOWN:
				type = KeyboardEventType.DOWN;
			case FlashKeyboardEvent.KEY_UP:
				type = KeyboardEventType.UP;
			default:
				return;
		}

		keys(code, type);
	}

}

#end