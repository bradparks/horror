package horror.render;

import horror.utils.IDisposable;
import horror.render.RenderManager;

class Shader implements IDisposable {

	public var name(default, null):String;
	public var vertexStructure(default, null):VertexStructure;

	@:allow(horror.render.RenderManager)
	var _rawData:RawShader;

	public function new(name:String, vertexStructure:VertexStructure) {
		this.name = name;
		this.vertexStructure = vertexStructure;
	}

	public function loadFromCode(vertexShaderCode:String, fragmentShaderCode:String) {
		_rawData = RenderManager.driver.createShader(vertexStructure, vertexShaderCode, fragmentShaderCode);
	}

	public function dispose() {
		if(_rawData != null) {
			RenderManager.driver.disposeShader(_rawData);
			_rawData = null;
		}
	}
}
