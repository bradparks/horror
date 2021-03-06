package;

import haxe.io.Bytes;

import horror.render.RenderContext;
import horror.render.Texture;
import horror.render.Material;
import horror.render.VertexStructure;
import horror.render.Matrix4;
import horror.render.VertexData;

import horror.renderex.TextureUtil;
import horror.renderex.MeshBatcher;

import horror.input.MouseEventType;
import horror.input.MouseEvent;

import horror.loaders.BytesLoader;
import horror.loaders.BatchLoader;

import horror.app.Application;

class Demo extends Application {

	var _cameraMatrix:Matrix4 = new Matrix4();
	var _vertexStructure:VertexStructure;

	var _batcher:MeshBatcher;

	var _material:Material;
	var _texture:Texture;

	var _checkerMaterial:Material;
	var _checkerTexture:Texture;

	var _time:Float = 0;
	var _blobs:Array<Blob> = [];

	public function new () {
		super();
	}

	override public function initialize() {
		trace("loading started...");

		var loader = new BatchLoader();
		loader.add(new BytesLoader("assets/rect.png"));
		loader.add(new BytesLoader("assets/checker.png"));
		loader.loaded.addOnce(onLoaded);
		loader.load();
	}

	function onLoaded(loader:BatchLoader) {
		trace("loading completed...");

		_vertexStructure = new VertexStructure();
		_vertexStructure.add("aVertexPosition", VertexData.FloatN(2));
		_vertexStructure.add("aTexCoord", VertexData.FloatN(2));
		_vertexStructure.add("aColorMult", VertexData.PackedColor);
		_vertexStructure.compile();

		_texture = TextureUtil.createFromPng(loader.get("assets/rect.png", Bytes));
		_checkerTexture = TextureUtil.createFromPng(loader.get("assets/checker.png", Bytes));

		_material= new Material();
		_material.shader = SimpleShader.create();
		_material.texture = _texture;

		_checkerMaterial = new Material();
		_checkerMaterial.shader = _material.shader;
		_checkerMaterial.texture = _checkerTexture;

		engine.input.onMouse.add(onMouse);

		_cameraMatrix.setTransform2D(0, 0, 1, 0);

		_batcher = new MeshBatcher(_vertexStructure);

		for(i in 0...10) {
			_blobs.push(new Blob());
		}

		start();
	}

	public override function update(dt:Float) {
		_time += dt;
		_cameraMatrix.setTransform2D(0, 0, 1.0 + 0.2* Math.sin(_time*5), 0);
		for(blob in _blobs) {
			blob.update(dt);
		}
	}

	public override function render() {
		// shows that clear is actually worked and frames updated
		engine.render.clear(0.2 + 0.2 * Math.sin(_time), 0.2, 0.3, 1.0);
		engine.render.begin();

		_batcher.begin();

		_batcher.changeViewModelMatrix(_cameraMatrix);

		_batcher.setState(_material, 4*3);

		for(blob in _blobs) {
			_batcher.setState(_material, blob.segmentsCount + 1);
			blob.draw(_batcher.buffer);
		}

		_batcher.changeViewModelMatrix(null);

		_batcher.setState(_material, 4*3);
		Quad.drawHorizontalGradient(_batcher.buffer, 8,  32, 42, 4, 0xffff0000, 0x00ff0000);
		Quad.drawHorizontalGradient(_batcher.buffer, 50, 32, 42, 4, 0xff00ff00, 0x0000ff00);
		Quad.drawHorizontalGradient(_batcher.buffer, 92, 32, 42, 4, 0xff0000ff, 0x000000ff);

		_batcher.setState(_checkerMaterial, 4);
		Quad.draw(_batcher.buffer, 8, 8, 128, 16);

		_batcher.end();

		engine.render.end();
	}


	function onMouse(e:MouseEvent) {
		if(e.type == MouseEventType.DOWN) {
			_material.texture = _material.texture == _texture ? null : _texture;
		}
	}
}