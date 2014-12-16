package horror.render;

import haxe.io.BytesData;

import horror.render.RenderContext;

class Mesh {

	public var vertexStructure(default, null):VertexStructure;
	public var numTriangles(default, null):Int = 0;

	var __data:MeshData;

	public function new(vertexStructure:VertexStructure) {
		this.vertexStructure = vertexStructure;
		__data = RenderContext.__driver.createMesh(vertexStructure);
	}

	public function dispose():Void {
		if(__data != null) {
			RenderContext.__driver.disposeMesh(__data);
			__data = null;
		}
	}

	public function uploadVertices(bytesData:BytesData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderContext.__driver.uploadVertices(__data, bytesData, bytesLength, bytesOffset);
	}

	public function uploadIndices(bytesData:BytesData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderContext.__driver.uploadIndices(__data, bytesData, bytesLength, bytesOffset);
	}
}
