package horror.render;

import horror.debug.Debug;
import horror.Horror;
import horror.utils.DisposeUtil;

class MeshBatcher {

	public var buffer(default, null):MeshBuffer;

	var _render:RenderManager;
	var _vertexStructure:VertexStructure;
	var _maxIndex:Int = 0xFFFF - 1;

	var _isStarted:Bool = false;
	var _meshes:Array<Mesh> = new Array<Mesh>();
	var _currentMeshIndex:Int;
	var _currentMesh:Mesh;
	var _currentMaterial:Material;
	var _currentVertexCount:Int;

	var _modelViewMatrix:Matrix3D = new Matrix3D();

	public function new(vs:VertexStructure) {
		_render = Horror.render;
		buffer = new MeshBuffer(vs.stride);
		buffer.setVertexStructure(vs);
		_vertexStructure = vs;
		_meshes.push(allocMesh());
	}

	public function dispose():Void {
		if(_isStarted) {
			end();
		}
		DisposeUtil.dispose(buffer);
		for(mesh in _meshes) {
			mesh.dispose();
		}
		_meshes = null;
		_vertexStructure = null;
		_render = null;
	}

	public function begin():Void {
		Debug.assert(_isStarted == false);

		_isStarted = true;
		_currentMeshIndex = 0;
		_currentMesh = _meshes[0];
		_currentMaterial = null;
		_currentVertexCount = 0;

		buffer.begin();
	}

	public function end():Void {
		Debug.assert(_isStarted == true);

		renderBatch(false);
		if(buffer.isStarted) {
			buffer.end();
		}
		_isStarted = false;
	}

	public function changeViewModelMatrix(matrix:Matrix3D):Void {
		if(_isStarted) {
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
		return new Mesh(_vertexStructure);
	}

	@:extern inline function checkBatchStateChanged(material:Material, vertexCount:Int):Bool {
		return _currentMaterial != material || _currentVertexCount + vertexCount > _maxIndex;
	}

	@:extern inline function renderCurrentBatch():Void {
		buffer.end();
		buffer.flush(_currentMesh);

		_render.setMatrix(_modelViewMatrix);
		_render.drawMesh(_currentMesh, _currentMaterial);
	}
}
