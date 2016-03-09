import vectorx.font.LayoutBehaviour;
import types.VerticalAlignment;
import types.HorizontalAlignment;
import types.Vector2;
import types.Data;
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

class StyledStringResourceProvider
{
    public function loadFont(file: String): Data
    {
        throw "not implemented";
    }

    public function loadImage(file: String, origDimensions: Vector2, dimensions: Vector2): ColorStorage
    {
        throw "not implemented";
    }

    public function getImageSize(file: String, origDimensions: Vector2, dimensions: Vector2): Vector2
    {
        throw "not implemented";
    }
}

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

    public static function createLayoutConfig(scale: Float, horizontalAlignment: HorizontalAlignment, verticalAlignment: VerticalAlignment, layoutBehaviour: LayoutBehaviour)
    {
        var config: TextLayoutConfig =
        {
            scale: scale,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            layoutBehaviour: layoutBehaviour
        };

        return config;
    }

    public static function createStyledStringContext(config: String, provider: StyledStringResourceProvider)
    {
        var loadFont = function (file: String)
        {
            return provider.loadFont(file);
        };

        var loadImage = function (file: String, origDimensions: Vector2, dimensions: Vector2)
        {
            return provider.loadImage(file, origDimensions, dimensions);
        };

        var getImageSize = function (file: String, origDimensions: Vector2, dimensions: Vector2)
        {
            return provider.getImageSize(file, origDimensions, dimensions);
        };

        return StyledStringContext.create(config, loadFont, loadImage, getImageSize);
    }
}