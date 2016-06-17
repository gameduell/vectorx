package vectorx.font;

import vectorx.misc.UnionFind;
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
    styles: Array<StyleConfig>
};

@:access(vectorx.font.StringStyle)
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

        var json: StyleStorageConfig = Json.parse(json);
        if (json.styles == null || json.styles.length == 0)
        {
            return;
        }

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

    public function getStyleNames(): Array<String>
    {
        var arr: Array<String> = [];
        for (i in styles)
        {
            arr.push(i.name);
        }

        return arr;
    }

    public function getStyle(name: String): StringStyle
    {
        return styles.get(name);
    }

    public function addStyle(style: StringStyle)
    {
        styles.set(style.name, style);
    }

    public function setStyleParent(styleName: String, parentName: String): Void
    {
        var style = styles.get(styleName);
        if (style == null)
        {
            throw 'Style $styleName is not found';
        }

        var parent = styles.get(parentName);
        if (parent == null)
        {
            throw 'Parent style $parentName is not found';
        }

        var names = getStyleNames();
        names.sort((function(a,b) return Reflect.compare(a, b)));

        var uf = new UnionFind(names.length);
        for (style in styles)
        {
            if (style.parent == null)
            {
                continue;
            }

            if (style.name == styleName)
            {
                continue;
            }

            uf.unite(names.indexOf(style.name), names.indexOf(style.parent.name));
        }

        if (uf.find(names.indexOf(styleName), names.indexOf(parentName)))
        {
            throw 'Could not set $styleName parent to $parentName, because it will create circular dependancy';
        }

        style.parent = parent;
    }

    public function removeStyle(name: String): Bool
    {
        return styles.remove(name);
    }

    public function renameStyle(name: String, newName: String): Void
    {
        var style = getStyle(name);
        if (style == null)
        {
            throw 'Style "$name" is not found';
        }

        if (name == newName)
        {
            return;
        }

        if (getStyle(newName) != null)
        {
            throw 'Failed to rename style "$name"". "$newName"" is already exists';
        }

        styles.remove(name);
        styles.set(newName, style);
        style.name = newName;
    }

    public function save(): String
    {
        var stylesArr: Array<StringStyle> = [];
        for (style in styles)
        {
            stylesArr.push(style);
        }

        if (stylesArr.length == 0)
        {
            return "";
        }

        stylesArr.sort(function(a,b) return Reflect.compare(a.name.toLowerCase(), b.name.toLowerCase()));

        var configStyles = new Array<StyleConfig>();
        for (style in stylesArr)
        {
            var styleConfig: StyleConfig =
            {
                name: style.name,
                value: style.style,
                parent: null
            };

            if (style.parent != null)
            {
                styleConfig.parent = style.parent.name;
            }

            configStyles.push(styleConfig);
        }

        var config: StyleStorageConfig = {styles: configStyles};
        return Json.stringify(config, null, "");
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