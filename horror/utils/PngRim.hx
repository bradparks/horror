package horror.utils;
/*
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import sys.io.File;

// https://github.com/fgenesis/pngrim
class PngRim {

	var width:Int;
	var height:Int;
	var pixels:Bytes;

	var _solid:Array<Int>;

	public function new () {}

	public static function processFile(path:String):Void {
		var p = new PngRim();
		p.load(path + ".png");
		p.makeOpaque();
		p.save(path + "_original_color.png");

		p.load(path + ".png");
		p.process();
		p.save(path + "_processed.png");
		p.makeOpaque();
		p.save(path + "_processed_color.png");
	}

	public function load(path:String) {
		var bytes = File.getBytes(path);
		var byteInput = new BytesInput (bytes, 0, bytes.length);
		var reader = new format.png.Reader(byteInput);
		var d = reader.read();
		var hdr = format.png.Tools.getHeader(d);
		pixels = format.png.Tools.extract32(d);
		width = hdr.width;
		height = hdr.height;
	}

	public function save(path:String) {
		var d = format.png.Tools.build32BGRA(width, height, pixels);
		var byteOut = new BytesOutput();
		var writer = new format.png.Writer(byteOut);
		writer.write(d);
		File.saveBytes(path, byteOut.getBytes());
	}

	public function makeOpaque() {
		var p = 3;
		for(i in 0...width*height) {
			pixels.set(p, 255);
			p += 4;
		}
	}

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


}
*/