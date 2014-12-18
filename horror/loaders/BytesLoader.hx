package horror.loaders;

import haxe.io.Bytes;

#if (openfl || flash)

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLLoaderDataFormat;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;

class BytesLoader extends BaseLoader
{
    var _loader:URLLoader;

	public var bytes(default, null):Bytes;

    public function new(url:String = null) {
        super(url);
    }

	public override function dispose() {
		cleanup();
		super.dispose();
	}

    override function performLoad():Void {
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.BINARY;
		_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
		_loader.addEventListener(Event.COMPLETE, onComplete);
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		_loader.load(new URLRequest(url));
		trace("loader started");
    }

    override public function performCancel():Void {
		_loader.close();
		cleanup();
		performComplete();
    }

    function onProgress(e:ProgressEvent):Void {
        if (e.bytesTotal > 0) {
            setProgress(e.bytesLoaded / e.bytesTotal);
        }
    }

    function onComplete(_):Void {

		var byteArray = cast (_loader.data, ByteArray);

		#if js

			bytes = Bytes.ofData(byteArray.byteView);

		#elseif flash

			bytes = Bytes.ofData(byteArray);

		#else

			bytes = byteArray;

		#end

		content = bytes;

		cleanup();
        performComplete();
    }

	function cleanup():Void {
		if(_loader != null) {
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.removeEventListener(Event.COMPLETE, onComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_loader = null;
		}
	}

    function onError(e:Event):Void {
		cleanup();
		performFail(e.toString());
    }
}

#elseif lime

import lime.net.URLLoader;
import lime.net.URLRequest;
import lime.net.URLLoaderDataFormat;
import lime.utils.ByteArray;

class BytesLoader extends BaseLoader
{
	var _loader:URLLoader;

	public var bytes(default, null):Bytes;

	public function new(url:String = null) {
		super(url);
	}

	public override function dispose() {
		cleanup();
		super.dispose();
	}

	override function performLoad():Void {
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.BINARY;
		_loader.onProgress.add(onProgress);
		_loader.onComplete.add(onComplete);
		_loader.onIOError.add(onError);
		_loader.onSecurityError.add(onError);
		_loader.load(new URLRequest(url));
	}

	override public function performCancel():Void {
		_loader.close();
		cleanup();
		performComplete();
	}

	function onProgress(loader:URLLoader, loaded:Int, total:Int):Void {
		trace("onProgress");
		if (total > 0) {
			setProgress(loaded / total);
		}
	}

	function onComplete(_):Void {
		trace("complete");
		var byteArray = cast (_loader.data, ByteArray);

		#if js
		bytes = Bytes.ofData(byteArray.byteView);
		#elseif flash
		bytes = Bytes.ofData(byteArray);
		#else
		bytes = byteArray;
		#end

		content = bytes;

		cleanup();
		performComplete();
	}

	function cleanup():Void {
		if(_loader != null) {
			_loader.onProgress.remove(onProgress);
			_loader.onComplete.remove(onComplete);
			_loader.onIOError.remove(onError);
			_loader.onSecurityError.remove(onError);
			_loader = null;
		}
	}

	function onError(loader:URLLoader, err:String):Void {
		cleanup();
		performFail(err);
	}
}

#elseif snow


import snow.assets.AssetBytes;
import horror.app.snow.SnowAppDelegate;

class BytesLoader extends BaseLoader
{
	public var bytes(default, null):Bytes;

	public function new(url:String = null) {
		super(url);
	}

	public override function dispose() {
		super.dispose();
	}

	override function performLoad():Void {
		untyped SnowAppDelegate.__instance.app.assets.bytes(url, {async:true, onload: onComplete});
	}

	override public function performCancel():Void {
		performComplete();
	}

	function onComplete(ba:AssetBytes):Void {
		#if js
		bytes = Bytes.ofData(ba.bytes.byteView);
		#else
		bytes = ba.bytes;
		#end

		content = bytes;

		performComplete();
	}

}


#end