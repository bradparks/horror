package horror.std;

@:access(horror.std.SignalBase)
class Signal1<A> extends SignalBase<A -> Void> {

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