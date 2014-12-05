package horror.input;

@:enum
abstract TouchEventType(Int) {
	var STATIONARY = 0;
	var BEGAN = 1;
	var MOVED = 2;
	var ENDED = 3;
	var CANCELLED = 4;
}