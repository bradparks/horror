package horror.std;

import horror.std.BaseSignal;
import horror.std.SignalSlot;

@:access(horror.std.BaseSignal)
class Signal2<A, B> extends BaseSignal<A -> B -> Void> {

	public function new(name:String = null) {
		super(name);
	}

	public function dispatch(a:A, b:B):Void {
		var slots = _slots;
		var len:Int = _slots.length;
		if(len == 0) {
			return;
		}
		++_numDispatchesInProgress;
		_slotsNeedCopying = true;

		for(i in 0...len) {
			var f:SignalSlot<A -> B -> Void> = slots[i];
			f.listener(a, b);
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