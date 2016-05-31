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

package vectorx;

import aggx.core.math.Calc;
import types.Data;
import types.RectI;

/**
* The ColorStorage is a container object to be configured before
* passing it to functions. It preallocates and holds the underlaying
* memory for the result of different vector graphics rasterizations.
* The result is always a four component vector with 32 bits per pixel.
* The component order is Red, Green, Blue, Alpha with 8 bits per component.
* The object is meant to be reused for consecutive drawing operations
* with different settings valid for the selectedRect property.
* The rasterization process will respect the rectangle defined
* in the selectedRect property as it would be a single data to write on.
**/
class ColorStorage
{
    /** The number of color components for this storage. The order is RGBA **/
    inline static public var COMPONENTS: Int = 4;

    /** The pixel buffer with the length in bytes of (width * height * COMPONENTS) **/
    public var data(default, null): Data;

    /** The width of data storage in pixels **/
    public var width(default, null): Int;

    /** The height of color data storage in pixels **/
    public var height(default, null): Int;

    /**
    * Defines a sub rectangle within the bounds of width and height seen from top left.
    * Measured in pixels. Default is (0, 0, width, height).
    * The vectorization writes into the selected rect.
    * If x + width exceeds the width of the ColorStorage, rasterizer will clip at the boundary.
    * If y + height exceeds the height of the ColorStorage, rasterizer will clip at the boundary.
    **/
    public var selectedRect(default, null): RectI;

    public function new (width: Int, height: Int, ?data: Data)
    {
        this.width = width;
        this.height = height;
        if (data != null)
        {
            this.data = data;
        }
        else
        {
            this.data = new Data(width * height * COMPONENTS);
        }
        this.selectedRect = new RectI();
        this.selectedRect.width = width;
        this.selectedRect.height = height;
    }

    public function clear(): Void
    {
        for (i in 0 ... this.width * this.height)
        {
            data.offset = i * COMPONENTS;
            data.writeUInt32(0);
        }
    }

    public function fill(color: Int): Void
    {
        for (i in 0 ... this.width * this.height)
        {
            data.offset = i * COMPONENTS;
            data.writeUInt32(color);
        }
    }

    public function resize(width: Int, height: Int): Void
    {
        clear();

        if (width == this.width && height == this.height)
        {
            return;
        }

        var newSize = width * height * COMPONENTS;
        if (data.allocedLength < newSize)
        {
            data.resize(newSize);
        }

        this.width = width;
        this.height = height;

        this.selectedRect.width = width;
        this.selectedRect.height = height;
        this.selectedRect.x = 0;
        this.selectedRect.y = 0;

        data.offset = 0;
    }
}