package horror.render;

import horror.memory.ByteArray;
import horror.render.RenderManager;

class Mesh {

	public var vertexStructure(default, null):VertexStructure;
	public var numTriangles(default, null):Int = 0;

	@:allow(horror.render.RenderManager)
	var _rawData:RawMesh;

	public function new(vertexStructure:VertexStructure) {
		this.vertexStructure = vertexStructure;
		_rawData = RenderManager.driver.createMesh(vertexStructure);
	}

	public function dispose():Void {
		if(_rawData != null) {
			RenderManager.driver.disposeMesh(_rawData);
			_rawData = null;
		}
	}

	function uploadVertices(data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderManager.driver.uploadVertices(_rawData, data, bytesLength, bytesOffset);
	}

	function uploadIndices(data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderManager.driver.uploadIndices(_rawData, data, bytesLength, bytesOffset);
	}
}
