package horror.render;

import horror.utils.IDisposable;
import horror.render.RenderManager;

class Shader implements IDisposable {

	public var name(default, null):String;

	// premultiply alpha blend by default
	public var sourceBlendFactor:BlendFactor = BlendFactor.ONE;
	public var destinationBlendFactor:BlendFactor = BlendFactor.ONE_MINUS_SOURCE_ALPHA;

	@:allow(horror.render.RenderManager)
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
}
