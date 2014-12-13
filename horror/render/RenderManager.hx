package horror.render;

import horror.memory.ByteArray;
import horror.app.ScreenManager;
import horror.debug.Debug;
import horror.utils.DisposeUtil;

#if flash

typedef RenderDriver = horror.render.stage3d.RenderDriver;
typedef RawMesh = horror.render.stage3d.RenderDriver.RawMesh;
typedef RawTexture = horror.render.stage3d.RenderDriver.RawTexture;
typedef RawShader = horror.render.stage3d.RenderDriver.RawShader;

#elseif openfl

typedef RenderDriver = horror.render.gl.RenderDriver;
typedef RawMesh = horror.render.gl.RenderDriver.RawMesh;
typedef RawTexture = horror.render.gl.RenderDriver.RawTexture;
typedef RawShader = horror.render.gl.RenderDriver.RawShader;

#end

class RenderManager {

	@:allow(horror.render.Texture)
	@:allow(horror.render.Shader)
	@:allow(horror.render.Mesh)
	static var driver(default, null):RenderDriver;

	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;

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
		driver = new RenderDriver();
	}

	public function initialize(onReady: Void -> Void):Void {
		Debug.assert(isInitialized == false);
		_cbOnReady = onReady;
		driver.initialize(onDriverInitialized);
	}

	function onDriverInitialized():Void {
		isInitialized = true;

		var screen = Horror.screen;
		screen.resized.add(onScreenResized);
		onScreenResized(screen);

		if(_cbOnReady != null) {
			_cbOnReady();
			_cbOnReady = null;
		}

		blankTexture = Texture.createFromColor(1, 1, 0xffffffff);
	}

	public function dispose():Void {
		DisposeUtil.dispose(driver);
		isInitialized = false;
	}

	public function clear(r:Float, g:Float, b:Float):Void {
		driver.clear(r, g, b);
	}

	public function begin():Void {
		_currentShader = null;
		_currentTexture = null;
		_currentMesh = null;
		_currentBlendModeHash = 0;
		driver.begin();
		__resetFrameStats();
	}

	public function end():Void {
		driver.end();
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
			driver.resize(width, height);
			this.width = width;
			this.height = height;
		}
	}

	public function drawMesh(mesh:Mesh, material:Material):Void {
		Debug.assert(mesh != null && mesh.numTriangles > 0 && material != null);

		setMaterial(material);
		setModelViewProjection();
		setMesh(mesh);

		var triangles:Int = mesh.numTriangles;
		driver.drawIndexedTriangles(triangles);
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
			driver.setMatrix(_mvpMatrix);
			_needToUploadMVP = false;
		}
	}

	function setMaterial(material:Material):Void {
		var shader = material.shader;
		if(shader != _currentShader) {
			var blendModeHash:Int = shader.getBlendModeHash();
			if(_currentBlendModeHash != blendModeHash) {
				driver.setBlendMode(shader.sourceBlendFactor, shader.destinationBlendFactor);
				_currentBlendModeHash = blendModeHash;
			}
			driver.setShader(shader._rawData);
			_currentShader = shader;
			_needToUploadMVP = true;
		}
		var texture = material.texture;
		if(texture == null) {
			texture = blankTexture;
		}
		if(texture != _currentTexture) {
			driver.setTexture(texture._rawData);
			_currentTexture = texture;
		}
	}

	function setMesh(mesh:Mesh):Void {
		driver.setMesh(mesh._rawData);
	}

	function onScreenResized(screen:ScreenManager):Void {
		resize(screen.width, screen.height);
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