package;

#if cpp
using cpp.NativeArray;
#end

private class Node {
	public var value:Int = 0;
	public var value2:Int = 0;
	public function new() {}
}

class HxcppArrayBenchmark extends Benchmark  {

	public var array:Array<Node> = new Array<Node>();
	public var int_array:Array<Int> = new Array<Int>();

	public function new() {
		super();

		var count = 10000;
		for(i in 0...count) {
			array.push(new Node());
			int_array.push(10);
		}

		add('Node-array read', runNodeArray);
		add('Node-array read unsafe', runNodeArray_Fast);
		add('Int-array read', runIntArray);
		add('Int-array read unsafe', runIntArray_Fast);
	}


	public function runNodeArray():Void {
		var i:Int = 0;
		var len:Int = array.length;
		while(i < len) {
			var node = array[i];
			node.value2 = node.value;
			++i;
		}
	}

	public function runNodeArray_Fast():Void {
		var i:Int = 0;
		var len:Int = array.length;
		while(i < len) {
			#if cpp
			var node:Node = untyped array.__unsafe_get(i);
			#else
			var node = array[i];
			#end
			node.value2 = node.value;
			++i;
		}
	}

	public function runIntArray():Void {
		var i:Int = 0;
		var sum:Int = 0;
		var len:Int = int_array.length;

		while(i < len) {
			var v = int_array[i];
			sum += v;
			++i;
		}
	}

	public function runIntArray_Fast():Void {
		var i:Int = 0;
		var len:Int = array.length;
		var sum:Int = 0;

		while(i < len) {
			#if cpp
			var v = untyped int_array.__unsafe_get(i);
			#else
			var v = int_array[i];
			#end
			sum += v;
			++i;
		}
	}
}