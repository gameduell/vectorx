package vectorx.font;

import types.Color4F;
import haxe.ds.StringMap;

class StyledString
{
    private static var parser: StyledStringParser = new StyledStringParser();

    public static function toAttributedString(styledString: String, provider: StyleProviderInterface): AttributedString
    {
        return parser.toAttributedString(styledString, provider);
    }
}
