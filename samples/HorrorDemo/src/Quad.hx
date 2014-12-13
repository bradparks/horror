package ;
import horror.render.MeshBuffer;
class Quad {

	public static function draw(buffer:MeshBuffer, x:Int, y:Int, width:Int, height:Int, color:Int = 0xffffffff) {

		buffer.writeTriangle(0, 1, 2);
		buffer.writeTriangle(2, 3, 0);

		buffer.writeFloat4(x, y, 0, 0);
		buffer.writeColor(color);

		buffer.writeFloat4(x + width, y, 1, 0);
		buffer.writeColor(color);

		buffer.writeFloat4(x + width, y + height, 1, 1);
		buffer.writeColor(color);

		buffer.writeFloat4(x, y + height, 0, 1);
		buffer.writeColor(color);

		buffer.push(4, 6);
	}

	public static function drawHorizontalGradient(buffer:MeshBuffer, x:Int, y:Int, width:Int, height:Int, color1:Int = 0xffffffff, color2:Int = 0xffffffff) {

		buffer.writeTriangle(0, 1, 2);
		buffer.writeTriangle(2, 3, 0);

		buffer.writeFloat4(x, y, 0, 0);
		buffer.writeColor(color1);

		buffer.writeFloat4(x + width, y, 1, 0);
		buffer.writeColor(color2);

		buffer.writeFloat4(x + width, y + height, 1, 1);
		buffer.writeColor(color2);

		buffer.writeFloat4(x, y + height, 0, 1);
		buffer.writeColor(color1);

		buffer.push(4, 6);
	}

	public function new() {
	}
}
