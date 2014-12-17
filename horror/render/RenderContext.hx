package horror.render;

import horror.std.Module;
import horror.std.Horror;

#if flash

typedef RenderDriver = horror.render.stage3d.Stage3DDriver;
typedef MeshData = horror.render.stage3d.Stage3DMeshData;
typedef TextureData = horror.render.stage3d.Stage3DTextureData;
typedef ShaderData = horror.render.stage3d.Stage3DShaderData;

#elseif openfl

typedef RenderDriver = horror.render.gl.GLDriver;
typedef MeshData = horror.render.gl.GLMeshData;
typedef TextureData = horror.render.gl.GLTextureData;
typedef ShaderData = horror.render.gl.GLShaderData;

#end

@:access(horror.render.Texture)
@:access(horror.render.Shader)
@:access(horror.render.Mesh)
class RenderContext extends Module {

	@:allow(horror.render.Texture)
	@:allow(horror.render.Shader)
	@:allow(horror.render.Mesh)
	static var __driver(default, null):RenderDriver;

	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	public var isLost(get, never):Bool;

	public var blankTexture(default, null):Texture;

	public var isInitialized(default, null):Bool = false;
	var _cbOnReady:Void->Void;

	var _currentShader:Shader;
	var _currentTexture:Texture;
	var _currentMesh:Mesh;
	var _currentBlendModeHash:Int = 0;

	var _projectionMatrix:Matrix4 = new Matrix4();
	var _modelViewMatrix:Matrix4;
	var _mvpMatrix:Matrix4 = new Matrix4();
	var _dirtyMVP:Bool = true;
	var _needToUploadMVP:Bool = true;

	public function new() {
		super();

		__driver = new RenderDriver();
	}

	public function initialize(onReady: Void -> Void):Void {
		Horror.assert(isInitialized == false);
		_cbOnReady = onReady;
		__driver.onInitialize = onDriverInitialized;
		__driver.onRestore = onDriverRestored;
		__driver.initialize();
	}

	function onDriverInitialized():Void {
		isInitialized = true;

		if(_cbOnReady != null) {
			_cbOnReady();
			_cbOnReady = null;
		}

		blankTexture = Texture.createWhiteBlank(1, 1);
	}

	function onDriverRestored():Void {

	}

	public override function dispose():Void {
		super.dispose();

		Horror.dispose(__driver);
		isInitialized = false;
	}

	public function clear(r:Float, g:Float, b:Float):Void {
		__driver.clear(r, g, b);
	}

	public function begin():Void {
		_currentShader = null;
		_currentTexture = null;
		_currentMesh = null;
		_currentBlendModeHash = 0;
		__driver.begin();
		__resetFrameStats();
	}

	public function end():Void {
		__driver.end();
	}

	public function setOrtho2D(x:Int, y:Int, width:Int, height:Int):Void {
		_projectionMatrix.setOrtho2D(0, 0, width, height);
		_dirtyMVP = true;
	}

	public function setMatrix(modelViewMatrix:Matrix4):Void {
		_modelViewMatrix = modelViewMatrix;
		_dirtyMVP = true;
	}

	public function resize(width:Int, height:Int):Void {
		if(this.width != width || this.height != height) {
			__driver.resize(width, height);
			this.width = width;
			this.height = height;
		}
	}

	public function drawMesh(mesh:Mesh, material:Material):Void {
		Horror.assert(mesh != null && mesh.numTriangles > 0 && material != null);

		setMaterial(material);
		setModelViewProjection();
		setMesh(mesh);

		var triangles:Int = mesh.numTriangles;
		__driver.drawIndexedTriangles(triangles);
		__trackDrawCall(triangles);
	}

	function setModelViewProjection():Void {
		if(_dirtyMVP) {
			if(_modelViewMatrix != null) {
				Matrix4.multiply(_projectionMatrix, _modelViewMatrix, _mvpMatrix);
			}
			else {
				_mvpMatrix.copyFromMatrix(_projectionMatrix);
			}
			_dirtyMVP = false;
			_needToUploadMVP = true;
		}
		if(_needToUploadMVP) {
			__driver.setMatrix(_mvpMatrix);
			_needToUploadMVP = false;
		}
	}

	function setMaterial(material:Material):Void {
		var shader = material.shader;
		if(shader != _currentShader) {
			var blendModeHash:Int = shader.getBlendModeHash();
			if(_currentBlendModeHash != blendModeHash) {
				__driver.setBlendMode(shader.sourceBlendFactor, shader.destinationBlendFactor);
				_currentBlendModeHash = blendModeHash;
			}
			__driver.setShader(shader.__data);
			_currentShader = shader;
			_needToUploadMVP = true;
		}
		var texture = material.texture;
		if(texture == null) {
			texture = blankTexture;
		}
		if(texture != _currentTexture) {
			__driver.setTexture(texture.__data);
			_currentTexture = texture;
		}
	}

	function setMesh(mesh:Mesh):Void {
		__driver.setMesh(mesh.__data);
	}

	inline function get_isLost():Bool {
		return __driver.isLost;
	}

	/*** STATS ***/
	public var trianglesPerFrame(default, null):Int = 0;
	public var drawCallsPerFrame(default, null):Int = 0;

	function __resetFrameStats():Void {
		trianglesPerFrame = 0;
		drawCallsPerFrame = 0;
	}

	function __trackDrawCall(triangles:Int):Void {
		trianglesPerFrame += triangles;
		++drawCallsPerFrame;
	}
}