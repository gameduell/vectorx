/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package tests.fontTest;

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
import gl.GL;
import gl.GLDefines;

class FontTest extends OpenGLTest
{
    inline private static var IMAGE_PATH = "libraryTest/images/lena.png";
    inline private static var FONT_PATH_ARIAL = "libraryTest/fonts/arial.ttf";
    inline private static var FONT_PATH_COMIC = "libraryTest/fonts/Pacifico.ttf";
    inline private static var FONT_PATH_JAPAN = "libraryTest/fonts/font_1_ant-kaku.ttf";

    inline private static var VERTEXSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.vsh";
    inline private static var FRAGMENTSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.fsh";

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

        testFontCreation();

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
        GL.clearColor(0.8, 0.8, 0.8, 1.0);
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

    private function testFontCreation()
    {
        var ttfData: Data = AssetLoader.getDataFromFile(FONT_PATH_JAPAN);

        var string1 = "ABCDEFGHJIKLMNOPQRSTUVWXYZ";
        var string2 = "abcdefghjiklmnopqrstuvwxyz";
        var string3 = "1234567890";
        var string4 = "!@#$%^&*()_+|{}:?><~`';/.,";
        var string5 = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦШЩЭЮЯ";
        var string6 = "абвгдеёжзийклмнопрстуфхцшщэюя";
        var japanString1 = '「ほのかアンティーク角」フォントは角ゴシックの漢字に合わせたウロコの付きの文字を組み合わせたアンチック体（アンティーク体）の日本語フォントです。';
        var japanString2 = '漢字等についてはオープンソースフォント「源柔ゴシック」を使用させて頂いております（詳細は後述）。';
        var japanString3 = '個人での利用のほか、商用利用においてデザイナーやクリエイターの方もご活用いただけます。';
        // TODO test strings with line breaks \n

        var ttfData: Data = AssetLoader.getDataFromFile("libraryTest/fonts/arial.ttf");
        var fontCache: FontCache = new FontCache(ttfData);

        var fontContext: FontContext = new FontContext();

        var font: Font = fontCache.createFontWithNameAndSize("Arial", 25.0);
        var font2: Font = fontCache.createFontWithNameAndSize("Arial", 20.0);
        var font3: Font = fontCache.createFontWithNameAndSize("Arial", 15.0);
        var font4: Font = fontCache.createFontWithNameAndSize("Arial", 10.0);


        var stringAttributes: StringAttributes = {range: new Range(), font: font};

        var attributedString: AttributedString = new AttributedString(string1, stringAttributes);

        var red: Color4F = new Color4F();
        red.setRGBA(1, 0, 0, 1);
        var green: Color4F = new Color4F();
        green.setRGBA(0, 1, 0, 1);
        var blue: Color4F = new Color4F();
        blue.setRGBA(0, 0, 1, 1);
        var white: Color4F = new Color4F();
        white.setRGBA(1, 1, 1, 1);

        //trace('test inside case');
        var stringAttributes2: StringAttributes = {range: new Range(10, 10), font: font2, foregroundColor: red, backgroundColor: white};
        attributedString.applyAttributes(stringAttributes2);
        //trace(attributedString);

        //trace('test left-right case');
        var stringAttributes3: StringAttributes = {range: new Range(5, 10), font: font3, foregroundColor: green};
        attributedString.applyAttributes(stringAttributes3);
        //trace(attributedString);

        //trace('full cover');
        var stringAttributes4: StringAttributes = {range: new Range(5, 10), font: font4, foregroundColor: blue};
        attributedString.applyAttributes(stringAttributes4);
        //trace(attributedString);

        // TODO test applying attributes

        var colorStorage: ColorStorage = new ColorStorage(pixelBufferWidth, pixelBufferHeight);
        data = colorStorage.data;
        colorStorage.selectedRect.x = 10;
        colorStorage.selectedRect.y = 20;
        colorStorage.selectedRect.width = 200;
        colorStorage.selectedRect.height = 300;

        var layoutConfig: TextLayoutConfig = {pointsToPixelRatio: 1.0,
                                              horizontalAlignment: HorizontalAlignment.Left,
                                              verticalAlignment: VerticalAlignment.Top,
                                              layoutBehaviour: LayoutBehaviour.Clip};

        fontContext.renderStringToColorStorage(attributedString, colorStorage, layoutConfig);
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
}