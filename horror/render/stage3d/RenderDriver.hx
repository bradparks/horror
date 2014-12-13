package horror.render.stage3d;

import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DTextureFilter;
import flash.display3D.Context3DWrapMode;
import flash.Lib;
import flash.events.Event;
import flash.errors.Error;
import flash.utils.ByteArray in FlashByteArray;
import flash.geom.Matrix3D in FlashMatrix3D;

import flash.display.Stage3D;
import flash.display3D.Context3D;
//import flash.display3D.Context3DProfile;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;

import horror.render.VertexStructure;
import horror.memory.ByteArray;
import horror.debug.Debug;

using StringTools;

/*** BASE RENDER TYPES ***/

class RawMesh {
	public var vertexStructure:VertexStructure;

	public var vertexBuffer:VertexBuffer3D;
	public var vertexBytesAllocated:Int;
	public var vertexBytesLength:Int;

	public var indexBuffer:IndexBuffer3D;
	public var indexBytesAllocated:Int;
	public var indexBytesLength:Int;

	public function new(vertexStructure:VertexStructure) {
		this.vertexStructure = vertexStructure;
	}
}

typedef RawTexture = Texture;

class RawShader {
	public var program:Program3D;
	public var vertexAGAL:FlashByteArray;
	public var fragmentAGAL:FlashByteArray;

	public function new() {}
}

/*** CONTEXT ***/

class RenderDriver {

	var _stage3d:Stage3D;
	var _context:Context3D;

	var _cbInitialized:Void->Void;
	var _currentShader:RawShader;
	var _oldFlash:Bool;
	var _currentIndexBuffer:IndexBuffer3D;

	static var TEMP_MATRIX:FlashMatrix3D = new FlashMatrix3D();

	public function new() {
	}

	public function initialize(callback:Void->Void):Void {
		_cbInitialized = callback;
		_stage3d = Lib.current.stage.stage3Ds[0];
		_stage3d.addEventListener(Event.CONTEXT3D_CREATE, onContextReady);
		_oldFlash = untyped (_stage3d.requestContext3D.length) == 1;
		if(_oldFlash) {
			_stage3d.requestContext3D(cast "auto");
		}
		else {
			_stage3d.requestContext3D(cast "auto", cast "baseline");//Context3DProfile.BASELINE);
		}
	}

	public function dispose():Void {
		if(_context != null) {
			_context.dispose(false);
			_context = null;
		}
		_stage3d = null;
		_currentShader = null;
	}

	private function onContextReady(e:Event):Void {
		_context = _stage3d.context3D;
		//#if debug
		//_context.enableErrorChecking = true;
		//#else
		_context.enableErrorChecking = false;
		//#end

		if (_cbInitialized != null) {
			_cbInitialized();
			_cbInitialized = null;
		}
	}

	public function resize(width:Int, height:Int):Void {
		if(_oldFlash) {
			_context.configureBackBuffer(width, height, 0);
		}
		else {
			_context.configureBackBuffer(width, height, 0, false, false);
		}
	}

	public function clear(r:Float = 1, g:Float = 1, b:Float = 1):Void {
		_context.clear(r, g, b, 1, 1, 0, Context3DClearMask.COLOR);
	}

	public function begin():Void {
		_context.setCulling(Context3DTriangleFace.NONE);
		_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
	}

	public function end():Void {
		_context.present();
	}

	public function drawIndexedTriangles(triangles:Int):Void {
		Debug.assert(_currentIndexBuffer != null);
		_context.drawTriangles(_currentIndexBuffer, 0, triangles);
	}

	public function setTexture(texture:RawTexture) {
		_context.setTextureAt(0, texture);
	}

	/*** SHADERS ***/

	public function createShader(vertexShaderCode:String, fragmentShaderCode:String):RawShader {
		var vertexProgram:AGALMiniAssembler = new AGALMiniAssembler();
		var pixelProgram:AGALMiniAssembler = new AGALMiniAssembler();

		vertexProgram.assemble(Context3DProgramType.VERTEX, vertexShaderCode);
		pixelProgram.assemble(Context3DProgramType.FRAGMENT, fragmentShaderCode);

		var shader = new RawShader();
		shader.vertexAGAL = vertexProgram.agalcode;
		shader.fragmentAGAL = pixelProgram.agalcode;
		return shader;
	}

	public function setShader(shader:RawShader):Void {
		if(shader.program == null) {
			_initializeShader(shader);
		}
		_context.setProgram(shader.program);
		_currentShader = shader;
		_context.setSamplerStateAt(0, Context3DWrapMode.CLAMP, Context3DTextureFilter.LINEAR, Context3DMipFilter.MIPNONE);
	}

	public function setBlendMode(src:BlendFactor, dst:BlendFactor):Void {
		_context.setBlendFactors(convertBlendFactor(src), convertBlendFactor(dst));
	}

