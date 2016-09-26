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
import aggx.core.utils.Debug;
import aggx.renderer.BlenderBase;
import aggx.core.memory.Pointer;
import aggx.core.memory.Byte;
import types.DataType;
import aggx.core.math.Calc;
import types.RectI;
import haxe.Utf8;
import aggx.vectorial.converters.ConvStroke;
import aggx.svg.SVGColors;
import aggx.vectorial.PathFlags;
import aggx.vectorial.VectorPath;
import types.Range;
import types.Vector2;
import types.Color4F;
import vectorx.font.StringAttributes;
import aggx.core.memory.MemoryAccess;
import aggx.rfpx.TrueTypeCollection;
import aggx.color.RgbaColor;
import aggx.typography.FontEngine;
import aggx.renderer.SolidScanlineRenderer;
import aggx.rasterizer.ScanlineRasterizer;
import aggx.rasterizer.Scanline;
import aggx.renderer.ClippingRenderer;
import aggx.renderer.PixelFormatRenderer;
import aggx.RenderingBuffer;
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

    private var blur: StackBlur = new StackBlur();

    private var measure: Vector2;

    public static var defaultAttributes: StringAttributes =
    {
        range: new AttributedRange(),
        foregroundColor: new Color4F(1, 1, 1, 1),
        baselineOffset: 0,
        strokeWidth: 0,
        strokeColor: new Color4F(),
        size: 25,
        extraLineSpacing: 0
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

        for (i in 0 ... textLayout.lines.length)
        {
            var line = textLayout.lines[i];
            var isLastLine = i == textLayout.lines.length - 1;
            var isFirstLine = i == 0;

            var x: Float = textLayout.alignX(line);

            var extraLineSpacing: Float = 0.;
            if ( !isFirstLine && line.spans.length > 0)
            {
                var span = line.spans[0];
                extraLineSpacing += span.extraLineSpacing != null ? span.extraLineSpacing : defaultAttributes.extraLineSpacing;
            }

            extraLineSpacing *= pixelRatio;

            if (renderTrimmed)
            {
                x -= textLayout.outputRect.x;
            }

            //y += extraLineSpacing;

            debugBox(x, y, line.width, line.maxBgHeight + extraLineSpacing);
            //baseline
            debugBox(x, y + line.maxSpanHeight + extraLineSpacing, line.width, 1);

            for (span in line.spans)
            {
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

                //intentionally left for debugging
                //debugBox(x, y + alignY, measureX + attachmentWidth, measureY);

                //render glyphs bboxes
#if vectorDebugDraw
                var dbgSpanWidth: Float = 0.0;
                var bboxX = x;
                for (i in 0 ... Utf8.length(spanString))
                {
                    var face = fontEngine.getFace(Utf8.charCodeAt(spanString, i));
                    var scale = fontEngine.getScale(span.getFontSize()) * pixelRatio;
                    if (face.glyph.bounds != null)
                    {
                        var bx =  face.glyph.bounds.x1 * scale;
                        var by =  -face.glyph.bounds.y1 * scale;
                        var w = (face.glyph.bounds.x2 - face.glyph.bounds.x1) * scale;
                        var h = (-face.glyph.bounds.y2 - -face.glyph.bounds.y1) * scale;
                        //intentionally left for debugging
                        //trace('h: $h y: ${measureY + by + alignY} max: $maxSpanHeight');
                        //trace('${Utf8.sub(spanString, i, 1)} w: $w h: $h advance: ${face.glyph.advanceWidth * scale} kern: $kern bboxX: ${bboxX + face.glyph.advanceWidth * scale + kern - textLayout.alignX(line)}');
                        debugBox(bboxX + bx, y + measure.y + by + alignY + baseLineOffset + extraLineSpacing, w, h);
                        ////debugBox(bboxX, y + measureY + by + alignY + baseLineOffset, face.glyph.advanceWidth * scale + kern, line.maxSpanHeight);
                    }

                    bboxX += face.glyph.advanceWidth * scale + kern;
                    dbgSpanWidth += face.glyph.advanceWidth * scale + kern;
                }

                Debug.assert(Math.abs(dbgSpanWidth) - Math.abs(measure.x) < 0.001, 'span width calculation');
#end

                //fill background if present
                if (span.backgroundColor != null && span.backgroundColor.a >= 1.0/255)
                {
                    scanlineRenderer.color.setFromColor4F(span.backgroundColor);
                    var height = isLastLine ? line.maxBgHeightWithShadow : line.maxBgHeight + extraLineSpacing;

                    box(path, x, y, measure.x + 1 + attachmentWidth,  height + 1);
                    rasterizer.reset();
                    rasterizer.addPath(path);
                    SolidScanlineRenderer.renderScanlines(rasterizer, scanline, scanlineRenderer);
                    path.removeAll();
                }

                var spanY: Float = y + alignY + baseLineOffset + extraLineSpacing;

                //render text shadows

                if (span.haveShadow())
                {
                    var shadow = span.shadow;
                    renderSpanShadow(span, pixelRatio, fontEngine, shadow.color, Math.ceil(shadow.blurRadius));
                    if (shadow.blurRadius > 0)
                    {
                        blur.blur(shadowBuffer, Math.ceil(shadow.blurRadius));
                    }
                    var dstX = Math.ceil(x + shadow.offset.x * pixelRatio - shadow.blurRadius);
                    var dstY = Math.ceil(spanY + shadow.offset.y * pixelRatio - shadow.blurRadius);
                    blendFromColorStorage(dstX, dstY, outStorage, shadowBuffer, shadowBuffer.selectedRect);
                }

                //render glyphs
                if (span.foregroundColor != null)
                {
                    scanlineRenderer.color.setFromColor4F(span.foregroundColor);
                }
                else
                {
                    scanlineRenderer.color.setFromColor4F(defaultAttributes.foregroundColor);
                }

                if (span.strokeWidth == null || span.strokeWidth >= 0)
                {
                    fontEngine.renderString(spanString, span.getFontSize() * pixelRatio, x, spanY, scanlineRenderer, kern);
                }

                //render outline
                if (span.strokeWidth != null)
                {
                    if (span.strokeColor != null)
                    {
                        scanlineRenderer.color.setFromColor4F(span.strokeColor);
                    }

                    var strokeWidth = Math.abs(span.strokeWidth);

                    fontEngine.renderStringStroke(spanString, span.getFontSize() * pixelRatio, x, spanY, scanlineRenderer, strokeWidth, kern);
                }

                x += measure.x;

                //render attachment
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

                    var alignY: Float = line.maxSpanHeight - attachment.bounds.height + attachment.heightBelowBaseline();
                    var spanY: Float = y + alignY + baseLineOffset;
                    debugBox(dstX, spanY, width, height);

                    blendFromColorStorage(Math.ceil(x), Math.ceil(spanY), outStorage, attachment.image, attachment.bounds);

                    x += attachment.bounds.width + 1;
                    srcData.offset = srcOffset;
                    dstData.offset = dstOffset;
                }

                fontEngine.rasterizer = null;
                fontEngine.scanline = null;
            }

            //y += line.maxBgHeight + extraLineSpacing;
            y += line.maxSpanHeight + extraLineSpacing;
        }

        renderDebugPath(scanlineRenderer);

        #if vectorFontRectDebug
        {
            var color = new Color4F(0, 0, 0, 0.3);
            if (dbgCount++ % 2 == 0)
            {
                trace('red');
                color.r = 1;
            }
            else
            {
                trace('green');
                color.g = 1;
            }
            scanlineRenderer.color.setFromColor4F(color);
            if (renderTrimmed)
            {
                box(path, 0, 0, textLayout.outputRect.width,  textLayout.outputRect.height);
            }
            else
            {
                box(path, textLayout.outputRect.x, textLayout.outputRect.y, textLayout.outputRect.width,  textLayout.outputRect.height);
            }
            rasterizer.reset();
            rasterizer.addPath(path);
            SolidScanlineRenderer.renderScanlines(rasterizer, scanline, scanlineRenderer);
            path.removeAll();
        }
        #end //vectorFontRectDebug

        MemoryAccess.select(prevMemory);
    }

    private static var dbgCount: UInt = 0;

    private static function blendFromColorStorage(x: Int, y: Int, destination: ColorStorage, source: ColorStorage, sourceRect: RectI)
    {
        var dstX = x < 0 ? 0 : x;

        var srcData = source.data;
        var dstData = destination.data;

        var srcOffset = srcData.offset;
        var dstOffset = dstData.offset;

        var distanceToBorder: Int = destination.selectedRect.x + destination.selectedRect.width - dstX;
        var width: Int = Calc.min(distanceToBorder, sourceRect.width);

        var beginY = x < 0 ? -x : 0;
        for (i in beginY ... sourceRect.height)
        {
            var srcYOffset: Int = i + sourceRect.y;
            if (srcYOffset > destination.selectedRect.y + destination.selectedRect.height)
            {
                break;
            }

            var src: Int = (source.width * srcYOffset + sourceRect.x) * ColorStorage.COMPONENTS;

            var dstY: Int = y + i;
            if (dstY >= destination.selectedRect.y + destination.selectedRect.height)
            {
                break;
            }

            if (dstY < destination.selectedRect.y)
            {
                continue;
            }

            var dst: Int = (destination.width * dstY + dstX) * ColorStorage.COMPONENTS;

            srcData.offset = src;

            var beginX = x < 0 ? -x : 0;
            srcData.offset += beginX * ColorStorage.COMPONENTS;
            for (j in beginX ... width)
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

    private function renderSpanShadow(span: AttributedSpan, pixelRatio: Float, fontEngine: FontEngine, color: Color4F, blurRadius: Int): ColorStorage
    {
        var width: Int = Math.ceil(Math.abs(measure.x + blurRadius * 2));
        var height: Int = Math.ceil(span.bboxHeight + blurRadius * 2);

        if (shadowBuffer == null)
        {
            shadowBuffer = new ColorStorage(width, height);
        }
        else
        {
            shadowBuffer.resize(width, height);
        }

        if (width == 0 || height == 0)
        {
            return shadowBuffer;
        }

        var memory = MemoryAccess.domainMemory;
        MemoryAccess.domainMemory = shadowBuffer.data;

        try
        {
            var stride: Int = ColorStorage.COMPONENTS * width;
            shadowRenderingStack = RenderingStack.initialise(shadowRenderingStack, width, height, stride);
            var renderer: SolidScanlineRenderer = shadowRenderingStack.scanlineRenderer;
            renderer.color.setFromColor4F(color);
            shadowBuffer.fill(renderer.color.b << 16 | renderer.color.g << 8 | renderer.color.r);
            fontEngine.renderString(span.string, span.getFontSize() * pixelRatio, blurRadius, blurRadius, renderer, span.kern * pixelRatio);
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
            renderer.color.set(SVGColors.get("turquoise"));
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
        target.lineTo(x, y + h);
        target.endPoly(PathFlags.CLOSE);
    }

    private inline function debugBox(x: Float, y: Float, w: Float, h: Float)
    {
        #if vectorDebugDraw
            box(debugPath, x, y, w, h);
        #end
    }
}
