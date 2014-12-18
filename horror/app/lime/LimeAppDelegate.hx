package horror.app.lime;

import lime.app.Application;
import lime.graphics.RenderContext;

class LimeAppDelegate extends Application {

	public function new() {
		super();
	}

	public override function init (context:RenderContext):Void {
		super.init(context);
		__startHorrorApp();
	}

	function __startHorrorApp():Void { }

}
