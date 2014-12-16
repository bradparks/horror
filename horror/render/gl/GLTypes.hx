package horror.render.gl;

import haxe.io.BytesData;

import openfl.gl.GL;
import openfl.utils.ArrayBufferView;

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

	#if js

	inline public static function getMemoryRange(bytesData:BytesData, length:Int = 0, offset:Int = 0):ArrayBufferView {
		if((length == 0 || bytesData.length == length) && offset == 0) {
			return bytesData;
		}
		return bytesData.subarray(offset, offset+length);
	}

	#else

	static var MEMORY_RANGE:ArrayBufferView = untyped new ArrayBufferView(1);

	public static function getMemoryRange(bytesData:BytesData, length:Int = 0, offset:Int = 0):ArrayBufferView {
		var bytesTotal = bytesData.length;
		length = length > 0 ? length : bytesTotal;

		var mr = MEMORY_RANGE;

		// memory range
		untyped mr.byteLength = length;
		untyped mr.byteOffset = offset;

		// ByteArray's Bytes modification
		untyped mr.buffer.b = bytesData;
		untyped mr.buffer.length = bytesTotal;

		// extra, not needed:
		//untyped mr.buffer.bytesAvailable = totalLength;
		//untyped mr.buffer.byteLength = totalLength;
		//untyped mr.bytes = bytesData;

		return mr;
	}

	#end

}
