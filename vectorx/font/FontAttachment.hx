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

import aggx.core.utils.Debug;
import types.RectI;

class FontAttachment
{
    /**
    * Ref to Image object which will be blit into the target storage at the current
    * character position instead of rendering the current character.
    * @Warning object is not copied. Take care of reseting the state of selecteRect.
    **/
    public var image(get, null): ColorStorage;

    /** Defines the layout bounds of the receiver's graphical representation in the text coordinate system. (pts) **/
    public var bounds(default, null): RectI; // Default zero uses the selectedRect of the image

    public var anchorPoint: Float;

    private var loadImage: Void -> ColorStorage;
    private var cachedImage: ColorStorage;

    public function new(loadImage: Void -> ColorStorage, x: Int, y: Int, width: Int, height: Int, anchorPoint: Float = 0)
    {
        this.loadImage = loadImage;
        this.bounds = new RectI();
        this.bounds.x = x;
        this.bounds.y = y;
        this.bounds.width = width;
        this.bounds.height = height;
        this.anchorPoint = anchorPoint;
    }

    private function get_image(): ColorStorage
    {
        if (cachedImage == null)
        {
            cachedImage = loadImage();
            this.bounds.x = cachedImage.selectedRect.x;
            this.bounds.y = cachedImage.selectedRect.y;
            if (!Debug.assert(this.bounds.width == cachedImage.selectedRect.width, "width must not change"))
            {
                trace('old: ${this.bounds.width} new: ${cachedImage.selectedRect.width}');
            }

            if (!Debug.assert(this.bounds.height == cachedImage.selectedRect.height, "height must not change"))
            {
                trace('old: ${this.bounds.height} new: ${cachedImage.selectedRect.height}');
            }

            this.bounds.width = cachedImage.selectedRect.width;
            this.bounds.height = cachedImage.selectedRect.height;
        }

        return cachedImage;
    }

    public function heightBelowBaseline(): Float
    {
        return anchorPoint * bounds.height;
    }

    public function heightAboveBaseline(): Float
    {
        return (1 - anchorPoint) * bounds.height;
    }

    public function toString(): String
    {
        return '{x: ${bounds.x} y; ${bounds.y} width: ${bounds.width} height: ${bounds.height} loaded: ${cachedImage != null}}';
    }
}
