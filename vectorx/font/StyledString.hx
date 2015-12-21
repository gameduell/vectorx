package vectorx.font;
import types.Color4F;
import haxe.ds.StringMap;
class StyledString
{
    private static var parser: StyledStringParser = new StyledStringParser();
    public static function toAttributedStringWithParameters(styledString: String, fontAliases: FontAliasesStorage, fontCache: FontCache, colors: StringMap<Color4F>): AttributedString
    {
        return parser.toAttributedString(styledString, fontAliases, fontCache, colors);
    }

    //
    public static function toAttributedString(styledString: String, context: StyledStringContext): AttributedString
    {
        return parser.toAttributedString(styledString, context.fontAliases, context.fontCache, context.colors);
    }
}
