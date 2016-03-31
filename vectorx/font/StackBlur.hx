package vectorx.font;

import png.Data.Color;
import types.Color4B;
import haxe.ds.Vector;
import aggx.core.memory.Byte;

class StackBlur
{
    private static var stackBlur8Mul:Vector<Byte> = Vector.fromArrayCopy([
        512,512,456,512,328,456,335,512,405,328,271,456,388,335,292,512,
        454,405,364,328,298,271,496,456,420,388,360,335,312,292,273,512,
        482,454,428,405,383,364,345,328,312,298,284,271,259,496,475,456,
        437,420,404,388,374,360,347,335,323,312,302,292,282,273,265,512,
        497,482,468,454,441,428,417,405,394,383,373,364,354,345,337,328,
        320,312,305,298,291,284,278,271,265,259,507,496,485,475,465,456,
        446,437,428,420,412,404,396,388,381,374,367,360,354,347,341,335,
        329,323,318,312,307,302,297,292,287,282,278,273,269,265,261,512,
        505,497,489,482,475,468,461,454,447,441,435,428,422,417,411,405,
        399,394,389,383,378,373,368,364,359,354,350,345,341,337,332,328,
        324,320,316,312,309,305,301,298,294,291,287,284,281,278,274,271,
        268,265,262,259,257,507,501,496,491,485,480,475,470,465,460,456,
        451,446,442,437,433,428,424,420,416,412,408,404,400,396,392,388,
        385,381,377,374,370,367,363,360,357,354,350,347,344,341,338,335,
        332,329,326,323,320,318,315,312,310,307,304,302,299,297,294,292,
        289,287,285,282,280,278,275,273,271,269,267,265,263,261,259
    ]);

    private static var stackBlur8Shr:Vector<Byte> = Vector.fromArrayCopy([
        9, 11, 12, 13, 13, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17,
        17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19,
        19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20,
        20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21,
        21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
        21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23,
        23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
        23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
        23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
        23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
        24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
        24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
        24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
        24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24
    ]);

    private static var accessor: ColorStorageAccessor = new ColorStorageAccessor();

    public static function blur(image: ColorStorage, radius: UInt): Void
    {
        accessor.set(image);
        blurX(accessor, radius);
        accessor.transpose();
        blurX(accessor, radius);
    }

    private static function blurX(image: ColorStorageAccessor, radius: UInt)
    {
        if (radius < 1)
        {
            return;
        }

        var stackStart: UInt = 0;
        var pix: Color4B = new Color4B();

        var sum = new Color4B();
        var sumIn = new Color4B();
        var sumOut = new Color4B();

        var w: UInt = image.width;
        var h: UInt = image.height;
        var wm: UInt = w - 1;
        var div: UInt = radius * 2 + 1;

        var divSum: UInt = (radius + 1) * (radius + 1);
        var maxVal: UInt = 0xffffffff;

        var mulSum: UInt = stackBlur8Mul[radius];
        var shrSum: UInt = stackBlur8Shr[radius];

        var buf: Vector<Color4B> = new Vector<Color4B>(w);
        for (i in 0 ... w)
        {
            buf[i] = new Color4B();
        }

        var stack: Vector<Color4B> = new Vector<Color4B>(div);

        for (y in 0 ... h)
        {
            sum.setRGBA(0, 0, 0, 0);
            sumIn.setRGBA(0, 0, 0, 0);
            sumOut.setRGBA(0, 0, 0, 0);

            image.getPixel(0, y, pix);

            for (i in 0 ... radius + 1)
            {
                stack[i] = new Color4B();
                stack[i].setRGBA(pix.r, pix.g, pix.b, pix.a);
                sumMulColor(sum, pix, i + 1);
                sumColor(sumOut, pix);
            }

            for (i in 1 ... radius + 1)
            {
                var x = (i > wm) ? wm : i;
                image.getPixel(x, y, pix);
                stack[i + radius].setRGBA(pix.r, pix.g, pix.b, pix.a);
                sumMulColor(sum, pix, radius + 1 - i);
                sumColor(sumIn, pix);
            }

            var stackPtr = radius;

            for (x in 0 ... w)
            {
                calcPix(buf[x], sum, mulSum, shrSum);
                subColor(sum, sumOut);

                var stackStart = stackPtr + div - radius;
                if(stackStart >= div)
                {
                    stackStart -= div;
                }

                var stackPix: Color4B = stack[stackStart];
                subColor(sumOut, stackPix);

                var xp = x + radius + 1;
                if(xp > wm)
                {
                    xp = wm;
                }

                image.getPixel(xp, y, pix);
                stackPix.setRGBA(pix.r, pix.g, pix.b, pix.a);

                sumColor(sumIn, pix);
                sumColor(sum, sumIn);

                ++stackPtr;
                if(stackPtr >= div)
                {
                    stackPtr = 0;
                }

                var stackPix = stack[stackPtr];

                sumColor(sumOut, stackPix);
                sumColor(sumIn, stackPix);
            }

            for (i in 0 ... w)
            {
                image.setPixel(i, y, buf[i]);
                trace('${buf[i]}');
            }

        }
    }

    private static inline function sumColor(val: Color4B, op: Color4B): Void
    {
        val.r += op.r;
        val.g += op.g;
        val.b += op.b;
        val.a += op.a;
    }

    private static inline function sumMulColor(val: Color4B, op: Color4B, coef: UInt): Void
    {
        val.r += op.r * coef;
        val.g += op.g * coef;
        val.b += op.b * coef;
        val.a += op.a * coef;
    }

    private static inline function calcPix(val: Color4B, sum: Color4B, mul: UInt, shr: UInt): Void
    {
        val.r = (sum.r * mul) >> shr;
        val.g = (sum.g * mul) >> shr;
        val.b = (sum.b * mul) >> shr;
        val.a = (sum.a * mul) >> shr;
    }

    private static inline function subColor(val: Color4B, op: Color4B): Void
    {
        val.r -= op.r;
        val.g -= op.g;
        val.b -= op.b;
        val.a -= op.a;
    }
}