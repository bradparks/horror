package;

import horror.input.MouseEventType;
import horror.input.MouseEvent;
import horror.render.Texture;
import horror.loaders.BaseLoader;
import horror.loaders.BytesLoader;
import horror.render.Material;
import horror.Horror;

import horror.app.ScreenManager;
import horror.app.LoopManager;

import horror.memory.ByteArray;
import horror.memory.UnsafeBytesBuffer;

import horror.render.VertexData;
import horror.render.Mesh;
import horror.render.RenderManager;
import horror.render.Matrix3D;
import horror.render.VertexStructure;
import horror.render.Shader;

class Main {

	var _render:RenderManager;
	var _material:Material;
	var _projectionMatrix:Matrix3D;
	var _modelViewMatrix:Matrix3D;
	var _vertexStructure:VertexStructure;
	var _mesh:Mesh;
	var _indexBytes:UnsafeBytesBuffer;
	var _vertexBytes:UnsafeBytesBuffer;
	var _texture:Texture;

	var _time:Float = 0;
	var _segmentsCount:Int = 64;
	var _indexCount:Int = 0;
	var _indexSize:Int = 2;
	var _vertexCount:Int = 0;
	var _vertexSize:Int = 0;

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
		//_vertexStructure.add("aColorOffset", VertexData.PackedColor);
		_vertexStructure.compile();

		_texture = new Texture();
		_texture.loadPngFromBytes(loader.getContent(ByteArray));

		_material= new Material();
		_material.shader = SimpleShader.create(_vertexStructure);
		_material.texture = _texture;

		Horror.input.onMouse.add(onMouse);

		init();
	}

	function onMouse(e:MouseEvent) {
		if(e.type == MouseEventType.DOWN) {
			if(_material.texture == _texture) {
				_material.texture = _render.blankTexture;
			}
			else {
				_material.texture = _texture;
			}
		}
	}

	function init() {
		_modelViewMatrix = Matrix3D.create2D(0, 0, 1, 0);

		_indexCount = _segmentsCount*3;
		_indexSize = 2;
		_vertexCount = (1 + _segmentsCount);
		_vertexSize = _vertexStructure.stride;

		_indexBytes = UnsafeBytesBuffer.fromSize(_indexCount * _indexSize);
		_vertexBytes = UnsafeBytesBuffer.fromSize(_vertexCount * _vertexSize);

		_mesh = new Mesh(_vertexStructure);

		Horror.loop.updated.add(update);
		Horror.screen.resized.add(resize);
		resize(Horror.screen);
	}

	function resize(screen:ScreenManager) {
		_projectionMatrix = Matrix3D.createOrtho(0, screen.width, screen.height, 0, 1000, -1000);
		_render.resize(screen.width, screen.height);
	}

	function update(loop:LoopManager) {
		var dt = loop.deltaTime;
		_time += dt;

		var c = 0.1 + 0.1*Math.sin(_time);
		_render.clear(c, c, 0.3);
		_render.begin();

		drawBlob(_time);

		_mesh.uploadVertices(_vertexBytes.data, _vertexCount * _vertexSize);
		_mesh.uploadIndices(_indexBytes.data, _indexCount * _indexSize);

		_render.setMaterial(_material);
		_render.setMatrix(_projectionMatrix, _modelViewMatrix);
		_render.setVertexBuffer(_mesh);
		_render.drawIndexedTriangles(_mesh, _indexCount);

		_render.end();
	}

	function drawBlob(t:Float) {

		var unsafeBytes = _indexBytes.getUnsafeBytes();
		var bytesPosition = 0;
		for(i in 0..._segmentsCount) {
			unsafeBytes.setUInt16_aligned(bytesPosition, 0);
			unsafeBytes.setUInt16_aligned(bytesPosition + 2, i+1);
			unsafeBytes.setUInt16_aligned(bytesPosition + 4, (i + 1) == _segmentsCount ? 1 : (i+2));
			bytesPosition += 6;
		}

		var centerX = Horror.screen.width / 2;
		var centerY = Horror.screen.height / 2;

		unsafeBytes = _vertexBytes.getUnsafeBytes();
		bytesPosition = 0;
		unsafeBytes.setFloat32_aligned(bytesPosition, centerX);
		unsafeBytes.setFloat32_aligned(bytesPosition + 4, centerY);
		unsafeBytes.setFloat32_aligned(bytesPosition + 8, 0.5);
		unsafeBytes.setFloat32_aligned(bytesPosition + 12, 0.5);
		unsafeBytes.setUInt32_aligned(bytesPosition + 16, 0xff00ffff);//abgr
		bytesPosition += 20;
		for(i in 0..._segmentsCount) {
			var angle = Math.PI*2.0*(i/_segmentsCount);
			var r = 100.0 + 6.0 * Math.sin(-t*4 + angle*5) - 10.0 * Math.sin(5*t + 2*angle);
			unsafeBytes.setFloat32_aligned(bytesPosition, centerX + r*Math.cos(angle));
			unsafeBytes.setFloat32_aligned(bytesPosition + 4, centerY + r*Math.sin(angle));
			unsafeBytes.setFloat32_aligned(bytesPosition + 8, 0.0);
			unsafeBytes.setFloat32_aligned(bytesPosition + 12, 0.0);
			unsafeBytes.setUInt32_aligned(bytesPosition + 16, 0xff00ff00);
			bytesPosition += 20;
		}
	}
}