package vectorx.font;

import lib.ha.aggx.typography.FontEngine;
import haxe.Utf8;

class TextLine
{
    public var begin(default, null): Int;
    public var lenght(get, null): Int;
    public var width(default, null): Float = 0;

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

    public static function calculate(string: AttributedString, textWidth: Float): Array<TextLine>
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
            var scale = fontEngine.getScale(span.font.sizeInPt);

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
                            advance = face.glyph.advanceWidth * scale;
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

        return output;
    }
}
