package;

import haxe.Timer;

class Benchmark {

	private var _tests:Array<BenchmarkTest> = [];
	private var _iterations:Int;

	public function new(iterations:Int = 10) {
		this._iterations = iterations;
	}

	private function add(name:String, func:Void->Void):Void {
		_tests.push(new BenchmarkTest(name, func));
	}

	public function run():Void {
		trace('[Benchmark] -----INFO-----');
		for(test in _tests) {
			var time:Float = Timer.stamp();
			for(i in 0..._iterations) {
				test.run();
			}
			time = (Timer.stamp() - time)*1000;
			trace('[Benchmark] ${test.name} : ${time} ms');

		}
		//trace('[Benchmark] --------------');
	}

}

class BenchmarkTest {
	public var name:String;
	public var run: Void->Void;

	public function new(name:String, func:Void->Void ) {
		this.name = name;
		this.run = func;
	}
}
