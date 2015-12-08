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

import types.RectI;
import haxe.Utf8;
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

    private static var defaultTextlayout: TextLayoutConfig =
    {
        pointsToPixelRatio: 1,
        horizontalAlignment: HorizontalAlignment.Left,
        verticalAlignment: VerticalAlignment.Top,
        layoutBehaviour: LayoutBehaviour.Clip
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

        if (layoutConfig == null)
        {
            layoutConfig = defaultTextlayout;
        }

        var renderingBuffer = new RenderingBuffer(outStorage.width, outStorage.height, ColorStorage.COMPONENTS * outStorage.width);
        var pixelFormatRenderer = new PixelFormatRenderer(renderingBuffer);
        var clippingRenderer = new ClippingRenderer(pixelFormatRenderer);
        var scanlineRenderer = new SolidScanlineRenderer(clippingRenderer);

        var cleanUpList: Array<FontEngine> = [];

        /*clippingRenderer.setClippingBounds(outStorage.selectedRect.x, outStorage.selectedRect.y,
            outStorage.selectedRect.x + outStorage.selectedRect.width,
            outStorage.selectedRect.y + outStorage.selectedRect.height);*/

        debugBox(outStorage.selectedRect.x, outStorage.selectedRect.y, outStorage.selectedRect.width, outStorage.selectedRect.height);

        var lines: Array<TextLine> = TextLine.calculate(attrString, outStorage.selectedRect.width, layoutConfig.pointsToPixelRatio);

        var height: Float = 0;
        for (line in lines)
        {
            height += line.maxBgHeight;
        }

        var y: Float = alignY(layoutConfig.verticalAlignment, outStorage.selectedRect, height);

        for (line in lines)
        {
            trace('rendering line: $line');

            var x: Float = alignX(layoutConfig.horizontalAlignment, outStorage.selectedRect, line);

            attrString.attributeStorage.eachSpanInRange(function(span: AttributedSpan): Void
            {
                trace('rendering span: $span');

                var fontEngine: FontEngine = span.font.internalFont;
                cleanUpList.push(fontEngine);
                fontEngine.rasterizer = rasterizer;
                fontEngine.scanline = scanline;

                var spanString: String = span.string;
                var measure = span.getMeasure();

                var measureX = measure.x * layoutConfig.pointsToPixelRatio;
                var measureY = measure.y * layoutConfig.pointsToPixelRatio;

                var alignY: Float = line.maxSpanHeight - measureY;
                debugBox(x, y + alignY, measureX, measureY);

                var baseLineOffset = span.baselineOffset == null ? defaultAttributes.baselineOffset : span.baselineOffset;
                baseLineOffset *= layoutConfig.pointsToPixelRatio;

                var kern = span.kern == null ? 0 : span.kern;
                kern *= layoutConfig.pointsToPixelRatio;

                var bboxX = x;
                for (i in 0 ... Utf8.length(spanString))
                {
                    var face = fontEngine.getFace(Utf8.charCodeAt(spanString, i));
                    var scale = fontEngine.getScale(span.font.sizeInPt) * layoutConfig.pointsToPixelRatio;
                    if (face.glyph.bounds != null)
                    {
                        var bx =  face.glyph.bounds.x1 * scale;
                        var by =  -face.glyph.bounds.y1 * scale;
                        var w = (face.glyph.bounds.x2 - face.glyph.bounds.x1) * scale;
                        var h = (-face.glyph.bounds.y2 - -face.glyph.bounds.y1) * scale;
                        //trace('h: $h y: ${measureY + by + alignY} max: $maxSpanHeight');
                        debugBox(bboxX + bx, y + measureY + by + alignY + baseLineOffset, w, h);
                    }

                    bboxX += face.glyph.advanceWidth * scale + kern;
                }

                if (span.backgroundColor != null)
                {
                    scanlineRenderer.color.setFromColor4F(span.backgroundColor);
                    //trace('bg: ${scanlineRenderer.color}');
                    box(path, x, y, measureX + 1, line.maxBgHeight + 1);
                    rasterizer.reset();
                    rasterizer.addPath(path);
                    SolidScanlineRenderer.renderScanlines(rasterizer, scanline, scanlineRenderer);
                    path.removeAll();
                }

                //trace('fg: ${scanlineRenderer.color}');

                if (span.foregroundColor != null)
                {
                    scanlineRenderer.color.setFromColor4F(span.foregroundColor);
                }
                else
                {
                    scanlineRenderer.color.setFromColor4F(defaultAttributes.foregroundColor);
                }

                if (span.strokeWidth == null || span.strokeWidth < 0)
                {
                    fontEngine.renderString(spanString, span.font.sizeInPt * layoutConfig.pointsToPixelRatio, x, y + alignY + baseLineOffset, scanlineRenderer, kern);
                }

                if (span.strokeWidth != null)
                {
                    if (span.strokeColor != null)
                    {
                        scanlineRenderer.color.setFromColor4F(span.strokeColor);
                    }

                    var strokeWidth = Math.abs(span.strokeWidth);

                    fontEngine.renderStringStroke(spanString, span.font.sizeInPt * layoutConfig.pointsToPixelRatio, x, y + alignY + baseLineOffset, scanlineRenderer, strokeWidth, kern);
                }

                x += measureX;

            }, line.begin, line.lenght);

            y += line.maxBgHeight;
        }

        //renderDebugPath(scanlineRenderer);

        MemoryAccess.select(null);
        for (font in cleanUpList)
        {
            font.scanline = null;
            font.scanline = null;
        }
    }

    private function alignX(align: HorizontalAlignment, rect: RectI, line: TextLine): Float
    {
        switch (align)
        {
            case null | HorizontalAlignment.Left:
                {
                    return rect.x;
                }
            case HorizontalAlignment.Right:
                {
                    return rect.x + rect.width - line.width;
                }
            case HorizontalAlignment.Center:
                {
                    return rect.x + (rect.width - line.width) / 2;
                }
        }
    }

    private function alignY(align: VerticalAlignment, rect: RectI, height: Float): Float
    {
        switch (align)
        {
            case null | VerticalAlignment.Top:
                {
                    return rect.y;
                }
            case VerticalAlignment.Bottom:
                {
                    return rect.y + rect.height - height;
                }
            case VerticalAlignment.Middle:
                {
                    return rect.y + (rect.height - height) / 2;
                }
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
