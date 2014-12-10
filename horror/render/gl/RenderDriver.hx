package horror.render.gl;

import horror.render.VertexStructure;
import horror.utils.IDisposable;
import horror.memory.ByteArray.ByteArrayData;

import openfl.utils.ArrayBufferView;
import openfl.utils.IMemoryRange;
import openfl.utils.UInt8Array;
import openfl.utils.ByteArray in LimeByteArray;

import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLTexture;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;

/*** BASE RENDER TYPES ***/
class RawMesh {
	public var vertexStructure:VertexStructure;
	public var vertexBuffer:GLBuffer;
	public var indexBuffer:GLBuffer;

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

typedef RawTexture = GLTexture;

class RawShader {
	public var vertexAttributes:Array<Int> = [];
	public var program:GLProgram;
	public var imageUniform:GLUniformLocation;
	public var modelViewMatrixUniform:GLUniformLocation;
	public var projectionMatrixUniform:GLUniformLocation;

	public function new() { }
}



class GLMemoryRange implements IMemoryRange {

	public var bytes:LimeByteArray;
	public var length:Int;
	public var offset:Int;

	public function new() {}

	public inline function set(bytes:LimeByteArray, offset:Int, length:Int):Void {
		this.bytes = bytes;
		this.length = length;
		this.offset = offset;
	}

	public function getByteBuffer ():LimeByteArray { return bytes; }
	public function getStart ():Int { return offset; }
	public function getLength ():Int { return length; }
}

/*** CONTEXT ***/
class RenderDriver implements IDisposable {
	var _currentShader:RawShader;

	public function new() {}

	public function initialize(callback:Void->Void):Void {
		if(callback != null) {
			callback();
		}
	}

	public function dispose():Void { }

	public function resize(width:Int, height:Int):Void {
		GL.viewport (0, 0, width, height);
	}

	public function clear(r:Float = 1, g:Float = 1, b:Float = 1):Void {
		GL.clearColor (r, g, b, 1.0);
		GL.clear (GL.COLOR_BUFFER_BIT);
	}

	public function begin():Void {
		GL.cullFace(GL.FRONT_AND_BACK);
		GL.depthMask(false);
		GL.disable(GL.DEPTH_TEST);
		GL.enable (GL.BLEND);
		setShader(null);
	}

	public function end():Void { }

	public function drawIndexedTriangles(triangles:Int):Void {
		GL.drawElements(GL.TRIANGLES, triangles*3, GL.UNSIGNED_SHORT, 0);
	}

	public function setTexture(texture:RawTexture) {
		GL.activeTexture (GL.TEXTURE0);
		GL.bindTexture (GL.TEXTURE_2D, texture);
		#if desktop
		GL.enable (GL.TEXTURE_2D);
		#end
	}

	/*** TEXTURES ***/

	public function createTextureFromByteArray(width:Int, height:Int, pixels:ByteArrayData):RawTexture {
		var texture = GL.createTexture ();
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, getGLImageData(pixels));
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.bindTexture (GL.TEXTURE_2D, null);
		return texture;
	}

	public function disposeTexture(texture:RawTexture):Void {
		GL.deleteTexture(texture);
	}

	/*** SHADERS ***/



	public function createShader(vertexShaderCode:String, fragmentShaderCode:String):RawShader {
		var vertexShader = _compileShader(vertexShaderCode, GL.VERTEX_SHADER);
		var fragmentShader = _compileShader(fragmentShaderCode, GL.FRAGMENT_SHADER);

		var program = GL.createProgram();
		GL.attachShader (program, vertexShader);
		GL.attachShader (program, fragmentShader);
		GL.linkProgram (program);

		if (GL.getProgramParameter (program, GL.LINK_STATUS) == 0) {
			throw "Unable to initialize the shader program.";
		}

		var shader = new RawShader();

		for(attr in GLParserUtil.extractAttributes(vertexShaderCode)) {
			shader.vertexAttributes.push(GL.getAttribLocation (program, attr));
		}

		shader.projectionMatrixUniform = GL.getUniformLocation (program, "uProjectionMatrix");
		shader.modelViewMatrixUniform = GL.getUniformLocation (program, "uModelViewMatrix");
		shader.imageUniform = GL.getUniformLocation (program, "uImage0");
		shader.program = program;

		return shader;
	}

