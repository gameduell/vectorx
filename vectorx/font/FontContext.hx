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

import vectorx.font.TextLayout;
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
    var scale: Float; // Default 1.0
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


    private var renderingStack: RenderingStack;

    private var shadowBuffer: ColorStorage;
    private var shadowRenderingStack: RenderingStack;

    private var measure: Vector2;

    private static var defaultAttributes: StringAttributes =
    {
        range: new AttributedRange(),
        foregroundColor: new Color4F(1, 1, 1, 1),
        baselineOffset: 0,
        strokeWidth: 0,
        strokeColor: new Color4F()
    };

    private static var defaultTextlayout: TextLayoutConfig =
    {
        scale: 1,
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

    public function calculateTextLayout(attrString: AttributedString,
                                        selectedRect: RectI,
                                        ?layoutConfig: TextLayoutConfig,
                                        ?attachmentResolver: String -> Float -> FontAttachment): TextLayout
    {
        if (layoutConfig == null)
        {
            layoutConfig = defaultTextlayout;
        }

        var textLayout = new TextLayout(attrString, layoutConfig, selectedRect, attachmentResolver);

        return textLayout;
    }

    /// TODO add docu
    /// Implement text layouting and glyph rasterization using aggx library
    /// and move / seperate necessary logic
    public function renderStringToColorStorage(textLayout: TextLayout, outStorage: ColorStorage, renderTrimmed: Bool = false): Void
    {
        if (outStorage.width == 0 || outStorage.height == 0)
        {
            return;
        }

        var prevMemory = MemoryAccess.domainMemory;
        MemoryAccess.select(outStorage.data);

        var stride = ColorStorage.COMPONENTS * outStorage.width;
        renderingStack = RenderingStack.initialise(renderingStack, outStorage.width, outStorage.height, stride);
        var scanlineRenderer = renderingStack.scanlineRenderer;

        debugBox(outStorage.selectedRect.x, outStorage.selectedRect.y, outStorage.selectedRect.width, outStorage.selectedRect.height);

        var pixelRatio: Float = textLayout.pixelRatio;
        var y: Float = textLayout.alignY();

        if (renderTrimmed)
        {
            y -= textLayout.outputRect.y;
        }

        debugBox(textLayout.outputRect.x, textLayout.outputRect.y, textLayout.outputRect.width, textLayout.outputRect.height);

        for (line in textLayout.lines)
        {
            //trace('rendering line: $line');

            var x: Float = textLayout.alignX(line);

            if (renderTrimmed)
            {
                x -= textLayout.outputRect.x;
            }

            debugBox(x, y, line.width, line.maxBgHeight);
            //baseline
            debugBox(x, y + line.maxSpanHeight, line.width, 1);

            for (span in line.spans)
            {
                //trace('rendering span: $span');

                var fontEngine: FontEngine = span.font.internalFont;
                fontEngine.rasterizer = rasterizer;
                fontEngine.scanline = scanline;

                var spanString: String = span.string;
                measure = span.getFinalSize(pixelRatio, measure);

                var alignY: Float = line.maxSpanHeight - measure.y;

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

#if vectorDebugDraw
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
                        debugBox(bboxX + bx, y + measure.y + by + alignY + baseLineOffset, w, h);
                        ////debugBox(bboxX, y + measureY + by + alignY + baseLineOffset, face.glyph.advanceWidth * scale + kern, line.maxSpanHeight);
                    }

                    bboxX += face.glyph.advanceWidth * scale + kern;
                    dbgSpanWidth += face.glyph.advanceWidth * scale + kern;
                    //trace('bboxX: $bboxX');
                }

                Debug.assert(Math.abs(dbgSpanWidth) - Math.abs(measure.x) < 0.001, 'span width calculation');
#end

                //trace('bg color: ${span.backgroundColor}');
                if (span.backgroundColor != null)
                {
                    scanlineRenderer.color.setFromColor4F(span.backgroundColor);
                    //trace('actual bg: ${scanlineRenderer.color}');
                    box(path, x, y, measure.x + 1 + attachmentWidth, line.maxBgHeight + 1);
                    rasterizer.reset();
                    rasterizer.addPath(path);
                    SolidScanlineRenderer.renderScanlines(rasterizer, scanline, scanlineRenderer);
                    path.removeAll();
                }

                //trace('fg: ${span.foregroundColor}');

                var spanY: Float = y + alignY + baseLineOffset;

                //if(span.shadow != null)
                var shadowData = new FontShadow();
                shadowData.offset.x = 2;
                shadowData.offset.y = 2;

                var shadow = renderSpanShadow(span, pixelRatio, fontEngine, shadowData.color, scanlineRenderer);


                if (span.foregroundColor != null)
                {
                    scanlineRenderer.color.setFromColor4F(span.foregroundColor);
                }
                else
                {
                    scanlineRenderer.color.setFromColor4F(defaultAttributes.foregroundColor);
                }

                //trace('actual fg: ${scanlineRenderer.color}');

                fontEngine.renderString(spanString, span.font.sizeInPt * pixelRatio, x, spanY, scanlineRenderer, kern);

                if (span.strokeWidth != null)
                {
                    if (span.strokeColor != null)
                    {
                        scanlineRenderer.color.setFromColor4F(span.strokeColor);
                    }

                    var strokeWidth = Math.abs(span.strokeWidth);

                    fontEngine.renderStringStroke(spanString, span.font.sizeInPt * pixelRatio, x, spanY, scanlineRenderer, strokeWidth, kern);
                }

                x += measure.x;

                if (span.attachment != null)
                {
                    //trace('Rendering attachment id: ${span.attachmentId} ${span.attachment}');

                    var attachment = span.attachment;
                    var dstX: Int = Math.ceil(x) + 1;

                    var distanceToBorder: Int = outStorage.selectedRect.x + outStorage.selectedRect.width - dstX;
                    var width: Int = Calc.min(distanceToBorder, span.attachment.bounds.width);
                    var height: Int = span.attachment.bounds.height;

                    var srcData = attachment.image.data;
                    var dstData = outStorage.data;

                    var srcOffset = srcData.offset;
                    var dstOffset = dstData.offset;

                    var alignY: Float = line.maxSpanHeight - attachment.bounds.height + attachment.heightBelowBaseline();
                    debugBox(dstX, spanY, width, height);

                    for (i in 0 ... height)
                    {
                        var srcYOffset: Int = i + attachment.bounds.y;
                        if (srcYOffset > outStorage.selectedRect.y + outStorage.selectedRect.height)
                        {
                            break;
                        }

                        var src: Int = (attachment.image.width * srcYOffset + attachment.bounds.x) * ColorStorage.COMPONENTS;

                        var dstY: Int = Math.ceil(spanY) + i + Math.ceil(baseLineOffset);
                        if (dstY >= outStorage.selectedRect.y + outStorage.selectedRect.height)
                        {
                            break;
                        }

                        if (dstY < outStorage.selectedRect.y)
                        {
                            continue;
                        }

                        //trace('dstY: $dstY dstX: $dstX rect: ${outStorage.selectedRect}');

                        var dst: Int = (outStorage.width * dstY + dstX) * ColorStorage.COMPONENTS;

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

                    x += attachment.bounds.width + 1;
                }

                fontEngine.rasterizer = null;
                fontEngine.scanline = null;
            }

            y += line.maxBgHeight;
        }

        renderDebugPath(scanlineRenderer);

        MemoryAccess.select(prevMemory);
    }

    private static function blendFromColorStorage(x: Int, y: Int, source: ColorStorage, sourceRect: RectI)
    {
        var dstX = x;

        var srcData = source.data;
        var dstData = MemoryAccess.domainMemory;

        var srcOffset = srcData.offset;
        var dstOffset = dstData.offset;

        for (i in 0 ... height)
        {
            var srcYOffset: Int = i + attachment.bounds.y;
            if (srcYOffset > outStorage.selectedRect.y + outStorage.selectedRect.height)
            {
                break;
            }

            var src: Int = (attachment.image.width * srcYOffset + attachment.bounds.x) * ColorStorage.COMPONENTS;

            var dstY: Int = y + i;
            if (dstY >= outStorage.selectedRect.y + outStorage.selectedRect.height)
            {
                break;
            }

            if (dstY < outStorage.selectedRect.y)
            {
                continue;
            }

            //trace('dstY: $dstY dstX: $dstX rect: ${outStorage.selectedRect}');

            var dst: Int = (outStorage.width * dstY + dstX) * ColorStorage.COMPONENTS;

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
    }

    private function renderSpanShadow(span: AttributedSpan, pixelRatio: Float, fontEngine: FontEngine, color: Color4F): ColorStorage
    {
        var width: Int = Math.ceil(measure.x);
        var height: Int = Math.ceil(measure.y);

        if (shadowBuffer == null)
        {
            shadowBuffer = new ColorStorage(width, height);
        }
        else
        {
            shadowBuffer.resize(width, height);
        }

        var memory = MemoryAccess.domainMemory;
        MemoryAccess.domainMemory = shadowBuffer.data;

        try
        {
            var stride: Int = ColorStorage.COMPONENTS * width;
            shadowRenderingStack = RenderingStack.initialise(shadowRenderingStack, width, height, stride);
            var renderer = shadowRenderingStack.scanlineRenderer;
            renderer.color.setFromColor4F(color);
            fontEngine.renderString(span.string, span.font.sizeInPt * pixelRatio, 0, 0, renderer, span.kern * pixelRatio);
        }
        catch(ex: Dynamic)
        {
            MemoryAccess.domainMemory = memory;
            throw ex;
        }

        MemoryAccess.domainMemory = memory;

        return shadowBuffer;
    }

    private inline function renderDebugPath(renderer: SolidScanlineRenderer)
    {
        #if vectorDebugDraw
            rasterizer.addPath(debugPathStroke);
            renderer.color.set(SVGColors.get("hotpink"));
            SolidScanlineRenderer.renderScanlines(rasterizer, scanline, renderer);
            rasterizer.reset();
            debugPath.removeAll();
        #end
    }

    private static inline function box(target: VectorPath, x: Float, y: Float, w: Float, h: Float)
    {
        target.moveTo(x, y);
        target.lineTo(x + w, y);
        target.lineTo(x + w, y + h);
        target.lineTo(x,y + h);
        target.endPoly(PathFlags.CLOSE);
    }

    private inline function debugBox(x: Float, y: Float, w: Float, h: Float)
    {
        #if vectorDebugDraw
            box(debugPath, x, y, w, h);
        #end
    }
}
