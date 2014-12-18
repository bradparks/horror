package horror.app;

import horror.std.Horror;
import horror.app.Engine;

class Application {
	public var engine(default, null):Engine;

	public function new() {
		engine = new Engine();
		engine.initialize(initialize);
	}

	public function initialize():Void { }

	public function start():Void {
		engine.onUpdate.add(update);
		engine.onRender.add(render);
	}

	public function update(dt:Float):Void { }
	public function render() { }

	public function dispose():Void {
		Horror.dispose(engine);
	}
}
