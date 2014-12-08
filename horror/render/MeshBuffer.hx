package horror.render;

import horror.memory.FastIO;
import horror.memory.FastMemory;
import horror.debug.Debug;
import horror.render.Mesh;


// init: set vertex structure
// 1. 'begin' the buffer
// 2. fill your data:
//   use generic way: unsafeBytes + grow
//   or use the fastest way: use writeMethods + push
// 3. 'end' and 'flush' to the mesh

@:access(horror.render.Mesh)
class MeshBuffer {

	public var io(default, null):FastIO;

	public var vertexBytesPosition(default, null):Int;
	public var indexBytesPosition(default, null):Int;

	public var nextVertex(default, null):Int;
	public var nextIndex(default, null):Int;

	public var numTriangles(get, never):Int;
	public var isEmpty(get, never):Bool;

	public var vertexStructure(default, set):VertexStructure;
	public var stride(default, null):Int;

	public var isStarted(default, null):Bool = false;

	var _mem:FastMemory;
	var _vertexBytesTotal:Int;
	var _indexBytesTotal:Int;

	public function new(maxVertexSize:Int = 24) {
		Debug.assert(maxVertexSize > 0 && maxVertexSize % 4 == 0);

		_vertexBytesTotal = 0xFFFF * maxVertexSize;
		_indexBytesTotal = 0x100000 * 2;

		_mem = FastMemory.fromSize(_vertexBytesTotal + _indexBytesTotal);
	}

	function set_vertexStructure(value:VertexStructure):VertexStructure {
		Debug.assert(value != null && value.stride > 0);

		vertexStructure = value;
		stride = value.stride;
		return value;
	}

	public function begin():Void {
		Debug.assert(isStarted == false && vertexStructure != null && stride > 0);

		io = _mem.lock();
		isStarted = true;

		nextVertex = 0;
		nextIndex = 0;
		vertexBytesPosition = getVertexStartPosition();
		indexBytesPosition = getIndexStartPosition();
	}

	inline public function end():Void {
		Debug.assert(isStarted == true);

		isStarted = false;
		_mem.unlock();
	}

	@:extern public inline function grow(verticesTotal:Int, indicesTotal:Int):Void {
		nextVertex += verticesTotal;
		nextIndex += indicesTotal;
		vertexBytesPosition += verticesTotal * stride;
		indexBytesPosition += indicesTotal << 1;
	}

	@:extern public inline function growFast(verticesTotal:Int, indicesTotal:Int, vertexBytesWritten:Int, indexBytesWritten:Int):Void {
		nextVertex += verticesTotal;
		nextIndex += indicesTotal;
		vertexBytesPosition += vertexBytesWritten;
		indexBytesPosition += indexBytesWritten;
	}

	public function flush(mesh:Mesh):Void {
		Debug.assert(isStarted == false && mesh.vertexStructure.stride == stride);

		var bytesData = _mem.data;
		var indexStartPosition = getIndexStartPosition();
		var vertexStartPosition = getVertexStartPosition();

		mesh.uploadVertices(bytesData, vertexBytesPosition - vertexStartPosition, vertexStartPosition);
		mesh.uploadIndices(bytesData, indexBytesPosition - indexStartPosition, indexStartPosition);
	}

	@:extern inline function get_isEmpty():Bool {
		return nextIndex == 0;
	}

	@:extern inline function get_numTriangles():Int {
		return Std.int(nextIndex / 3);
	}

	@:extern inline function getIndexStartPosition():Int {
		return _vertexBytesTotal;
	}

	@:extern inline function getVertexStartPosition():Int {
		return 0;
	}

	@:extern public inline function writeTriangle(index1:Int, index2:Int, index3:Int):Void {
		var p:Int = indexBytesPosition;
		var baseVertex:Int = nextVertex;
		io.setUInt16_aligned(p,     baseVertex+index1);
		io.setUInt16_aligned(p + 2, baseVertex+index2);
		io.setUInt16_aligned(p + 4, baseVertex+index3);
		indexBytesPosition += 6;
	}

	@:extern public inline function writeFloat2(x:Float, y:Float):Void {
		var p:Int = vertexBytesPosition;
		io.setFloat32_aligned(p,     x);
		io.setFloat32_aligned(p + 4, y);
		vertexBytesPosition += 8;
	}

	@:extern public inline function writeFloat4(x:Float, y:Float, z:Float, w:Float):Void {
		var p:Int = vertexBytesPosition;
		io.setFloat32_aligned(p,     x);
		io.setFloat32_aligned(p + 4, y);
		io.setFloat32_aligned(p + 8, z);
		io.setFloat32_aligned(p + 12, w);
		vertexBytesPosition += 16;
	}

	@:extern public inline function writePackedColor(colorABGR:Int):Void {
		var p:Int = vertexBytesPosition;
		io.setUInt32_aligned(p, colorABGR);
		vertexBytesPosition += 4;
	}

	@:extern public inline function push(verticesTotal:Int, indicesTotal:Int):Void {
		nextVertex += verticesTotal;
		nextIndex += indicesTotal;
	}
}
