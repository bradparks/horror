package horror.input;

@:allow(horror.input.InputManager)
class KeyboardEvent {

	public var manager(default, null):InputManager;

	public var type(default, null):KeyboardEventType = KeyboardEventType.NONE;

	public var keyCode(default, null):UInt = 0;
	public var keyModifiers(default, null):Int = 0;
	public var repeated:Bool = false;

	public function new() {
	}
}
