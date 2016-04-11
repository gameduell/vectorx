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

class AttributedStringPart
{
	public var text (default, default): String;
	public var attributes (default, set): StringAttributes;

	private var span: AttributedSpan;

	public static function makeWithSpan(text: String, span: AttributedSpan): AttributedStringPart
	{
		var attributes: StringAttributes = {
			range: span.range,
			font: span.font,
			backgroundColor: span.backgroundColor,
			foregroundColor: span.foregroundColor,
			baselineOffset: span.baselineOffset,
			kern: span.kern,
			strokeWidth: span.strokeWidth,
			strokeColor: span.strokeColor,
			shadow: span.shadow,
			attachmentId: span.attachmentId
		};
		return new AttributedStringPart(text, attributes);
	}

	public function new(text: String, attributes: StringAttributes)
	{
		span = new AttributedSpan(text, 0, text.length);

		this.text = text;
		this.attributes = attributes;
	}

	public function toString(): String
    {
        return 'AttributedStringPart {string: $text span:\n$span}';
    }

	private function set_attributes(value: StringAttributes): StringAttributes
	{
		this.attributes = value;
		if (value != null)
		{
			span.applyAttributes(value);
		}

		return value;
	}
}
