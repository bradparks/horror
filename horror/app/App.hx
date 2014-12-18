package horror.app;

#if flash
typedef App = horror.app.flash.FlashBaseApp;
#else
typedef App = horror.app.snow.SnowBaseApp;
#end