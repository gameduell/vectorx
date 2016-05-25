package vectorx.font;

import haxe.ds.StringMap;

typedef StyleConfig =
{
    name: String,
    value: String
};

typedef StyleStorageConfig =
{
    ?styles: List<StyledStringClassConfig>
};

class StyleStorage
{
    private var styles: StringMap<StringStyle> = new StringMap<StringStyle>();

    public function new(): Void
    {

    }

    public function load(json: String): Void
    {
        throw "not implemented";
    }

    public function merge(storage: StyledStringClassStorage): Void
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
}