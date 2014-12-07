package horror.loaders;

import openfl.Assets;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;

import horror.memory.ByteArray;

class BytesLoader extends BaseLoader
{
    var _loader:URLLoader;

    public function new(url:String = null) {
        super(url);
    }

	public override function dispose() {
		cleanup();
		super.dispose();
	}

    override function performLoad():Void {

		/*if(url.indexOf(".png") < 0 && Assets.exists(url, AssetType.BINARY)) {
			trace('$url LOADING with Assets');
			Assets.loadBytes(url, onAssetsLoaded);
		}
		else {*/
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.load(new URLRequest(url));
		//}
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
        var data = cast (_loader.data, ByteArrayData);
        content = new ByteArray(data);
		cleanup();
        performComplete();
    }

	function onAssetsLoaded(data:ByteArrayData):Void {
		content = new ByteArray(data);
		cleanup();
		performComplete();
	}

	function cleanup():Void {
		if(_loader != null) {
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.removeEventListener(Event.COMPLETE, onComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader = null;
		}
	}

    function onError(e:IOErrorEvent):Void {
		cleanup();
		performFail(e.toString());
    }
}