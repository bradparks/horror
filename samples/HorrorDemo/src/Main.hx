package;

import horror.render.MeshBatcher;
import horror.loaders.BatchLoader;
import horror.debug.Debug;
import horror.memory.ByteArray;
import horror.input.MouseEventType;
import horror.input.MouseEvent;

import horror.loaders.BaseLoader;
import horror.loaders.BytesLoader;
import horror.Horror;

import horror.app.ScreenManager;
import horror.app.LoopManager;

import horror.render.VertexData;
import horror.render.Mesh;
import horror.render.RenderManager;
import horror.render.Matrix3D;
import horror.render.VertexStructure;
import horror.render.Shader;
import horror.render.MeshBuffer;
import horror.render.Texture;
import horror.render.Material;

class Main {

	var _render:RenderManager;
	var _cameraMatrix:Matrix3D = new Matrix3D();
	var _vertexStructure:VertexStructure;

	var _batcher:MeshBatcher;

	var _material:Material;
	var _texture:Texture;

	var _checkerMaterial:Material;
	var _checkerTexture:Texture;

	var _time:Float = 0;
	var _blobs:Array<Blob> = [];

	public function new () {
		Horror.initialize(start);
	}

	function start() {
		var loader = new BatchLoader();
		loader.add(new BytesLoader("assets/rect.png"));
		loader.add(new BytesLoader("assets/checker.png"));
		loader.loaded.addOnce(onLoaded);
		loader.load();
	}

	function onLoaded(loader:BatchLoader) {
		_render = Horror.render;

		_vertexStructure = new VertexStructure();
		_vertexStructure.add("aVertexPosition", VertexData.FloatN(2));
		_vertexStructure.add("aTexCoord", VertexData.FloatN(2));
		_vertexStructure.add("aColorMult", VertexData.PackedColor);
		_vertexStructure.compile();

		_texture = new Texture();
		_texture.loadPngFromBytes(loader.get("assets/rect.png", ByteArray));
		_checkerTexture = new Texture();
		_checkerTexture.loadPngFromBytes(loader.get("assets/checker.png", ByteArray));

		_material= new Material();
		_material.shader = SimpleShader.create();
		_material.texture = _texture;

		_checkerMaterial = new Material();
		_checkerMaterial.shader = _material.shader;
		_checkerMaterial.texture = _checkerTexture;

		Horror.input.onMouse.add(onMouse);

		_cameraMatrix.setTransform2D(0, 0, 1, 0);

		_batcher = new MeshBatcher(_vertexStructure);

		Horror.loop.updated.add(update);
		Horror.screen.resized.add(resize);
		resize(Horror.screen);

		for(i in 0...10) {
			_blobs.push(new Blob());
		}
	}

	function resize(screen:ScreenManager) {
		_render.setOrthographicProjection(screen.width, screen.height);
		trace('resize: ${screen.width}x${screen.height}');
	}


	function update(loop:LoopManager) {
		var dt = loop.deltaTime;
		_time += dt;

		//var hw:Int = Horror.screen.width >> 1;
		//var hh:Int = Horror.screen.height >> 1;
		//_cameraMatrix.setTransform2D(-hw, -hh, 1.0 + 0.2* Math.sin(_time*5), 0);
		_cameraMatrix.setTransform2D(0, 0, 1.0 + 0.2* Math.sin(_time*5), 0);
		// shows that clear is actually worked and frames updated
		_render.clear(0.2 + 0.2 * Math.sin(_time), 0.2, 0.3);
		_render.begin();

		_batcher.begin();

		_batcher.changeViewModelMatrix(_cameraMatrix);

		_batcher.setState(_material, 4*3);

		for(blob in _blobs) {
			blob.update(dt);
			_batcher.setState(_material, blob.segmentsCount + 1);
			blob.draw(_batcher.buffer);
		}

		_batcher.changeViewModelMatrix(null);

		_batcher.setState(_material, 4*3);
		Quad.drawQuad(_batcher.buffer, 8, 32, 40, 4, 0x77ff0000);
		Quad.drawQuad(_batcher.buffer, 48, 36, 40, 4, 0x7700ff00);
		Quad.drawQuad(_batcher.buffer, 88, 40, 40, 4, 0x770000ff);

		_batcher.setState(_checkerMaterial, 4);
		Quad.drawQuad(_batcher.buffer, 8, 8, 128, 16);

		_batcher.end();

		_render.end();
	}

	function onMouse(e:MouseEvent) {
		if(e.type == MouseEventType.DOWN) {
			_material.texture = _material.texture == _texture ? null : _texture;
		}

		/*if(e.type == MouseEventType.UP) {
			Horror.dispose();
			openfl.system.System.exit(0);
		}*/
	}
}