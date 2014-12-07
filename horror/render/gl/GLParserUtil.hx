package horror.render.gl;

class GLParserUtil {

	static var ATTRIBUTE_REGEX:EReg = ~/attribute [^\d\W]\w* ([^\d\W]\w*);/g;

	public static function extractAttributes(vertexShaderCode:String):Array<String> {
		var attribs:Array<String> = [];
		var regex = ATTRIBUTE_REGEX;
		while(regex.match(vertexShaderCode)) {
			attribs.push(regex.matched(1));
			vertexShaderCode = regex.matchedRight();
		}
		return attribs;
	}
}
