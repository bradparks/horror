package horror.utils;

import horror.utils.ArrayUtil;

@:generic
class Pool<T:Constructable> implements IPool<T> {
    public var name(default, null):String;
    var objects:Array<T> = new Array<T>();
    var length:Int = 0;
    var allocated:Int = 0;

    public function new(?name:String) {
        if(name == null) {
            var typeName = Type.getClassName(Type.getClass(this));
            var a = typeName.split(".");
            var b = a[a.length-1].split("_");
            name = b[b.length-1];
        }
        this.name = name;
		PoolKeeper.pools.push(this);
    }

    public function free(object:T):Void {
        while(length >= objects.length) {
            //var newList = new Vector<T>(objects.length*2);
            //Vector.blit(objects, 0, newList, 0, objects.length);
			objects.push(null);
        }
        objects[length] = object;
        ++length;
    }

    public function next():T {
        if (length > 0) {
            var index = --length;
            var object = objects[index];
            objects[index] = null;
            return object;
        }
        ++allocated;

        return new T();
    }

    public function toString():String{
        return 'Pool<$name> {Allocated: $allocated, Free: $length, BufferSize: ${objects.length} }';
    }
}

class PoolKeeper {
	public static var pools(default, never):Array<IPool<Dynamic>> = new Array<IPool<Dynamic>>();

	public static function getAllPoolInfo():String {
		return ArrayUtil.join(pools, "\n");
	}
}

private typedef Constructable = {
	function new():Void;
}

private interface IPool<T> {
	public function free(object:T):Void;
	public function next():T;
	public function toString():String;
}
