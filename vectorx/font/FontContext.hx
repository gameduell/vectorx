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

import lib.ha.core.utils.Debug;
import lib.ha.aggx.renderer.BlenderBase;
import lib.ha.core.memory.Pointer;
import lib.ha.core.memory.Byte;
import types.DataType;
import lib.ha.core.math.Calc;
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
    private var debugPath: VectorPath = new VectorPath();
    private var path: VectorPath = new VectorPath();
    private var debugPathStroke: ConvStroke;

    private static var defaultAttributes: StringAttributes =
    {
        range: new AttributedRange(),
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
        debugPathStroke = new ConvStroke(debugPath);
        debugPathStroke.width = 1;
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

        var textLayout = new TextLayout(attrString, layoutConfig, outStorage.selectedRect);
        var pixelRatio: Float = textLayout.pixelRatio;
        var y: Float = textLayout.alignY();

        debugBox(outStorage.selectedRect.x, y, outStorage.selectedRect.width, textLayout.height);

        for (line in textLayout.lines)
        {
            //trace('rendering line: $line');

            var x: Float = textLayout.alignX(line);

            for (span in line.spans)
            {
                //trace('rendering span: $span');

                var fontEngine: FontEngine = span.font.internalFont;
                cleanUpList.push(fontEngine);
                fontEngine.rasterizer = rasterizer;
                fontEngine.scanline = scanline;

                var spanString: String = span.string;
                var measure = span.getMeasure();

                var measureX = measure.x * pixelRatio;
                var measureY = measure.y * pixelRatio;

                var alignY: Float = line.maxSpanHeight - measureY;

                var baseLineOffset = span.baselineOffset == null ? defaultAttributes.baselineOffset : span.baselineOffset;
                baseLineOffset *= pixelRatio;

                var kern = span.kern == null ? 0 : span.kern;
                kern *= pixelRatio;

                var attachmentWidth: Float = 0;
                if (span.attachment != null)
                {
                    attachmentWidth = span.attachment.bounds.width + 2;
                }

                //debugBox(x, y + alignY, measureX + attachmentWidth, measureY);

                var dbgSpanWidth: Float = 0.0;
                var bboxX = x;
                for (i in 0 ... Utf8.length(spanString))
                {
                    var face = fontEngine.getFace(Utf8.charCodeAt(spanString, i));
                    var scale = fontEngine.getScale(span.font.sizeInPt) * pixelRatio;
                    if (face.glyph.bounds != null)
                    {
                        var bx =  face.glyph.bounds.x1 * scale;
                        var by =  -face.glyph.bounds.y1 * scale;
                        var w = (face.glyph.bounds.x2 - face.glyph.bounds.x1) * scale;
                        var h = (-face.glyph.bounds.y2 - -face.glyph.bounds.y1) * scale;
                        //trace('h: $h y: ${measureY + by + alignY} max: $maxSpanHeight');
                        //trace('${Utf8.sub(spanString, i, 1)} w: $w h: $h advance: ${face.glyph.advanceWidth * scale} kern: $kern bboxX: ${bboxX + face.glyph.advanceWidth * scale + kern - textLayout.alignX(line)}');
                        //debugBox(bboxX + bx, y + measureY + by + alignY + baseLineOffset, w, h);
                        ////debugBox(bboxX, y + measureY + by + alignY + baseLineOffset, face.glyph.advanceWidth * scale + kern, line.maxSpanHeight);
                    }

                    bboxX += face.glyph.advanceWidth * scale + kern;
                    dbgSpanWidth += face.glyph.advanceWidth * scale + kern;
                    //trace('bboxX: $bboxX');
                }

                Debug.assert(Math.abs(dbgSpanWidth) - Math.abs(measureX) < 0.001, 'span width calculation');

                if (span.backgroundColor != null)
                {
                    scanlineRenderer.color.setFromColor4F(span.backgroundColor);
                    //trace('bg: ${scanlineRenderer.color}');
                    box(path, x, y, measureX + 1 + attachmentWidth, line.maxBgHeight + 1);
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
                    fontEngine.renderString(spanString, span.font.sizeInPt * pixelRatio, x, y + alignY + baseLineOffset, scanlineRenderer, kern);
                }

                if (span.strokeWidth != null)
                {
                    if (span.strokeColor != null)
                    {
                        scanlineRenderer.color.setFromColor4F(span.strokeColor);
                    }

                    var strokeWidth = Math.abs(span.strokeWidth);

                    fontEngine.renderStringStroke(spanString, span.font.sizeInPt * pixelRatio, x, y + alignY + baseLineOffset, scanlineRenderer, strokeWidth, kern);
                }

                x += measureX;

                if (span.attachment != null)
                {
                    var attachment = span.attachment;
                    var dstX: Int = Math.ceil(x) + 1;

                    var distanceToBorder: Int = outStorage.selectedRect.x + outStorage.selectedRect.width - dstX;
                    var width: Int = Calc.min(distanceToBorder, span.attachment.bounds.width);
                    var height: Int = span.attachment.bounds.height;

                    var srcData = attachment.image.data;
                    var dstData = outStorage.data;

                    var srcOffset = srcData.offset;
                    var dstOffset = dstData.offset;

                    var alignY: Float = line.maxSpanHeight - attachment.bounds.height;
                    debugBox(dstX, y + alignY + baseLineOffset, width, height);

                    for (i in 0 ... height)
                    {
                        var srcYOffset: Int = i + attachment.bounds.y + Math.ceil(baseLineOffset);
                        var src: Int = (attachment.image.width * srcYOffset + attachment.bounds.x) * ColorStorage.COMPONENTS;

                        var dstY: Int = Math.ceil(y + alignY + baseLineOffset);
                        if (dstY >= outStorage.selectedRect.y + outStorage.selectedRect.height)
                        {
                            break;
                        }

                        var dst: Int = (outStorage.width * (i + dstY) + dstX) * ColorStorage.COMPONENTS;

                        srcData.offset = src;

                        for (j in 0 ... width)
                        {
                            var r: Byte = srcData.readUInt8();
                            srcData.offset++;
                            var g: Byte = srcData.readUInt8();
                            srcData.offset++;
                            var b: Byte = srcData.readUInt8();
                            srcData.offset++;
                            var a: Byte = srcData.readUInt8();
                            srcData.offset++;

                            BlenderBase.blendPix(dst, r, g, b, a);

                            dst += ColorStorage.COMPONENTS;
                        }
                    }

                    srcData.offset = srcOffset;
                    dstData.offset = dstOffset;

                    x += attachment.bounds.width + 1;
                }

            };

            y += line.maxBgHeight;
        }

        renderDebugPath(scanlineRenderer);

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
