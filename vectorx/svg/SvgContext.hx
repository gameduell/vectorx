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

import haxe.io.Bytes;
import types.Data;
class SvgContext
{
    // TODO

    public function new()
    {
    }

    // Compile time // Unit tests // This function should be compiled to a standalone
    // application which serves the artist as a checker if their provides svg are correct.
    // Further it is used in a buildstep to convert all svg assets to our binary format.
    public function convertSvgToVectorBin(inSvg: Xml, outVectorBin: Bytes)
    {
        // Checks svg for compliance and parses the svg into our intermediate format which is binary.

        // Compliance should include TODO
        // Every SVG must specify width and height in Points
        // Check throws/logs error if features are used which are not supported
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
    public function deserializeVectorBin(inVectorBin: Data, outVectorBin: VectorBin)
    {

    }

    // RunTime TODO
    public function renderVectorBinToColorStorage(inVectorBin: VectorBin, outStorage: ColorStorage): Void
    {

    }
}


class VectorBin
{

}
