package vectorx.font;

import haxe.Utf8;
class StyledStringParser
{
    private var attributesStack: Array<AttributedSpan>;
    private var currentAttribute: AttributedSpan;
    private var currentString: StringBuf;
    private var sourceString: String;
    private var currentCharIndex: Int;
    private var currentChar: String;
    private var resultSpans: Array<AttributedSpan>;

    public function new()
    {

    }

    private function reset(): Void
    {
        attributesStack = new Array<AttributedSpan>();
        currentString = new StringBuf();
        currentCharIndex = 0;
        sourceString = null;
        currentAttribute = null;
    }

    private function nextChar(): String
    {
        currentChar = Utf8.charCodeAt(sourceString, ++currentCharIndex);
        return currentChar;
    }
    private function readCode(): String
    {
        var code: StringBuf = new StringBuf();
        while (nextChar() != "]")
        {
            code.add(currentChar);
        }

        nextChar();
        return code.toString();
    }

    private function parseCode(): Void
    {
        var code = readCode();
        var kv = code.split('=');
    }

    private function pushAttribute(attribute: AttributedSpan): AttributedSpan
    {
        attributesStack.push(attribute);
        currentAttribute = attribute;
        return currentAttribute;
    }

    private function popAttribute(): AttributedSpan
    {
        var attr = attributesStack.pop();
        resultSpans.push(attr);
    }

    private function updateAttributes()
    {
        for (span in attributesStack)
        {
            span.range.length++;
        }
    }

    public function toAttributedString(styledString: String, fontAliases: FontAliasesStorage): AttributedString
    {
        reset();

        sourceString = styledString;
        currentChar = Utf8.sub(styledString, currentCharIndex, 1);


        while (currentCharIndex < Utf8.length(styledString))
        {

            if (currentChar == '[')
            {
                parseCode();
            }
            else
            {
                currentString.add(currentChar)

            }

            nextChar();
        }
    }
}
