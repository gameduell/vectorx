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

import types.Vector2;
import types.Color4F;
import vectorx.font.AttributedString.StringAttributes;
import lib.ha.core.memory.MemoryAccess;
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
    private var scanline: Scanline;
    private var rasterizerizer: ScanlineRasterizer;
    private var fontCache: FontCache;
    private static var defaultAttributes: StringAttributes =
    {
        foregroundColor: new Color4F(),
        baselineOffset: 0,
        strokeWidth: 0,
        strokeColor: new Color4F()
    };

    public function new()
    {
        rasterizerizer = new ScanlineRasterizer();
        scanline = new Scanline();
        var ttfData: Data = AssetLoader.getDataFromFile("libraryTest/fonts/arial.ttf");
        fontCache = new FontCache(ttfData);
    }

    /// TODO add docu
    /// Implement text layouting and glyph rasterization using aggx library
    /// and move / seperate necessary logic
    public function renderStringToColorStorage(attrString: AttributedString,
                                                      outStorage: ColorStorage,
                                                      layoutConfig: TextLayoutConfig = null): Void
    {
        var data = outStorage.data;
        MemoryAccess.select(data);
        var renderingBuffer = new RenderingBuffer(outStorage.width, outStorage.height, ColorStorage.COMPONENTS * outStorage.width);
        var pixelFormatRenderer = new PixelFormatRenderer(renderingBuffer);
        var clippingRenderer = new ClippingRenderer(pixelFormatRenderer);
        var scanlineRenderer = new SolidScanlineRenderer(clippingRenderer);

        //clippingRenderer.setClippingBounds(outStorage.selectedRect.x, outStorage.selectedRect.y, outStorage.selectedRect.width, outStorage.selectedRect.height);

        var x: Float = outStorage.selectedRect.x;
        var y: Float = outStorage.selectedRect.y;

        var measure: Vector2 = new Vector2();
        for (span in attrString.attributeStorage.spans)
        {
            var fontEngine: FontEngine = span.font.internalFont;
            var spanString: String = attrString.string.substr(span.range.index, span.range.length);
            fontEngine.measureString(spanString, measure);
            var dy: Float = measure.y / 2;
            fontEngine.renderString(spanString, span.font.sizeInPt)
        }

        MemoryAccess.select(null);
    }
}
