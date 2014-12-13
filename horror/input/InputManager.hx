package horror.input;

import horror.utils.DisposeUtil;
import horror.signals.Signal1;

import openfl.Lib;
import openfl.display.Stage;
import openfl.events.MouseEvent in FlashMouseEvent;
import openfl.events.KeyboardEvent in FlashKeyboardEvent;
import openfl.events.TouchEvent in FlashTouchEvent;

class InputManager {

	public var onMouse(default, null):Signal1<MouseEvent> = new Signal1<MouseEvent>("Mouse Event");
	public var onKeyboard(default, null):Signal1<KeyboardEvent> = new Signal1<KeyboardEvent>("Keyboard Event");

	var _stage:Stage;
	var _mouseEvent:MouseEvent = new MouseEvent();
	var _keyboardEvent:KeyboardEvent = new KeyboardEvent();

	//var _lastKeys:Map<Int, Bool> = new Map<Int, Bool>();
	var _currentKeys:Map<Int, Bool> = new Map<Int, Bool>();

	public function new() {
		_stage = Lib.current.stage;

		_stage.addEventListener(FlashMouseEvent.MOUSE_DOWN, handleMouseEvent);
		_stage.addEventListener(FlashMouseEvent.MOUSE_UP, handleMouseEvent);
		_stage.addEventListener(FlashMouseEvent.MOUSE_MOVE, handleMouseEvent);

		_stage.addEventListener(FlashKeyboardEvent.KEY_DOWN, handleKeyboardEvent);
		_stage.addEventListener(FlashKeyboardEvent.KEY_UP, handleKeyboardEvent);

		_mouseEvent.manager = this;
		_keyboardEvent.manager = this;
	}

	public function dispose():Void {
		if(_stage != null) {
			_stage.removeEventListener(FlashMouseEvent.MOUSE_DOWN, handleMouseEvent);
			_stage.removeEventListener(FlashMouseEvent.MOUSE_UP, handleMouseEvent);
			_stage.removeEventListener(FlashMouseEvent.MOUSE_MOVE, handleMouseEvent);

			_stage.removeEventListener(FlashKeyboardEvent.KEY_DOWN, handleKeyboardEvent);
			_stage.removeEventListener(FlashKeyboardEvent.KEY_UP, handleKeyboardEvent);

			_mouseEvent.manager = null;
			_mouseEvent = null;

			_keyboardEvent.manager = null;
			_keyboardEvent = null;
		}

		DisposeUtil.dispose(onMouse);
		DisposeUtil.dispose(onKeyboard);
	}

	function handleMouseEvent(e:FlashMouseEvent):Void {
		var me = _mouseEvent;
		me.x = Std.int(e.stageX);
		me.y = Std.int(e.stageY);
		switch(e.type) {
			case FlashMouseEvent.MOUSE_MOVE:
				me.type = MouseEventType.MOVE;
				me.button = MouseEventButton.NONE;
			case FlashMouseEvent.MOUSE_DOWN:
				me.type = MouseEventType.DOWN;
				me.button = MouseEventButton.LEFT;
			case FlashMouseEvent.MOUSE_UP:
				me.type = MouseEventType.UP;
				me.button = MouseEventButton.LEFT;
			case FlashMouseEvent.MIDDLE_MOUSE_DOWN:
				me.type = MouseEventType.DOWN;
				me.button = MouseEventButton.MIDDLE;
			case FlashMouseEvent.MIDDLE_MOUSE_UP:
				me.type = MouseEventType.UP;
				me.button = MouseEventButton.MIDDLE;
			case FlashMouseEvent.RIGHT_MOUSE_DOWN:
				me.type = MouseEventType.DOWN;
				me.button = MouseEventButton.RIGHT;
			case FlashMouseEvent.RIGHT_MOUSE_UP:
				me.type = MouseEventType.UP;
				me.button = MouseEventButton.RIGHT;
			default:
				return;
		}
		onMouse.dispatch(me);
	}

	function handleKeyboardEvent(e:FlashKeyboardEvent):Void {
		var code = e.keyCode;
		var lastState = _currentKeys.exists(code) && _currentKeys[code];
		var ke = _keyboardEvent;
		ke.keyCode = code;

		switch(e.type) {
			case FlashKeyboardEvent.KEY_DOWN:
				ke.type = KeyboardEventType.DOWN;
				ke.repeated = lastState;
				_currentKeys[code] = true;

			case FlashKeyboardEvent.KEY_UP:
				ke.type = KeyboardEventType.UP;
				ke.repeated = !lastState;
				_currentKeys[code] = false;
			default:
				return;
		}

		// TOOD:
		ke.keyModifiers = 0;
		if(!ke.repeated) {
			onKeyboard.dispatch(ke);
		}
	}
}