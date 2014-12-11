package;

@:access(RenderableNode)
@:access(SceneNode)
class TraversalBenchmark extends Benchmark  {

	public static var NODE_STACK:Array<SceneNode> = new Array<SceneNode>();
	public static var INSTANCE:TraversalBenchmark;
	public var rec_count:Array<Int> = [0, 0];
	public var stack_count:Array<Int> = [0, 0];

	var mcCount:Int = 30000;
	var quadCount:Int = 20;
	var visitCount:Int = 20;
	var graph:SceneNode;

	public function new() {
		super();

		INSTANCE = this;

		initGraph();
		for(i in 0...0xFFFF) {
			NODE_STACK.push(null);
		}


		add('recursive', runRec);
		add('recursive_2', runRec2);
		add('stack', runStack);
		//add('end', onEnd);
	}

	function onEnd() {
		//trace("" +rec_count[0] + " "  +rec_count[1] + " " +stack_count[0] + " "  +stack_count[1]);
	}

	function runRec():Void {
		graph.rec_visitChildren(0);
	}

	function runRec2():Void {
		graph.rec2_visitChildren(0, this);
	}

	function runStack():Void {
		graph.stack_visitChildren(0, this);
	}

	function initGraph():Void {
		graph = new SceneNode();
		for(i in 0...mcCount) {
			var mc = new SceneNode();
			for(j in 0...quadCount) {
				var quad = new RenderableNode();
				mc.addChild(quad);
				++visitCount;
			}
			graph.addChild(mc);
			++visitCount;
		}
	}
}

private class SceneNode {
	var _active:Bool = true;
	var _children:Array<SceneNode>;
	var _dirtyFlags:Int = 0;
	var _renderable:Bool = false;

	public function new(initChildren:Bool = true) {
		_children = initChildren ? (new Array<SceneNode>()) : null;
	}

	public function addChild(child:SceneNode):Void {
		_children.push(child);
	}

	function rec_visit():Void {
		TraversalBenchmark.INSTANCE.rec_count[0]++;
		var df = _dirtyFlags;
		_dirtyFlags = 0;
		rec_visitChildren(df);
	}

	inline function rec_visitChildren(parentDirtyFlags:Int):Void {
		var children:Array<SceneNode> = _children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child:SceneNode = children[i];
				if(child._active) {
					child._dirtyFlags |= parentDirtyFlags;
					child.rec_visit();
				}
				++i;
			}
		}
	}

	function rec2_visit(bm:TraversalBenchmark):Void {
		bm.rec_count[0]++;
		var df = _dirtyFlags;
		_dirtyFlags = 0;
		rec2_visitChildren(df, bm);
	}

	function rec2_visitChildren(dirtyFlags:Int, bm:TraversalBenchmark):Void {
		var children:Array<SceneNode> = _children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child:SceneNode = children[i];
				if(child._active) {
					child._dirtyFlags |= dirtyFlags;
					child.rec2_visit(bm);
				}
				++i;
			}
		}
	}

	function stack_visit(bm:TraversalBenchmark):Void {
		bm.stack_count[0]++;
	}


	function stack_visitChildren(dirtyFlags:Int, bm:TraversalBenchmark):Void {
		if(_children == null) {
			return;
		}

		var top:Int = 0;
		var stack:Array<SceneNode> = TraversalBenchmark.NODE_STACK;
		var i:Int = 0;
		var num:Int = 0;
		var children:Array<SceneNode>;
		var node:SceneNode;
		var child:SceneNode;

		children = _children;
		num = children.length;
		i = 0;
		while(i < num) {
			child = children[i];
			if(child._active) {
				//child._dirtyFlags |= dirtyFlags;
				stack[top] = child;
				++top;
			}
			++i;
		}

		while(top > 0) {
			--top;
			node = stack[top];
			dirtyFlags = node._dirtyFlags;
			node.stack_visit(bm);
			children = node._children;
			if(children != null) {
				num = children.length;
				i = 0;
				while(i < num) {
					child = children[i];
					if(child._active) {
						//child._dirtyFlags |= dirtyFlags;
						stack[top] = child;
						++top;
					}
					++i;
				}
			}
		}
	}

}

private class RenderableNode extends SceneNode {
	public function new() {
		super(false);
		_renderable = true;
	}

	override function rec_visit():Void {
		var bm = TraversalBenchmark.INSTANCE;
		bm.rec_count[0]++;
		bm.rec_count[1]++;
	}

	override function rec2_visit(bm:TraversalBenchmark):Void {
		bm.rec_count[0]++;
		bm.rec_count[1]++;
	}

	override function stack_visit(bm:TraversalBenchmark):Void {
		bm.stack_count[0]++;
		bm.stack_count[1]++;
	}
}