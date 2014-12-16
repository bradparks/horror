package horror.std;

class SignalSlot<TListener> {

	public var listener:TListener;
	public var once:Bool = false;

	public function new(listener:TListener, once:Bool) {
		this.listener = listener;
		this.once = once;
	}
}
