package horror.render;

import horror.std.Debug;

#if flash

typedef Matrix3D_Data = flash.Vector<Float>;

#elseif openfl

typedef Matrix3D_Data = openfl.utils.Float32Array;

#end

class Matrix4 implements ArrayAccess<Float> {

    //public var determinant (get, null):Float;
    public var rawData(default, null):Matrix3D_Data;

    public function new () {
        #if flash
		rawData = new Matrix3D_Data(16, true);
        #else
		rawData = new Matrix3D_Data(16);
        #end
    }

	@:arrayAccess inline public function get(index:Int):Float {
		return rawData[index];
	}


	@:arrayAccess inline public function set(index:Int, value:Float):Float {
		rawData[index] = value;
		return value;
	}

	public function copyFromArray(data:Array<Float>) {
		Debug.assert(data.length >= 16);
		for(i in 0...16) {
			rawData[i] = data[i];
		}
	}

	public function copyFromMatrix(matrix:Matrix4) {
		var r1 = rawData;
		var r2 = matrix.rawData;
		for(i in 0...16) {
			r1[i] = r2[i];
		}
	}

	public function toString():String {
		var str = '';
		for(v in rawData) str += v + ' ';
		return str;
	}

	public static function multiply(left:Matrix4, right:Matrix4, destination:Matrix4):Matrix4 {
		Debug.assert(left != null && right != null && destination != null);

		var m1 = right.rawData;
		var m2 = left.rawData;
		var r = destination.rawData;
		var m111:Float = m1[0], m121:Float = m1[4], m131:Float = m1[8],  m141:Float = m1[12],
		    m112:Float = m1[1], m122:Float = m1[5], m132:Float = m1[9],  m142:Float = m1[13],
		    m113:Float = m1[2], m123:Float = m1[6], m133:Float = m1[10], m143:Float = m1[14],
		    m114:Float = m1[3], m124:Float = m1[7], m134:Float = m1[11], m144:Float = m1[15],
		    m211:Float = m2[0], m221:Float = m2[4], m231:Float = m2[8],  m241:Float = m2[12],
		    m212:Float = m2[1], m222:Float = m2[5], m232:Float = m2[9],  m242:Float = m2[13],
		    m213:Float = m2[2], m223:Float = m2[6], m233:Float = m2[10], m243:Float = m2[14],
		    m214:Float = m2[3], m224:Float = m2[7], m234:Float = m2[11], m244:Float = m2[15];

		r[0] = m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
		r[1] = m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
		r[2] = m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
		r[3] = m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;

		r[4] = m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
		r[5] = m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
		r[6] = m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
		r[7] = m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;

		r[8] = m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
		r[9] = m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
		r[10] = m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
		r[11] = m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;

		r[12] = m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
		r[13] = m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
		r[14] = m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
		r[15] = m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;

		return destination;
	}

    public function setTransform2D(x:Float, y:Float, scale:Float = 1, rotation:Float = 0):Matrix4 {
		var theta = rotation * Math.PI / 180.0;
        var cs = Math.cos(theta)*scale;
        var sn = Math.sin(theta)*scale;
		var data = rawData;

		data[0] = cs;
		data[1] = -sn;
		data[2] = 0;
		data[3] = 0;

		data[4] = sn;
		data[5] = cs;
		data[6] = 0;
		data[7] = 0;

		data[8] = 0;
		data[9] = 0;
		data[10] = 1;
		data[11] = 0;

		data[12] = x;
		data[13] = y;
		data[14] = 0;
		data[15] = 1;

        return this;
    }

	public function setOrtho2D(x:Float, y:Float, width:Float, height:Float, zNear:Float = -1000, zFar:Float = 1000):Matrix4 {
		return setOrthoProjection(x, x + width, y + height, y, zNear, zFar);
	}

    function setOrthoProjection(x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float):Matrix4 {
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);
		var data = rawData;

		data[0] = 2.0 * sx;
		data[1] = 0;
		data[2] = 0;
		data[3] = 0;

		data[4] = 0;
		data[5] = 2.0 * sy;
		data[6] = 0;
		data[7] = 0;

		data[8] = 0;
		data[9] = 0;
		data[10] = -2.0 * sz;
		data[11] = 0;

		data[12] = -(x0 + x1) * sx;
		data[13] = -(y0 + y1) * sy;
		data[14] = -(zNear + zFar) * sz;
		data[15] = 1;

        return this;
    }

}