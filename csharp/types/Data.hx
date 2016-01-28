/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package types;

import types.DataType;

import StringTools;
import cs.system.io.MemoryStream;
import cs.system.io.BinaryReader;
import cs.system.io.BinaryWriter;
import cs.system.io.SeekOrigin;
import cs.system.text.Encoding;

class Data
{
    inline static public var SIZE_OF_INT8: Int = 1;
    inline static public var SIZE_OF_UINT8: Int = 1;
    inline static public var SIZE_OF_INT16: Int = 2;
    inline static public var SIZE_OF_UINT16: Int = 2;
    inline static public var SIZE_OF_INT32: Int = 4;
    inline static public var SIZE_OF_UINT32: Int = 4;
    inline static public var SIZE_OF_FLOAT32: Int = 4;
    inline static public var SIZE_OF_FLOAT64: Int = 8;

    public var memory: MemoryStream;
    public var reader: BinaryReader;
    public var writer: BinaryWriter;

/// offset view, all uses of data should start at offset and use up to offset length
    public var offset(default, set): Int;
    public var offsetLength: Int;

    public function set_offset(value: Int): Int
    {
        offset = value;
        offsetLength = allocedLength - offset;
        return offset;
    }

    public function new(sizeInBytes: Int): Void /// if 0, empty data, does not create the underlying memory. Can be set externally.
    {
        allocedLength = sizeInBytes;
        offsetLength = sizeInBytes;
        //TODO write zeroes or smth
        memory = new MemoryStream(sizeInBytes);
        reader = new BinaryReader(memory);
        writer = new BinaryWriter(memory);

        memset(sizeInBytes, 0);
    }

