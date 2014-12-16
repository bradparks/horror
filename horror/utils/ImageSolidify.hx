package utils;
/*
class ImageSolidify {
	public function process() {
		var w = width;
		var h = height;

		_solid = new Array<Int>();
		for(i in 0 ... w * h) _solid.push(0);

		var R = new Array<Pos>();
		var Q = new Array<Pos>();

		for(y in 0...h) {
			for(x in 0...w) {
				if(getA(x, y) > 0) {
					setSolid(x, y, 1);
				}
				else {
					var p = new Pos(x, y, 0);
					setSolid(x, y, 0);
					for(oy in -1...2) {
						for(ox in -1...2) {
							var xn = x + ox;
							var yn = y + oy;
							if(xn < w && yn < h && getA(xn, yn) > 0) {
								++p.n;
							}
						}
					}

					if(p.n > 0) {
						Q.push(p);
					}
				}
			}
		}

		var cm = new Map<Int, Int>();
		var iterations = 1000;
		while(iterations --> 0 && Q.length > 0) {
			trace('N: $iterations, Q: ${Q.length}');

			Q.sort(sorter);

			while(Q.length > 0) {
				var r = 0.0;
				var g = 0.0;
				var b = 0.0;
				var c = 0.0;
				var p = Q.pop();
				if(solid(p.x, p.y)) {
					continue;
				}

				var a = getA(p.x, p.y);
				for(oy in -1...2) {
					var y = p.y + oy;
					if(y >= 0 && y < h) {
						for(ox in -1...2) {
							var x = p.x + ox;
							if(x >= 0 && x < w) {
								if(solid(x, y)) {
									r += getR(x, y);
									g += getG(x, y);
									b += getB(x, y);
									++c;
								}
								else {
									R.push(new Pos(x, y, 0));
								}
							}
						}
					}
				}

				setSolid(p.x, p.y, 1);
				setPixel(p.x, p.y, Std.int(r / c), Std.int(g / c), Std.int(b / c), a);
			}

			while(R.length > 0) {
				var p = R.pop();
				if(solid(p.x, p.y)) {
					continue;
				}
				for(oy in -1...2) {
					for(ox in -1...2) {
						var xn = p.x + ox;
						var yn = p.y + oy;
						if(xn < w && yn < h && solid(xn, yn)) {
							++p.n;
						}
					}
				}
				Q.push(p);
			}
		}
	}

	function sorter(p1:Pos, p2:Pos):Int {
		return p2.n - p1.n;
	}

	@:extern inline function getB(x:Int, y:Int):Int { return pixels.get(((x + y*width) << 2) + 0); }
	@:extern inline function getG(x:Int, y:Int):Int { return pixels.get(((x + y*width) << 2) + 1); }
	@:extern inline function getR(x:Int, y:Int):Int { return pixels.get(((x + y*width) << 2) + 2); }
	@:extern inline function getA(x:Int, y:Int):Int { return pixels.get(((x + y*width) << 2) + 3); }
	@:extern inline function solid(x:Int, y:Int):Bool { return _solid[x + y*width] > 0; }
	@:extern inline function setSolid(x:Int, y:Int, v:Int):Void { _solid[x + y*width] = v; }
	@:extern inline function setPixel(x:Int, y:Int, r:Int, g:Int, b:Int, a:Int) {
		var p = ((x + y*width) << 2);
		pixels.set(p+0, b);
		pixels.set(p+1, g);
		pixels.set(p+2, r);
		pixels.set(p+3, a);
	}

	@:extern inline function color24(x:Int, y:Int):Int {
		var p = ((x + y*width) << 2);
		return (pixels.get(p+2) << 16) | (pixels.get(p+1) << 8) | pixels.get(p);
	}

	@:extern inline function setColor24(x:Int, y:Int, v:Int) {
		var p = ((x + y*width) << 2);
		pixels.set(p+2, (v >> 16) & 0xFF);
		pixels.set(p+1, (v >> 8) & 0xFF);
		pixels.set(p  ,  v & 0xFF);
	}
}

private class Pos {

	public var x:Int;
	public var y:Int;
	public var n:Int;

	public function new(x:Int, y:Int, n:Int) {
		this.x = x;
		this.y = y;
		this.n = n;
	}
}*/