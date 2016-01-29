import vectorx.font.AttributedRange;
import vectorx.font.AttributedString.StringAttributes;
import types.Color4F;
import vectorx.font.Font;
import vectorx.font.FontCache;
import vectorx.font.StyledStringContext;
import vectorx.font.FontContext;
import vectorx.svg.SvgContext;
import lib.ha.svg.SVGData;
import vectorx.ColorStorage;
import types.DataTest;


class MainCs
{
    public static function main(): Void
    {
        DataTest.testAll();
        var colorStorage: ColorStorage = new ColorStorage(512, 512);
        var svgData = new SVGData();
        var context = new SvgContext();
        context.renderVectorBinToColorStorage(svgData, colorStorage);

        var fontCache = new FontCache(null);
        var styleStringContext = new StyledStringContext(fontCache);
    }

    public static function _createStringAttributes(range: AttributedRange, font: Font, color: Color4F): StringAttributes
    {
        var attr: StringAttributes = {range: range, font: font, foregroundColor: color};
        return attr;
    }
}