	public function setMatrix(modelViewMatrix:Matrix4):Void {
		TEMP_MATRIX.rawData = modelViewMatrix.rawData;
		_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, TEMP_MATRIX, true);
	}

	public function setMesh(mesh:RawMesh):Void {
		_currentIndexBuffer = mesh.indexBuffer;
		var vb3d = mesh.vertexBuffer;
		var vas = mesh.vertexStructure;
		var vertexStructure = mesh.vertexStructure;
		var stride:Int = vertexStructure.stride;
		for(i in 0...vertexStructure.size()) {
			var ve:VertexElement = vertexStructure.elements[i];
			_context.setVertexBufferAt(i, vb3d, ve.offset >> 2, _getVertexBufferFormat(ve.data));
		}
	}

	public function disposeShader(shader:RawShader):Void {
		shader.program.dispose();
		shader.program = null;
	}

	function _initializeShader(shader:RawShader):Void {
		shader.program = _context.createProgram();
		shader.program.upload(shader.vertexAGAL, shader.fragmentAGAL);
	}

	inline static function _getVertexBufferFormat(format:VertexData):Context3DVertexBufferFormat {
		return
			switch(format) {
				case VertexData.FloatN(1):
					Context3DVertexBufferFormat.FLOAT_1;
				case VertexData.FloatN(2):
					Context3DVertexBufferFormat.FLOAT_2;
				case VertexData.FloatN(3):
					Context3DVertexBufferFormat.FLOAT_3;
				case VertexData.FloatN(4):
					Context3DVertexBufferFormat.FLOAT_4;
				case VertexData.PackedColor:
					Context3DVertexBufferFormat.BYTES_4;
				case VertexData.FloatN(_):
					throw 'unmatched';
			}
	}

	/*** TEXTURES ***/

	public function createTextureFromByteArray(width:Int, height:Int, pixels:ByteArrayData):RawTexture {
		var texture = _context.createTexture(width, height, Context3DTextureFormat.BGRA, false); // 0 - streamingLevel
		texture.uploadFromByteArray(pixels, 0, 0);
		return texture;
	}

	public function disposeTexture(texture:RawTexture):Void {
		texture.dispose();
	}

	/*** VERTEX  / INDEX BUFFERS ***/
	public function createMesh(vertexStructure:VertexStructure):RawMesh {
		return new RawMesh(vertexStructure);
	}

	public function uploadVertices(mesh:RawMesh, data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		_resizeVertexBuffer(mesh, bytesLength);
		mesh.vertexBuffer.uploadFromByteArray(data, bytesOffset, 0, Std.int(mesh.vertexBytesLength / mesh.vertexStructure.stride));
	}

	public function uploadIndices(mesh:RawMesh, data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		_resizeIndexBuffer(mesh, bytesLength);
		mesh.indexBuffer.uploadFromByteArray(data, bytesOffset, 0, mesh.indexBytesLength >> 1);
	}

	public function disposeMesh(mesh:RawMesh):Void {
		_reallocIndexBuffer(mesh, 0);
		_reallocVertexBuffer(mesh, 0);
	}

	function _reallocVertexBuffer(mesh:RawMesh, size:Int):Void {
		if(mesh.vertexBuffer != null) {
			mesh.vertexBuffer.dispose();
			mesh.vertexBuffer = null;
			mesh.vertexBytesAllocated = 0;
			mesh.vertexBytesLength = 0;
		}
		if(size > 0) {
			var stride = mesh.vertexStructure.stride;
			var numVertices = Std.int(size / stride);
			var data32PerVertex = stride >> 2;
			if(_oldFlash) {
				mesh.vertexBuffer = _context.createVertexBuffer(numVertices, data32PerVertex);
			}
			else {
				var f = untyped _context.createVertexBuffer;
				mesh.vertexBuffer = untyped f(numVertices, data32PerVertex, "dynamicDraw");
			}
			mesh.vertexBytesAllocated = size;
		}
	}

	function _resizeVertexBuffer(mesh:RawMesh, size:Int):Void {
		if(size > mesh.vertexBytesAllocated) {
			_reallocVertexBuffer(mesh, size);
		}
		mesh.vertexBytesLength = size;
	}

	function _reallocIndexBuffer(mesh:RawMesh, size:Int):Void {
		if(mesh.indexBuffer != null) {
			mesh.indexBuffer.dispose();
			mesh.indexBuffer = null;
			mesh.indexBytesAllocated = 0;
			mesh.indexBytesLength = 0;
		}
		if(size > 0) {
			var numIndices = size >> 1;
			if(_oldFlash) {
				mesh.indexBuffer = _context.createIndexBuffer(numIndices);
			}
			else {
				var f = untyped _context.createIndexBuffer;
				mesh.indexBuffer = untyped f(numIndices, "dynamicDraw");
			}
			mesh.indexBytesAllocated = size;
		}
	}

	function _resizeIndexBuffer(mesh:RawMesh, size:Int):Void {
		if(size > mesh.indexBytesAllocated) {
			_reallocIndexBuffer(mesh, size);
		}
		mesh.indexBytesLength = size;
	}

	public static function convertBlendFactor(blendMode:BlendFactor):Context3DBlendFactor {
		return switch(blendMode) {
			case BlendFactor.ZERO:
				Context3DBlendFactor.ZERO;
			case BlendFactor.ONE:
				Context3DBlendFactor.ONE;
			case BlendFactor.DESTINATION_ALPHA:
				Context3DBlendFactor.DESTINATION_ALPHA;
			case BlendFactor.DESTINATION_COLOR:
				Context3DBlendFactor.DESTINATION_COLOR;
			case BlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
			case BlendFactor.ONE_MINUS_DESTINATION_COLOR:
				Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
			case BlendFactor.SOURCE_ALPHA:
				Context3DBlendFactor.SOURCE_ALPHA;
			case BlendFactor.SOURCE_COLOR:
				Context3DBlendFactor.SOURCE_COLOR;
			case BlendFactor.ONE_MINUS_SOURCE_ALPHA:
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case BlendFactor.ONE_MINUS_SOURCE_COLOR:
				Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
		}
	}

}
