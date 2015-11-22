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

package vectorx.font;

import lib.ha.rfpx.TrueTypeCollection;
import lib.ha.rfpx.TrueTypeCollection;
import tests.utils.AssetLoader;
import lib.ha.aggx.color.RgbaColor;
import lib.ha.aggx.typography.FontEngine;
import lib.ha.aggx.renderer.SolidScanlineRenderer;
import lib.ha.aggx.rasterizer.ScanlineRasterizer;
import lib.ha.aggx.rasterizer.Scanline;
import lib.ha.aggx.renderer.ClippingRenderer;
import lib.ha.aggx.renderer.PixelFormatRenderer;
import lib.ha.aggx.RenderingBuffer;
import lib.ha.core.memory.MemoryManager;
import types.Data;
import types.VerticalAlignment;
import types.HorizontalAlignment;

typedef TextLayoutConfig =
{
    var pointsToPixelRatio: Float; // Default 1.0
    var horizontalAlignment: HorizontalAlignment; // Default left
    var verticalAlignment: VerticalAlignment; // Default top
    var layoutBehaviour: LayoutBehaviour; // Default Clip
}

class FontContext
{
    private var _scanline:Scanline;
    private var _rasterizerizer:ScanlineRasterizer;

    public function new()
    {
        _rasterizerizer = new ScanlineRasterizer();
        _scanline = new Scanline();
    }

    /// TODO add docu
    /// Implement text layouting and glyph rasterization using aggx library
    /// and move / seperate necessary logic
    public function renderStringToColorStorage(attrString: AttributedString,
                                                      outStorage: ColorStorage,
                                                      layoutConfig: TextLayoutConfig = null): Void
    {
        var data = outStorage.data;
        var pixelBuffer = MemoryManager.mallocEx(data);
        var renderingBuffer = new RenderingBuffer(pixelBuffer, outStorage.width, outStorage.height, ColorStorage.COMPONENTS * outStorage.width);
        var pixelFormatRenderer = new PixelFormatRenderer(renderingBuffer);
        var clippingRenderer = new ClippingRenderer(pixelFormatRenderer);
        var scanlineRenderer = new SolidScanlineRenderer(clippingRenderer);

        var string1 = "ABCDEFGHJIKLMNOPQRSTUVWXYZ";
        var string2 = "abcdefghjiklmnopqrstuvwxyz";
        var string3 = "1234567890";
        var string4 = "!@#$%^&*()_+|{}:?><~`';/.,";
        var string5 = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦШЩЭЮЯ";
        var string6 = "абвгдеёжзийклмнопрстуфхцшщэюя";
        var japanString1 = '「ほのかアンティーク角」フォントは角ゴシックの漢字に合わせたウロコの付きの文字を組み合わせたアンチック体（アンティーク体）の日本語フォントです。';
        var japanString2 = '漢字等についてはオープンソースフォント「源柔ゴシック」を使用させて頂いております（詳細は後述）。';
        var japanString3 = '個人での利用のほか、商用利用においてデザイナーやクリエイターの方もご活用いただけます。';

        var ttfData: Data = AssetLoader.getDataFromFile("libraryTest/fonts/font_1_ant-kaku.ttf");
        var fontEngine = new FontEngine(TrueTypeCollection.create(ttfData));
        var fontSize = 80;

        scanlineRenderer.color = new RgbaColor(255, 0, 0);

        var x = 10;
        var y = 0 * fontSize / 20;

        fontEngine.renderString(string1, fontSize, x, y, scanlineRenderer);

        scanlineRenderer.color = new RgbaColor(27, 106, 240);

        var x = 10;
        var y = 20 * fontSize / 20;

        fontEngine.renderString(string2, fontSize, x, y, scanlineRenderer);

        scanlineRenderer.color = new RgbaColor(227, 200, 26);

        var x = 10;
        var y = 40 * fontSize / 20;

        fontEngine.renderString(string3, fontSize, x, y, scanlineRenderer);

        scanlineRenderer.color = new RgbaColor(106, 27, 240);

        var x = 10;
        var y = 60 * fontSize / 20;

        fontEngine.renderString(string4, fontSize, x, y, scanlineRenderer);

        scanlineRenderer.color = new RgbaColor(136, 207, 100);

        var x = 10;
        var y = 80 * fontSize / 20;

        fontEngine.renderString(string5, fontSize, x, y, scanlineRenderer);

        scanlineRenderer.color = new RgbaColor(136, 20, 50);

        var x = 10;
        var y = 100 * fontSize / 20;

        fontEngine.renderString(string6, fontSize, x, y, scanlineRenderer);

        var x = 10;
        var y = 120 * fontSize / 20;

        fontEngine.renderString(japanString1, fontSize, x, y, scanlineRenderer);

        var x = 10;
        var y = 140 * fontSize / 20;

        fontEngine.renderString(japanString2, fontSize, x, y, scanlineRenderer);

        var x = 10;
        var y = 160 * fontSize / 20;

        fontEngine.renderString(japanString3, fontSize, x, y, scanlineRenderer);
    }
}
