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

import haxe.CallStack;
import types.DataType.DataTypeUtils;
import types.Data;
import types.DataStringTools;

import types.DataType;

using types.DataStringTools;


class DataTest //extends haxe.unit.TestCase
{
    function new()
    {

    }

    private static function assertTrue(v: Bool)
    {
        if (!v)
        {
            trace(CallStack.toString(CallStack.callStack()));
            throw "Assertion failed";
        }
    }

    public  static function testAll(): Void
    {
        trace("testAll()");

        //does not work in unity
        /*var r = new haxe.unit.TestRunner();
        r.add(new DataTest());
        r.run();*/

        var obj: DataTest = new DataTest();
        obj.testCreation();
        obj.testSettingUnsignedShort();
        obj.testResize();
        obj.testResizeFrom0();
        obj.testSettingAFloat();
        obj.testSettingArrayWithOffset();
        obj.testSettingData();
        obj.testSettingDouble();
        obj.testSettingFloatArray();
        obj.testSettingIntArray();
        obj.testSettingUnsignedByte();
        obj.testSettingValueWithOffset();
        obj.testDataStringTools();
    }

    public static function nearlyEqual(a: Float, b: Float): Bool
    {
        var absA = Math.abs(a);
        var absB = Math.abs(b);
        var diff = Math.abs(a - b);

        if (a == b)
        { // shortcut, handles infinities
            return true;
        }
        else if (a * b == 0)
        { // a or b or both are zero
// relative error is not meaningful here
            return diff < (0.0001 * 0.0001);
        }
        else
        { // use relative error
            return diff / (absA + absB) < 0.0001;
        }
    }

    private function assertFloatArray(floatArray: Array<Float>, data: Data, dataType: DataType): Void
    {
        var failed = false;
        var prevOffset = data.offset;
        var currentOffset = prevOffset;

        var resArr: Array<Float> = [];
        for (i in 0...floatArray.length)
        {
            data.offset = currentOffset;
            var f = floatArray[i];
            var fInData = data.readFloat(dataType);
            resArr.push(fInData);
            if (!nearlyEqual(f, fInData))
            {
                failed = true;
                //break;
            }
            currentOffset += DataTypeUtils.dataTypeByteSize(dataType);
        }
        data.offset = prevOffset;

        if (failed)
        {
            data.dump();
            trace("Comparison Failed, expected: " + floatArray.toString() + " and got: " + resArr.toString());
            assertTrue(false);
        }
        assertTrue(true);
    }

    private function assertIntArray(intArray: Array<Int>, data: Data, dataType: DataType): Void
    {
        var failed = false;
        var prevOffset = data.offset;
        var currentOffset = prevOffset;
        for (i in 0...intArray.length)
        {
            data.offset = currentOffset;
            var int = intArray[i];
            var intInData = data.readInt(dataType);
            if (int != intInData)
            {
                failed = true;
                break;
            }
            currentOffset += DataTypeUtils.dataTypeByteSize(dataType);
        }
        data.offset = prevOffset;

        if (failed)
        {
            trace("Comparison Failed, expected: " + intArray.toString() + " and got: " + data.toString(dataType));
            assertTrue(false);
        }
        assertTrue(true);
    }

    public function testCreation(): Void
    {
        trace('testCreation');
        var data = new Data(4);
        assertTrue(data != null && data.allocedLength == 4);
    }

    public function testSettingAFloat(): Void
    {
        trace('testSettingAFloat');
        var data = new Data(4);
        data.writeFloat(1.1, DataTypeFloat32);
        //data.dump();
        assertFloatArray([1.1], data, DataTypeFloat32);
    }

    public function testSettingUnsignedShort(): Void
    {
        trace('testSettingUnsignedShort');
        var data = new Data(2);
        data.writeInt(1, DataTypeUInt16);
        assertIntArray([1], data, DataTypeUInt16);
    }

    public function testSettingUnsignedByte(): Void
    {
        trace("testSettingUnsignedByte");
        var data = new Data(1);
        data.writeInt(1, DataTypeUInt8);
        assertIntArray([1], data, DataTypeUInt8);
    }

