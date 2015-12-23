package vectorx.font;

import types.RectI;
import haxe.ds.StringMap;

class FontAttachmentStorage
{
    private var images: StringMap<ColorStorage> = new StringMap<ColorStorage>();
    private var attachments: StringMap<FontAttachment> = new StringMap<FontAttachment>();
    public var loadImage: String -> ColorStorage;

    public function new()
    {

    }

    public function getAttachment(name: String): FontAttachment
    {
        return attachments.get(name);
    }

    public function addAttachment(name: String, imageFile: String, bounds: RectI): Void
    {
        var image = images.get(imageFile);
        if (image == null)
        {
            image = loadImage(imageFile);
        }

        var attachment = new FontAttachment(image, bounds.x, bounds.y, bounds.width, bounds.height);
        attachments.set(name, attachment);
    }
}
