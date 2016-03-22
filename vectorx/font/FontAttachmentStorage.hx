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
    public var getImageSize: String -> Vector2 -> Vector2 -> Vector2;

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

        var imageSrc = config.image;
        var loadImage = function()
        {
            if (Math.ceil(dimensions.x) == 0 || Math.ceil(dimensions.y) == 0)
            {
                return new ColorStorage(0, 0);
            }

            return loadImage(imageSrc, origDimensions, dimensions);
        };

        var finalDimensions = getImageSize(imageSrc, origDimensions, dimensions);
        //intentionally left for debugging
        //trace('new attach: key: $key finalDim: {${finalDimensions.x}, ${finalDimensions.y}}');
        var attachment = new FontAttachment(loadImage, 0, 0, Math.ceil(finalDimensions.x), Math.ceil(finalDimensions.y), config.anchorPoint);
        attachments.set(key, attachment);

        return attachment;
    }

    public function addAttachmentConfig(config: AttachmentConfig): Void
    {
        attachmentsConfigs.set(config.name, config);
    }

    public function toString(): String
    {
        var strBuf = new StringBuf();
        strBuf.add("{\n");
        for (attachment in attachments)
        {
            strBuf.add('$attachment\n');
        }
        strBuf.add("}\n");

        return strBuf.toString();
    }
}
