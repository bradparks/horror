package horror.render;

import horror.utils.IDisposable;
import horror.render.RenderManager;

@:allow(horror.render.RenderManager)
class Shader implements IDisposable {

	public var name(default, null):String;

	public var sourceBlendFactor:BlendFactor = BlendFactor.SOURCE_ALPHA;
	public var destinationBlendFactor:BlendFactor = BlendFactor.ONE_MINUS_SOURCE_ALPHA;

	var _rawData:RawShader;

	public function new(name:String) {
		this.name = name;
	}

	public function loadFromCode(vertexShaderCode:String, fragmentShaderCode:String) {
		_rawData = RenderManager.driver.createShader(vertexShaderCode, fragmentShaderCode);
	}

	public function dispose() {
		if(_rawData != null) {
			RenderManager.driver.disposeShader(_rawData);
			_rawData = null;
		}
	}

	function getBlendModeHash():Int {
		return (sourceBlendFactor << 16) | destinationBlendFactor;
	}
}
