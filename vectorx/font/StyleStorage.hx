package vectorx.font;

import haxe.Json;
import types.Color4F;
import haxe.ds.StringMap;

typedef StyleConfig =
{
    name: String,
    ?parent: String,
    value: String
};

typedef StyleStorageConfig =
{
    ?styles: List<StyleConfig>
};

class StyleStorage implements StyleProviderInterface
{
    private var styles: StringMap<StringStyle> = new StringMap<StringStyle>();
    public var provider: StyleProviderInterface;

    public function new(): Void
    {

    }

    public function load(json: String, provider: StyleProviderInterface): Void
    {
        this.provider = provider;

        var json: StyleStorageConfig = Json.parse(configJson);
        if (json.styles == null || json.styles.length == 0)
        {
            return;
        }

        var parentMap = new StringMap<String>();

        for (styleConfig in json.styles)
        {
            styles.set(styleConfig.name, new StringStyle(styleConfig.name, styleConfig.value));
        }

        //resolve parents
        for (styleConfig in json.styles)
        {
            var parentName = styleConfig.parent;
            if (parentName == null)
            {
                continue;
            }

            var name: String = styleConfig.name;
            var style = styles.get(name);
            var parent = styles.get(parentName);
            if (parent == null)
            {
                throw 'Parent style $parentName is not found';
            }

            style.parent = parent;
        }

        //parse actual styles
        for (styleConfig in json.styles)
        {
            var name: String = styleConfig.name;
            var style = styles.get(name);

            var final = style.getFinalStyle();
            var attr: StringAttributes = {range: new AttributedRange()};
            style.attr = StyledStringParser.parseAttributes(final, this, attr);
        }

        this.provider = null;
    }

    public function merge(storage: StyleStorage): Void
    {
        throw "not implemented";
    }

    public function getStyle(name: String): StringStyle
    {
        throw "not implemented";
    }

    public function addStyle(style: StringStyle)
    {
        throw "not implemented";
    }

    public function removeStyle(name: String): Bool
    {
        throw "not implemented";
    }

    public function save(): String
    {
        throw "not implemented";
    }

    public function getFontAliases(): FontAliasesStorage
    {
        return provider.getFontAliases();
    }

    public function getFontCache(): FontCache
    {
        return provider.getFontCache();
    }

    public function getColors(): StringMap<Color4F>
    {
        return provider.getColors();
    }

    public function getStyles(): StyleStorage
    {
        throw "Could not reference anohter style in current style";
    }
}