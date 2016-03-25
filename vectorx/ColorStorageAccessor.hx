package vectorx;

import types.Color4B;
import vectorx.ColorStorage;

class ColorStorageAccessor
{
    public var width(default, null): Int;
    public var height(default, null): Int;

    private var storage: ColorStorage;
    private var stride: Int;
    public var transposed: Bool;


    public function new()
    {

    }

    public function transpose(): Void
    {
        transposed = !transposed;
        var oldWidth = width;
        width = height;
        height = oldWidth;
    }

    public function set(storage: ColorStorage)
    {
        this.storage = storage;
        stride = storage.width * ColorStorage.COMPONENTS;
        transposed = false;
    }

    public function pixel(x: UInt, y: UInt, output: Color4B): Void
    {
        var addr: Int = 0;

        if (transposed)
        {
            addr = stride * x + y * ColorStorage.COMPONENTS
        }
        else
        {
           addr = stride * y + x * ColorStorage.COMPONENTS
        }
        
        storage.data.offset = addr;
        var value = storage.data.readUInt32();

        output.a = value & 0xFF;
        value = value >> 8;

        output.b = value & 0xFF;
        value = value >> 8;

        output.g = value & 0xFF;
        value = value >> 8;

        output.r = value & 0xFF;
    }
}