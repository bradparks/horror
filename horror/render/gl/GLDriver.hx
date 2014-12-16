package horror.render.gl;

import haxe.io.BytesData;
import haxe.io.Bytes;

import openfl.Lib;
import openfl.gl.GL;
import openfl.gl.GLShader;
import openfl.display.OpenGLView;

import horror.render.VertexStructure;
import horror.memory.ByteArray;

/*** CONTEXT ***/
class GLDriver {

	inline static var MESH_UPLOAD_TECHNIQUE:Int = GL.DYNAMIC_DRAW;

	public var isLost(default, null) = false;
	public var onRestore:Void->Void;
	public var onInitialize:Void->Void;

	var _stage:openfl.display.Stage;
	var _currentShader:GLShaderData;

	public function new() {}

	public function initialize():Void {
		_stage = Lib.current.stage;
		_stage.addEventListener(OpenGLView.CONTEXT_LOST, __onContextLost);
		_stage.addEventListener(OpenGLView.CONTEXT_RESTORED, __onContextRestored);

		GL.cullFace(GL.FRONT_AND_BACK);
		GL.depthMask(false);
		GL.enable (GL.BLEND);
		GL.disable(GL.DEPTH_TEST);
		GL.disable(GL.STENCIL_TEST);
		GL.disable(GL.DITHER);
		//GL.disable(GL.FOG);
		//GL.disable(GL.ALPHA_TEST);
		//GL.pixelZoom(1, 1);
		#if html5
		GL.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 0);
		#end

		if(onInitialize != null) {
			onInitialize();
			onInitialize = null;
		}
	}

	public function dispose():Void {
		_stage.removeEventListener(OpenGLView.CONTEXT_LOST, __onContextLost);
		_stage.removeEventListener(OpenGLView.CONTEXT_RESTORED, __onContextRestored);
		_stage = null;

		onRestore = null;
		onInitialize = null;
		isLost = true;
	}

	public function resize(width:Int, height:Int):Void {
		GL.viewport (0, 0, width, height);
	}

	public function clear(r:Float = 1, g:Float = 1, b:Float = 1):Void {
		GL.clearColor (r, g, b, 1.0);
		GL.clear (GL.COLOR_BUFFER_BIT);
	}

	public function begin():Void {

	}

	public function end():Void {
		setShader(null);
	}

	public function drawIndexedTriangles(triangles:Int):Void {
		GL.drawElements(GL.TRIANGLES, triangles*3, GL.UNSIGNED_SHORT, 0);
	}

	public function setTexture(texture:GLTextureData) {
		GL.activeTexture (GL.TEXTURE0);
		GL.bindTexture (GL.TEXTURE_2D, texture);
		#if desktop
		GL.enable (GL.TEXTURE_2D);
		#end
	}

	/*** TEXTURES ***/

	public function createTextureFromBytes(width:Int, height:Int, bytesData:BytesData):GLTextureData {
		var texture = GL.createTexture ();
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, GLTypes.getMemoryRange(bytesData));
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.bindTexture (GL.TEXTURE_2D, null);
		return texture;
	}

	public function disposeTexture(texture:GLTextureData):Void {
		GL.deleteTexture(texture);
	}

	/*** SHADERS ***/

	public function createShader(vertexShaderCode:String, fragmentShaderCode:String):GLShaderData {
		var shader = new GLShaderData();
		shader.compile(vertexShaderCode, fragmentShaderCode);
		return shader;
	}

	public function setShader(shader:GLShaderData):Void {
		// TODO: optimize enabling/disabling
		if(_currentShader != null) {
			for(i in _currentShader.vertexAttributes) {
				GL.disableVertexAttribArray(i);
			}
		}

		if(shader != null) {
			GL.useProgram (shader.program);
			for(i in shader.vertexAttributes) {
				GL.enableVertexAttribArray(i);
			}
			GL.uniform1i (shader.imageUniform, 0);
		}

		_currentShader = shader;
	}

	public function setBlendMode(src:BlendFactor, dst:BlendFactor):Void {
		GL.blendFunc(GLTypes.getBlendFactor(src), GLTypes.getBlendFactor(dst));
	}

	public function setMatrix(modelViewProjection:Matrix4):Void {
		GL.uniformMatrix4fv (_currentShader.mvpUniform, false, modelViewProjection.rawData);
	}

	public function setMesh(mesh:GLMeshData):Void {
		GL.bindBuffer(GL.ARRAY_BUFFER, mesh.vertexBuffer);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);
		var vertexStructure = mesh.vertexStructure;
		var stride = vertexStructure.stride;
		var vas = _currentShader.vertexAttributes;
		for(i in 0...vertexStructure.size()) {
			var ve:VertexElement = vertexStructure.elements[i];
			if(i < vas.length) {
				switch(ve.data) {
					case VertexData.FloatN(elements):
						GL.vertexAttribPointer (vas[i], elements, GL.FLOAT, false, stride, ve.offset);
					case VertexData.PackedColor:
						GL.vertexAttribPointer (vas[i], 4, GL.UNSIGNED_BYTE, true, stride, ve.offset);
				}
			}
		}
	}

	public function disposeShader(shader:GLShaderData):Void {
		shader.dispose();
	}

	/*** VERTEX / INDEX BUFFERS ***/
	public function createMesh(vertexStructure:VertexStructure):GLMeshData {
		return new GLMeshData(vertexStructure);
	}

	public function uploadVertices(mesh:GLMeshData, bytesData:BytesData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		GL.bindBuffer(GL.ARRAY_BUFFER, mesh.vertexBuffer);
		if(bytesLength > mesh.vertexBufferLength) {
			GL.bufferData(GL.ARRAY_BUFFER, GLTypes.getMemoryRange(bytesData, bytesLength, bytesOffset), MESH_UPLOAD_TECHNIQUE);
			mesh.vertexBufferLength = bytesLength;
		}
		else {
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, GLTypes.getMemoryRange(bytesData, bytesLength, bytesOffset));
		}
	}

	public function uploadIndices(mesh:GLMeshData, bytesData:BytesData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);
		if(bytesLength > mesh.indexBufferLength) {
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, GLTypes.getMemoryRange(bytesData, bytesLength, bytesOffset), MESH_UPLOAD_TECHNIQUE);
			mesh.indexBufferLength = bytesLength;
		}
		else {
			GL.bufferSubData(GL.ELEMENT_ARRAY_BUFFER, 0, GLTypes.getMemoryRange(bytesData, bytesLength, bytesOffset));
		}
	}

	public function disposeMesh(mesh:GLMeshData):Void {
		mesh.dispose();
	}


	/*** Context lost/restored events ***/
	function __onContextLost(_) {
		isLost = true;
	}

	function __onContextRestored(_) {
		isLost = false;
		if(onRestore != null) {
			onRestore();
		}
	}
}
