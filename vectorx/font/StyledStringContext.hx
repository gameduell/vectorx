package vectorx.font;

import types.Data;
import lib.ha.svg.SVGStringParsers;
import haxe.Json;
import types.Color4F;
import haxe.ds.StringMap;

typedef FontAliasConfig = {font: String, size: Int, alias: String};
typedef StyledStringContextConfing = {defaultFont: String, colors: Array<Dynamic>, fonts: Array<FontAliasConfig>};

class StyledStringContext
{

    public var fontCache(default, null): FontCache;
    public var fontAliases(default, null): FontAliasesStorage;
    public var colors(default, null): StringMap<Color4F>;

    public function new(fontCache: FontCache)
    {
        this.fontCache = fontCache;
        fontAliases = new FontAliasesStorage();
        colors = new StringMap<Color4F>();
    }

    public static function create(configJson: String, loadFontFunc: String -> Data): StyledStringContext
    {
        var json: StyledStringContextConfing = Json.parse(configJson);
        trace(json);

        var defaultFont: String = json.defaultFont;
        if (defaultFont == null)
        {
            throw "No default font speciefied in config JSOM";
        }

        var fontCache = new FontCache(loadFontFunc(defaultFont));
        var context = new StyledStringContext(fontCache);

        trace(json.colors);
        if (json.colors != null)
        {
            for (name in Reflect.fields(json.colors))
            {
                trace(name);
                var colorValue: String = Reflect.field(json.colors, name);
                trace(colorValue);
                var color = SVGStringParsers.parseColor(colorValue);
                context.colors.set(name, new Color4F(color.r / 255.0, color.g / 255.0, color.b / 255.0, color.a / 255.0));
            }
        }

        if (json.fonts != null)
        {
            for (fontValue in json.fonts)
            {
                context.fontAliases.addAlias(fontValue.alias, fontValue.font, fontValue.size);
            }
        }

        return context;
    }
}
