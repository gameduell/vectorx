package vectorx.font;
class StyledString
{
    private static var parser: StyledStringParser = new StyledStringParser();
    public static function toAttributedString(styledString: String, fontAliases: FontAliasesStorage): AttributedString
    {
        return parser.toAttributedString(styledString, fontAliases);
    }
}
