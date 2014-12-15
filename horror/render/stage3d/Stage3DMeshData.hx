package horror.render.stage3d;

import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;

import horror.render.VertexStructure;

class Stage3DMeshData {
	public var vertexStructure:VertexStructure;

	public var vertexBuffer:VertexBuffer3D;
	public var vertexBytesAllocated:Int;
	public var vertexBytesLength:Int;

	public var indexBuffer:IndexBuffer3D;
	public var indexBytesAllocated:Int;
	public var indexBytesLength:Int;

	public function new(vertexStructure:VertexStructure) {
		this.vertexStructure = vertexStructure;
	}

	function reallocVertexBuffer(context:Context3D, size:Int):Void {
		if(vertexBuffer != null) {
			vertexBuffer.dispose();
			vertexBuffer = null;
			vertexBytesAllocated = 0;
			vertexBytesLength = 0;
		}
		if(size > 0) {
			var stride = vertexStructure.stride;
			var numVertices = Std.int(size / stride);
			var data32PerVertex = stride >> 2;
			if(Stage3DDriver.OLD_API) {
				vertexBuffer = context.createVertexBuffer(numVertices, data32PerVertex);
			}
			else {
				var f = untyped context.createVertexBuffer;
				vertexBuffer = untyped f(numVertices, data32PerVertex, "dynamicDraw");
			}
			vertexBytesAllocated = size;
		}
	}

	public inline function resizeVertexBuffer(context:Context3D, size:Int):Void {
		if(size > vertexBytesAllocated) {
			reallocVertexBuffer(context, size);
		}
		vertexBytesLength = size;
	}

	function reallocIndexBuffer(context:Context3D, size:Int):Void {
		if(indexBuffer != null) {
			indexBuffer.dispose();
			indexBuffer = null;
			indexBytesAllocated = 0;
			indexBytesLength = 0;
		}
		if(size > 0) {
			var numIndices = size >> 1;
			if(Stage3DDriver.OLD_API) {
				indexBuffer = context.createIndexBuffer(numIndices);
			}
			else {
				var f = untyped context.createIndexBuffer;
				indexBuffer = untyped f(numIndices, "dynamicDraw");
			}
			indexBytesAllocated = size;
		}
	}

	public inline function resizeIndexBuffer(context:Context3D, size:Int):Void {
		if(size > indexBytesAllocated) {
			reallocIndexBuffer(context, size);
		}
		indexBytesLength = size;
	}

	public inline function dispose() {
		reallocIndexBuffer(null, 0);
		reallocVertexBuffer(null, 0);
	}
}