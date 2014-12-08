package ;

import horror.render.MeshBuffer;
import horror.Horror;

class Blob {
	var x:Float;
	var y:Float;
	var vx:Float;
	var vy:Float;
	var color:Int = 0xffffffff;
	var blowSpeed:Float = 1.;
	var t:Float = 0.;
	var segmentsCount:Int = 64;

	public function new() {
		x = Math.random()*Horror.screen.width;
		y = Math.random()*Horror.screen.height;
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
		buffer.writeTriangle(0, segmentsCount,  1);


		buffer.writeFloat4(x, y, 0.5, 0.5);
		buffer.writePackedColor(0xff00ffff);
		for(i in 0...segmentsCount) {
			var angle = Math.PI * 2. * (i/segmentsCount);
			var r = 100. + 6. * Math.sin(-t*4. + angle*5.) - 10. * Math.sin(5.*t + 2.*angle);
			buffer.writeFloat4(x + r*Math.cos(angle), y + r*Math.sin(angle), 0.5, 0.0);
			buffer.writePackedColor(0xff00ff00);
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
		if(x > Horror.screen.width) {
			vx = -vx;
			x = Horror.screen.width;
		}
		if(y > Horror.screen.height) {
			vy = -vy;
			y = Horror.screen.height;
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