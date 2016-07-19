package vectorx.font;

import types.Vector2;
import aggx.core.utils.Debug;
import aggx.typography.FontEngine;
import haxe.Utf8;
import StringTools;

using StringTools;

class TextLine
{
    public var begin(default, null): Int;
    public var lenght(get, null): Int;
    public var width(default, null): Float = 0;
    public var maxSpanHeight(default, null): Float = 0;
    public var maxBgHeight(default, null): Float = 0;
    public var maxBgHeightWithShadow(default, null): Float = 0;

    public var spans: Array<AttributedSpan> = [];

    private var breakAt: Int = -1;
    private var charAtBreakPos: Int = 0;

    private var measure: Vector2;

    private static inline var SPACE = 32;
    private static inline var TAB = 9;
    private static inline var NEWLINE = 10;

    public function toString(): String
    {
        var str: StringBuf = new StringBuf();
        str.add('{begin: $begin breakAt: $breakAt len: $lenght width: $width maxSpanHeight: $maxSpanHeight maxBgHeight: $maxBgHeight spans:\n {');
        for (span in spans)
        {
            str.add('{$span}\n');
        }
        str.add("}");
        return str.toString();
    }

    public function getLineString(): String
    {
        var str: StringBuf = new StringBuf();
        for (span in spans)
        {
            str.add('${span.string}');
        }
        return str.toString();
    }

    public function lastSpan(): AttributedSpan
    {
        if (spans.length == 0)
        {
            return null;
        }

        return spans[spans.length - 1];
    }

    private function new(begin: Int = 0)
    {
        this.begin = begin;
    }

    public function get_lenght(): Int
    {
        if (breakAt == -1)
        {
            return -1;
        }

        return breakAt - begin;
    }

    private function calculateMaxSpanHeight(span: AttributedSpan, pixelRatio: Float)
    {
        var fontEngine: FontEngine = span.font.internalFont;
        var spanString: String = span.string;
        measure = span.getFinalSize(pixelRatio, measure);
        if (measure.y > maxSpanHeight)
        {
            maxSpanHeight = measure.y;
        }

        if (span.attachment != null)
        {
            var attachmentHeight = span.attachment.heightAboveBaseline();
            if (attachmentHeight > maxSpanHeight)
            {
                maxSpanHeight = attachmentHeight;
            }
        }
    }

    private function calculateMaxBgHeight(span: AttributedSpan, pixelRatio: Float)
    {
        var fontEngine: FontEngine = span.font.internalFont;
        var spanString: String = span.string;
        measure = span.getFinalSize(pixelRatio, measure);

        var alignY: Float = maxSpanHeight - measure.y;

        for (i in 0 ... Utf8.length(spanString))
        {
            var face = fontEngine.getFace(Utf8.charCodeAt(spanString, i));
            if (face.glyph.bounds == null)
            {
                continue;
            }
            var scale = fontEngine.getScale(span.getFontSize());

            var by =  -face.glyph.bounds.y1 * scale * pixelRatio;

            var ext: Float = alignY + measure.y + by;
            if (ext > maxBgHeight)
            {
                maxBgHeight = ext;
                span.bboxHeight = ext;
            }

            if (span.haveShadow())
            {
                var shadowExt = ext + span.shadow.offset.y * pixelRatio + span.shadow.blurRadius;
                if (shadowExt > maxBgHeightWithShadow)
                {
                    maxBgHeightWithShadow = shadowExt;
                }
            }
        }

        if (span.attachment != null)
        {
            var ext = maxSpanHeight + span.attachment.heightBelowBaseline();
            if (ext > maxBgHeight)
            {
                maxBgHeight = ext;
            }
        }

        maxBgHeight = Math.max(maxSpanHeight, maxBgHeight);
        maxBgHeightWithShadow = Math.max(maxBgHeightWithShadow, maxBgHeight);
    }

    private static var currentWidth: Float = 0;
    private static var textWidth: Float = 0;
    private static var pos: Int = 0;
    private static var currentLine: TextLine = null;

