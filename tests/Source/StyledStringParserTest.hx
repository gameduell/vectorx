import haxe.ds.StringMap;
import vectorx.font.StyledString;
import vectorx.font.FontAliasesStorage;
import types.Color4F;
import filesystem.FileSystem;
import vectorx.font.FontCache;
import types.Data;

class StyledStringParserTest extends unittest.TestCase
{

    public function testBasic(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "[f=arial_12]abc[/f][f=arial_14]def[/f]";
        var attributedString = StyledString.toAttributedString(string, aliases, fontCache, colors);

        trace(attributedString.attributeStorage.spans);

        assertTrue(attributedString.attributeStorage.spans.length == 2);

        assertTrue(attributedString.attributeStorage.spans[0].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[0].range.index == 0);
        assertTrue(attributedString.attributeStorage.spans[0].range.length == 3);

        assertTrue(attributedString.attributeStorage.spans[1].font.sizeInPt == 14);
        assertTrue(attributedString.attributeStorage.spans[1].range.index == 3);
        assertTrue(attributedString.attributeStorage.spans[1].range.length == 3);
    }

    private function initFontCache(): FontCache
    {
        var ttfData: Data = getDataFromFile("arial.ttf");
        assertTrue(ttfData != null);
        return new FontCache(ttfData);
    }

    private function initColors(): StringMap<Color4F>
    {
        return[
            'red' => new Color4F(1, 0, 0, 1),
            'green' => new Color4F(0, 1, 0, 1),
            'blue' => new Color4F(0, 0, 1, 1)
        ];
    }

    private function initFontAliases(): FontAliasesStorage
    {
        var aliases: FontAliasesStorage = new FontAliasesStorage();
        aliases.addAlias("arial_12", "Arial", 12);
        aliases.addAlias("arial_14", "Arial", 14);
        return aliases;
    }

    static private function getDataFromFile(filename: String): Data
    {
        var fileUrl = FileSystem.instance().getUrlToStaticData() + "/" + filename;
        return getDataFromFileUrl(fileUrl);
    }

    static private function getDataFromFileUrl(fileUrl: String): Data
    {
        var reader: filesystem.FileReader = FileSystem.instance().getFileReader(fileUrl);

        if (reader == null)
        {
            trace("Couldnt find file for fileUrl: " + fileUrl);
            return null;
        }

        var fileSize = FileSystem.instance().getFileSize(fileUrl);

        var data = new Data(fileSize);
        reader.readIntoData(data);

        return data;
    }
}
