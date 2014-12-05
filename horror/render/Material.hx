package horror.render;

class Material {

	public var texture:Texture;
	public var shader:Shader;

	// premultiply alpha blend by default
	public var sourceBlendFactor:BlendFactor = BlendFactor.ONE;
	public var destinationBlendFactor:BlendFactor = BlendFactor.ONE_MINUS_SOURCE_ALPHA;

	public function new(shader:Shader = null) {
		this.shader = shader;
	}
}
