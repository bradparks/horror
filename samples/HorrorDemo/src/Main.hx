package;

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
	var _material:Material;
	var _cameraMatrix:Matrix3D = new Matrix3D();
	var _vertexStructure:VertexStructure;
	var _mesh:Mesh;
	var _meshBuffer:MeshBuffer;
	var _texture:Texture;

	var _time:Float = 0;
	var _blobs:Array<Blob> = [];

	public function new () {
		Horror.initialize(start);
	}

	function start() {
		var loader:BytesLoader = new BytesLoader("assets/rect.png");
		loader.loaded.add(onLoaded);
		loader.load();
	}

	function onLoaded(loader:BaseLoader) {
		_render = Horror.render;

		_vertexStructure = new VertexStructure();
		_vertexStructure.add("aVertexPosition", VertexData.FloatN(2));
		_vertexStructure.add("aTexCoord", VertexData.FloatN(2));
		_vertexStructure.add("aColorMult", VertexData.PackedColor);
		_vertexStructure.compile();

		_texture = new Texture();
		_texture.loadPngFromBytes(loader.getContent(ByteArray));

		_material= new Material();
		_material.shader = SimpleShader.create();
		_material.texture = _texture;

		Horror.input.onMouse.add(onMouse);

		_cameraMatrix.setTransform2D(0, 0, 1, 0);

		_mesh = new Mesh(_vertexStructure);
		_meshBuffer = new MeshBuffer();
		_meshBuffer.vertexStructure = _vertexStructure;

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

		_meshBuffer.begin();
		for(blob in _blobs) {
			blob.update(dt);
			blob.draw(_meshBuffer);
		}
		_meshBuffer.end();
		_meshBuffer.flush(_mesh);

		_render.setMatrix(_cameraMatrix);
		_render.drawMesh(_mesh, _material);

		_render.end();
	}

	function onMouse(e:MouseEvent) {
		if(e.type == MouseEventType.DOWN) {
			_material.texture = _material.texture == _texture ? null : _texture;
		}
	}
}