package horror.utils;

import horror.std.Debug;

using horror.utils.ArrayUtil;

@:generic
class ActiveArray<T> {

	var _buffer:Array<T>;
	//var current(default, null):T;
	var _iterator:Int = -1;
	var _step:Int = 1;
	var _length:Int = 0;

	public function new(data:Array<T> = null) {
		_buffer = data != null ? data : new Array<T>();
	}

	public function begin():T {
        Debug.assert(!isWalking, "Walking already started, only single walk in time supported");
		if(_buffer.length > 0) {
			_iterator = 0;
			_length = _buffer.length;
			return setCurrentIndex(0);
		}
		return null;
	}

	public function end():Void {
		Debug.assert(isWalking);
		_iterator = -1;
		_step = 1;
		_length = 0;
	}

	public var length(get, never):Int;
	inline function get_length():Int { return _buffer.length; }

	public var isWalking(get, never):Bool;
	inline function get_isWalking():Bool { return _iterator >= 0; }

	public var isCurrentRemoved(get, never):Bool;
	inline function get_isCurrentRemoved():Bool { return _step == 0; }

	public inline function contains(element:T):Bool {
		return _buffer.indexOf(element) >= 0;
	}

	private inline function setCurrentIndex(index:Int):T {
		return index < _length ? _buffer.unsafeGet(index) : null;
	}

	public inline function getAt(index:Int):T {
		return _buffer[index];
	}

	public inline function next():T {
		Debug.assert(isWalking);
		var i:Int = (_iterator += _step);
		_step = 1;
		if(i < _length) {
			return _buffer.unsafeGet(i);
		}
		end();
		return null;
	}

	public inline function push(element:T):Void {
		_buffer.push(element);
	}

	// remove first element
	public function remove(element:T):Void {
		var i:Int = _iterator;
		if(i < 0) {
			_buffer.remove(element);
			return;
		}
		var index:Int = _buffer.indexOf(element);
		Debug.assert(index >= 0);
		if(index < i) {
			--_iterator;
		}
		else if(index == i) {
			_step = 0;
		}
		if(index < _length) {
			--_length;
		}
		_buffer.splice(index, 1);
	}

	public function removeAt(index:Int):Void {
		Debug.assert(index >= 0 && index < _buffer.length);
		var i:Int = _iterator;
		if(i >= 0) {
			if(index < i) {
				--_iterator;
			}
			else if(index == i) {
				_step = 0;
			}
			if(index < _length) {
				--_length;
			}
		}
		_buffer.splice(index, 1);
	}

	public function removeWhere(prediction: T->Bool) {
		var i:Int = 0;
		while(i < _buffer.length) {
			if(prediction(_buffer[i])) {
				removeAt(i);
				continue;
			}
			++i;
		}
	}

	public function removeCurrent(removeNext:Bool = false) {
		Debug.assert(isWalking);
		if (_step == 0 && !removeNext) {
			return;
		}
		_buffer.splice(_iterator, 1);
		_step = 0;
		--_length;
	}

	public function forEach(functor:T -> Void):Void {
		var c:T = begin();
		while(isWalking) {
			functor(c);
			c = next();
		}
	}

	public function clear() {
		if(_iterator >= 0) {
			_step = 0;
			_length = 0;
		}
		_buffer.splice(0, _buffer.length);
	}

	public inline function first():T {
		return _buffer.length > 0 ? _buffer[0] : null;
	}

	public inline function lastIterationElement():T {
		return _buffer[_length-1];
	}

	public function addRange(source:Array<T>) {
		for(element in source) {
			_buffer.push(element);
		}
	}
}
