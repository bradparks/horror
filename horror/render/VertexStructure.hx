package horror.render;

class VertexStructure {

	public var elements(default, null):Array<VertexElement> = [];
	public var stride(default, null):Int;

	public function new() {
	}

	public function add(name:String, data:VertexData) {
		elements.push(new VertexElement(name, data));
	}

	public function size(): Int {
		return elements.length;
	}

	public function getAt(index:Int):VertexElement {
		return elements[index];
	}

	public function compile():Void {
		var offset:Int = 0;
		for(i in 0...elements.length) {
			var vl:VertexElement = elements[i];
			vl.offset = offset;
			switch(vl.data) {
				case VertexData.FloatN(elements):
					offset += elements << 2;
				case VertexData.PackedColor:
					offset += 4;
			}
		}
		stride = offset;
	}
}
