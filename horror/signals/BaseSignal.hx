package horror.signals;

import horror.utils.IDisposable;

import Reflect;

class BaseSignal<T> implements IDisposable {

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
		var i:Int = 0;
		while(i < _slots.length) {
			if(Reflect.compareMethods(_slots[i], listener)) {
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

