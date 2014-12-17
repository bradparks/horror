package horror.utils;

class ImageTools {

	// https://github.com/fgenesis/pngrim
	public static function solidify(image:ImageBytes, iterations:Int = 4):Void {

		image.lock();
		var w = image.width;
		var h = image.height;
		var solidMap = new BitMask(w, h);
		solidMap.outerFlag = true;

		function sorter(p1:Pos, p2:Pos):Int {
			return p2.n - p1.n;
		}

		var R = new Array<Pos>();
		var Q = new Array<Pos>();

		for(y in 0...h) {
			for(x in 0...w) {
				if(image.a(x, y) > 0) {
					solidMap.set(x, y, true);
				}
				else {
					var p = new Pos(x, y, 0);
					solidMap.set(x, y, false);
					for(oy in -1...2) {
						for(ox in -1...2) {
							var xn = x + ox;
							var yn = y + oy;
							if(xn < w && yn < h && image.a(xn, yn) > 0) {
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

		while(iterations --> 0 && Q.length > 0) {
			trace('[N: $iterations] Q: ${Q.length}');

			Q.sort(sorter);

			while(Q.length > 0) {
				var r = 0.0;
				var g = 0.0;
				var b = 0.0;
				var c = 0.0;
				var p = Q.pop();
				if(solidMap.get(p.x, p.y)) {
					continue;
				}

				var a = image.a(p.x, p.y);
				for(oy in -1...2) {
					var y = p.y + oy;
					if(y >= 0 && y < h) {
						for(ox in -1...2) {
							var x = p.x + ox;
							if(x >= 0 && x < w) {
								if(solidMap.get(x, y)) {
									r += image.r(x, y);
									g += image.g(x, y);
									b += image.b(x, y);
									++c;
								}
								else {
									R.push(new Pos(x, y, 0));
								}
							}
						}
					}
				}

				solidMap.set(p.x, p.y, true);
				image.setPixel(p.x, p.y, Std.int(r / c), Std.int(g / c), Std.int(b / c), a);
			}

			while(R.length > 0) {
				var p = R.pop();
				if(solidMap.get(p.x, p.y)) {
					continue;
				}
				for(oy in -1...2) {
					for(ox in -1...2) {
						var xn = p.x + ox;
						var yn = p.y + oy;
						if(xn < w && yn < h && solidMap.get(xn, yn)) {
							++p.n;
						}
					}
				}
				Q.push(p);
			}
		}
		image.unlock();
	}

	public static function makeOpaque(image:ImageBytes):Void {
		var io = image.lock();
		var total = image.width * image.height;
		var p = 3;
		for(i in 0...total) {
			io[p] = 255;
			p += 4;
		}
		image.unlock();
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
}