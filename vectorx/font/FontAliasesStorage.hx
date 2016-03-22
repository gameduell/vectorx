package vectorx.font;
import haxe.ds.StringMap;

class FontAlias
{
    public var font: String;
    public var size: Float;

    public function new(font: String, size: Float)
    {
        this.font = font;
        this.size = size;
    }
}

class FontAliasesStorage
{
    private var fontMap: StringMap<FontAlias> = new StringMap<FontAlias>();

    public function new()
    {
    }

    public function addAlias(alias: String, font: String, size: Float): Void
    {
        fontMap.set(alias, new FontAlias(font, size));
    }

    public function getFont(alias: String, cache: FontCache): Font
    {
        var alias = fontMap.get(alias);

        if (alias == null)
        {
            return null;
        }

        return cache.createFontWithNameAndSize(alias.font, alias.size);
    }
}
