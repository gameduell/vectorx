package vectorx.font;

class AttributedRange
{
    /** The starting index for this range **/
    public var index: Int = 0;

    /** The amount of items to cover, -1 means the entire possible range from index **/
    public var length: Int = -1;

    inline public function new(index: Int = 0, length: Int = -1)
    {
        this.index = index;
        this.length = length;
    }

    public function toString(): String
    {
        return '{index: $index, length: $length}';
    }
}
