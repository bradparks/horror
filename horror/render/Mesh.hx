package horror.render;

import horror.utils.IDisposable;
import horror.memory.ByteArray;
import horror.render.RenderManager;

class Mesh implements IDisposable {

	public var vertexStructure(default, null):VertexStructure;

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

	public function uploadVertices(data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderManager.driver.uploadVertices(_rawData, data, bytesLength, bytesOffset);
	}

	public function uploadIndices(data:ByteArrayData, bytesLength:Int = 0, bytesOffset:Int = 0):Void {
		RenderManager.driver.uploadIndices(_rawData, data, bytesLength, bytesOffset);
	}
}
