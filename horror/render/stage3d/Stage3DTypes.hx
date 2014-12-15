package horror.render.stage3d;

import flash.geom.Matrix3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DVertexBufferFormat;

import horror.render.VertexData;
import horror.render.BlendFactor;

class Stage3DTypes {

	static var MATRIX:Matrix3D = new Matrix3D();

	public inline static function getMatrix3D(m:Matrix4):Matrix3D {

		MATRIX.rawData = m.rawData;
		return MATRIX;
	}

	public inline static function getBlendFactor(blendMode:BlendFactor):Context3DBlendFactor {

		return switch(blendMode) {
			case BlendFactor.ZERO:
				Context3DBlendFactor.ZERO;
			case BlendFactor.ONE:
				Context3DBlendFactor.ONE;
			case BlendFactor.DESTINATION_ALPHA:
				Context3DBlendFactor.DESTINATION_ALPHA;
			case BlendFactor.DESTINATION_COLOR:
				Context3DBlendFactor.DESTINATION_COLOR;
			case BlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
			case BlendFactor.ONE_MINUS_DESTINATION_COLOR:
				Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
			case BlendFactor.SOURCE_ALPHA:
				Context3DBlendFactor.SOURCE_ALPHA;
			case BlendFactor.SOURCE_COLOR:
				Context3DBlendFactor.SOURCE_COLOR;
			case BlendFactor.ONE_MINUS_SOURCE_ALPHA:
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case BlendFactor.ONE_MINUS_SOURCE_COLOR:
				Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
		}

	}

	public inline static function getVertexBufferFormat(format:VertexData):Context3DVertexBufferFormat {

		return switch(format) {
			case VertexData.FloatN(1):
				Context3DVertexBufferFormat.FLOAT_1;
			case VertexData.FloatN(2):
				Context3DVertexBufferFormat.FLOAT_2;
			case VertexData.FloatN(3):
				Context3DVertexBufferFormat.FLOAT_3;
			case VertexData.FloatN(4):
				Context3DVertexBufferFormat.FLOAT_4;
			case VertexData.PackedColor:
				Context3DVertexBufferFormat.BYTES_4;
			case VertexData.FloatN(_):
				throw 'unmatched';
		}

	}

}
