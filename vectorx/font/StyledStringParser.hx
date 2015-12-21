package vectorx.font;

import types.Color4F;
import haxe.ds.StringMap;
import types.Range;
import vectorx.font.AttributedString.StringAttributes;
import haxe.Utf8;
import StringTools;

using StringTools;

class StyledStringAttribute
{
    public var stringAttributes: StringAttributes;
    public var priority: Int;

    public function new(attr: StringAttributes, priority: Int)
    {
        this.stringAttributes = attr;
        this.priority = priority;
    }
}

class StyledStringParser
{
    private var attributesStack: Array<StringAttributes>;
    private var currentAttribute: StringAttributes;
    private var currentString: StringBuf;
    private var sourceString: String;
    private var currentCharIndex: Int;
    private var currentChar: String;
    private var resultAttributes: Array<StyledStringAttribute>;

    public function new()
    {

    }

    private function reset(): Void
    {
        attributesStack = new Array<StringAttributes>();
        resultAttributes = new Array<StyledStringAttribute>();
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

        var range: AttributedRange = new AttributedRange(currentString.length, 0);
        var attr: StringAttributes = null;

        //trace('k: ${kv[0]} v: ${kv[1]}');

        switch(kv[0])
        {
            case "f" | "font":
                {
                    var font = aliases.getFont(kv[1], cache);
                    if (font == null)
                    {
                        throw 'Font alias ${kv[1]} is not found';
                    }

                    attr = {range: range, font: font};
                }

            case "c" | "color":
                {
                    var color = colors.get(kv[1]);
                    if (color == null)
                    {
                        throw 'Color ${kv[1]} is not found';
                    }
                    attr = {range: range, foregroundColor:color };
                }
            case "bg" | "background": attr = {range: range, backgroundColor: colors.get(kv[1])};
            case "basline": attr = {range: range, baselineOffset: Std.parseFloat(kv[1])};
            case "kern": attr = {range: range, kern: Std.parseFloat(kv[1])};
            case "strokeWidth": attr = {range: range, strokeWidth: Std.parseFloat(kv[1])};
            case "strokeColor": attr = {range: range, strokeColor: colors.get(kv[1])};
            default: throw('undefined code "${kv[0]}""');
        }

        pushAttribute(attr);
    }

    private function pushAttribute(attribute: StringAttributes): StringAttributes
    {
        //trace('pushAttribute $attribute');

        attributesStack.push(attribute);
        currentAttribute = attribute;
        return currentAttribute;
    }

    private function popAttribute(): StringAttributes
    {
        var priority = attributesStack.length;
        var attr = attributesStack.pop();
        //trace('popAttribute $attr');

        resultAttributes.push(new StyledStringAttribute(attr, priority));
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

        try
        {
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
//trace(currentString);
                    updateAttributes();
                }

                nextChar();
            }

            resultAttributes.sort(function(a: StyledStringAttribute, b: StyledStringAttribute) : Int
            {
                if (a.priority == b.priority)
                {
                    return 0;
                }
                if (a.priority > b.priority)
                {
                    return 1;
                }

                return -1;
            });

//trace(resultAttributes);
            var attrString = new AttributedString(currentString.toString());
            for (attr in resultAttributes)
            {
//trace(attr);
                attrString.applyAttributes(attr.stringAttributes);
            }

            reset();

            return attrString;
        }
        catch(ex: String)
        {
            reset();
            ex = '!!$ex!!';
            var attrString = new AttributedString(ex);
            var font = fontCache.createFontWithNameAndSize(null, 25);
            var attr =
            {
                font: font,
                range: new AttributedRange(0, ex.length),
                foregroundColor: new Color4F(1, 0.5, 0.8, 1.0),
                strokeWidth: -3.0,
                strokeColor: new Color4F(0.0, 0.0, 0.0, 1.0)
            };
            attrString.applyAttributes(attr);

            return attrString;
        }

    }
}
