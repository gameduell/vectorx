import StyledStringParserTest.MockProvider;
import vectorx.font.AttributedString;
import vectorx.font.AttributedStringPart;
import vectorx.font.StyledStringParser;
import vectorx.font.FontAliasesStorage;
import vectorx.font.FontCache;

class AttributedStringTest extends unittest.TestCase
{
	public function testConversion(): Void
	{
		var originalString: String = "[kern=5]abc[kern=10]def[/kern]ghi[/kern]";
		var parser = new StyledStringParser();
		var cache = new FontCache(null);
		var provider = new MockProvider();
		var attributedString: AttributedString = parser.toAttributedString(originalString, provider);
		var strings: Array<AttributedStringPart> = attributedString.toAttributedStringPartArray();
		assertTrue(strings.length == 3);
		assertTrue(strings[0].text == "abc");
		assertTrue(strings[0].attributes.range.index == 0);
		assertTrue(strings[0].attributes.range.length == 3);
		assertTrue(strings[0].attributes.kern == 5);
		assertTrue(strings[1].text == "def");
		assertTrue(strings[1].attributes.range.index == 0);
		assertTrue(strings[1].attributes.range.length == 3);
		assertTrue(strings[1].attributes.kern == 10);
		assertTrue(strings[2].text == "ghi");
		assertTrue(strings[2].attributes.range.index == 0);
		assertTrue(strings[2].attributes.range.length == 3);
		assertTrue(strings[2].attributes.kern == 5);
		var merged: AttributedString = AttributedString.fromAttributedStringPartArray(strings);
		assertTrue(merged.string == "abcdefghi");
		assertTrue(merged.attributeStorage.spans.length == 3);
		assertTrue(merged.attributeStorage.spans[0].range.index == 0);
		assertTrue(merged.attributeStorage.spans[0].range.length == 3);
		assertTrue(merged.attributeStorage.spans[1].range.index == 3);
		assertTrue(merged.attributeStorage.spans[1].range.length == 3);
		assertTrue(merged.attributeStorage.spans[2].range.index == 6);
		assertTrue(merged.attributeStorage.spans[2].range.length == 3);
	}
}
