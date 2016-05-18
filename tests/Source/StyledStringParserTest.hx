import types.RectI;
import vectorx.font.FontContext;
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
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);

        assertTrue(attributedString.attributeStorage.spans.length == 2);
        assertTrue(attributedString.string == "abcdef");

        assertTrue(attributedString.attributeStorage.spans[0].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[0].range.index == 0);
        assertTrue(attributedString.attributeStorage.spans[0].range.length == 3);

        assertTrue(attributedString.attributeStorage.spans[1].font.sizeInPt == 14);
        assertTrue(attributedString.attributeStorage.spans[1].range.index == 3);
        assertTrue(attributedString.attributeStorage.spans[1].range.length == 3);
    }

    public function testNested(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "[f=arial_12]a[f=arial_14]bc[/f]def[/f]";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);

        assertTrue(attributedString.attributeStorage.spans.length == 3);
        assertTrue(attributedString.string == "abcdef");

        assertTrue(attributedString.attributeStorage.spans[0].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[0].range.index == 0);
        assertTrue(attributedString.attributeStorage.spans[0].range.length == 1);

        assertTrue(attributedString.attributeStorage.spans[1].font.sizeInPt == 14);
        assertTrue(attributedString.attributeStorage.spans[1].range.index == 1);
        assertTrue(attributedString.attributeStorage.spans[1].range.length == 2);

        assertTrue(attributedString.attributeStorage.spans[2].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[2].range.index == 3);
        assertTrue(attributedString.attributeStorage.spans[2].range.length == 3);

    }

    public function testMultiple(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "[f=arial_12,c=red]a[f=arial_14]bc[/f]def[/fc]";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);

        assertTrue(attributedString.attributeStorage.spans.length == 3);
        assertTrue(attributedString.string == "abcdef");

        assertTrue(attributedString.attributeStorage.spans[0].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[0].range.index == 0);
        assertTrue(attributedString.attributeStorage.spans[0].range.length == 1);
        assertTrue(attributedString.attributeStorage.spans[0].foregroundColor.isEqual(colors.get("red")));

        assertTrue(attributedString.attributeStorage.spans[1].font.sizeInPt == 14);
        assertTrue(attributedString.attributeStorage.spans[1].range.index == 1);
        assertTrue(attributedString.attributeStorage.spans[1].range.length == 2);
        assertTrue(attributedString.attributeStorage.spans[1].foregroundColor.isEqual(colors.get("red")));

        assertTrue(attributedString.attributeStorage.spans[2].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[2].range.index == 3);
        assertTrue(attributedString.attributeStorage.spans[2].range.length == 3);
        assertTrue(attributedString.attributeStorage.spans[2].foregroundColor.isEqual(colors.get("red")));
    }

    public function testEscapeChars(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "abc\\[\\]";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);
        assertTrue(attributedString.string == "abc[]");
    }

    public function testAttachmentOnly(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "{attachmentId}";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);

        assertTrue(attributedString.attributeStorage.spans[0].attachmentId == "attachmentId");
    }

    public function testSizeOverride(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "[f=arial_12,s=14]a[/f]";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);

        assertTrue(attributedString.attributeStorage.spans[0].size == 14);
    }

    public function testCrlf(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "aaaa\nbbb\ncc";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);
        var context = new FontContext();

        var rect = new RectI();
        rect.x = 0;
        rect.y = 0;
        rect.width = 1000;
        rect.height = 1000;

        var layout = context.calculateTextLayout(attributedString, rect);

        assertTrue(layout.lines[0].getLineString().indexOf("\n", 0) == -1);
        assertTrue(layout.lines[1].getLineString().indexOf("\n", 0) == -1);
        assertTrue(layout.lines[2].getLineString().indexOf("\n", 0) == -1);
    }

    public function testSize(): Void
    {
        var fontCache = initFontCache();
        var colors: StringMap<Color4F> = initColors();
        var aliases: FontAliasesStorage = initFontAliases();
        var string = "[s=10000]aaaa\nbbb\ncc[/]";
        var attributedString = StyledString.toAttributedStringWithParameters(string, aliases, fontCache, colors);
        var context = new FontContext();

        var rect = new RectI();
        rect.x = 0;
        rect.y = 0;
        rect.width = 100;
        rect.height = 100;

        var layout = context.calculateTextLayout(attributedString, rect);

        assertTrue(layout.lines[0].getLineString().indexOf("\n", 0) == -1);
        assertTrue(layout.lines[1].getLineString().indexOf("\n", 0) == -1);
        assertTrue(layout.lines[2].getLineString().indexOf("\n", 0) == -1);
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
