package horror.std;

import horror.std.BaseSignal;
import horror.std.SignalSlot;

@:access(horror.std.BaseSignal)
class Signal1<A> extends BaseSignal<A -> Void> {

	public function new(name:String = null) {
		super(name);
	}

	public function dispatch(a:A):Void {
		var slots = _slots;
		var len:Int = _slots.length;
		if(len == 0) {
			return;
		}
		++_numDispatchesInProgress;
		_slotsNeedCopying = true;

		for(i in 0...len) {
			var f:SignalSlot<A -> Void> = slots[i];
			f.listener(a);
			if(f.once) {
				remove(f.listener);
			}
		}

		--_numDispatchesInProgress;
		if(_numDispatchesInProgress == 0) {
			_slotsNeedCopying = false;
		}
	}
}