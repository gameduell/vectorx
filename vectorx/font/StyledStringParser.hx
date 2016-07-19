package vectorx.font;

//import logger.Logger;
import csharp.VectorxCs.StyledStringResourceProvider;
import aggx.svg.SVGStringParsers;
import haxe.Utf8;
import types.Color4F;
import haxe.ds.StringMap;
import types.Range;
import vectorx.font.StringAttributes;
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
    private var isEscapeChar: Bool = false;

    private static inline var TAB = 9;

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

        var range: AttributedRange = new AttributedRange(currentString.length, 0);
        var rootAttr: StringAttributes = {range: range};
        pushAttribute(rootAttr);
    }

    private function nextChar(): String
    {
        isEscapeChar = false;
        if (currentCharIndex >= sourceString.length)
        {
            throw "unexpected end of string";
        }

        currentChar = Utf8.sub(sourceString, ++currentCharIndex, 1);
        if (currentChar == "\\")
        {
            var char = nextChar();
            isEscapeChar = true;
            switch (char)
            {
                case "n": currentChar = "\n";
                case "t": currentChar = "\t";
            }
        }

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

    private function readAttachment(): String
    {
        var attachment: StringBuf = new StringBuf();
        while (nextChar() != "}")
        {
            attachment.add(currentChar);
        }

        return attachment.toString();
    }

    private function parseAttachment(): Void
    {
        var attachmentName = readAttachment();
        var range: AttributedRange = new AttributedRange(currentString.length, 0);

        var kern: Null<Float> = null;
        var font: Font = null;

        var attr: StringAttributes =
        {
            range: range,
            font: currentAttribute.font,
            foregroundColor: currentAttribute.foregroundColor,
            backgroundColor: currentAttribute.backgroundColor,
            baselineOffset: currentAttribute.baselineOffset,
            kern: currentAttribute.kern,
            strokeWidth: currentAttribute.strokeWidth,
            strokeColor: currentAttribute.strokeColor
        };

        currentAttribute.attachmentId = attachmentName;

        popAttribute();
        pushAttribute(attr);
    }

    private static function parseShadow(string: String, colors: StringMap<Color4F>): FontShadow
    {
        var shadow = new FontShadow();

        var attributes = string.split(";");
        for (attr in attributes)
        {
            var kv: Array<String> = attr.trim().split(":");
            if (kv.length != 2)
            {
                throw "Invalid shadow format";
            }

            switch(kv[0].trim())
            {
                case "x":
                    {
                        shadow.offset.x = Std.parseFloat(kv[1]);
                    }

                case "y":
                    {
                        shadow.offset.y = Std.parseFloat(kv[1]);
                    }

                case "blur" | "b":
                    {
                        shadow.blurRadius = Std.parseFloat(kv[1]);
                    }

                case "color" | "c": shadow.color = parseColor(kv[1].trim(), colors);
            }
        }

        return shadow;
    }

    public static function parseColor(value: String, colors: StringMap<Color4F>): Color4F
    {
        var color = colors.get(value);
        if (color == null)
        {
            var color = SVGStringParsers.parseColor(value);
            return new Color4F(color.r / 255.0, color.g / 255.0, color.b / 255.0, color.a / 255.0);
        }

        return color;
    }

    private static function applyStyle(attr: StringAttributes, style: StringAttributes): StringAttributes
    {
        if (style.font != null)
        {
            attr.font = style.font;
        }

        if (style.size != null)
        {
            attr.size = style.size;
        }

        if (style.backgroundColor != null)
        {
            attr.backgroundColor = style.backgroundColor;
        }

        if (style.foregroundColor != null)
        {
            attr.foregroundColor = style.foregroundColor;
        }

        if (style.kern != null)
        {
            attr.kern = style.kern;
        }

        if (style.baselineOffset != null)
        {
            attr.baselineOffset = style.baselineOffset;
        }

        if (style.extraLineSpacing != null)
        {
            attr.extraLineSpacing = style.extraLineSpacing;
        }

        if (style.strokeWidth != null)
        {
            attr.strokeWidth = style.strokeWidth;
        }

        if (style.strokeColor != null)
        {
            attr.strokeColor = style.strokeColor;
        }

        if (style.shadow != null)
        {
            attr.shadow = style.shadow;
        }

        if (style.foregroundColor != null)
        {
            attr.foregroundColor = style.foregroundColor;
        }

        return attr;
    }

    private static function parseFloat(value: String): Float
    {
        var val = Std.parseFloat(value);
        if (Math.isNaN(val))
        {
            return 0.0;
        }

        return val;
    }

    public static function parseAttributes(code: String, provider: StyleProviderInterface, attr: StringAttributes): StringAttributes
    {
        var codes = code.split(",");
        for (code in codes)
        {
            var kv: Array<String> = code.trim().split('=');

            if (kv[0].length == 0)
            {
                continue;
            }

            switch(kv[0].trim())
            {
                case "f" | "font":
                    {
                        var font = provider.getFontAliases().getFont(kv[1], provider.getFontCache());
                        if (font == null)
                        {
                            font = provider.getFontCache().createFontWithNameAndSize(kv[1], 1);
                            if (font == null)
                            {
                                throw 'Font or font alias ${kv[1]} is not found';
                            }
                        }
                        else
                        {
                            attr.size = Math.ceil(font.sizeInPt);
                        }

                        attr.font = font;
                    }

                case "c" | "color": attr.foregroundColor = parseColor(kv[1], provider.getColors());
                case "s" | "size":
                    {
                        try
                        {
                            var size = Std.parseInt(kv[1]);
                            if (size != 0)
                            {
                                attr.size = size;
                            }
                        }
                        catch(ex: Dynamic)
                        {

                        }
                    }
                case "style": applyStyle(attr, provider.getStyles().getStyle(kv[1]).attr);
                case "bg" | "background": attr.backgroundColor = parseColor(kv[1], provider.getColors());
                case "baseline": attr.baselineOffset = parseFloat(kv[1]);
                case "extraSpacing" | "xspc": attr.extraLineSpacing = parseFloat(kv[1]);
                case "kern": attr.kern = parseFloat(kv[1]);
                case "strokeWidth" | "sw": attr.strokeWidth = parseFloat(kv[1]);
                case "strokeColor" | "sc": attr.strokeColor = parseColor(kv[1], provider.getColors());
                case "shadow" | "shdw" | "sh": attr.shadow = parseShadow(kv[1], provider.getColors());
                default: throw('undefined code "${kv[0]}"');
            }
        }

        return attr;
    }

    private function parseCode(provider: StyleProviderInterface): Void
    {
        var code = readCode();
        if (code.trim().startsWith("/"))
        {
            popAttribute();
            return;
        }

        var range: AttributedRange = new AttributedRange(currentString.length, 0);
        var attr: StringAttributes = {range: range};

        pushAttribute(parseAttributes(code, provider, attr));
    }

    private function pushAttribute(attribute: StringAttributes): StringAttributes
    {
        attributesStack.push(attribute);
        currentAttribute = attribute;
        return currentAttribute;
    }

    private function popAttribute(): StringAttributes
    {
        var priority = attributesStack.length;
        var attr = attributesStack.pop();

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

    public function toAttributedString(styledString: String, provider: StyleProviderInterface): AttributedString
    {
        reset();

        sourceString = styledString;
        currentChar = Utf8.sub(styledString, currentCharIndex, 1);

        while (currentCharIndex < Utf8.length(styledString))
        {
            if (currentChar == '[' && !isEscapeChar)
            {
                parseCode(provider);
            }
            else if (currentChar == '{' && !isEscapeChar)
            {
                parseAttachment();
            }
            else
            {
                if (Utf8.charCodeAt(currentChar, 0) != TAB)
                {
                    currentString.add(currentChar);
                }
                else
                {
                    currentString.add(" ");
                }
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

        var attrString = new AttributedString(currentString.toString());
        var defaultAttr =
        {
            font: provider.getFontCache().createFontWithNameAndSize(null, 25),
            range: new AttributedRange(0, currentString.length)
        };
        attrString.applyAttributes(defaultAttr);

        for (attr in resultAttributes)
        {
            attrString.applyAttributes(attr.stringAttributes);
        }

        reset();

        return attrString;
    }
}
