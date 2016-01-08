package vectorx.svg;

import types.Data;

class SvgDataWrapper
{
    public var data: Data;

    public function new(?data: Data)
    {
        this.data = data;
    }

    public function writeUInt8(value: Int): Void
    {
        checkAllocationSize(1);
        data.writeUInt8(value);
        data.offset += 1;
    }

    public function readUInt8(): Int
    {
        var ret = data.readUInt8();
        data.offset += 1;
        return ret;
    }

    public function writeUInt16(value: Int): Void
    {
        checkAllocationSize(2);
        data.writeUInt16(value);
        data.offset += 2;
    }

    public function readUInt16(): Int
    {
        var ret = data.readUInt16();
        data.offset += 2;
        return ret;
    }

    public function writeUInt32(value: Int): Void
    {
        checkAllocationSize(4);
        data.writeUInt32(value);
        data.offset += 4;
    }

    public function readUInt32(): Int
    {
        var ret = data.readUInt32();
        data.offset += 4;
        return ret;
    }

    public function writeFloat32(value: Float): Void
    {
        checkAllocationSize(4);
        data.writeFloat32(value);
        data.offset += 4;
    }

    public function readFloat32(): Float
    {
        var ret = data.readFloat32();
        data.offset += 4;
        return ret;
    }

    private function checkAllocationSize(next: Int): Void
    {
        var bytesLeft: Int = data.allocedLength - data.offset;
        if (bytesLeft > next)
        {
            return;
        }

        var newSize: Int = Math.ceil(data.allocedLength * 1.8);
        data.resize(newSize);
    }
}
