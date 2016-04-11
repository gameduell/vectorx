import haxe.macro.Expr.ExprOf;
import vectorx.font.AttributedSpan;
import vectorx.font.AttributedSpanStorage;

class AttributedSpanStorageTest extends unittest.TestCase
{
    public function testBasic()
    {
        var string = "abcdefghjiklmnopqrstuvwxyz";
        var storage = new AttributedSpanStorage();
        var span = new AttributedSpan(string, 0, string.length);
        storage.addSpan(span);
        assertTrue(storage.spans.length == 1);

        checkSpanContinuity(string.length, storage);
    }

    public function testInsideCase()
    {
        var string = "abcdefghjiklmnopqrstuvwxyz";
        var storage = new AttributedSpanStorage();
        var span = new AttributedSpan(string, 0, string.length);
        span.kern = 1;
        storage.addSpan(span);

        span = new AttributedSpan(string, 10, 10);
        span.kern = 10;
        storage.addSpan(span);

        checkSpanContinuity(string.length, storage);

        assertTrue(storage.spans.length == 3);

        assertTrue(storage.spans[0].kern == 1);
        assertTrue(storage.spans[1].kern == 10);
        assertTrue(storage.spans[2].kern == 1);
    }

    public function testLeftCase()
    {
        var string = "abcdefghjiklmnopqrstuvwxyz";
        var storage = new AttributedSpanStorage();
        var span = new AttributedSpan(string, 0, string.length);
        span.kern = 1;
        storage.addSpan(span);

        span = new AttributedSpan(string, 20, 6);
        span.kern = 10;
        storage.addSpan(span);

        checkSpanContinuity(string.length, storage);

        assertTrue(storage.spans.length == 2);
        assertTrue(storage.spans[0].kern == 1);
        assertTrue(storage.spans[1].kern == 10);
    }

    public function testRightCase()
    {
        var string = "abcdefghjiklmnopqrstuvwxyz";
        var storage = new AttributedSpanStorage();
        var span = new AttributedSpan(string, 0, string.length);
        span.kern = 1;
        storage.addSpan(span);

        span = new AttributedSpan(string, 0, 10);
        span.kern = 10;
        storage.addSpan(span);

        checkSpanContinuity(string.length, storage);

        assertTrue(storage.spans.length == 2);
        assertTrue(storage.spans[0].kern == 10);
        assertTrue(storage.spans[1].kern == 1);
    }

    public function testCover()
    {
        var string = "abcdefghjiklmnopqrstuvwxyz";
        var storage = new AttributedSpanStorage();
        var span = new AttributedSpan(string, 0, string.length);
        span.kern = 1;
        storage.addSpan(span);

        span = new AttributedSpan(string, 10, 10);
        span.kern = 2;
        storage.addSpan(span);

        checkSpanContinuity(string.length, storage);
        assertTrue(storage.spans.length == 3);

        span = new AttributedSpan(string, 10, 10);
        span.kern = 3;
        storage.addSpan(span);

        checkSpanContinuity(string.length, storage);
        assertTrue(storage.spans.length == 3);

        assertTrue(storage.spans[0].kern == 1);
        assertTrue(storage.spans[1].kern == 3);
        assertTrue(storage.spans[2].kern == 1);
    }

	public function testAppending(): Void
	{
		var string = "abcdefghjiklmnopqrstuvwxyz";
        var storage = new AttributedSpanStorage();
		var startIndexes: Array<Int> = [0, 5, 10, 15, 20];
		var lengths: Array<Int> = [5, 5, 5, 5, 6];
		var totalLength: Int = 0;
		for (i in 0...startIndexes.length)
		{
			var span = new AttributedSpan(string, startIndexes[i], lengths[i]);
	        span.kern = i + 1;
	        storage.addSpan(span);
			totalLength += lengths[i];
			checkSpanContinuity(totalLength, storage);
		}
	}

    private function checkSpanContinuity(len: Int, store: AttributedSpanStorage): Void
    {
        var index: Int = 0;
        for (span in store.spans)
        {
			assertTrue(index == span.range.index);
            index += span.range.length;
        }

		assertTrue(index == len);
    }
}
