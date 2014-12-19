package horror.input;

#if (flash || hrr_openfl)

typedef KeyCode = flash.ui.Keyboard;

#elseif hrr_snow

private typedef KC = snow.types.Types.Key;

class KeyCode {
	public static var ENTER:UInt 	= cast KC.enter;
	public static var Z:UInt 		= cast KC.key_z;
	public static var SPACE:UInt 	= cast KC.space;
}

/*
public static var unknown : Int                     = 0;

public static var enter : Int                       = 13;
public static var escape : Int                      = 27;
public static var backspace : Int                   = 8;
public static var tab : Int                         = 9;
public static var space : Int                       = 32;
public static var exclaim : Int                     = 33;
public static var quotedbl : Int                    = 34;
public static var hash : Int                        = 35;
public static var percent : Int                     = 37;
public static var dollar : Int                      = 36;
public static var ampersand : Int                   = 38;
public static var quote : Int                       = 39;
public static var leftparen : Int                   = 40;
public static var rightparen : Int                  = 41;
public static var asterisk : Int                    = 42;
public static var plus : Int                        = 43;
public static var comma : Int                       = 44;
public static var minus : Int                       = 45;
public static var period : Int                      = 46;
public static var slash : Int                       = 47;
public static var key_0 : Int                       = 48;
public static var key_1 : Int                       = 49;
public static var key_2 : Int                       = 50;
public static var key_3 : Int                       = 51;
public static var key_4 : Int                       = 52;
public static var key_5 : Int                       = 53;
public static var key_6 : Int                       = 54;
public static var key_7 : Int                       = 55;
public static var key_8 : Int                       = 56;
public static var key_9 : Int                       = 57;
public static var colon : Int                       = 58;
public static var semicolon : Int                   = 59;
public static var less : Int                        = 60;
public static var equals : Int                      = 61;
public static var greater : Int                     = 62;
public static var question : Int                    = 63;
public static var at : Int                          = 64;

//       Skip uppercase letters

public static var leftbracket : Int                 = 91;
public static var backslash : Int                   = 92;
public static var rightbracket : Int                = 93;
public static var caret : Int                       = 94;
public static var underscore : Int                  = 95;
public static var backquote : Int                   = 96;
public static var key_a : Int                       = 97;
public static var key_b : Int                       = 98;
public static var key_c : Int                       = 99;
public static var key_d : Int                       = 100;
public static var key_e : Int                       = 101;
public static var key_f : Int                       = 102;
public static var key_g : Int                       = 103;
public static var key_h : Int                       = 104;
public static var key_i : Int                       = 105;
public static var key_j : Int                       = 106;
public static var key_k : Int                       = 107;
public static var key_l : Int                       = 108;
public static var key_m : Int                       = 109;
public static var key_n : Int                       = 110;
public static var key_o : Int                       = 111;
public static var key_p : Int                       = 112;
public static var key_q : Int                       = 113;
public static var key_r : Int                       = 114;
public static var key_s : Int                       = 115;
public static var key_t : Int                       = 116;
public static var key_u : Int                       = 117;
public static var key_v : Int                       = 118;
public static var key_w : Int                       = 119;
public static var key_x : Int                       = 120;
public static var key_y : Int                       = 121;
public static var key_z : Int                       = 122;

public static var capslock : Int             = from_scan(Scancodes.capslock);

public static var f1 : Int                   = from_scan(Scancodes.f1);
public static var f2 : Int                   = from_scan(Scancodes.f2);
public static var f3 : Int                   = from_scan(Scancodes.f3);
public static var f4 : Int                   = from_scan(Scancodes.f4);
public static var f5 : Int                   = from_scan(Scancodes.f5);
public static var f6 : Int                   = from_scan(Scancodes.f6);
public static var f7 : Int                   = from_scan(Scancodes.f7);
public static var f8 : Int                   = from_scan(Scancodes.f8);
public static var f9 : Int                   = from_scan(Scancodes.f9);
public static var f10 : Int                  = from_scan(Scancodes.f10);
public static var f11 : Int                  = from_scan(Scancodes.f11);
public static var f12 : Int                  = from_scan(Scancodes.f12);

public static var printscreen : Int          = from_scan(Scancodes.printscreen);
public static var scrolllock : Int           = from_scan(Scancodes.scrolllock);
public static var pause : Int                = from_scan(Scancodes.pause);
public static var insert : Int               = from_scan(Scancodes.insert);
public static var home : Int                 = from_scan(Scancodes.home);
public static var pageup : Int               = from_scan(Scancodes.pageup);
public static var delete : Int               = 127;
public static var end : Int                  = from_scan(Scancodes.end);
public static var pagedown : Int             = from_scan(Scancodes.pagedown);
public static var right : Int                = from_scan(Scancodes.right);
public static var left : Int                 = from_scan(Scancodes.left);
public static var down : Int                 = from_scan(Scancodes.down);
public static var up : Int                   = from_scan(Scancodes.up);

public static var numlockclear : Int         = from_scan(Scancodes.numlockclear);
public static var kp_divide : Int            = from_scan(Scancodes.kp_divide);
public static var kp_multiply : Int          = from_scan(Scancodes.kp_multiply);
public static var kp_minus : Int             = from_scan(Scancodes.kp_minus);
public static var kp_plus : Int              = from_scan(Scancodes.kp_plus);
public static var kp_enter : Int             = from_scan(Scancodes.kp_enter);
public static var kp_1 : Int                 = from_scan(Scancodes.kp_1);
public static var kp_2 : Int                 = from_scan(Scancodes.kp_2);
public static var kp_3 : Int                 = from_scan(Scancodes.kp_3);
public static var kp_4 : Int                 = from_scan(Scancodes.kp_4);
public static var kp_5 : Int                 = from_scan(Scancodes.kp_5);
public static var kp_6 : Int                 = from_scan(Scancodes.kp_6);
public static var kp_7 : Int                 = from_scan(Scancodes.kp_7);
public static var kp_8 : Int                 = from_scan(Scancodes.kp_8);
public static var kp_9 : Int                 = from_scan(Scancodes.kp_9);
public static var kp_0 : Int                 = from_scan(Scancodes.kp_0);
public static var kp_period : Int            = from_scan(Scancodes.kp_period);

public static var application : Int          = from_scan(Scancodes.application);
public static var power : Int                = from_scan(Scancodes.power);
public static var kp_equals : Int            = from_scan(Scancodes.kp_equals);
public static var f13 : Int                  = from_scan(Scancodes.f13);
public static var f14 : Int                  = from_scan(Scancodes.f14);
public static var f15 : Int                  = from_scan(Scancodes.f15);
public static var f16 : Int                  = from_scan(Scancodes.f16);
public static var f17 : Int                  = from_scan(Scancodes.f17);
public static var f18 : Int                  = from_scan(Scancodes.f18);
public static var f19 : Int                  = from_scan(Scancodes.f19);
public static var f20 : Int                  = from_scan(Scancodes.f20);
public static var f21 : Int                  = from_scan(Scancodes.f21);
public static var f22 : Int                  = from_scan(Scancodes.f22);
public static var f23 : Int                  = from_scan(Scancodes.f23);
public static var f24 : Int                  = from_scan(Scancodes.f24);
public static var execute : Int              = from_scan(Scancodes.execute);
public static var help : Int                 = from_scan(Scancodes.help);
public static var menu : Int                 = from_scan(Scancodes.menu);
public static var select : Int               = from_scan(Scancodes.select);
public static var stop : Int                 = from_scan(Scancodes.stop);
public static var again : Int                = from_scan(Scancodes.again);
public static var undo : Int                 = from_scan(Scancodes.undo);
public static var cut : Int                  = from_scan(Scancodes.cut);
public static var copy : Int                 = from_scan(Scancodes.copy);
public static var paste : Int                = from_scan(Scancodes.paste);
public static var find : Int                 = from_scan(Scancodes.find);
public static var mute : Int                 = from_scan(Scancodes.mute);
public static var volumeup : Int             = from_scan(Scancodes.volumeup);
public static var volumedown : Int           = from_scan(Scancodes.volumedown);
public static var kp_comma : Int             = from_scan(Scancodes.kp_comma);
public static var kp_equalsas400 : Int       = from_scan(Scancodes.kp_equalsas400);

public static var alterase : Int             = from_scan(Scancodes.alterase);
public static var sysreq : Int               = from_scan(Scancodes.sysreq);
public static var cancel : Int               = from_scan(Scancodes.cancel);
public static var clear : Int                = from_scan(Scancodes.clear);
public static var prior : Int                = from_scan(Scancodes.prior);
public static var return2 : Int              = from_scan(Scancodes.return2);
public static var separator : Int            = from_scan(Scancodes.separator);
public static var out : Int                  = from_scan(Scancodes.out);
public static var oper : Int                 = from_scan(Scancodes.oper);
public static var clearagain : Int           = from_scan(Scancodes.clearagain);
public static var crsel : Int                = from_scan(Scancodes.crsel);
public static var exsel : Int                = from_scan(Scancodes.exsel);

public static var kp_00 : Int                = from_scan(Scancodes.kp_00);
public static var kp_000 : Int               = from_scan(Scancodes.kp_000);
public static var thousandsseparator : Int   = from_scan(Scancodes.thousandsseparator);
public static var decimalseparator : Int     = from_scan(Scancodes.decimalseparator);
public static var currencyunit : Int         = from_scan(Scancodes.currencyunit);
public static var currencysubunit : Int      = from_scan(Scancodes.currencysubunit);
public static var kp_leftparen : Int         = from_scan(Scancodes.kp_leftparen);
public static var kp_rightparen : Int        = from_scan(Scancodes.kp_rightparen);
public static var kp_leftbrace : Int         = from_scan(Scancodes.kp_leftbrace);
public static var kp_rightbrace : Int        = from_scan(Scancodes.kp_rightbrace);
public static var kp_tab : Int               = from_scan(Scancodes.kp_tab);
public static var kp_backspace : Int         = from_scan(Scancodes.kp_backspace);
public static var kp_a : Int                 = from_scan(Scancodes.kp_a);
public static var kp_b : Int                 = from_scan(Scancodes.kp_b);
public static var kp_c : Int                 = from_scan(Scancodes.kp_c);
public static var kp_d : Int                 = from_scan(Scancodes.kp_d);
public static var kp_e : Int                 = from_scan(Scancodes.kp_e);
public static var kp_f : Int                 = from_scan(Scancodes.kp_f);
public static var kp_xor : Int               = from_scan(Scancodes.kp_xor);
public static var kp_power : Int             = from_scan(Scancodes.kp_power);
public static var kp_percent : Int           = from_scan(Scancodes.kp_percent);
public static var kp_less : Int              = from_scan(Scancodes.kp_less);
public static var kp_greater : Int           = from_scan(Scancodes.kp_greater);
public static var kp_ampersand : Int         = from_scan(Scancodes.kp_ampersand);
public static var kp_dblampersand : Int      = from_scan(Scancodes.kp_dblampersand);
public static var kp_verticalbar : Int       = from_scan(Scancodes.kp_verticalbar);
public static var kp_dblverticalbar : Int    = from_scan(Scancodes.kp_dblverticalbar);
public static var kp_colon : Int             = from_scan(Scancodes.kp_colon);
public static var kp_hash : Int              = from_scan(Scancodes.kp_hash);
public static var kp_space : Int             = from_scan(Scancodes.kp_space);
public static var kp_at : Int                = from_scan(Scancodes.kp_at);
public static var kp_exclam : Int            = from_scan(Scancodes.kp_exclam);
public static var kp_memstore : Int          = from_scan(Scancodes.kp_memstore);
public static var kp_memrecall : Int         = from_scan(Scancodes.kp_memrecall);
public static var kp_memclear : Int          = from_scan(Scancodes.kp_memclear);
public static var kp_memadd : Int            = from_scan(Scancodes.kp_memadd);
public static var kp_memsubtract : Int       = from_scan(Scancodes.kp_memsubtract);
public static var kp_memmultiply : Int       = from_scan(Scancodes.kp_memmultiply);
public static var kp_memdivide : Int         = from_scan(Scancodes.kp_memdivide);
public static var kp_plusminus : Int         = from_scan(Scancodes.kp_plusminus);
public static var kp_clear : Int             = from_scan(Scancodes.kp_clear);
public static var kp_clearentry : Int        = from_scan(Scancodes.kp_clearentry);
public static var kp_binary : Int            = from_scan(Scancodes.kp_binary);
public static var kp_octal : Int             = from_scan(Scancodes.kp_octal);
public static var kp_decimal : Int           = from_scan(Scancodes.kp_decimal);
public static var kp_hexadecimal : Int       = from_scan(Scancodes.kp_hexadecimal);

public static var lctrl : Int                = from_scan(Scancodes.lctrl);
public static var lshift : Int               = from_scan(Scancodes.lshift);
public static var lalt : Int                 = from_scan(Scancodes.lalt);
public static var lmeta : Int                = from_scan(Scancodes.lmeta);
public static var rctrl : Int                = from_scan(Scancodes.rctrl);
public static var rshift : Int               = from_scan(Scancodes.rshift);
public static var ralt : Int                 = from_scan(Scancodes.ralt);
public static var rmeta : Int                = from_scan(Scancodes.rmeta);

public static var mode : Int                 = from_scan(Scancodes.mode);

public static var audionext : Int            = from_scan(Scancodes.audionext);
public static var audioprev : Int            = from_scan(Scancodes.audioprev);
public static var audiostop : Int            = from_scan(Scancodes.audiostop);
public static var audioplay : Int            = from_scan(Scancodes.audioplay);
public static var audiomute : Int            = from_scan(Scancodes.audiomute);
public static var mediaselect : Int          = from_scan(Scancodes.mediaselect);
public static var www : Int                  = from_scan(Scancodes.www);
public static var mail : Int                 = from_scan(Scancodes.mail);
public static var calculator : Int           = from_scan(Scancodes.calculator);
public static var computer : Int             = from_scan(Scancodes.computer);
public static var ac_search : Int            = from_scan(Scancodes.ac_search);
public static var ac_home : Int              = from_scan(Scancodes.ac_home);
public static var ac_back : Int              = from_scan(Scancodes.ac_back);
public static var ac_forward : Int           = from_scan(Scancodes.ac_forward);
public static var ac_stop : Int              = from_scan(Scancodes.ac_stop);
public static var ac_refresh : Int           = from_scan(Scancodes.ac_refresh);
public static var ac_bookmarks : Int         = from_scan(Scancodes.ac_bookmarks);

public static var brightnessdown : Int       = from_scan(Scancodes.brightnessdown);
public static var brightnessup : Int         = from_scan(Scancodes.brightnessup);
public static var displayswitch : Int        = from_scan(Scancodes.displayswitch);
public static var kbdillumtoggle : Int       = from_scan(Scancodes.kbdillumtoggle);
public static var kbdillumdown : Int         = from_scan(Scancodes.kbdillumdown);
public static var kbdillumup : Int           = from_scan(Scancodes.kbdillumup);
public static var eject : Int                = from_scan(Scancodes.eject);
public static var sleep : Int                = from_scan(Scancodes.sleep);*/

#elseif hrr_lime

private typedef KC = lime.ui.KeyCode;

@:enum abstract KeyCode(UInt) to UInt from UInt {
	var ENTER 	= cast KC.RETURN;
	var Z 		= cast KC.Z;
	var SPACE 	= cast KC.SPACE;
}

#end