package horror.renderex;

import horror.render.Matrix4;
import horror.render.Material;
import horror.render.Mesh;
import horror.render.VertexStructure;
import horror.render.RenderContext;

import horror.std.Horror;

class MeshBatcher {

	public var context(default, null):RenderContext;
	public var buffer(default, null):MeshBuffer;
	public var vertexStructure(default, null):VertexStructure;
	public var isStarted(default, null):Bool = false;

	var _maxIndex:Int = 0xFFFF - 1;
	var _meshes:Array<Mesh> = new Array<Mesh>();
	var _currentMeshIndex:Int;
	var _currentMesh:Mesh;
	var _currentMaterial:Material;
	var _currentVertexCount:Int;

	var _modelViewMatrix:Matrix4;

	public function new(vs:VertexStructure) {
		context = Horror.get(RenderContext);
		buffer = new MeshBuffer(vs.stride);
		buffer.setVertexStructure(vs);
		vertexStructure = vs;

		_meshes.push(allocMesh());
	}

	public function dispose():Void {
		if(isStarted) {
			end();
		}
		Horror.dispose(buffer);
		for(mesh in _meshes) {
			mesh.dispose();
		}
		_meshes = null;
		vertexStructure = null;
		context = null;
	}

	public function begin():Void {
		Horror.assert(isStarted == false);
		isStarted = true;

		_currentMeshIndex = 0;
		_currentMesh = _meshes[0];
		_currentMaterial = null;
		_currentVertexCount = 0;

		buffer.begin();
	}

	public function end():Void {
		Horror.assert(isStarted == true);

		renderBatch(false);
		if(buffer.isStarted) {
			buffer.end();
		}
		isStarted = false;
	}

	public function changeViewModelMatrix(matrix:Matrix4):Void {
		if(isStarted) {
			breakBatching(null);
		}

		// COPY OR DISTURBANCE? (outside modifications)
		_modelViewMatrix = matrix;
	}

	@:extern inline public function setState(material:Material, vertexCount:Int):Void {
		if(checkBatchStateChanged(material, vertexCount)) {
			breakBatching(material);
		}
		_currentVertexCount += vertexCount;
	}

	public function renderBatch(nextMeshRequired:Bool):Void {
		if(_currentVertexCount > 0) {
			renderCurrentBatch();
			if(nextMeshRequired) {
				if(++_currentMeshIndex == _meshes.length) {
					_meshes.push(allocMesh());
				}
				_currentMesh = _meshes[_currentMeshIndex];
				buffer.begin();
			}
		}
	}

	@:extern inline function breakBatching(nextMaterial:Material):Void {
		if(_currentMaterial != null) {
			renderBatch(true);
		}
		_currentMaterial = nextMaterial;
		_currentVertexCount = 0;
	}

	@:extern inline function allocMesh():Mesh {
		return new Mesh(vertexStructure);
	}

	@:extern inline function checkBatchStateChanged(material:Material, vertexCount:Int):Bool {
		return _currentMaterial != material || _currentVertexCount + vertexCount > _maxIndex;
	}

	@:extern inline function renderCurrentBatch():Void {
		buffer.end();
		buffer.flush(_currentMesh);

		context.setMatrix(_modelViewMatrix);
		context.drawMesh(_currentMesh, _currentMaterial);
	}
}
