package horror.std;

import horror.std.BaseSignal;
import horror.std.SignalSlot;

@:access(horror.std.BaseSignal)
class Signal0 extends BaseSignal<Void->Void> {

	public function new(name:String = null) {
		super(name);
	}

	public function dispatch():Void {
		var slots = _slots;
		var len:Int = _slots.length;
		if(len == 0) {
			return;
		}
		++_numDispatchesInProgress;
		_slotsNeedCopying = true;

		for(i in 0...len) {
			var f:SignalSlot<Void->Void> = slots[i];
			f.listener();
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
