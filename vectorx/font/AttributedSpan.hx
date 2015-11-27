package vectorx.font;

import types.Color4F;
import vectorx.font.AttributedString.StringAttributes;
import types.Range;

class AttributedSpan
{
    public var range(default, null): AttributedRange;
    public var font: Font = null;
    public var backgroundColor: Color4F = null;
    public var foregroundColor: Color4F = null;
    public var baselineOffset:  Null<Float>;
    public var kern: Null<Float> = null;
    public var strokeWidth: Null<Float> = null;
    public var strokeColor: Color4F = null;
    public var shadow: FontShadow = null;
    public var attachment: FontAttachment = null;

    private var id(default, null): Int;
    private static var nextId: Int = 0;

    public function new(range: AttributedRange)
    {
        this.range = range;
        id = nextId++;
    }

    public function toString(): String
    {
        if (font != null)
        {
            return '{id: $id, index: ${range.index} length: ${range.length} fon: $font}';
        }

        return '{id: $id, index: ${range.index} length: ${range.length}}';
    }

    private inline function choose<T>(dst: T, src: T)
    {
        if (src == null)
        {
            return dst;
        }

        return src;
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
    }

    public function applyDefaults(source: StringAttributes)
    {

    }
}
