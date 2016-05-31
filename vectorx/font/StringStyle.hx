package vectorx.font;

import vectorx.font.StyleStorage.StyleConfig;
import StringTools;

using StringTools;

class StringStyle
{
    public var name(default, null): String;
    public var attr: StringAttributes;
    public var parent: StringStyle;
    public var style(default, null): String;

    private var finalStyle: String;

    public function new(name: String, style: String): Void
    {
        this.name = name;
        this.style = style;
    }

    public function getFinalStyle(): String
    {
        if (finalStyle != null)
        {
            return finalStyle;
        }

        finalStyle = style;

        if (parent != null)
        {
            var parentStyle = parent.getFinalStyle();
            if (parentStyle != null && parentStyle.trim().length > 0)
            {
                finalStyle = '$finalStyle,$parentStyle';
            }
        }

        return finalStyle;
    }
}