package horror.input;

#if flash
typedef KeyCode = flash.ui.Keyboard;
#elseif snow
typedef KeyCode = snow.types.Types.Key;
#elseif lime
typedef KeyCode = lime.ui.KeyCode;
#end