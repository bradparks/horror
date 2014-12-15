package horror.render.gl;

import openfl.utils.ArrayBufferView;
import openfl.gl.GL;

import horror.memory.ByteArray;
import horror.render.BlendFactor;

class GLTypes {

	public static function getBlendFactor(blendMode:BlendFactor):Int {

		return switch(blendMode) {
			case BlendFactor.ZERO:
				GL.ZERO;
			case BlendFactor.ONE:
				GL.ONE;
			case BlendFactor.DESTINATION_ALPHA:
				GL.DST_ALPHA;
			case BlendFactor.DESTINATION_COLOR:
				GL.DST_COLOR;
			case BlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				GL.ONE_MINUS_DST_ALPHA;
			case BlendFactor.ONE_MINUS_DESTINATION_COLOR:
				GL.ONE_MINUS_DST_COLOR;
			case BlendFactor.SOURCE_ALPHA:
				GL.SRC_ALPHA;
			case BlendFactor.SOURCE_COLOR:
				GL.SRC_COLOR;
			case BlendFactor.ONE_MINUS_SOURCE_ALPHA:
				GL.ONE_MINUS_SRC_ALPHA;
			case BlendFactor.ONE_MINUS_SOURCE_COLOR:
				GL.ONE_MINUS_SRC_COLOR;
		}

	}

	#if html5

	inline public static function getMemoryRange(data:ByteArrayData, length:Int = 0, offset:Int = 0):ArrayBufferView {
		if((length == 0 || data.byteView.length == length) && offset == 0) {
			return data.byteView;
		}
		return data.byteView.subarray(offset, offset+length);
	}

	#else

	static var MEMORY_RANGE:ArrayBufferView = untyped new ArrayBufferView(0);

	inline public static function getMemoryRange(data:ByteArrayData, length:Int = 0, offset:Int = 0):ArrayBufferView {
		length = length > 0 ? length : data.byteLength;
		var mr = MEMORY_RANGE;
		untyped mr.buffer = data;
		untyped mr.byteLength = length;
		untyped mr.byteOffset = offset;
		return mr;
	}

	#end

}
