package horror.std;

@:access(horror.std.SignalBase)
class Signal0 extends SignalBase<Void->Void> {

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
