package horror.render;

import horror.memory.UnsafeBytes;
import horror.debug.Debug;
import horror.render.Mesh;
import horror.memory.UnsafeBytesBuffer;

class MeshBuffer {

	public var unsafeBytes(default, null):UnsafeBytes;

	public var vertexBytesPosition(default, null):Int;
	public var indexBytesPosition(default, null):Int;

	public var nextVertex(default, null):Int;
	public var nextIndex(default, null):Int;

	var _bytes:UnsafeBytesBuffer;
	var _vertexBytesTotal:Int;
	var _indexBytesTotal:Int;

	var _currentMesh:Mesh;
	var _currentStride:Int;

	public function new(maxVertexSize:Int = 24) {
		Debug.assert(maxVertexSize > 0 && maxVertexSize % 4 == 0);

		_vertexBytesTotal = 0xFFFF * maxVertexSize;
		_indexBytesTotal = 0x100000 * 2;

		_bytes = UnsafeBytesBuffer.fromSize(_vertexBytesTotal + _indexBytesTotal);
	}

	public function begin(mesh:Mesh):Void {
		Debug.assert(_currentMesh == null && mesh != null);

		_currentMesh = mesh;
		_currentStride = mesh.vertexStructure.stride;
		unsafeBytes = _bytes.getUnsafeBytes();
		resetPositions();
	}

	public inline function grow(verticesTotal:Int, indicesTotal:Int):Void {
		nextVertex += verticesTotal;
		nextIndex += indicesTotal;
		vertexBytesPosition += verticesTotal*_currentStride;
		indexBytesPosition += indicesTotal << 1;
	}

	public function end():Void {
		Debug.assert(_currentMesh != null);

		var mesh = _currentMesh;
		var bytesData = _bytes.data;
		var indexStartPosition = getIndexStartPosition();
		var vertexStartPosition = getVertexStartPosition();

		mesh.uploadVertices(bytesData, vertexBytesPosition - vertexStartPosition, vertexStartPosition);
		mesh.uploadIndices(bytesData, indexBytesPosition - indexStartPosition, indexStartPosition);

		//unsafeBytes = null;
		_currentMesh = null;
		_currentStride = 0;
	}

	inline function getIndexStartPosition():Int {
		return _vertexBytesTotal;
	}

	inline function getVertexStartPosition():Int {
		return 0;
	}

	function resetPositions():Void {
		nextVertex = 0;
		nextIndex = 0;
		vertexBytesPosition = getVertexStartPosition();
		indexBytesPosition = getIndexStartPosition();
	}
}
