package horror.render;

@:enum abstract BlendFactor(Int) {
	var ZERO = 0;
	var ONE = 1;
	var DESTINATION_ALPHA = 2;
	var DESTINATION_COLOR = 3;
	var ONE_MINUS_DESTINATION_ALPHA = 4;
	var ONE_MINUS_DESTINATION_COLOR = 5;
	var SOURCE_ALPHA = 6;
	var SOURCE_COLOR = 7;
	var ONE_MINUS_SOURCE_ALPHA = 8;
	var ONE_MINUS_SOURCE_COLOR = 9;
}
