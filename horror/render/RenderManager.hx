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

	public var trianglesPerFrame(default, null):Int = 0;
	public var drawCallsPerFrame(default, null):Int = 0;

	public var isInitialized(default, null):Bool = false;
	var _cbOnReady:Void->Void;

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

		blankTexture = new Texture();
		uploadBlankTexture();
	}

	function uploadBlankTexture() {
		var bytes = new ByteArray();
		bytes.writeUInt32(0xffffffff);
		blankTexture.loadFromBytes(1, 1, bytes.data);
		bytes.clear();
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
		driver.begin();
		trianglesPerFrame = 0;
		drawCallsPerFrame = 0;
	}

	public function end():Void {
		driver.end();
	}

	public function setMaterial(material:Material):Void {
		setShader(material.shader);
		setTexture(material.texture);
		setBlendMode(material.sourceBlendFactor, material.destinationBlendFactor);
	}

	public function setBlendMode(sourceBlendFactor:BlendFactor, destinationBlendFactor:BlendFactor):Void {
		driver.setBlendMode(sourceBlendFactor, destinationBlendFactor);
	}

	public function setTexture(texture:Texture):Void {
		driver.setTexture(texture != null ? texture._rawData : null);
	}

	function setShader(shader:Shader):Void {
		driver.setShader(shader != null ? shader._rawData : null);
	}

	public function setMatrix(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void {
		driver.setMatrix(projectionMatrix, modelViewMatrix);
	}

	public function setVertexBuffer(vertexBuffer:Mesh):Void {
		driver.setVertexBuffer(vertexBuffer._rawData);
	}

	public function resize(width:Int, height:Int):Void {
		if(this.width != width || this.height != height) {
			driver.resize(width, height);
			this.width = width;
			this.height = height;
		}
	}

	public function drawIndexedTriangles(indexBuffer:Mesh, indexCount:Int):Void {
		driver.drawIndexedTriangles(indexBuffer._rawData, indexCount);

		// stats
		trianglesPerFrame += Std.int(indexCount / 3);
		++drawCallsPerFrame;
	}

}