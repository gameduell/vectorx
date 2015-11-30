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

import lib.ha.aggx.vectorial.converters.ConvStroke;
import lib.ha.svg.SVGColors;
import lib.ha.aggx.vectorial.PathFlags;
import lib.ha.aggx.vectorial.VectorPath;
import types.Range;
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
    private var rasterizer: ScanlineRasterizer;
    private var fontCache: FontCache;
    private var debugPath: VectorPath = new VectorPath();
    private var path: VectorPath = new VectorPath();
    private var debugPathStroke: ConvStroke;

    private static var defaultAttributes: StringAttributes =
    {
        range: new Range(),
        foregroundColor: new Color4F(),
        baselineOffset: 0,
        strokeWidth: 0,
        strokeColor: new Color4F()
    };

    public function new()
    {
        rasterizer = new ScanlineRasterizer();
        scanline = new Scanline();
        var ttfData: Data = AssetLoader.getDataFromFile("libraryTest/fonts/arial.ttf");
        fontCache = new FontCache(ttfData);
        debugPathStroke = new ConvStroke(debugPath);
        debugPathStroke.width = 2;
    }

    /// TODO add docu
    /// Implement text layouting and glyph rasterization using aggx library
    /// and move / seperate necessary logic
    public function renderStringToColorStorage(attrString: AttributedString,
                                                      outStorage: ColorStorage,
                                                      layoutConfig: TextLayoutConfig = null): Void
    {
        MemoryAccess.select(outStorage.data);
        var renderingBuffer = new RenderingBuffer(outStorage.width, outStorage.height, ColorStorage.COMPONENTS * outStorage.width);
        var pixelFormatRenderer = new PixelFormatRenderer(renderingBuffer);
        var clippingRenderer = new ClippingRenderer(pixelFormatRenderer);
        var scanlineRenderer = new SolidScanlineRenderer(clippingRenderer);
        var cleanUpList: Array<FontEngine> = [];

        clippingRenderer.setClippingBounds(outStorage.selectedRect.x, outStorage.selectedRect.y,
            outStorage.selectedRect.x + outStorage.selectedRect.width,
            outStorage.selectedRect.y + outStorage.selectedRect.height);

        debugBox(outStorage.selectedRect.x, outStorage.selectedRect.y, outStorage.selectedRect.width, outStorage.selectedRect.height);

        var x: Float = outStorage.selectedRect.x;
        var y: Float = outStorage.selectedRect.y;

        trace('{${outStorage.selectedRect}}');

        var measure: Vector2 = new Vector2();
        for (span in attrString.attributeStorage.spans)
        {
            trace('rendering span: $span');

            var fontEngine: FontEngine = span.font.internalFont;
            cleanUpList.push(fontEngine);
            fontEngine.rasterizer = rasterizer;
            fontEngine.scanline = scanline;

            var spanString: String = attrString.string.substr(span.range.index, span.range.length);
            fontEngine.measureString(spanString, span.font.sizeInPt, measure);
            trace(measure);
            debugBox(x, y, measure.x, measure.y);

            if (span.backgroundColor != null)
            {
                scanlineRenderer.color.setFromColor4F(span.backgroundColor);
                //trace('bg: ${scanlineRenderer.color}');
                box(path, x, y, measure.x + 1, measure.y + 1);
                rasterizer.reset();
                rasterizer.addPath(path);
                SolidScanlineRenderer.renderScanlines(rasterizer, scanline, scanlineRenderer);
                path.removeAll();
            }

            if (span.foregroundColor != null)
            {
                scanlineRenderer.color.setFromColor4F(span.foregroundColor);
            }
            else
            {
                scanlineRenderer.color.setFromColor4F(defaultAttributes.foregroundColor);
            }

            //trace('fg: ${scanlineRenderer.color}');
            fontEngine.renderString(spanString, span.font.sizeInPt, x, y, scanlineRenderer, measure);
            x += measure.x;
        }

        //renderDebugPath(scanlineRenderer);

        MemoryAccess.select(null);
        for (font in cleanUpList)
        {
            font.scanline = null;
            font.scanline = null;
        }
    }

    private function renderDebugPath(renderer: SolidScanlineRenderer)
    {
        rasterizer.addPath(debugPathStroke);
        renderer.color = SVGColors.get("hotpink");
        SolidScanlineRenderer.renderScanlines(rasterizer, scanline, renderer);
        rasterizer.reset();
        debugPath.removeAll();
    }

    private static function box(target: VectorPath, x: Float, y: Float, w: Float, h: Float)
    {
        target.moveTo(x, y);
        target.lineTo(x + w, y);
        target.lineTo(x + w, y + h);
        target.lineTo(x,y + h);
        target.endPoly(PathFlags.CLOSE);
    }

    private function debugBox(x: Float, y: Float, w: Float, h: Float)
    {
        box(debugPath, x, y, w, h);
    }
}
