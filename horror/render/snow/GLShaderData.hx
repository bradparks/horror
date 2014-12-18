package horror.render.snow;

import snow.render.opengl.GL;
import snow.render.opengl.GL.GLShader;
import snow.render.opengl.GL.GLProgram;
import snow.render.opengl.GL.GLUniformLocation;

class GLShaderData {

	public var vertexAttributes:Array<Int> = [];
	public var program:GLProgram;
	public var imageUniform:GLUniformLocation;
	public var mvpUniform:GLUniformLocation;

	public function new() { }



	public function compile(vertexShaderCode:String, fragmentShaderCode:String):Void {
		var vertexShader = _compileShader(vertexShaderCode, GL.VERTEX_SHADER);
		var fragmentShader = _compileShader(fragmentShaderCode, GL.FRAGMENT_SHADER);

		program = GL.createProgram();
		GL.attachShader (program, vertexShader);
		GL.attachShader (program, fragmentShader);
		GL.linkProgram (program);

		if (GL.getProgramParameter (program, GL.LINK_STATUS) == 0) {
			throw "Unable to initialize the shader program.";
		}

		for(attr in _extractAttributes(vertexShaderCode)) {
			vertexAttributes.push(GL.getAttribLocation (program, attr));
		}

		mvpUniform = GL.getUniformLocation (program, "uModelViewProjection");
		imageUniform = GL.getUniformLocation (program, "uImage0");
	}

	inline public function dispose() {
		GL.deleteProgram(program);
		vertexAttributes.splice(0, vertexAttributes.length);
	}

	/*** UTILITIES ***/

	static function _compileShader(code:String, shaderType:Int):GLShader {
		#if !desktop
		if(shaderType == GL.FRAGMENT_SHADER) {
			code = "precision mediump float;" + code;
		}
		#end

		var glShader = GL.createShader (shaderType);
		GL.shaderSource (glShader, code);
		GL.compileShader (glShader);
		if (GL.getShaderParameter (glShader, GL.COMPILE_STATUS) == 0) {
			if(shaderType == GL.FRAGMENT_SHADER) {
				throw "Error compiling FRAGMENT shader";
			}
			else if(shaderType == GL.VERTEX_SHADER) {
				throw "Error compiling VERTEX shader";
			}
		}
		return glShader;
	}

	static var ATTRIBUTE_REGEX:EReg = ~/attribute [^\d\W]\w* ([^\d\W]\w*);/g;

	static function _extractAttributes(vertexShaderCode:String):Array<String> {
		var attribs:Array<String> = [];
		var regex = ATTRIBUTE_REGEX;
		while(regex.match(vertexShaderCode)) {
			attribs.push(regex.matched(1));
			vertexShaderCode = regex.matchedRight();
		}
		return attribs;
	}

}
