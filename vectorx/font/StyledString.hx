package vectorx.font;
import types.Color4F;
import haxe.ds.StringMap;
class StyledString
{
    private static var parser: StyledStringParser = new StyledStringParser();
    public static function toAttributedString(styledString: String, fontAliases: FontAliasesStorage, colors: StringMap<Color4F>): AttributedString
    {
        return parser.toAttributedString(styledString, fontAliases, colors);
    }
}