    public static function calculate(string: AttributedString, width: Float, attachmentResolver: String -> Float -> FontAttachment, pixelRatio: Float = 1.0): Array<TextLine>
    {
        var output: Array<TextLine> = [];

        currentWidth = 0;
        pos = 0;
        textWidth = width;

        currentLine = new TextLine();
        output.push(currentLine);

        var spanIterator = string.attributeStorage.iterator();
        while (spanIterator.hasNext())
        {
            var span: AttributedSpan = spanIterator.next();
            if (span.attachmentId != null)
            {
                span.attachment = attachmentResolver(span.attachmentId, pixelRatio);
            }
            currentLine.spans.push(span);

            var fontEngine: FontEngine = span.font.internalFont;
            var spanString: String = span.string;
            var scale = fontEngine.getScale(span.getFontSize()) * pixelRatio;
            var kern = span.kern == null ? 0 : span.kern;
            kern *= pixelRatio;

            var shadowExt: Float = 0;
            if (span.haveShadow())
            {
                shadowExt = span.shadow.offset.x * pixelRatio + span.shadow.blurRadius;
            }

            for (i in 0 ... Utf8.length(spanString))
            {
                var advance: Float = 0;
                var needNewLine: Bool = false;
                var code: Int = Utf8.charCodeAt(spanString, i);

                if (code == NEWLINE)
                {
                    var force: Bool = true;
                    span = newLine(code, output, 0, 0, force);
                }
                else
                {
                    if (code == SPACE || code == TAB)
                    {
                        currentLine.breakAt = pos;
                        currentLine.charAtBreakPos = code;
                        currentLine.width = currentWidth;
                    }

                    var face = fontEngine.getFace(code);
                    advance = face.glyph.advanceWidth * scale + kern;
                }

                span = newLine(code, output, advance, shadowExt);
                pos++;
            }

            if (span.attachment != null)
            {
                var code: Int = 0x1F601;
                var advance: Float = span.attachment.bounds.width + 2;
                span = newLine(code, output, advance, 0);
            }
        }

        output[output.length - 1].breakAt = -1;
        output[output.length - 1].width = currentWidth;

        for(line in output)
        {
            for (span in line.spans)
            {
                line.calculateMaxSpanHeight(span, pixelRatio);
            }

            for (span in line.spans)
            {
                line.calculateMaxBgHeight(span, pixelRatio);
            }
        }

        currentLine = null;
        return output;
    }

    private static function newLine(code: Int, output: Array<TextLine>, advance: Float, shadow:Float, force: Bool = false): AttributedSpan
    {
        var currentSpan = currentLine.spans[currentLine.spans.length - 1];

        if (currentWidth + advance + shadow > textWidth || force)
        {
            if (currentLine.breakAt == -1)
            {
                currentLine.breakAt = pos;
                currentLine.charAtBreakPos = code;
                currentLine.width = currentWidth;
            }
            currentWidth -= currentLine.width;

            var startAt: Int = currentLine.breakAt;
            switch (currentLine.charAtBreakPos)
            {
                case SPACE | TAB | NEWLINE: startAt++;
                default:
            }

            var rightBound = currentSpan.range.index + currentSpan.range.length;
            var leftSpanLength: Int = startAt - currentSpan.range.index;
            if (rightBound >= startAt || (rightBound == startAt && currentSpan.attachment != null))
            {
                currentLine.spans.pop();
                if (leftSpanLength > 0)
                {
                    var leftSpan: AttributedSpan = new AttributedSpan("");
                    leftSpan.setFromSpan(currentSpan);
                    leftSpan.attachment = null;
                    leftSpan.range.length = leftSpanLength;
                    leftSpan.updateString();
                    currentLine.spans.push(leftSpan);
                }

                var rightSpan: AttributedSpan = new AttributedSpan("");
                rightSpan.setFromSpan(currentSpan);
                rightSpan.range.index = startAt;
                rightSpan.range.length = currentSpan.range.length - leftSpanLength;
                rightSpan.updateString();

                currentSpan = rightSpan;
            }

            var lastSpanInLine = currentLine.lastSpan();
            if (lastSpanInLine != null)
            {
                if (lastSpanInLine.string != null && lastSpanInLine.string.endsWith("\n"))
                {
                    lastSpanInLine.range.length--;
                    lastSpanInLine.updateString();
                }

                if(lastSpanInLine.haveShadow() && lastSpanInLine.attachmentId == null)
                {
                    currentLine.width += Math.ceil(shadow);
                }
            }

            currentLine = new TextLine(startAt);
            currentLine.spans.push(currentSpan);
            output.push(currentLine);
        }

        currentWidth += advance;
        return currentSpan;
    }
}
