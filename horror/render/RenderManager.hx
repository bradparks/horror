package horror.render;

import horror.memory.ByteArray;
import horror.app.ScreenManager;
import horror.debug.Debug;
import horror.utils.DisposeUtil;
import horror.utils.IDisposable;

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

class RenderManager implements IDisposable {

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

	function onScreenResized(screen:ScreenManager):Void {
		resize(screen.width, screen.height);
	}

	public function dispose():Void {
		DisposeUtil.dispose(driver);
		driver = null;
		isInitialized = false;
	}

	public function clear(r:Float, g:Float, b:Float):Void {
		driver.clear(r, g, b);
	}

	public function begin():Void {
		_currentShader = null;
		_currentTexture = null;
		_currentMesh = null;
		driver.begin();
		__resetFrameStats();
	}

	public function end():Void {
		driver.end();
	}

	public function setMaterial(material:Material):Void {
		var shader = material.shader;
		if(shader != _currentShader) {
			driver.setBlendMode(shader.sourceBlendFactor, shader.destinationBlendFactor);
			driver.setShader(shader._rawData);
			_currentShader = shader;
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

	public function setMatrix(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void {
		driver.setMatrix(projectionMatrix, modelViewMatrix);
	}

	// after mesh modification you must to re set it
	public function setMesh(mesh:Mesh):Void {
		driver.setMesh(mesh._rawData);
	}

	public function resize(width:Int, height:Int):Void {
		if(this.width != width || this.height != height) {
			driver.resize(width, height);
			this.width = width;
			this.height = height;
		}
	}

	public function drawIndexedTriangles(triangles:Int):Void {
		Debug.assert(triangles >= 1);
		driver.drawIndexedTriangles(triangles);
		__trackDrawCall(triangles);
	}

	// STATS

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