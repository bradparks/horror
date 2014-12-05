package ;

import horror.render.VertexStructure;
import horror.render.Shader;

class SimpleShader {

	public static function create(vertexStructure:VertexStructure):Shader {
		var shader = new Shader("simple", vertexStructure);
		shader.loadFromCode(VERTEX_CODE, FRAGMENT_CODE);
		return shader;
	}

	#if flash

	private static var FRAGMENT_CODE:String =
	"tex ft0, v0, fs0 <SAMPLING_OPTIONS>
mul oc, ft0, v1
";

	private static var VERTEX_CODE:String =
	"m44 vt0, va0, vc0
m44 op, vt0, vc4
mov v0, va1
mov v1, va2
";

	#elseif openfl
	private static var FRAGMENT_CODE:String =
	"varying vec2 vTexCoord;
			varying vec4 vColorMult;
			uniform sampler2D uImage0;

			void main()
			{
				gl_FragColor = texture2D(uImage0, vTexCoord)*vColorMult;
			}";

	private static var VERTEX_CODE:String =
	"attribute vec2 aVertexPosition;
			attribute vec2 aTexCoord;
			attribute vec4 aColorMult;
			varying vec2 vTexCoord;
			varying vec4 vColorMult;

			uniform mat4 uModelViewMatrix;
			uniform mat4 uProjectionMatrix;

			void main() {
				vTexCoord = aTexCoord;
				vColorMult = aColorMult;
				gl_Position = uProjectionMatrix * uModelViewMatrix * vec4 (aVertexPosition, 0.0, 1.0);
			}";


	#end
}

