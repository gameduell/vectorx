package vectorx.font;

import vectorx.font.StyledStringContext.AttachmentConfig;
import types.Vector2;
import types.RectI;
import haxe.ds.StringMap;

class FontAttachmentStorage
{
    private var images: StringMap<ColorStorage> = new StringMap<ColorStorage>();
    private var attachmentsConfigs: StringMap<AttachmentConfig> = new StringMap<AttachmentConfig>();
    private var attachments: StringMap<FontAttachment> = new StringMap<FontAttachment>();
    public var loadImage: String -> Vector2 -> Vector2 -> ColorStorage;

    public function new()
    {

    }

    public function getAttachment(name: String, scale: Float): FontAttachment
    {
        var config = attachmentsConfigs.get(name);
        if (config == null)
        {
            throw 'Attachment $name is not found';
        }

        var width: Int = config.width;
        var height: Int = config.height;

        var dimensions = new Vector2();
        dimensions.setXY(width * scale, height * scale);

        var key = '$name$$${Math.ceil(dimensions.x)}_${Math.ceil(dimensions.y)}}';
        var value = attachments.get(key);

        if (value != null)
        {
            return value;
        }

        var origDimensions = new Vector2();
        origDimensions.setXY(width, height);

        var bitmap: ColorStorage = loadImage(config.image, origDimensions, dimensions);

        var attachment = new FontAttachment(bitmap,
                        bitmap.selectedRect.x,
                        bitmap.selectedRect.y,
                        bitmap.selectedRect.width,
                        bitmap.selectedRect.height,
                        config.anchorPoint);

        attachments.set(key, attachment);

        return attachment;
    }

    public function addAttachmentConfig(config: AttachmentConfig): Void
    {
        attachmentsConfigs.set(config.name, config);
    }
}
