package tests.fontTest;

import lib.ha.svg.SVGData;
import vectorx.svg.SvgContext;
import tests.OpenGLTest;
import vectorx.font.AttributedRange;
import vectorx.font.FontAttachment;
import lib.ha.core.math.Calc;
import lib.ha.aggx.RenderingBuffer;
import lib.ha.core.memory.MemoryAccess;
import types.Color4F;
import haxe.CallStack;
import lib.ha.core.utils.Debug;
import vectorx.font.LayoutBehaviour;
import types.VerticalAlignment;
import types.HorizontalAlignment;
import vectorx.font.FontContext;
import vectorx.ColorStorage;
import types.Range;
import vectorx.font.AttributedString;
import vectorx.font.Font;
import vectorx.font.FontCache;
import tests.utils.Bitmap;
import tests.utils.ImageDecoder;
import tests.utils.AssetLoader;
import duellkit.DuellKit;
import tests.utils.Shader;
import types.Data;
import types.DataStringTools;
import gl.GL;
import gl.GLDefines;

using types.DataStringTools;

class SvgSerializeTest extends OpenGLTest
{
    inline private static var VERTEXSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.vsh";
    inline private static var FRAGMENTSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.fsh";

    inline private static var SVG_PATH_TIGER = "libraryTest/vector/tiger.svg";

    private var textureShader: Shader;
    private var animatedMesh: AnimatedMesh;

    static private var texture: GLTexture;

//---------------------------------------------------------------------------------------------------
    static var pixelBufferWidth:UInt = 1024;
    static var pixelBufferHeight:UInt = 768;
    static var pixelBufferSize:UInt = pixelBufferWidth * pixelBufferHeight * ColorStorage.COMPONENTS;
//---------------------------------------------------------------------------------------------------
    static var data: Data;

    static var enterFrame: Void -> Void = null;

// Create OpenGL objectes (Shaders, Buffers, Textures) here
    override private function onCreate(): Void
    {
        super.onCreate();

        configureOpenGLState();
        createShader();
        createMesh();

        testSvgSerialization();

        createTexture();
    }

// Destroy your created OpenGL objectes
    override public function onDestroy(): Void
    {
        destroyTexture();
        destroyMesh();
        destroyShader();

        super.onDestroy();
    }

    private function configureOpenGLState(): Void
    {
        GL.clearColor(0.5, 0.5, 0.5, 1.0);
    }

    private function createShader()
    {
        var vertexShader: String = AssetLoader.getStringFromFile(VERTEXSHADER_PATH);
        var fragmentShader: String = AssetLoader.getStringFromFile(FRAGMENTSHADER_PATH);

        textureShader = new Shader();
        textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color", "a_TexCoord"], ["u_Tint", "s_Texture"]);
    }

    private function destroyShader(): Void
    {
        textureShader.destroyShader();
    }

    private function createMesh()
    {
        animatedMesh = new AnimatedMesh();
        animatedMesh.createBuffers();
    }

    private function destroyMesh()
    {
        animatedMesh.destroyBuffers();
    }

    private function createTexture(): Void
    {
        data.offset = 0;
        data.offsetLength = pixelBufferSize;

        var bitmap: Bitmap = new Bitmap(data, pixelBufferWidth, pixelBufferHeight, 4);

/// Create, configure and upload opengl texture

        texture = GL.createTexture();

        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

// Configure Filtering Mode
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MAG_FILTER, GLDefines.LINEAR);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MIN_FILTER, GLDefines.LINEAR);

// Configure wrapping
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_S, GLDefines.CLAMP_TO_EDGE);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_T, GLDefines.CLAMP_TO_EDGE);

// Copy data to gpu memory
        switch (bitmap.components)
        {
            case 3:
                {
                    GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 2);
                    GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGB, bitmap.width, bitmap.height, 0, GLDefines.RGB, GLDefines.UNSIGNED_SHORT_5_6_5, bitmap.data);
                }
            case 4:
                {
                    GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
                    GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGBA, bitmap.width, bitmap.height, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, bitmap.data);
                }
            case 1:
                {
                    GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 1);
                    GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.ALPHA, bitmap.width, bitmap.height, 0, GLDefines.ALPHA, GLDefines.UNSIGNED_BYTE, bitmap.data);
                }
            default: throw("Unsupported number of components");
        }

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);
    }

    static private function reuploadTexture()
    {
        data.offset = 0;
        data.offsetLength = pixelBufferSize;

        GL.bindTexture(GLDefines.TEXTURE_2D, texture);
// GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGBA, pixelBufferWidth, pixelBufferHeight, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, data);
        GL.texSubImage2D(GLDefines.TEXTURE_2D, 0, 0, 0, pixelBufferWidth, pixelBufferHeight, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, data);
    }

    private function destroyTexture(): Void
    {
        GL.deleteTexture(texture);
    }

    private function update(deltaTime: Float, currentTime: Float)
    {
        if (enterFrame != null)
        {
            enterFrame();
        }
    }

    override private function render()
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT);

        update(DuellKit.instance().frameDelta, DuellKit.instance().time);

        GL.useProgram(textureShader.shaderProgram);

        GL.uniform4f(textureShader.uniformLocations[0], 1.0, 1.0, 1.0, 1.0);

        GL.activeTexture(GLDefines.TEXTURE0);
        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

        animatedMesh.bindMesh();

        animatedMesh.draw();

        animatedMesh.unbindMesh();
        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);
        GL.useProgram(GL.nullProgram);
    }

    public function testSvgSerialization(): Void
    {
        var svgSrcData = AssetLoader.getDataFromFile(SVG_PATH_TIGER);

        var svgBinData = new Data(1024 * 100);
        var svgXml = Xml.parse(svgSrcData.readString());
        var svgData = new SVGData();

        SvgContext.convertSvgToVectorBin(svgXml, svgBinData);
        svgBinData.offset = 0;
        SvgContext.deserializeVectorBin(svgBinData, svgData);

        var colorStorage: ColorStorage = new ColorStorage(pixelBufferWidth, pixelBufferHeight);
        data = colorStorage.data;

        var svgContext = new SvgContext();

        svgContext.renderVectorBinToColorStorage(svgData, colorStorage);
    }
}
