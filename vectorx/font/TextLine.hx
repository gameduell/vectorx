package vectorx.font;

import lib.ha.aggx.typography.FontEngine;
import haxe.Utf8;

class TextLine
{
    public var begin(default, null): Int;
    public var lenght(get, null): Int;
    public var width(default, null): Float = 0;
    public var maxSpanHeight(default, null): Float = 0;
    public var maxBgHeight(default, null): Float = 0;

    private var breakAt: Int = -1;
    private var charAtBreakPos: Int = 0;

    private static inline var SPACE = 32;
    private static inline var TAB = 9;
    private static inline var NEWLINE = 10;

    public function toString(): String
    {
        return '{begin: $begin breakAt: $breakAt len: $lenght width: $width}';
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

    private function calculateMaxSpanHeight(span: AttributedSpan)
    {
        var fontEngine: FontEngine = span.font.internalFont;
        var spanString: String = span.string;
        var measure = span.getMeasure();

        if (measure.y > maxSpanHeight)
        {
            maxSpanHeight = measure.y;
        }
    }

    private function calculateMaxBgHeight(span: AttributedSpan)
    {
        var fontEngine: FontEngine = span.font.internalFont;
        var spanString: String = span.string;
        var measure = span.getMeasure();
        var alignY: Float = maxSpanHeight - measure.y;

        for (i in 0 ... Utf8.length(spanString))
        {
            var face = fontEngine.getFace(Utf8.charCodeAt(spanString, i));
            if (face.glyph.bounds == null)
            {
                continue;
            }
            var scale = fontEngine.getScale(span.font.sizeInPt);

            var by =  -face.glyph.bounds.y1 * scale;
            var h = (-face.glyph.bounds.y2 - -face.glyph.bounds.y1) * scale;

            var ext: Float = (alignY + measure.y + by);
            if (ext > maxBgHeight)
            {
                maxBgHeight = ext;
            }
        }
    }

    public static function calculate(string: AttributedString, textWidth: Float, pixelRatio: Float = 1.0): Array<TextLine>
    {
        var output: Array<TextLine> = [];
        var currentWidth: Float = 0;

        var pos: Int = 0;

        var currentLine = new TextLine();
        output.push(currentLine);

        string.attributeStorage.eachSpanInRange(function(span: AttributedSpan)
        {
            var fontEngine: FontEngine = span.font.internalFont;
            var spanString: String = span.string;
            var scale = fontEngine.getScale(span.font.sizeInPt) * pixelRatio;
            var kern = span.kern == null ? 0 : span.kern;
            kern *= pixelRatio;

            for (i in 0 ... Utf8.length(spanString))
            {
                //trace('i: $i pos: $pos string: $spanString');
                var code: Int = Utf8.charCodeAt(spanString, i);
                var advance: Float = 0;

                var needNewLine: Bool = false;

                switch(code)
                {
                    case SPACE | TAB:
                        {
                            //trace('space: $pos');
                            currentLine.breakAt = pos;
                            currentLine.charAtBreakPos = code;
                            currentLine.width = currentWidth;
                        }
                    case NEWLINE:
                        {
                            //trace('newline: $pos');
                            needNewLine = true;
                        }
                    default:
                        {
                            var face = fontEngine.getFace(code);
                            advance = face.glyph.advanceWidth * scale + kern;
                            if (currentWidth + advance > textWidth)
                            {
                                //trace('pos: $pos currentWidth: $currentWidth advance: $advance textWidth: $textWidth');
                                needNewLine = true;
                            }
                        }
                }

                if (needNewLine)
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

                    currentLine = new TextLine(startAt);
                    output.push(currentLine);
                }

                currentWidth += advance;
                pos++;
            }

        });


        output[output.length - 1].breakAt = -1;
        output[output.length - 1].width = currentWidth;

        for(line in output)
        {
            string.attributeStorage.eachSpanInRange(function(span: AttributedSpan)
            {
                line.calculateMaxSpanHeight(span);
            }, line.begin, line.lenght);

            string.attributeStorage.eachSpanInRange(function(span: AttributedSpan)
            {
                line.calculateMaxBgHeight(span);
            }, line.begin, line.lenght);

            line.maxSpanHeight *= pixelRatio;
            line.maxBgHeight *= pixelRatio;
        }

        return output;
    }
}
