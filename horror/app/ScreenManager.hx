package horror.app;

import openfl.system.Capabilities;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.Lib;

import horror.utils.DisposeUtil;
import horror.utils.IDisposable;
import horror.signals.Signal1;

class ScreenManager implements IDisposable {

	// Viewport
	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var width(default, null):Int = 1;
	public var height(default, null):Int = 1;

	public var dpi(default, null):Int = 0;
	public var resolutionX(default, null):Int = 0;
	public var resolutionY(default, null):Int = 0;

	public var resized(default, null):Signal1<ScreenManager> = new Signal1<ScreenManager>("Resize Event");

	var _stage:Stage;

	public function new() {
		_stage = Lib.current.stage;
		_stage.addEventListener(Event.RESIZE, onStageResized);
		onStageResized(null);

		resolutionX = Std.int(Capabilities.screenResolutionX);
		resolutionY = Std.int(Capabilities.screenResolutionY);
		dpi = Std.int(Capabilities.screenDPI);
	}

	public function dispose():Void {
		if(_stage != null) {
			_stage.removeEventListener(Event.RESIZE, onStageResized);
			_stage = null;
		}
		DisposeUtil.dispose(resized);
		resized = null;
	}

	function onStageResized(e:Event):Void {
		if (_stage.stageWidth != width || _stage.stageHeight != height) {
			width = _stage.stageWidth;
			height = _stage.stageHeight;
			resized.dispatch(this);
		}
	}
}