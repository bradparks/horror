package horror.render.gl;

#if hrr_openfl

import openfl.gl.GL;
import openfl.gl.GLBuffer;

#elseif hrr_lime

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;

#elseif hrr_snow

import snow.render.opengl.GL;
import snow.render.opengl.GL.GLBuffer;

#end

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