package horror.render;

import horror.memory.ByteArray;
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

	function uploadVertices(data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderContext.__driver.uploadVertices(__data, data, bytesLength, bytesOffset);
	}

	function uploadIndices(data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderContext.__driver.uploadIndices(__data, data, bytesLength, bytesOffset);
	}
}
