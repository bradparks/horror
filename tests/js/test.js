(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Benchmark = function(iterations) {
	if(iterations == null) iterations = 10;
	this._tests = [];
	this._iterations = iterations;
};
Benchmark.prototype = {
	add: function(name,func) {
		this._tests.push(new BenchmarkTest(name,func));
	}
	,run: function() {
		console.log("[Benchmark] -----INFO-----");
		var _g = 0;
		var _g1 = this._tests;
		while(_g < _g1.length) {
			var test = _g1[_g];
			++_g;
			var time = haxe.Timer.stamp();
			var _g3 = 0;
			var _g2 = this._iterations;
			while(_g3 < _g2) {
				var i = _g3++;
				test.run();
			}
			time = (haxe.Timer.stamp() - time) * 1000;
			console.log("[Benchmark] " + test.name + " : " + time + " ms");
		}
		this.onEnd();
	}
	,onEnd: function() {
	}
};
var BenchmarkTest = function(name,func) {
	this.name = name;
	this.run = func;
};
var Main = function() { };
Main.main = function() {
	var b = new TraversalBenchmark();
	b.run();
	b.run();
	b.run();
};
var TraversalBenchmark = function() {
	this.quadCount = 20;
	this.mcCount = 30000;
	this.stack_ll_count = [0,0];
	this.stack_count = [0,0];
	this.rec_ll_count = [0,0];
	this.rec_count = [0,0];
	Benchmark.call(this);
	this.initGraph();
	this.add("stack",$bind(this,this.runStack));
	this.add("stack_ll",$bind(this,this.runStackLL));
	this.add("recursive",$bind(this,this.runRec));
	this.add("recursive_ll",$bind(this,this.runRecLL));
};
TraversalBenchmark.__super__ = Benchmark;
TraversalBenchmark.prototype = $extend(Benchmark.prototype,{
	onEnd: function() {
	}
	,runRec: function() {
		this.graph.rec_visitChildren(0,this);
	}
	,runRecLL: function() {
		this.graph.rec_ll_visitChildren(0,this);
	}
	,runStack: function() {
		this.graph.stack_visitChildren(0,this);
	}
	,runStackLL: function() {
		this.graph.stack_ll_visitChildren(0,this);
	}
	,initGraph: function() {
		this.graph = new _TraversalBenchmark.SceneNode();
		var _g1 = 0;
		var _g = this.mcCount;
		while(_g1 < _g) {
			var i = _g1++;
			var mc = new _TraversalBenchmark.SceneNode();
			var _g3 = 0;
			var _g2 = this.quadCount;
			while(_g3 < _g2) {
				var j = _g3++;
				var quad = new _TraversalBenchmark.RenderableNode();
				mc.addChild(quad);
			}
			this.graph.addChild(mc);
		}
	}
});
var _TraversalBenchmark = {};
_TraversalBenchmark.SceneNode = function(initChildren) {
	if(initChildren == null) initChildren = true;
	this._renderable = false;
	this._dirtyFlags = 0;
	this._active = true;
	if(initChildren) this._children = new Array(); else this._children = null;
};
_TraversalBenchmark.SceneNode._initNodeStack = function() {
	var arr = new Array();
	var _g = 0;
	while(_g < 65535) {
		var i = _g++;
		arr.push(null);
	}
	return arr;
};
_TraversalBenchmark.SceneNode.prototype = {
	addChild: function(child) {
		this._children.push(child);
		if(this._firstChild == null) {
			child.getHead().linkNext(this._next);
			this._next = child;
			if(child != null) child._prev = this;
			this._firstChild = this._lastChild = child;
		} else {
			var oldHead = this.getHead();
			child.getHead().linkNext(oldHead._next);
			oldHead._next = child;
			if(child != null) child._prev = oldHead;
			this._lastChild._nextSibling = child;
			child._prevSibling = this._lastChild;
			this._lastChild = child;
		}
	}
	,getHead: function() {
		if(this._nextSibling != null) return this._nextSibling._prev; else if(this._firstChild == null) return this;
		return this._lastChild.getHead();
	}
	,linkNext: function(node) {
		this._next = node;
		if(node != null) node._prev = this;
	}
	,rec_visit: function(bm) {
		this.rec_visitChildren(0,bm);
	}
	,rec_visitChildren: function(dirtyFlags,bm) {
		var children = this._children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child = children[i];
				if(child._active) child.rec_visit(bm);
				++i;
			}
		}
	}
	,rec_ll_visit: function(bm) {
		this.rec_ll_visitChildren(0,bm);
	}
	,rec_ll_visitChildren: function(dirtyFlags,bm) {
		var child = this._firstChild;
		while(child != null) {
			if(child._active) child.rec_ll_visit(bm);
			child = child._nextSibling;
		}
	}
	,stack_visit: function(bm) {
	}
	,stack_visitChildren: function(dirtyFlags,bm) {
		if(this._children == null) return;
		var top = 0;
		var stack = _TraversalBenchmark.SceneNode.NODE_STACK;
		var i = 0;
		var num = 0;
		var children;
		var node;
		var child;
		children = this._children;
		num = children.length;
		i = 0;
		while(i < num) {
			child = children[i];
			if(child._active) {
				stack[top] = child;
				++top;
			}
			++i;
		}
		while(top > 0) {
			--top;
			node = stack[top];
			node.stack_visit(bm);
			children = node._children;
			if(children != null) {
				num = children.length;
				i = 0;
				while(i < num) {
					child = children[i];
					if(child._active) {
						stack[top] = child;
						++top;
					}
					++i;
				}
			}
		}
	}
	,stack_ll_visit: function(bm) {
	}
	,stack_ll_visitChildren: function(dirtyFlags,bm) {
		var node = this._next;
		while(node != null) {
			if(node._active) {
				node._dirtyFlags |= dirtyFlags;
				node.stack_ll_visit(bm);
			}
			node = node._next;
		}
	}
};
_TraversalBenchmark.RenderableNode = function() {
	_TraversalBenchmark.SceneNode.call(this,false);
	this._renderable = true;
};
_TraversalBenchmark.RenderableNode.__super__ = _TraversalBenchmark.SceneNode;
_TraversalBenchmark.RenderableNode.prototype = $extend(_TraversalBenchmark.SceneNode.prototype,{
	rec_visit: function(bm) {
	}
	,rec_ll_visit: function(bm) {
	}
	,stack_visit: function(bm) {
	}
	,stack_ll_visit: function(bm) {
	}
});
var haxe = {};
haxe.Timer = function() { };
haxe.Timer.stamp = function() {
	return new Date().getTime() / 1000;
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
_TraversalBenchmark.SceneNode.NODE_STACK = _TraversalBenchmark.SceneNode._initNodeStack();
Main.main();
})();
