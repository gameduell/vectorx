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

import haxe.xml.Check.Attrib;

class AttributedString
{
    public var attributeStorage(default, null): AttributedSpanStorage = new AttributedSpanStorage();
    public var string(default, null): String;

    public function new (string: String, attributes: StringAttributes = null)
    {
        var index: Int  = 0;
        var length: Int = string.length;

        // Convert string to internal representation.
        this.string = string;

        if (attributes != null)
        {
            index = attributes.range.index;

            if (attributes.range.length != -1)
            {
                length = attributes.range.length;
            }
            else
            {
                length = string.length - index;
            }
        }

        var span: AttributedSpan = new AttributedSpan(string, index, length);

        if (attributes != null)
        {
            span.applyAttributes(attributes);
        }

        attributeStorage.addSpan(span);
    }

    /**
    * Attributes are merged into the current representation state
    * for the specified range by replacing the previous state.
    * Attributes are overriden per String item, if specified in the StringAttributes typedef
    *
    * 0 = attribute disabled / default
    * 1 = attribute set
    *
    * Default attributes  x(010)   x(010)   x(010)   x(010)   x(010)   x(010)   x(010)
    * Applied attributes                    a(011)   a(011)   a(011)   a(011)
    * Applied attributes           b(101)   b(101)   b(101)
    * Result  attributes  y(010)   y(111)   y(111)   y(111)   y(011)   y(011)   y(010)
    *                   [ E      , X      , A      , M      , P      , L      , E      ]
    **/
    public function applyAttributes(attributes: StringAttributes)
    {
        var span: AttributedSpan = new AttributedSpan(string, attributes.range.index, attributes.range.length);
        span.applyAttributes(attributes);
        attributeStorage.addSpan(span);
    }

    public function toString(): String
    {
        return 'AttributedString {string: $string attributes:\n$attributeStorage}';
    }

	public function toAttributedStringPartArray(): Array<AttributedStringPart>
	{
		var result = new Array<AttributedStringPart>();

		for (i in 0...attributeStorage.spans.length)
		{
			var originalSpan: AttributedSpan = attributeStorage.spans[i];
			var origin: Int = originalSpan.range.index;
			var length: Int = originalSpan.range.length;
			var text: String = string.substr(origin, length);
			var span = new AttributedSpan(text, 0, length);
			span.setFromSpan(originalSpan);
			span.range.index = 0;
			span.range.length = length;

			var simpleString: AttributedStringPart = AttributedStringPart.makeWithSpan(text, span);
			result.push(simpleString);
		}

		return result;
	}

	public static function fromAttributedStringPartArray(strings: Array<AttributedStringPart>): AttributedString
	{
		if (strings.length == 0)
		{
			return new AttributedString("", null);
		}

		var text: String = "";
		for (i in 0...strings.length)
		{
			text += strings[i].text;
		}
		var firstAttribute: StringAttributes = strings[0].attributes;
		var result = new AttributedString(text, firstAttribute);
		var position: Int = firstAttribute.range.length;
		for (i in 1...strings.length)
		{
			var attributes: StringAttributes = {
				range: new AttributedRange(position, strings[i].attributes.range.length),
				font: strings[i].attributes.font,
				backgroundColor: strings[i].attributes.backgroundColor,
				foregroundColor: strings[i].attributes.foregroundColor,
				baselineOffset: strings[i].attributes.baselineOffset,
				kern: strings[i].attributes.kern,
				strokeWidth: strings[i].attributes.strokeWidth,
				strokeColor: strings[i].attributes.strokeColor,
				shadow: strings[i].attributes.shadow,
				attachmentId: strings[i].attributes.attachmentId
			};
			result.applyAttributes(attributes);
			position += attributes.range.length;
		}

		return result;
	}
}
