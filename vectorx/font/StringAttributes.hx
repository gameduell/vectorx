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

import types.Color4F;
import types.Range;

typedef StringAttributes = {
    /** Range to apply the attributes on the string **/
    var range: AttributedRange; // Default entire string range

    /** Font from FontCache **/
    @:optional var font: Font; // Defaul null (default font)

    /** Font size **/
    @:optional var size: Int; // Default 25

    /** Background color of the string **/
    @:optional var backgroundColor: Color4F; // null (no background color)

    /** Foreground color of the string **/
    @:optional var foregroundColor: Color4F; // Default black

    /**
    * Float value, as points offset from baseline
    * The baseline offset attribute is a literal distance,
    * in pixels, by which the characters should be shifted
    * above the baseline (for positive offsets) or below (for negative offsets).
    **/
    @:optional var baselineOffset:  Null<Float>; // Default 0.0

    /**
    * Default null, use default kerning specified in font file;
    * 0.0, kerning off; non-zero, points by which to modify default kerning
    * The kerning attribute indicates how much the following character
    * should be shifted from its default offset as defined by the
    * current character’s font; a positive kern indicates a shift
    * farther along and a negative kern indicates a shift closer to the current character.
    **/
    @:optional var kern: Null<Float>; // Defaul null

    /**
    * Float value, as percent of font point size
    * Default 0.0, no stroke;
    * negative, stroke alone;
    * positive, stroke and fill
    * (a typical value for outlined text would be 3.0)
    **/
    @:optional var strokeWidth: Null<Float>; // Default 0.0

    /** Stroke color of the string **/
    @:optional var strokeColor: Color4F; // null (same as foregroundColor)

    /** Shadow object **/
    @:optional var shadow: FontShadow; // null (no shadow)

    /** Extra line spacing **/
    @:optional var extraLineSpacing: Null<Float>; // Default 0.0

    @:optional var attachmentId: String; // null (no attachment)
}
