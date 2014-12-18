package horror.render.snow;

import snow.render.opengl.GL;
import snow.render.opengl.GL.GLBuffer;

class GLMeshData {

	public var vertexStructure:VertexStructure;
	public var vertexBuffer:GLBuffer;
	public var indexBuffer:GLBuffer;
	public var vertexBufferLength:Int = 0;
	public var indexBufferLength:Int = 0;

	public function new(vertexStructure:VertexStructure) {
		this.vertexStructure = vertexStructure;
		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
	}

	public function dispose() {
		GL.deleteBuffer(indexBuffer);
		GL.deleteBuffer(vertexBuffer);
	}
}
