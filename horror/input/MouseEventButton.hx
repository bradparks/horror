package horror.input;

@:enum
abstract MouseEventButton(Int) from Int {
	var NONE = -1;
	var LEFT = 0;
	var MIDDLE = 1;
	var RIGHT = 2;
}
