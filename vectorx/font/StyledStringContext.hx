package vectorx.font;

import vectorx.font.TextLayout;
import vectorx.font.FontContext.TextLayoutConfig;
import types.Vector2;
import types.RectI;
import types.Data;
import lib.ha.svg.SVGStringParsers;
import haxe.Json;
import types.Color4F;
import haxe.ds.StringMap;

typedef FontAliasConfig =
{
    font: String,
    size: Int,
    alias: String
};

typedef ColorConfig =
{
    name: String,
    value: String
};

typedef AttachmentConfig =
{
    name: String,
    image: String,
    width: Int,
    height: Int,
    ?anchorPoint: Float
};

typedef StyledStringContextConfing =
{
    defaultFont: String,
    ?colors: Array<ColorConfig>,
    ?fontAliases: Array<FontAliasConfig>,
    ?loadFonts: Array<String>,
    ?attachments: Array<AttachmentConfig>
};

class StyledStringContext
{
    public var fontCache(default, null): FontCache;
    public var fontAttachments(default, null): FontAttachmentStorage;
    public var fontAliases(default, null): FontAliasesStorage;
    public var colors(default, null): StringMap<Color4F>;
    public var fontContext: FontContext;

    private var loadImage: String -> Vector2 -> Vector2 -> ColorStorage;

    public function loadFontAttachment(id: String, scale: Float): FontAttachment
    {
        return fontAttachments.getAttachment(id, scale);
    }

    public function new(fontCache: FontCache)
    {
        this.fontCache = fontCache;
        fontAttachments = new FontAttachmentStorage();
        fontAliases = new FontAliasesStorage();
        colors = new StringMap<Color4F>();
    }

    public function calculateTextLayout(styledString: String, rect: RectI, layoutConfig: TextLayoutConfig): TextLayout
    {
        if (styledString.length == 0)
        {
            return null;
        }

        var attributedString = StyledString.toAttributedString(styledString, this);
        var loadAttachment = function(name: String, scale: Float)
        {
            return loadFontAttachment(name, scale);
        }

        var layout = fontContext.calculateTextLayout(attributedString, rect, layoutConfig, loadAttachment);

        return layout;
    }

    public function renderStringToColorStorage(layout: TextLayout, colorStorage: ColorStorage, renderTrimmed: Bool = false)
    {
        if (layout == null)
        {
            return;
        }

        fontContext.renderStringToColorStorage(layout, colorStorage, renderTrimmed);
    }

    public static function create(configJson: String, loadFontFunc: String -> Data,
                                  loadImage: String -> Vector2 -> Vector2 -> ColorStorage,
                                  getImageSize: String -> Vector2 -> Vector2 -> Vector2,
                                  ?fontContext: FontContext): StyledStringContext
    {
        var json: StyledStringContextConfing = Json.parse(configJson);

        var defaultFont: String = json.defaultFont;
        if (defaultFont == null)
        {
            throw "No default font speciefied in config JSON";
        }

        var fontCache = new FontCache(loadFontFunc(defaultFont));
        var context = new StyledStringContext(fontCache);
        context.fontAttachments.loadImage = loadImage;
        context.fontAttachments.getImageSize = getImageSize;

        if (fontContext == null)
        {
            fontContext = new FontContext();
        }

        context.fontContext = fontContext;

        if (json.loadFonts != null)
        {
            for (fontName in json.loadFonts)
            {
                fontCache.preloadFontFromTTFData(loadFontFunc(fontName));
            }
        }

        if (json.fontAliases != null)
        {
            for (fontValue in json.fontAliases)
            {
                context.fontAliases.addAlias(fontValue.alias, fontValue.font, fontValue.size);
            }
        }

        if (json.attachments != null)
        {
            for (attachment in json.attachments)
            {
                context.fontAttachments.addAttachmentConfig(attachment);
            }
        }

        if (json.colors != null)
        {
            for (colorConfig in json.colors)
            {
                var color = SVGStringParsers.parseColor(colorConfig.value);
                context.colors.set(colorConfig.name, new Color4F(color.r / 255.0, color.g / 255.0, color.b / 255.0, color.a / 255.0));
            }
        }

        return context;
    }
}
