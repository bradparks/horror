package horror.input;

@:allow(horror.input.InputManager)
class MouseEvent {

	public var manager(default, null):InputManager;

	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;

	public var type(default, null):MouseEventType = MouseEventType.MOVE;
	public var button(default, null):MouseEventButton = MouseEventButton.LEFT;

	public function new() {
	}
}
