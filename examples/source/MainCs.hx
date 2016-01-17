import vectorx.font.FontCache;
import vectorx.font.StyledStringContext;
import vectorx.font.FontContext;
import vectorx.svg.SvgContext;
import lib.ha.svg.SVGData;
import vectorx.ColorStorage;


class MainCs
{
    public static function main(): Void
    {
        var colorStorage: ColorStorage = new ColorStorage(512, 512);
        var svgData = new SVGData();
        var context = new SvgContext();
        context.renderVectorBinToColorStorage(svgData, colorStorage);

        var fontCache = new FontCache(null);
        var styleStringContext = new StyledStringContext(fontCache);

    }
}