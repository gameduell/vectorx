package vectorx.font;

import haxe.Utf8;
import types.Vector2;
import types.Color4F;
import vectorx.font.StringAttributes;
import types.Range;

class AttributedSpan
{
    public var range(default, null): AttributedRange = new AttributedRange();
    public var font: Font = null;
    public var backgroundColor: Color4F = null;
    public var foregroundColor: Color4F = null;
    public var baselineOffset:  Null<Float>;
    public var kern: Null<Float> = null;
    public var size: Null<Int>;
    public var strokeWidth: Null<Float> = null;
    public var strokeColor: Color4F = null;
    public var shadow: FontShadow = null;
    public var attachment: FontAttachment = null;
    public var attachmentId: String = null;
    public var extraLineSpacing: Null<Float> = null;

    public var baseString(default, null): String;
    public var string(default, null): String;
    public var bboxHeight: Float;

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
        this.attachmentId = other.attachmentId;
        this.baseString = other.baseString;
        this.string = other.string;
        this.size = other.size;
        this.extraLineSpacing = other.extraLineSpacing;
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
        this.string = Utf8.sub(baseString, range.index, range.length);
    }

    public function toString(): String
    {
        //return '{id: $id, range: ${range.index}[${range.length}] str: $string font: $font backgroud: $backgroundColor measure: {x: ${measure.x} y: ${measure.y}} attachment: $attachment}';
        return '{id: $id, range: ${range.index}[${range.length}] str: $string font: $font attachment: $attachmentId}';
    }

    private inline function choose<T>(dst: T, src: T)
    {
		return src == null ? dst : src;
    }

    private inline function chooseBefore<T>(dst: T, src: T)
    {
		return dst == null ? src : dst;
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
        attachmentId = chooseBefore(attachmentId, source.attachmentId);
        size = chooseBefore(size, source.size);
        extraLineSpacing = chooseBefore(extraLineSpacing, source.extraLineSpacing);

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
        attachmentId = choose(attachmentId, source.attachmentId);
        size = choose(size, source.size);
        extraLineSpacing = choose(extraLineSpacing, source.extraLineSpacing);

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
        attachmentId = choose(attachmentId, source.attachmentId);

        size = choose(size, source.size);

        extraLineSpacing = choose(extraLineSpacing, source.extraLineSpacing);

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
                font.internalFont.measureString(string, getFontSize(), measure, kern);
            }

            measured = true;
        }

        return measure;
    }

    public function haveShadow()
    {
        return shadow != null && string != null && string.length > 0;
    }

    public function getFontSize(): Int
    {
        if (size == null)
        {
            return FontContext.defaultAttributes.size;
        }

        return size;
    }
    public function getFinalSize(pixelRatio: Float, ?output: Vector2): Vector2
    {
        if (output == null)
        {
            output = new Vector2();
        }

        var measure = getMeasure();

        output.x = measure.x * pixelRatio;
        output.y = measure.y * pixelRatio;

        return output;
    }
}
