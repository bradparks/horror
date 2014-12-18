package horror.render.gl;

#if openfl

typedef GLTextureData = openfl.gl.GLTexture;

#elseif lime

typedef GLTextureData = lime.graphics.opengl.GLTexture;

#elseif snow

typedef GLTextureData = snow.render.opengl.GL.GLTexture;

#end