package;

#if flash
private typedef PArray<T> = flash.Vector<T>;
#else
private typedef PArray<T> = Array<T>;
#end

class TraversalBenchmark extends Benchmark  {

	// traversal results, to check we traverses all nodes by all modes
	public var rec_count:Array<Int> = [0, 0];
	public var rec_ll_count:Array<Int> = [0, 0];
	public var stack_ll_count:Array<Int> = [0, 0];

	var mcCount:Int = 30000;
	var quadCount:Int = 20;
	var graph:SceneNode;

	public function new() {
		super();

		initGraph();

		add('stack_ll', runStackLL);
		add('recursive_ll', runRecLL);
		add('recursive', runRec);
	}

	override function onEnd() {
		// Trace traversal results if have error;
		var a1 = rec_count[0]; var a2 = rec_ll_count[0]; var a3 = stack_ll_count[0];
		var b1 = rec_count[1]; var b2 = rec_ll_count[1]; var b3 = stack_ll_count[1];
		if(a1 != a2 || a2 != a3 || b1 != b2 || b2 != b3) {
			trace("ERROR: ");
			trace("rec_arr: " + rec_count[0] + " " + rec_count[1]);
			trace("rec_ll: " + rec_ll_count[0] + " "  + rec_ll_count[1]);
			trace("stack_ll: " + stack_ll_count[0] + " " + stack_ll_count[1]);
		}
		else {
			trace("SUCCESS: " + (a1 + b1) + " nodes total processed");
		}
	}

	function runRec():Void {
		graph.rec_visitChildren(0, this);
	}

	function runRecLL():Void {
		graph.rec_ll_visitChildren(0, this);
	}

	function runStackLL():Void {
		graph.stack_ll_visitChildren(0, this);
	}

	function initGraph():Void {
		graph = new SceneNode();
		for(i in 0...mcCount) {
			var mc = new SceneNode();
			for(j in 0...quadCount) {
				var quad = new RenderableNode();
				mc.addChild(quad);
			}
			graph.addChild(mc);
		}
	}
}

private class SceneNode {
	var _active:Bool = true;
	var _children:PArray<SceneNode>;
	var _dirtyFlags:Int = 0;
	var _renderable:Bool = false;

	// double linked list
	var _nextSibling:SceneNode;
	var _prevSibling:SceneNode;
	var _firstChild:SceneNode;
	var _lastChild:SceneNode;

	// for non-recursive traversal
	var _next:SceneNode;
	var _prev:SceneNode;

	public function new(initChildren:Bool = true) {
		_children = initChildren ? (new PArray<SceneNode>()) : null;
	}

	public function addChild(child:SceneNode):Void {
		_children.push(child);

		// linked lists
		if(_firstChild == null) {
			// for non-recursive
			child.getHead().linkNext(_next);
			linkNext(child);

			// dll
			_firstChild = _lastChild = child;
		}
		else {
			// for non-recursive
			var oldHead = getHead();
			child.getHead().linkNext(oldHead._next);
			oldHead.linkNext(child);

			// dll
			_lastChild._nextSibling = child;
			child._prevSibling = _lastChild;
			_lastChild = child;
		}
	}

	/*** utilities for global linked-list initialization ***/
	function getHead () : SceneNode {
		if (_nextSibling != null) {
			return _nextSibling._prev;
		}
		else if (_firstChild == null) {
			return this;
		}
		return _lastChild.getHead();
	}

	inline function linkNext (node:SceneNode) : Void {
		_next = node;
		if (node != null) {
			node._prev = this;
		}
	}

