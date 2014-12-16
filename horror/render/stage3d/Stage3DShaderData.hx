package horror.render.stage3d;

import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.display3D.Context3DProgramType;
import flash.utils.ByteArray in FlashByteArray;

class Stage3DShaderData {

	public var program:Program3D;

	public var vertexAGAL:FlashByteArray;
	public var fragmentAGAL:FlashByteArray;

	public function new() {}

	public function compile(vertexShaderCode:String, fragmentShaderCode:String):Void {

		var vertexProgram:AGALMiniAssembler = new AGALMiniAssembler();
		var pixelProgram:AGALMiniAssembler = new AGALMiniAssembler();

		vertexProgram.assemble(Context3DProgramType.VERTEX, vertexShaderCode);
		pixelProgram.assemble(Context3DProgramType.FRAGMENT, fragmentShaderCode);

		vertexAGAL = vertexProgram.agalcode;
		fragmentAGAL = pixelProgram.agalcode;
	}

	public function dispose() {

		program.dispose();
		program = null;
	}

	public function initialize(context:Context3D):Void {

		program = context.createProgram();
		program.upload(vertexAGAL, fragmentAGAL);
	}
}