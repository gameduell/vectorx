package vectorx.font;

import types.Color4F;
import haxe.ds.StringMap;
import types.Range;
import vectorx.font.AttributedString.StringAttributes;
import haxe.Utf8;
import StringTools;

using StringTools;

class StyledStringParser
{
    private var attributesStack: Array<StringAttributes>;
    private var currentAttribute: StringAttributes;
    private var currentString: StringBuf;
    private var sourceString: String;
    private var currentCharIndex: Int;
    private var currentChar: String;
    private var resultAttributes: Array<StringAttributes>;

    public function new()
    {

    }

    private function reset(): Void
    {
        attributesStack = new Array<StringAttributes>();
        currentString = new StringBuf();
        currentCharIndex = 0;
        sourceString = null;
        currentAttribute = null;
    }

    private function nextChar(): String
    {
        currentChar = Utf8.sub(sourceString, ++currentCharIndex, 1);
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

    private function parseCode(aliases: FontAliasesStorage, cache: FontCache, colors: StringMap<Color4F>): Void
    {
        var code = readCode();
        var kv = code.split('=');

        if (kv[0].startsWith("/"))
        {
            popAttribute();
            return;
        }

        var range: AttributedRange = new AttributedRange(currentString.length - 1);
        var attr: StringAttributes;


        switch(kv[0])
        {
            case "f" | "font": attr = {range: range, font: aliases.getFont(kv[1], cache)};
            case "c" | "color": attr = {range: range, foregroundColor: colors.get(kv[1])};
            case "bg" | "background": attr = {range: range, backgroundColor: colors.get(kv[1])};
            case "basline": attr = {range: range, baselineOffset: Std.parseFloat(kv[1])};
            case "kern": attr = {range: range, kern: Std.parseFloat(kv[1])};
            case "strokeWidth": attr = {range: range, strokeWidth: Std.parseFloat(kv[1])};
            case "strokeColor": attr = {range: range, strokeColor: colors.get(kv[1])};
        }

    }

    private function pushAttribute(attribute: StringAttributes): StringAttributes
    {
        attributesStack.push(attribute);
        currentAttribute = attribute;
        return currentAttribute;
    }

    private function popAttribute(): StringAttributes
    {
        var attr = attributesStack.pop();
        resultAttributes.push(attr);
        if (attributesStack.length > 0)
        {
            currentAttribute = attributesStack[attributesStack.length - 1];
        }
        else
        {
            currentAttribute = null;
        }

        return currentAttribute;
    }

    private function updateAttributes()
    {
        for (attr in attributesStack)
        {
            attr.range.length++;
        }
    }

    public function toAttributedString(styledString: String, fontAliases: FontAliasesStorage, fontCache: FontCache, colors: StringMap<Color4F>): AttributedString
    {
        reset();

        sourceString = styledString;
        currentChar = Utf8.sub(styledString, currentCharIndex, 1);

        while (currentCharIndex < Utf8.length(styledString))
        {
            if (currentChar == '[')
            {
                parseCode(fontAliases, fontCache, colors);
            }
            else
            {
                currentString.add(currentChar);
            }

            currentString.add(currentChar);
            updateAttributes();
            nextChar();
        }

        var attrString = new AttributedString(currentString.toString());
        for (attr in resultAttributes)
        {
            attrString.applyAttributes(attr);
        }

        reset();

        return attrString;
    }
}
