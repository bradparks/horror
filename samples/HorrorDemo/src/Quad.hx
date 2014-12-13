package ;
import horror.render.MeshBuffer;
class Quad {

	public static function drawQuad(buffer:MeshBuffer, x:Int, y:Int, width:Int, height:Int, color:Int = 0xffffffff) {

		buffer.writeTriangle(0, 1, 2);
		buffer.writeTriangle(2, 3, 0);

		buffer.writeFloat4(x, y, 0, 0);
		buffer.writePackedColor(color);

		buffer.writeFloat4(x + width, y, 1, 0);
		buffer.writePackedColor(color);

		buffer.writeFloat4(x + width, y + height, 1, 1);
		buffer.writePackedColor(color);

		buffer.writeFloat4(x, y + height, 0, 1);
		buffer.writePackedColor(color);

		buffer.push(4, 6);
	}

	public function new() {
	}
}