    public function testSettingDouble(): Void
    {
        trace("testSettingDouble");
        var data = new Data(8);
        data.writeFloat(1.01223, DataTypeFloat64);
        assertFloatArray([1.01223], data, DataTypeFloat64);
    }

    public function testSettingIntArray(): Void
    {
        trace("testSettingIntArray");
        var array = [1, 2, 3, 4, 5];
        var data = new Data(array.length * 4);
        data.writeIntArray(array, DataTypeInt32);

        assertIntArray([1, 2, 3, 4, 5], data, DataTypeInt32);
    }

    public function testSettingFloatArray(): Void
    {
        trace("testSettingFloatArray");
        var array = [1.1, 2.1, 3.1, 4.1, 5.1];
        var data = new Data(array.length * 4);
        data.writeFloatArray(array, DataTypeFloat32);

        assertFloatArray([1.1, 2.1, 3.1, 4.1, 5.1], data, DataTypeFloat32);
    }

    public function testSettingData(): Void
    {
        trace('testSettingData');
        var array = [1, 2, 3, 4, 5];
        var data = new Data(array.length * 4);
        data.writeIntArray(array, DataTypeInt32);

        var array2 = [6, 7];
        var data2 = new Data(array2.length * 4);
        data2.writeIntArray(array2, DataTypeInt32);

        data.writeData(data2);

        assertIntArray([6, 7, 3, 4, 5], data, DataTypeInt32);
    }

    public function testSettingValueWithOffset(): Void
    {
        trace('testSettingValueWithOffset');
        var data = new Data(2 * 4);
        data.writeInt(1, DataTypeInt32);
        data.offset = 4;
        data.writeInt(2, DataTypeInt32);
        data.offset = 0;

        assertIntArray([1, 2], data, DataTypeInt32);
    }

    public function testSettingDataWithOffset(): Void
    {
        trace('testSettingDataWithOffset');
        var array = [1, 2, 3, 4, 5];
        var data = new Data(array.length * 4);
        data.writeIntArray(array, DataTypeInt32);

        var array2 = [6, 7];
        var data2 = new Data(array2.length * 4);
        data2.writeIntArray(array2, DataTypeInt32);

        data.offset = 8;
        data.writeData(data2);
        data.offset = 0;

        assertIntArray([1, 2, 6, 7, 5], data, DataTypeInt32);
    }

    public function testSettingArrayWithOffset(): Void
    {
        trace('testSettingArrayWithOffset');
        var array = [1, 2, 3, 4, 5];
        var data = new Data(array.length * 4);
        data.writeIntArray(array, DataTypeInt32);

        var array2 = [6, 7];
        data.offset = 8;
        data.writeIntArray(array2, DataTypeInt32);
        data.offset = 0;

        assertIntArray([1, 2, 6, 7, 5], data, DataTypeInt32);
    }

    public function testDataStringTools(): Void
    {
        trace("testDataStringTools");
        var str = "Test String With 2 byte UTF8 character <†> and 4 byte UTF8 character <১>";

        var data = new Data(76);
        data.writeString(str);

        var newStr = data.readString();
        trace(newStr);
        assertTrue(str == newStr);
    }

    public function testResize(): Void
    {
        trace('testResize');
        var array = [1, 2, 3, 4, 5];
        var data = new Data((array.length - 1) * 4);
        data.resize((array.length) * 4);
        data.writeIntArray(array, DataTypeInt32);

        assertIntArray([1, 2, 3, 4, 5], data, DataTypeInt32);

    }

    public function testResizeFrom0(): Void
    {
        trace('testResizeFrom0');
        var array = [1, 2, 3, 4, 5];
        var data = new Data(0);
        data.resize((array.length) * 4);
        data.writeIntArray(array, DataTypeInt32);

        assertIntArray([1, 2, 3, 4, 5], data, DataTypeInt32);
    }

///missing testing offset with smaller types than int/float, and future big types like double
}