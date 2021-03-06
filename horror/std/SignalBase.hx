package horror.std;

import Reflect;

class SignalBase<T> {

	var _name:String = null;
	var _slots:Array<SignalSlot<T>> = new Array<SignalSlot<T>>();
	var _numDispatchesInProgress:Int = 0;
	var _slotsNeedCopying:Bool = false;

	public var numListeners(get, never):Int;

	public function new(name:String) {
		_name = name;
	}

	public function dispose():Void {
		clear();
		_slots = null;
		_name = null;
	}

	public function clear():Void {
		_slots.splice(0, _slots.length);
		_slotsNeedCopying = false;
	}

	public function add(listener:T):Void {
		_slots.push(new SignalSlot<T>(listener, false));
	}

	public function addOnce(listener:T):Void {
		_slots.push(new SignalSlot<T>(listener, true));
	}

	public function remove(listener:T):Void {
		// elegant but we need to check copying
		//while(_slots.remove(listener)) {};

		var i:Int = 0;
		while(i < _slots.length) {
			if(

			#if neko

			Reflect.compareMethods(_slots[i].listener, listener)

			#else

			_slots[i].listener == listener

			#end

			) {
				if(_slotsNeedCopying) {
					_slots = _slots.copy();
					_slotsNeedCopying = false;
				}
				_slots.splice(i, 1);
			}
			else {
				++i;
			}
		}
	}

	inline function get_numListeners():Int {
		return _slots.length;
	}
}

