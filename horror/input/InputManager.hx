package horror.input;

import horror.std.Module;
import horror.std.Horror;
import horror.std.Signal1;

class InputManager extends Module {

	public var onMouse(default, null):Signal1<MouseEvent> = new Signal1<MouseEvent>("Mouse Event");
	public var onKeyboard(default, null):Signal1<KeyboardEvent> = new Signal1<KeyboardEvent>("Keyboard Event");

	var _mouseEvent:MouseEvent = new MouseEvent();
	var _keyboardEvent:KeyboardEvent = new KeyboardEvent();

	//var _lastKeys:Map<Int, Bool> = new Map<Int, Bool>();
	var _currentKeys:Map<Int, Bool> = new Map<Int, Bool>();

	public function new() {
		super();
	}

	public override function dispose():Void {
		super.dispose();

		Horror.dispose(onMouse);
		Horror.dispose(onKeyboard);
	}

	public function update():Void {

	}

	public function handleMouseEvent(x:Int, y:Int, type:MouseEventType, button:MouseEventButton):Void {
		var me = _mouseEvent;
		me.x = x;
		me.y = y;
		me.type = type;
		me.button = button;
		onMouse.dispatch(me);
	}

	public function handleKeyboardEvent(code:UInt, type:KeyboardEventType):Void {
		var lastState = _currentKeys.exists(code) && _currentKeys[code];

		var ke = _keyboardEvent;
		ke.keyCode = code;
		ke.type = type;

		switch(type) {
			case KeyboardEventType.DOWN:

				ke.repeated = lastState;
				_currentKeys[code] = true;

			case KeyboardEventType.UP:

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