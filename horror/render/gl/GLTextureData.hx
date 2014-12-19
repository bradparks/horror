package horror.render.gl;

#if hrr_openfl

typedef GLTextureData = openfl.gl.GLTexture;

#elseif hrr_lime

typedef GLTextureData = lime.graphics.opengl.GLTexture;

#elseif hrr_snow

typedef GLTextureData = snow.render.opengl.GL.GLTexture;

#end