package horror.render.stage3d;

import haxe.io.BytesData;

import flash.Lib;
import flash.events.Event;
import flash.geom.Matrix3D in FlashMatrix3D;

import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DTextureFilter;
import flash.display3D.Context3DWrapMode;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;

import horror.render.VertexStructure;
import horror.std.Horror;

using StringTools;

class Stage3DDriver {

	public static var OLD_API:Bool = true;

	public var isLost(get, never):Bool;
	public var onRestore:Void->Void;
	public var onInitialize:Void->Void;

	var _stage3d:Stage3D;
	var _context:Context3D;

	var _currentShader:Stage3DShaderData;
	var _currentIndexBuffer:IndexBuffer3D;

	public function new() {
	}

	public function initialize():Void {
		_stage3d = Lib.current.stage.stage3Ds[0];
		_stage3d.addEventListener(Event.CONTEXT3D_CREATE, onContextReady);
		OLD_API = untyped (_stage3d.requestContext3D.length) == 1;
		if(OLD_API) {
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
		var oldContext = _context;
		_context = _stage3d.context3D;
		#if debug
		_context.enableErrorChecking = true;
		#else
		_context.enableErrorChecking = false;
		#end

		if(oldContext != null) {
			if(onRestore != null) {
				onRestore();
			}
		}
		else {
			if (onInitialize != null) {
				onInitialize();
				onInitialize = null;
			}
		}
	}

	public function resize(width:Int, height:Int):Void {
		if(OLD_API) {
			_context.configureBackBuffer(width, height, 0);
		}
		else {
			_context.configureBackBuffer(width, height, 0, false, false);
		}
	}

	public function clear(r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void {
		_context.clear(r, g, b, a, 1, 0, Context3DClearMask.COLOR);
	}

	public function begin():Void {
		_context.setCulling(Context3DTriangleFace.NONE);
		_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
	}

	public function end():Void {
		_context.present();
	}

	public function drawIndexedTriangles(triangles:Int):Void {
		Horror.assert(_currentIndexBuffer != null);
		_context.drawTriangles(_currentIndexBuffer, 0, triangles);
	}

	public function setTexture(texture:Stage3DTextureData) {
		_context.setTextureAt(0, texture);
	}

	/*** SHADERS ***/

	public function createShader(vertexShaderCode:String, fragmentShaderCode:String):Stage3DShaderData {
		var shader = new Stage3DShaderData();
		shader.compile(vertexShaderCode, fragmentShaderCode);
		return shader;
	}

	public function setShader(shader:Stage3DShaderData):Void {
		if(shader.program == null) {
			shader.initialize(_context);
		}
		_context.setProgram(shader.program);
		_currentShader = shader;
		_context.setSamplerStateAt(0, Context3DWrapMode.CLAMP, Context3DTextureFilter.LINEAR, Context3DMipFilter.MIPNONE);
	}

	public function setBlendMode(src:BlendFactor, dst:BlendFactor):Void {
		_context.setBlendFactors(Stage3DTypes.getBlendFactor(src), Stage3DTypes.getBlendFactor(dst));
	}

	public function setMatrix(modelViewMatrix:Matrix4):Void {
		_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0,
												Stage3DTypes.getMatrix3D(modelViewMatrix), true);
	}

	public function setMesh(mesh:Stage3DMeshData):Void {
		_currentIndexBuffer = mesh.indexBuffer;
		var vb3d = mesh.vertexBuffer;
		var vas = mesh.vertexStructure;
		var vertexStructure = mesh.vertexStructure;
		var stride:Int = vertexStructure.stride;
		for(i in 0...vertexStructure.size()) {
			var ve:VertexElement = vertexStructure.elements[i];
			_context.setVertexBufferAt(i, vb3d, ve.offset >> 2, Stage3DTypes.getVertexBufferFormat(ve.data));
		}
	}

	public function disposeShader(shader:Stage3DShaderData):Void {
		shader.dispose();
	}

	/*** TEXTURES ***/

	public function createTextureFromBytes(width:Int, height:Int, bytesData:BytesData):Stage3DTextureData {
		var texture = _context.createTexture(width, height, Context3DTextureFormat.BGRA, false); // 0 - streamingLevel
		texture.uploadFromByteArray(bytesData, 0, 0);
		return texture;
	}

	public function disposeTexture(texture:Stage3DTextureData):Void {
		texture.dispose();
	}

	/*** VERTEX  / INDEX BUFFERS ***/
	public function createMesh(vertexStructure:VertexStructure):Stage3DMeshData {
		return new Stage3DMeshData(vertexStructure);
	}

	public function uploadVertices(mesh:Stage3DMeshData, bytesData:BytesData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		mesh.resizeVertexBuffer(_context, bytesLength);
		mesh.vertexBuffer.uploadFromByteArray(bytesData, bytesOffset, 0, Std.int(mesh.vertexBytesLength / mesh.vertexStructure.stride));
	}

	public function uploadIndices(mesh:Stage3DMeshData, bytesData:BytesData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		mesh.resizeIndexBuffer(_context, bytesLength);
		mesh.indexBuffer.uploadFromByteArray(bytesData, bytesOffset, 0, mesh.indexBytesLength >> 1);
	}

	public function disposeMesh(mesh:Stage3DMeshData):Void {
		mesh.dispose();
	}

	/** CONTEXT LOST **/
	inline function get_isLost():Bool {
		return _context == null || _context.driverInfo == "Disposed";
	}

}
