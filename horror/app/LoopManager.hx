package horror.app;

import haxe.Timer;

import horror.std.Module;
import horror.std.Horror;
import horror.std.Signal1;

import openfl.Lib;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.display.OpenGLView;

class LoopManager extends Module {

	public var timeStamp(default, null):Float = 0.0;
	public var deltaTime(default, null):Float = 0.001;
	public var targetFrameRate(get, set):Int;

	public var updated(default, null):Signal1<LoopManager> = new Signal1<LoopManager>("Update Event");

	// INTERNAL
	var _stage:Stage;

	public function new():Void {
		super();

		_stage = Lib.current.stage;

		initLoop();
		timeStamp = getTimeStamp();
	}

	public override function dispose():Void {
		super.dispose();

		if(_stage != null) {
			termLoop();
			_stage = null;
		}

		Horror.dispose(updated);
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

	function get_targetFrameRate():Int {
		return Std.int(_stage.frameRate);
	}

	function set_targetFrameRate(value:Int):Int {
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


}
