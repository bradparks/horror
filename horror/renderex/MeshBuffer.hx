package horror.renderex;

import horror.render.VertexStructure;
import horror.render.Color32;
import horror.render.Mesh;

import horror.memory.FastIO;
import horror.memory.FastMemory;

import horror.std.Horror;

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

	public var stride(default, null):Int;

	public var isStarted(default, null):Bool = false;

	var _mem:FastMemory;
	var _vertexBytesTotal:Int;
	var _indexBytesTotal:Int;

	public function new(maxVertexSize:Int = 24, maxVertices:Int = 0xFFFF, maxIndices:Int = 0x100000) {
		Horror.assert(maxVertexSize > 0 && maxVertexSize % 4 == 0);
		Horror.assert(maxVertices <= 0xFFFF && maxVertices > 0);
		Horror.assert(maxIndices <= 0x100000 && maxIndices > 0);

		_vertexBytesTotal = maxVertices * maxVertexSize;
		_indexBytesTotal = maxIndices << 1;

		_mem = FastMemory.fromSize(_vertexBytesTotal + _indexBytesTotal);
	}

	public function dispose():Void {
		Horror.assert(_mem != null);

		Horror.dispose(_mem, true);
		io = FastIO.NULL;
	}

	public function begin():Void {
		Horror.assert(isStarted == false);

		io = _mem.lock();
		isStarted = true;

		nextVertex = 0;
		nextIndex = 0;
		vertexBytesPosition = getVertexStartPosition();
		indexBytesPosition = getIndexStartPosition();
	}

	inline public function end():Void {
		Horror.assert(isStarted == true);

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
		Horror.assert(isStarted == false && mesh.vertexStructure.stride == stride);

		var bytesData = _mem.data;
		var indexStartPosition = getIndexStartPosition();
		var vertexStartPosition = getVertexStartPosition();

		mesh.uploadVertices(bytesData, vertexBytesPosition - vertexStartPosition, vertexStartPosition);
		mesh.uploadIndices(bytesData, indexBytesPosition - indexStartPosition, indexStartPosition);
		mesh.numTriangles = numTriangles;
	}

	@:extern public inline function writeTriangle(index1:Int, index2:Int, index3:Int):Void {
		var p:Int = indexBytesPosition;
		var baseVertex:Int = nextVertex;
		io.setUInt16_aligned(p,     baseVertex+index1);
		io.setUInt16_aligned(p + 2, baseVertex+index2);
		io.setUInt16_aligned(p + 4, baseVertex+index3);
		indexBytesPosition = p + 6;
	}

	@:extern public inline function writeFloat2(x:Float, y:Float):Void {
		var p:Int = vertexBytesPosition;
		io.setFloat32_aligned(p,     x);
		io.setFloat32_aligned(p + 4, y);
		vertexBytesPosition = p + 8;
	}

	@:extern public inline function writeFloat4(x:Float, y:Float, z:Float, w:Float):Void {
		var p:Int = vertexBytesPosition;
		io.setFloat32_aligned(p,     x);
		io.setFloat32_aligned(p + 4, y);
		io.setFloat32_aligned(p + 8, z);
		io.setFloat32_aligned(p + 12, w);
		vertexBytesPosition = p + 16;
	}

	@:extern public inline function writeColor(color:Color32):Void {
		var p:Int = vertexBytesPosition;
		io.setUInt32_aligned(p, color);
		vertexBytesPosition = p + 4;
	}

	@:extern public inline function push(verticesTotal:Int, indicesTotal:Int):Void {
		nextVertex += verticesTotal;
		nextIndex += indicesTotal;
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

	public function setVertexStructure(vs:VertexStructure):Void {
		Horror.assert(vs != null && vs.stride > 0);
		stride = vs.stride;
	}
}
