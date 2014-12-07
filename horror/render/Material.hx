package horror.render;

class Material {

	public var texture:Texture;
	public var shader:Shader;

	public function new(shader:Shader = null) {
		this.shader = shader;
	}
}
