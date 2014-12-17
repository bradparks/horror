package horror.std;

class Module implements IModule {

	public function new() {
		Horror.register(this);
	}

	public function dispose():Void {
		Horror.drop(this);
	}
}