    @:functionCode("
        byte tmp = (byte) value;
        for (int i = 0; i < size; i++)
            writer.Write(tmp);
    ")
    private function memset(size: Int, value: Int)
    {

    }

    public function writeData(data: Data): Void
    {
        data.memory.Seek(0, SeekOrigin.Begin);
        memory.Seek(0, SeekOrigin.Begin);
        data.memory.WriteTo(memory);
    }

// Int write and read functions

    public function writeInt(value: Int, targetDataType: DataType): Void
    {
        switch(targetDataType)
        {
            case DataType.DataTypeInt8: writeInt8(value);
            case DataType.DataTypeUInt8: writeUInt8(value);
            case DataType.DataTypeInt16: writeInt16(value);
            case DataType.DataTypeUInt16: writeUInt16(value);
            case DataType.DataTypeInt32: writeInt32(value);
            case DataType.DataTypeUInt32: writeUInt32(value);
            case DataType.DataTypeFloat32: writeFloat32(value);
            case DataType.DataTypeFloat64: writeFloat64(value);
        }
    }

    public function writeIntArray(array: Array<Int>, dataType: DataType): Void
    {
        var dataSize = types.DataTypeUtils.dataTypeByteSize(dataType);

        var prevOffset = offset;
        for(i in 0...array.length)
        {
            writeInt(array[i], dataType);
            offset += dataSize;
        }
        offset = prevOffset;
    }

    private inline function seek(): Void
    {
        //trace('seek() offset: $offset');
        memory.Seek(offset, SeekOrigin.Begin);
    }

    public function dump(): Void
    {
        var buf = new StringBuf();
        buf.add('dumping data:\n');
        memory.Seek(0, SeekOrigin.Begin);
        var j = 0;
        for(i in 0 ... allocedLength)
        {
            var byte = StringTools.hex(reader.ReadByte(), 2);
            buf.add(byte);
            j++;
            if (j >= 16)
            {
                buf.add('\n');
                j = 0;
            }
            else
            {
                buf.add(" ");
            }
        }

        trace(buf);
    }

    @:functionCode("
        seek();
        sbyte tmp = (sbyte) value;
        writer.Write(tmp);
    ")
    public function writeInt8(value: Int): Void{}

    @:functionCode("
        seek();
        byte tmp = (byte) value;
        writer.Write(tmp);
    ")
    public function writeUInt8(value: Int): Void
    {

    }

    @:functionCode("
        seek();
        short tmp = (short) value;
        writer.Write(tmp);
    ")
    public function writeInt16(value: Int): Void {}

    @:functionCode("
        seek();
        ushort tmp = (ushort) value;
        writer.Write(tmp);
    ")
    public function writeUInt16(value: Int): Void {}

    @:functionCode("
        seek();
        writer.Write((uint)value);
    ")
    public function writeInt32(value: Int): Void
    {

    }

    @:functionCode("
        seek();
        writer.Write(value);
    ")
    public function writeUInt32(value: Int): Void
    {

    }

    public function readInt(targetDataType: DataType): Int
    {
        switch(targetDataType)
        {
            case DataType.DataTypeInt8: return readInt8();
            case DataType.DataTypeUInt8: return readUInt8();
            case DataType.DataTypeInt16: return readInt16();
            case DataType.DataTypeUInt16: return readUInt16();
            case DataType.DataTypeInt32: return readInt32();
            case DataType.DataTypeUInt32: return readUInt32();
            case DataType.DataTypeFloat32: return Std.int(readFloat32());
            case DataType.DataTypeFloat64: return Std.int(readFloat64());
        }
    }

    public function readIntArray(count: Int, dataType: DataType): Array<Int>
    {
        var dataSize = types.DataTypeUtils.dataTypeByteSize(dataType);

        var prevOffset = offset;

        var array = new Array<Int>();
        for(i in 0...count)
        {
            array.push(readInt(dataType));
            offset += dataSize;
        }

        offset = prevOffset;
        return array;
    }

    public function readInt8(): Int
    {
        seek();
        return reader.ReadSByte();
    }

    public function readUInt8(): Int
    {
        seek();
        return reader.ReadByte();
    }

    public function readInt16(): Int
    {
        seek();
        return reader.ReadInt16();
    }

    public function readUInt16(): Int
    {
        seek();
        return reader.ReadUInt16();
    }

    public function readInt32(): Int
    {
        seek();
        return reader.ReadInt32();
    }

    public function readUInt32(): Int
    {
        seek();
        return reader.ReadUInt32();
    }

// Float write and read functions


    public function writeFloat(value: Float, targetDataType: DataType): Void
    {
        switch(targetDataType)
        {
            case DataType.DataTypeInt8: writeInt8(Std.int(value));
            case DataType.DataTypeUInt8: writeUInt8(Std.int(value));
            case DataType.DataTypeInt16: writeInt16(Std.int(value));
            case DataType.DataTypeUInt16: writeUInt16(Std.int(value));
            case DataType.DataTypeInt32: writeInt32(Std.int(value));
            case DataType.DataTypeUInt32: writeUInt32(Std.int(value));
            case DataType.DataTypeFloat32: writeFloat32(value);
            case DataType.DataTypeFloat64: writeFloat64(value);
        }
    }

    public function writeFloatArray(array: Array<Float>, dataType: DataType): Void
    {
        var dataSize = types.DataTypeUtils.dataTypeByteSize(dataType);

        var prevOffset = offset;
        for(i in 0...array.length)
        {
            writeFloat(array[i], dataType);
            offset += dataSize;
        }
        offset = prevOffset;
    }

    @:functionCode("
        seek();
        float tmp = (float)value;
        writer.Write(tmp);
    ")
    public function writeFloat32(value: Float): Void {}

    @:functionCode("
        seek();
        double tmp = (double)value;
        writer.Write(tmp);
    ")
    public function writeFloat64(value: Float): Void {}

    public function readFloat(targetDataType: DataType): Float
    {
        switch(targetDataType)
        {
            case DataType.DataTypeFloat32: return readFloat32();
            case DataType.DataTypeFloat64: return readFloat64();
            case DataType.DataTypeInt8: return readInt8();
            case DataType.DataTypeUInt8: return readUInt8();
            case DataType.DataTypeInt16: return readInt16();
            case DataType.DataTypeUInt16: return readUInt16();
            case DataType.DataTypeInt32: return readInt32();
            case DataType.DataTypeUInt32: return readUInt32();
        }
    }

    public function readFloatArray(count: Int, dataType: DataType): Array<Float>
    {
        var dataSize = types.DataTypeUtils.dataTypeByteSize(dataType);

        var prevOffset = offset;

        var array = new Array<Float>();
        for(i in 0...count)
        {
            array.push(readFloat(dataType));

            offset += dataSize;
        }
        offset = prevOffset;
        return array;
    }

    public function readFloat32(): Float
    {
        seek();
        return reader.ReadSingle();
    }

    public function readFloat64(): Float
    {
        seek();
        return reader.ReadDouble();
    }

    public function toString(?dataType: DataType): String
    {
        return "";
    }

    public function resetOffset(): Void /// makes offset 0 and offsetLength be allocedLength
    {
        offset = 0;
        offsetLength = allocedLength;
    }

/// should not be used for reading and writing on the data
    public var allocedLength: Int;

/// if underlying pointer is set externally a new pointer will be created with a copy of that external pointer's memory.
    public function resize(newSize: Int): Void
    {
        memory.SetLength(newSize);
        var grow: Int = 0;
        if (newSize > allocedLength)
        {
            grow = newSize - allocedLength;
        }
        allocedLength = newSize;
        offsetLength = allocedLength - offset;

        //TODO unittest
        if (grow > 0)
        {
            memory.Seek(allocedLength - grow, SeekOrigin.Begin);
            memset(0, grow);
        }
    }

    @:functionCode("
        seek();
        var tmp = reader.ReadBytes(offsetLength);
        return System.Text.Encoding.UTF8.GetString(tmp);
    ")
    public function readString(): String
    {
        return "";
    }

    @:functionCode("
        seek();
        var tmp = System.Text.Encoding.UTF8.GetBytes(value);
        writer.Write(tmp);
    ")
    public function writeString(value: String): Void {}

/// makes the part pointed by offset and offset length become the full length of the data
/// by resizing the data fit exactly that.
    public function trim(): Void
    {

    }
}
