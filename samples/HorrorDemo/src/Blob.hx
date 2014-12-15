package ;

import horror.app.Application;
import horror.render.Color32;
import horror.render.MeshBuffer;

class Blob {

	public var segmentsCount(default, null):Int = 64;

	var x:Float;
	var y:Float;
	var vx:Float;
	var vy:Float;
	var color:Color32 = 0xffffffff;
	var blowSpeed:Float = 1.;
	var t:Float = 0.;

	public function new() {
		x = Math.random() * Application.current.screen.width;
		y = Math.random() * Application.current.screen.height;
		vx = 100. - 200. * Math.random();
		vy = 100. - 200. * Math.random();
		color = Math.random() > 0.5 ? 0xff00ff00 : 0xffff0000;
		blowSpeed = 1. + 2. * Math.random();
		segmentsCount = 32 + Std.int(33*Math.random());
	}

	public function draw(buffer:MeshBuffer) {

		for(i in 0...segmentsCount-1) {
			buffer.writeTriangle(0, i+1, i+2);
		}
		buffer.writeTriangle(0, segmentsCount, 1);

		buffer.writeFloat4(x, y, 0.5, 0.5);
		buffer.writeColor(0xffffff00);
		for(i in 0...segmentsCount) {
			var angle = Math.PI * 2. * (i/segmentsCount);
			var r = 100. + 6. * Math.sin(-t*4. + angle*5.) - 10. * Math.sin(5.*t + 2.*angle);
			buffer.writeFloat4(x + r*Math.cos(angle), y + r*Math.sin(angle), 0.5, 0.0);
			buffer.writeColor(color);
		}

		buffer.push(segmentsCount + 1, segmentsCount * 3);
	}

	public function update(dt:Float):Void {
		t += dt*blowSpeed;
		x += vx*dt;
		y += vy*dt;
		checkBounds();
	}

	public function checkBounds():Void {
		var screen = Application.current.screen;

		if(x > screen.width) {
			vx = -vx;
			x = screen.width;
		}
		if(y > screen.height) {
			vy = -vy;
			y = screen.height;
		}
		if(x < 0) {
			vx = -vx;
			x = 0;
		}
		if(y < 0) {
			vy = -vy;
			y = 0;
		}
	}
}