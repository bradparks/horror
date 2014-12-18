package ;

import horror.std.Horror;
import horror.app.Engine;

class BasicApp {

	public var engine(default, null):Engine;

	public function new():Void {

		engine = new Engine();
		engine.initialize(initialize);

	}

	public function initialize():Void { }

	public function start():Void {
		engine.updated.add(update);
	}

	public function update(dt:Float):Void { }

	public function dispose():Void {
		Horror.dispose(engine);
	}
}
