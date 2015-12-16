import filesystem.FileSystem;
import vectorx.font.FontCache;
import types.Data;

class StyledStringParserTest extends unittest.TestCase
{

    public function testBasic(): Void
    {
        var fontCache = initFontCache();
    }

    private function initFontCache(): FontCache
    {
        var ttfData: Data = getDataFromFile("arial.ttf");
        assertTrue(ttfData != null);
        return new FontCache(ttfData);
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
