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
};
var TraversalBenchmark = function() {
	this.visitCount = 20;
	this.quadCount = 20;
	this.mcCount = 30000;
	this.stack_count = [0,0];
	this.rec_count = [0,0];
	Benchmark.call(this);
	TraversalBenchmark.INSTANCE = this;
	this.initGraph();
	var _g = 0;
	while(_g < 65535) {
		var i = _g++;
		TraversalBenchmark.NODE_STACK.push(null);
	}
	this.add("recursive",$bind(this,this.runRec));
	this.add("recursive_2",$bind(this,this.runRec2));
	this.add("stack",$bind(this,this.runStack));
};
TraversalBenchmark.__super__ = Benchmark;
TraversalBenchmark.prototype = $extend(Benchmark.prototype,{
	onEnd: function() {
	}
	,runRec: function() {
		this.graph.rec_visitChildren(0);
	}
	,runRec2: function() {
		this.graph.rec2_visitChildren(0,this);
	}
	,runStack: function() {
		this.graph.stack_visitChildren(0,this);
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
				++this.visitCount;
			}
			this.graph.addChild(mc);
			++this.visitCount;
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
_TraversalBenchmark.SceneNode.prototype = {
	addChild: function(child) {
		this._children.push(child);
	}
	,rec_visit: function() {
		TraversalBenchmark.INSTANCE.rec_count[0]++;
		var df = this._dirtyFlags;
		this._dirtyFlags = 0;
		this.rec_visitChildren(df);
	}
	,rec_visitChildren: function(parentDirtyFlags) {
		var children = this._children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child = children[i];
				if(child._active) {
					child._dirtyFlags |= parentDirtyFlags;
					child.rec_visit();
				}
				++i;
			}
		}
	}
	,rec2_visit: function(bm) {
		bm.rec_count[0]++;
		var df = this._dirtyFlags;
		this._dirtyFlags = 0;
		this.rec2_visitChildren(df,bm);
	}
	,rec2_visitChildren: function(dirtyFlags,bm) {
		var children = this._children;
		if(children != null) {
			var len = children.length;
			var i = 0;
			while(i < len) {
				var child = children[i];
				if(child._active) {
					child._dirtyFlags |= dirtyFlags;
					child.rec2_visit(bm);
				}
				++i;
			}
		}
	}
	,stack_visit: function(bm) {
		bm.stack_count[0]++;
	}
	,stack_visitChildren: function(dirtyFlags,bm) {
		if(this._children == null) return;
		var top = 0;
		var stack = TraversalBenchmark.NODE_STACK;
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
			dirtyFlags = node._dirtyFlags;
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
};
_TraversalBenchmark.RenderableNode = function() {
	_TraversalBenchmark.SceneNode.call(this,false);
	this._renderable = true;
};
_TraversalBenchmark.RenderableNode.__super__ = _TraversalBenchmark.SceneNode;
_TraversalBenchmark.RenderableNode.prototype = $extend(_TraversalBenchmark.SceneNode.prototype,{
	rec_visit: function() {
		var bm = TraversalBenchmark.INSTANCE;
		bm.rec_count[0]++;
		bm.rec_count[1]++;
	}
	,rec2_visit: function(bm) {
		bm.rec_count[0]++;
		bm.rec_count[1]++;
	}
	,stack_visit: function(bm) {
		bm.stack_count[0]++;
		bm.stack_count[1]++;
	}
});
var haxe = {};
haxe.Timer = function() { };
haxe.Timer.stamp = function() {
	return new Date().getTime() / 1000;
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
TraversalBenchmark.NODE_STACK = new Array();
Main.main();
})();