	/*** RECURSIVE ARRAYS ***/
	public function rec_visit(bm:TraversalBenchmark):Void {
		bm.rec_count[0]++;
		//var df = _dirtyFlags;
		//_dirtyFlags = 0;

		// INLINE by hands (haxe can't inline this even with @:extern)
		// rec_visitChildren(0, bm);
		var children:PArray<SceneNode> = _children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child:SceneNode = children[i];
				if(child._active) {
					//child._dirtyFlags |= dirtyFlags;
					child.rec_visit(bm);
				}
				++i;
			}
		}
	}

	public function rec_visitChildren(dirtyFlags:Int, bm:TraversalBenchmark):Void {
		var children:PArray<SceneNode> = _children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child:SceneNode = children[i];
				if(child._active) {
					//child._dirtyFlags |= dirtyFlags;
					child.rec_visit(bm);
				}
				++i;
			}
		}
	}

	/*** RECURSIVE LINKED-LISTS ***/
	public function rec_ll_visit(bm:TraversalBenchmark):Void {
		bm.rec_ll_count[0]++;
		//var df = _dirtyFlags;
		//_dirtyFlags = 0;

		// INLINE by hands (haxe can't inline this even with @:extern)
		// rec_ll_visitChildren(0, bm);
		var child = _firstChild;
		while(child != null) {
			if(child._active) {
				//child._dirtyFlags |= dirtyFlags;
				child.rec_ll_visit(bm);
			}
			child = child._nextSibling;
		}
	}

	public function rec_ll_visitChildren(dirtyFlags:Int, bm:TraversalBenchmark):Void {
		var child = _firstChild;
		while(child != null) {
			if(child._active) {
				//child._dirtyFlags |= dirtyFlags;
				child.rec_ll_visit(bm);
			}
			child = child._nextSibling;
		}
	}

	/*** TRAVERSAL WITH LINKED-LISTS AND NON-RECURSIVE **/
	public function stack_ll_visit(bm:TraversalBenchmark):Void {
		bm.stack_ll_count[0]++;
	}

	public function stack_ll_validateParent(bm:TraversalBenchmark):Void {

	}

	public function stack_ll_visitChildren(dirtyFlags:Int, bm:TraversalBenchmark):Void {
		var node = _next;
		while(node != null) {
			if(node._active) {
				// NOT CORRECTLY NOW, we lose ability to propaganate right flags in parent-children dependency
				// this logic is must be out and will be additional overhead, one additional non-deterministic call
				node.stack_ll_validateParent(bm);
				//node._dirtyFlags |= dirtyFlags;
				node.stack_ll_visit(bm);
			}
			node = node._next;
		}
	}

	/*** TRAVERSAL WITH ARRAYS AND NON-RECURSIVE ***/
	// very slow in all test and finally EXCLUDED
	/*
	public function stack_visit(bm:TraversalBenchmark):Void {
		//bm.stack_count[0]++;
	}

	// use pre-allocated nodes-array for implementing depth-first traversal in non-recursive way
	static var NODE_STACK:PArray<SceneNode> = _initNodeStack();

	static function _initNodeStack():PArray<SceneNode> {
		var arr = new PArray<SceneNode>();
		for(i in 0...0xFFFF) {
			arr.push(null);
		}
		return arr;
	}

	public function stack_visitChildren(dirtyFlags:Int, bm:TraversalBenchmark):Void {
		if(_children == null) {
			return;
		}

		var top:Int = 0;
		var stack:PArray<SceneNode> = NODE_STACK;
		var i:Int = 0;
		var num:Int = 0;
		var children:PArray<SceneNode>;
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
			//dirtyFlags = node._dirtyFlags;
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
	}*/
}

private class RenderableNode extends SceneNode {
	public function new() {
		super(false);
		_renderable = true;
	}

	public override function rec_visit(bm:TraversalBenchmark):Void {
		// and expensive render logic
		bm.rec_count[0]++;
		bm.rec_count[1]++;
	}

	public override function rec_ll_visit(bm:TraversalBenchmark):Void {
		// and expensive render logic
		bm.rec_ll_count[0]++;
		bm.rec_ll_count[1]++;
	}

	public override function stack_ll_visit(bm:TraversalBenchmark):Void {
		// and expensive render logic
		bm.stack_ll_count[0]++;
		bm.stack_ll_count[1]++;
	}

	/*public override function stack_visit(bm:TraversalBenchmark):Void {
		// and expensive render logic
		bm.stack_count[0]++;
		bm.stack_count[1]++;
	}*/
}