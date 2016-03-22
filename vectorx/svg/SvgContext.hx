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

package vectorx.svg;

import aggx.core.math.Calc;
import aggx.core.geometry.AffineTransformer;
import aggx.svg.SVGData;
import aggx.svg.SVGDataBuilder;
import aggx.svg.SVGParser;
import aggx.svg.SVGRenderer;
import aggx.rasterizer.ScanlineRasterizer;
import aggx.rasterizer.Scanline;
import aggx.renderer.SolidScanlineRenderer;
import aggx.renderer.ClippingRenderer;
import aggx.renderer.PixelFormatRenderer;
import aggx.RenderingBuffer;
import aggx.core.memory.MemoryAccess;
import haxe.io.Bytes;
import types.Data;

class SvgContext
{
    private var scanline: Scanline;
    private var rasterizer: ScanlineRasterizer;
    private var svgRenderer: SVGRenderer;
    private var transform: AffineTransformer;

    private static var dataWrapper: SvgDataWrapper = new SvgDataWrapper();

    public function new()
    {
        rasterizer = new ScanlineRasterizer();
        scanline = new Scanline();
        svgRenderer = new SVGRenderer();
        transform = new AffineTransformer();
    }

    public static function parseSvg(svg: Xml): SVGData
    {
        var builder = new SVGDataBuilder();
        var parser = new SVGParser(builder);
        parser.processXML(svg);

        return builder.data;
    }

    // Compile time // Unit tests // This function should be compiled to a standalone
    // application which serves the artist as a checker if their provides svg are correct.
    // Further it is used in a buildstep to convert all svg assets to our binary format.
    public static function convertSvgToVectorBin(inSvg: Xml, outVectorBin: Data)
    {
        // Checks svg for compliance and parses the svg into our intermediate format which is binary.

        // Compliance should include TODO
        // Every SVG must specify width and height in Points
        // Check throws/logs error if features are used which are not supported

        var svgData = parseSvg(inSvg);

        dataWrapper.data = outVectorBin;
        SvgSerializer.writeSvgData(dataWrapper, svgData);
        dataWrapper.data = null;
    }

    /*
     * To goal of converting the svg to our intermediate binary format at compile-time
     * is to save time when reading it at runtime and not to ship raw svgs into the product,
     * but a one directional format, which cannot easily converted back to SVG. (Saves art work copyrights)
     *
     * The format should somehow look similar to the data which is created during the parsing
     * in the SVGParser/SVGPathRenderer class of aggx.
     *
     * One of the slow things of the svg parsing from xml is, that is allows for different type
     * of representation for the same data. (For example you can separated by comma or space).
     * Having this in an own fixed and single defined way improves the parsing process.
     *
      * */

    
    // RunTime // Unit tests TODO
    public static function deserializeVectorBin(inVectorBin: Data, outVectorBin: SVGData)
    {
        dataWrapper.data = inVectorBin;
        SvgSerializer.readSvgData(dataWrapper, outVectorBin);
        dataWrapper.data = null;
    }

    public function renderVectorBinToColorStorage(inVectorBin: SVGData, outStorage: ColorStorage, ?transform: AffineTransformer): Void
    {
        var prevMemory = MemoryAccess.domainMemory;
        MemoryAccess.select(outStorage.data);

        var renderingBuffer = new RenderingBuffer(outStorage.width, outStorage.height, ColorStorage.COMPONENTS * outStorage.width);
        var pixelFormatRenderer = new PixelFormatRenderer(renderingBuffer);
        var clippingRenderer = new ClippingRenderer(pixelFormatRenderer);
        var scanlineRenderer = new SolidScanlineRenderer(clippingRenderer);

        clippingRenderer.setClippingBounds(outStorage.selectedRect.x,
                                            outStorage.selectedRect.y,
                                            outStorage.selectedRect.x + outStorage.selectedRect.width,
                                            outStorage.selectedRect.y + outStorage.selectedRect.height);
        inVectorBin.expandValue = 0.1;
        var alpha = 1.0;

        if (transform == null)
        {
            transform = AffineTransformer.translator(0.0, 0.0);
        }

        svgRenderer.render(inVectorBin, rasterizer, scanline, clippingRenderer, transform, alpha);

        MemoryAccess.select(prevMemory);
    }
}