	public function setShader(shader:RawShader):Void {
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
		GL.blendFunc(convertBlendFactor(src), convertBlendFactor(dst));
	}

	public function setMatrix(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void {
		GL.uniformMatrix4fv (_currentShader.projectionMatrixUniform, false, projectionMatrix.rawData);
		GL.uniformMatrix4fv (_currentShader.modelViewMatrixUniform, false, modelViewMatrix.rawData);
	}

	public function setMesh(mesh:RawMesh):Void {
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

	public function disposeShader(shader:RawShader):Void {
		GL.deleteProgram(shader.program);
	}

	function _compileShader(code:String, shaderType:Int):GLShader {
		#if !desktop
		if(shaderType == GL.FRAGMENT_SHADER) {
			code = "precision mediump float;" + code;
		}
		#end

		var glShader = GL.createShader (shaderType);
		GL.shaderSource (glShader, code);
		GL.compileShader (glShader);
		if (GL.getShaderParameter (glShader, GL.COMPILE_STATUS) == 0) {
			if(shaderType == GL.FRAGMENT_SHADER) {
				throw "Error compiling FRAGMENT shader";
			}
			else if(shaderType == GL.VERTEX_SHADER) {
				throw "Error compiling VERTEX shader";
			}
		}
		return glShader;
	}

	/*** VERTEX / INDEX BUFFERS ***/
	public function createMesh(vertexStructure:VertexStructure):RawMesh {
		return new RawMesh(vertexStructure);
	}

	public function uploadVertices(mesh:RawMesh, data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		GL.bindBuffer(GL.ARRAY_BUFFER, mesh.vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, getGLBufferData(data, bytesLength, bytesOffset), GL.DYNAMIC_DRAW);
	}

	public function uploadIndices(mesh:RawMesh, data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, getGLBufferData(data, bytesLength, bytesOffset), GL.DYNAMIC_DRAW);
	}

	public function disposeMesh(mesh:RawMesh):Void {
		mesh.dispose();
	}

/***** GL BYTES UTILITY ****/

	#if html5
	static inline function getGLBufferData(data:ByteArrayData, length:Int, offset:Int = 0):UInt8Array {
		if((length == 0 || data.byteView.length == length) && offset == 0) {
			return data.byteView;
		}
		return data.byteView.subarray(offset, offset+length);
	}
	#else
	static var _memoryRange:GLMemoryRange = new GLMemoryRange();
	static inline function getGLBufferData(data:ByteArrayData, length:Int, offset:Int = 0):GLMemoryRange {
		_memoryRange.set(data, offset, length);
		return _memoryRange;
	}
	#end


	static inline function getGLImageData(data:ByteArrayData):UInt8Array {
		#if html5
		return data.byteView;
		#else
		return new UInt8Array(data);
		#end
	}

	public static function convertBlendFactor(blendMode:BlendFactor):Int {
		return switch(blendMode) {
			case BlendFactor.ZERO:
				GL.ZERO;
			case BlendFactor.ONE:
				GL.ONE;
			case BlendFactor.DESTINATION_ALPHA:
				GL.DST_ALPHA;
			case BlendFactor.DESTINATION_COLOR:
				GL.DST_COLOR;
			case BlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				GL.ONE_MINUS_DST_ALPHA;
			case BlendFactor.ONE_MINUS_DESTINATION_COLOR:
				GL.ONE_MINUS_DST_COLOR;
			case BlendFactor.SOURCE_ALPHA:
				GL.SRC_ALPHA;
			case BlendFactor.SOURCE_COLOR:
				GL.SRC_COLOR;
			case BlendFactor.ONE_MINUS_SOURCE_ALPHA:
				GL.ONE_MINUS_SRC_ALPHA;
			case BlendFactor.ONE_MINUS_SOURCE_COLOR:
				GL.ONE_MINUS_SRC_COLOR;
		}
	}
}
