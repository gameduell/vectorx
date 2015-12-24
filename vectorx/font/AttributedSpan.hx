package vectorx.font;

import types.Vector2;
import types.Color4F;
import vectorx.font.AttributedString.StringAttributes;
import types.Range;

class AttributedSpan
{
    public var range(default, null): AttributedRange = new AttributedRange();
    public var font: Font = null;
    public var backgroundColor: Color4F = null;
    public var foregroundColor: Color4F = null;
    public var baselineOffset:  Null<Float>;
    public var kern: Null<Float> = null;
    public var strokeWidth: Null<Float> = null;
    public var strokeColor: Color4F = null;
    public var shadow: FontShadow = null;
    public var attachment: FontAttachment = null;

    public var baseString(default, null): String;
    public var string(default, null): String;

    private var measure: Vector2 = new Vector2();
    private var measured: Bool = false;

    private var id(default, null): Int;
    private static var nextId: Int = 0;

    public function setFromSpan(other: AttributedSpan)
    {
        this.range.index = other.range.index;
        this.range.length = other.range.length;
        this.font = other.font;
        this.backgroundColor = other.backgroundColor;
        this.foregroundColor = other.foregroundColor;
        this.baselineOffset = other.baselineOffset;
        this.kern = other.kern;
        this.strokeWidth = other.strokeWidth;
        this.strokeColor = other.strokeColor;
        this.shadow = other.shadow;
        this.attachment = other.attachment;
        this.baseString = other.baseString;
        this.string = other.string;
        this.measured = false;
    }

    public function new(string: String, index: Int = 0, len: Int = 0)
    {
        this.range.index = index;
        this.range.length = len;

        if (this.range.length == -1)
        {
            this.range.length = string.length;
        }

        id = nextId++;

        baseString = string;
        updateString();
    }

    public function updateString()
    {
        this.string = baseString.substr(range.index, range.length);
    }

    public function toString(): String
    {
        //return '{id: $id, range: ${range.index}[${range.length}] str: $string font: $font backgroud: $backgroundColor measure: {x: ${measure.x} y: ${measure.y}} attachment: $attachment}';
        return '{id: $id, range: ${range.index}[${range.length}] str: $string kern: $kern font: $font}';
    }

    private inline function choose<T>(dst: T, src: T)
    {
        if (src == null)
        {
            return dst;
        }

        return src;
    }

    private inline function chooseBefore<T>(dst: T, src: T)
    {
        if (dst == null)
        {
            return src;
        }

        return dst;
    }

    public function applyBefore(source: AttributedSpan)
    {
        font = chooseBefore(font, source.font);
        backgroundColor = chooseBefore(backgroundColor, source.backgroundColor);
        foregroundColor = chooseBefore(foregroundColor, source.foregroundColor);
        baselineOffset = chooseBefore(baselineOffset, source.baselineOffset);
        kern = chooseBefore(kern, source.kern);
        strokeWidth = chooseBefore(strokeWidth, source.strokeWidth);
        strokeColor = chooseBefore(strokeColor, source.strokeColor);
        shadow = chooseBefore(shadow, source.shadow);
        attachment = chooseBefore(attachment, source.attachment);
        measured = false;
    }

    public function apply(source: AttributedSpan)
    {
        font = choose(font, source.font);
        backgroundColor = choose(backgroundColor, source.backgroundColor);
        foregroundColor = choose(foregroundColor, source.foregroundColor);
        baselineOffset = choose(baselineOffset, source.baselineOffset);
        kern = choose(kern, source.kern);
        strokeWidth = choose(strokeWidth, source.strokeWidth);
        strokeColor = choose(strokeColor, source.strokeColor);
        shadow = choose(shadow, source.shadow);
        attachment = choose(attachment, source.attachment);
        measured = false;
    }

    public function applyAttributes(source: StringAttributes)
    {
        font = choose(font, source.font);
        backgroundColor = choose(backgroundColor, source.backgroundColor);
        foregroundColor = choose(foregroundColor, source.foregroundColor);
        baselineOffset = choose(baselineOffset, source.baselineOffset);
        kern = choose(kern, source.kern);
        strokeWidth = choose(strokeWidth, source.strokeWidth);
        strokeColor = choose(strokeColor, source.strokeColor);
        shadow = choose(shadow, source.shadow);
        attachment = choose(attachment, source.attachment);
        measured = false;
    }

    public function getMeasure(): Vector2
    {
        if (!measured)
        {
            if (range.length == 0)
            {
                measure.setXY(0, 0);
            }
            else
            {
                var kern = this.kern == null ? 0 : this.kern;
                font.internalFont.measureString(string, font.sizeInPt, measure, kern);
            }

            measured = true;
        }

        return measure;
    }
}
