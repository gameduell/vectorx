package vectorx.font;

import types.Color4F;
import haxe.ds.StringMap;

interface StyledStringResourceProvider
{
    public function getFontAliases(): FontAliasesStorage;
    public function getFontCache(): FontCache;
    public function getColors(): StringMap<Color4F>;
    public function getClasses(): StyledStringClassStorage;
}