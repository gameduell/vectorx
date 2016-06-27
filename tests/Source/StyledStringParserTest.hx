import vectorx.font.StyleStorage;
import vectorx.font.StyleProviderInterface;
import types.RectI;
import vectorx.font.FontContext;
import haxe.ds.StringMap;
import vectorx.font.StyledString;
import vectorx.font.FontAliasesStorage;
import types.Color4F;
import filesystem.FileSystem;
import vectorx.font.FontCache;
import types.Data;

class MockProvider implements StyleProviderInterface
{
    var fontCache: FontCache;
    var aliases: FontAliasesStorage;
    var colors: StringMap<Color4F>;
    var styleStorage: StyleStorage;

    public function new()
    {
        var ttfData: Data = getDataFromFile("arial.ttf");
        fontCache =  new FontCache(ttfData);

        colors = [
            'red' => new Color4F(1, 0, 0, 1),
            'green' => new Color4F(0, 1, 0, 1),
            'blue' => new Color4F(0, 0, 1, 1)
        ];

        aliases = new FontAliasesStorage();
        aliases.addAlias("arial_12", "Arial", 12);
        aliases.addAlias("arial_14", "Arial", 14);

        styleStorage = new StyleStorage();
    }

    public function getFontAliases(): FontAliasesStorage
    {
        return aliases;
    }

    public function getFontCache(): FontCache
    {
        return fontCache;
    }

    public function getColors(): StringMap<Color4F>
    {
        return colors;
    }

    public function getStyles(): StyleStorage
    {
        return null;
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

class StyledStringParserTest extends unittest.TestCase
{

    public function testBasic(): Void
    {
        var provider = new MockProvider();
        var string = "[f=arial_12]abc[/f][f=arial_14]def[/f]";
        var attributedString = StyledString.toAttributedString(string, provider);

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
        var provider = new MockProvider();
        var string = "[f=arial_12]a[f=arial_14]bc[/f]def[/f]";
        var attributedString = StyledString.toAttributedString(string, provider);

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
        var provider = new MockProvider();
        var string = "[f=arial_12,c=red]a[f=arial_14]bc[/f]def[/fc]";
        var attributedString = StyledString.toAttributedString(string, provider);

        assertTrue(attributedString.attributeStorage.spans.length == 3);
        assertTrue(attributedString.string == "abcdef");

        assertTrue(attributedString.attributeStorage.spans[0].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[0].range.index == 0);
        assertTrue(attributedString.attributeStorage.spans[0].range.length == 1);
        assertTrue(attributedString.attributeStorage.spans[0].foregroundColor.isEqual(provider.getColors().get("red")));

        assertTrue(attributedString.attributeStorage.spans[1].font.sizeInPt == 14);
        assertTrue(attributedString.attributeStorage.spans[1].range.index == 1);
        assertTrue(attributedString.attributeStorage.spans[1].range.length == 2);
        assertTrue(attributedString.attributeStorage.spans[1].foregroundColor.isEqual(provider.getColors().get("red")));

        assertTrue(attributedString.attributeStorage.spans[2].font.sizeInPt == 12);
        assertTrue(attributedString.attributeStorage.spans[2].range.index == 3);
        assertTrue(attributedString.attributeStorage.spans[2].range.length == 3);
        assertTrue(attributedString.attributeStorage.spans[2].foregroundColor.isEqual(provider.getColors().get("red")));
    }

    public function testEscapeChars(): Void
    {
        var provider = new MockProvider();
        var string = "abc\\[\\]";
        var attributedString = StyledString.toAttributedString(string, provider);
        assertTrue(attributedString.string == "abc[]");
    }

    public function testAttachmentOnly(): Void
    {
        var provider = new MockProvider();
        var string = "{attachmentId}";
        var attributedString = StyledString.toAttributedString(string, provider);

        assertTrue(attributedString.attributeStorage.spans[0].attachmentId == "attachmentId");
    }

    public function testSizeOverride(): Void
    {
        var provider = new MockProvider();
        var string = "[f=arial_12,s=14]a[/f]";
        var attributedString = StyledString.toAttributedString(string, provider);

        assertTrue(attributedString.attributeStorage.spans[0].size == 14);
    }

    public function testCrlf(): Void
    {
        var provider = new MockProvider();
        var string = "aaaa\nbbb\ncc";
        var attributedString = StyledString.toAttributedString(string, provider);
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
        var provider = new MockProvider();
        var string = "[s=10000]aaaa\nbbb\ncc[/]";
        var attributedString = StyledString.toAttributedString(string, provider);
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
}
