package horror.render;

#if flash

typedef Matrix3D_Data = flash.Vector<Float>;

#elseif openfl

typedef Matrix3D_Data = openfl.utils.Float32Array;

#end

class Matrix3D {

    //public var determinant (get, null):Float;
    public var rawData:Matrix3D_Data;

    public function new (data:Array<Float>) {
        #if flash
        rawData = Matrix3D_Data.ofArray(data);
        #else
        rawData = new Matrix3D_Data(data);
        #end
    }

    public static function create2D(x:Float, y:Float, scale:Float = 1, rotation:Float = 0):Matrix3D
    {
        var theta = rotation * Math.PI / 180.0;
        var c = Math.cos(theta);
        var s = Math.sin(theta);

        var array =
        [
        c*scale,  -s*scale, 0,  0,
        s*scale,  c*scale, 0,  0,
        0,        0,        1,  0,
        x,        y,        0,  1
        ];

        return new Matrix3D(array);
    }

    public static function createOrtho(x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float):Matrix3D
    {
        var sx = 1.0 / (x1 - x0);
        var sy = 1.0 / (y1 - y0);
        var sz = 1.0 / (zFar - zNear);

        var array =
        [
        2.0*sx,       0,          0,                 0,
        0,            2.0*sy,     0,                 0,
        0,            0,          -2.0*sz,           0,
        - (x0+x1)*sx, - (y0+y1)*sy, - (zNear+zFar)*sz,  1
        ];
        return new Matrix3D(array);
    }

}