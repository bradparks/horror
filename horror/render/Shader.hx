package horror.render;

import horror.render.RenderContext;

@:allow(horror.render.RenderContext)
class Shader {

	public var name(default, null):String;

	public var sourceBlendFactor:BlendFactor = BlendFactor.SOURCE_ALPHA;
	public var destinationBlendFactor:BlendFactor = BlendFactor.ONE_MINUS_SOURCE_ALPHA;

	var __data:ShaderData;

	public function new(name:String) {
		this.name = name;
	}

	public function loadFromCode(vertexShaderCode:String, fragmentShaderCode:String) {
		__data = RenderContext.__driver.createShader(vertexShaderCode, fragmentShaderCode);
	}

	public function dispose() {
		if(__data != null) {
			RenderContext.__driver.disposeShader(__data);
			__data = null;
		}
	}

	function getBlendModeHash():Int {
		return (sourceBlendFactor << 16) | destinationBlendFactor;
	}
}
