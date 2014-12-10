package horror.app;

import haxe.Timer;

import horror.utils.DisposeUtil;
import horror.utils.IDisposable;
import horror.signals.Signal1;

import openfl.Lib;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.OpenGLView;

class LoopManager implements IDisposable {

	public var timeStamp(default, null):Float = 0.0;
	public var deltaTime(default, null):Float = 0.001;
	public var frameRate(get, set):Int;

	public var updated(default, null):Signal1<LoopManager> = new Signal1<LoopManager>("Update Event");

	// INTERNAL
	var _stage:Stage;

	public function new():Void {
		_stage = Lib.current.stage;
		_stage.scaleMode = StageScaleMode.NO_SCALE;
		_stage.align = StageAlign.TOP_LEFT;
		_stage.addEventListener(openfl.display.OpenGLView.CONTEXT_LOST, onContextLost);
		_stage.addEventListener(openfl.display.OpenGLView.CONTEXT_RESTORED, onContextRestored);

		initLoop();
		timeStamp = getTimeStamp();
	}

	function onContextLost(_) {
		trace("lost");
	}

	function onContextRestored(_) {
		trace("restored");
	}

	public function dispose():Void {
		if(_stage != null) {
			termLoop();
			_stage = null;
		}
		DisposeUtil.dispose(updated);
		updated = null;
	}

	inline function getTimeStamp():Float {
		return Timer.stamp();
	}

	function __update(args):Void {
		var now:Float = getTimeStamp();
		deltaTime = now - timeStamp;
		timeStamp = now;

		updated.dispatch(this);
	}

	function get_frameRate():Int {
		return Std.int(_stage.frameRate);
	}

	function set_frameRate(value:Int):Int {
		_stage.frameRate = value;
		return Std.int(_stage.frameRate);
	}

	#if flash

	function initLoop():Void {
		_stage.addEventListener(Event.ENTER_FRAME, __update);
	}

	function termLoop():Void {
		_stage.removeEventListener(Event.ENTER_FRAME, __update);
	}

	#else

	var _openGLView:OpenGLView;

	function initLoop():Void {
		if(OpenGLView.isSupported) {
			_openGLView = new OpenGLView();
			_openGLView.render = __update;
			_stage.addChild(_openGLView);
		}
		else {
			trace("WebGL is not supported or use -dom flag in gl project file");
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


}
