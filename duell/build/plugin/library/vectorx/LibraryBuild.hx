/*
 * Copyright (c) 2003-2016 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package duell.build.plugin.library.vectorx;

import haxe.ds.StringMap;
import haxe.format.JsonParser;
import duell.helpers.BinaryFileWriter;
import duell.build.objects.Configuration;
import duell.build.plugin.library.filesystem.AssetProcessorRegister;
import duell.helpers.CommandHelper;
import duell.helpers.DirHashHelper;
import duell.helpers.FileHelper;
import duell.helpers.LogHelper;
import duell.helpers.PathHelper;
import duell.helpers.PlatformHelper;
import duell.objects.DuellLib;
import haxe.io.Path;
import haxe.Json;
import python.lib.Os;
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;

using duell.helpers.HashHelper;
using StringTools;

class LibraryBuild
{
    private var writer: BinaryFileWriter = new BinaryFileWriter();

    public function new()
    {}

    public function postParse(): Void
    {
        if (Configuration.getData().PLATFORM == null || Configuration.getData().PLATFORM.PLATFORM_NAME == "unitylayout")
            return;

        AssetProcessorRegister.registerProcessor(process, AssetProcessorPriority.AssetProcessorPriorityLow, 0);
    }

    private function process(): Void
    {
        var changedFontFiles: Array<String> = [];

        for (folder in AssetProcessorRegister.foldersThatChanged)
        {
            LogHelper.info("", 'vectorx - Processing changed folder $folder');

            var path = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, folder]);
            if (!FileSystem.exists(path))
            {
                continue;
            }

            var files = PathHelper.getRecursiveFileListUnderFolder(path);

            for (file in files)
            {
                if (!file.endsWith(".ttf") && !file.endsWith(".ttf.bytes"))
                {
                    continue;
                }

                LogHelper.info("", 'vectorx font collector - Processing changed file $file');
                changedFontFiles.push(Path.join([folder, file]));
            }
        }


        var fontsManifestFile = Path.join([Configuration.getData().OUTPUT, "vectorx", "fonts.json"]);

        var oldFiles = getCurrentFonts(fontsManifestFile);
        var fileMap: StringMap<Int> = new StringMap<Int>();

        oldFiles = oldFiles.concat(changedFontFiles);
        var newFiles: Array<String> = [];
        for (file in oldFiles)
        {
            var fullPath = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, file]);
            if (!FileSystem.exists(fullPath))
            {
                LogHelper.info("", 'vectorx font collector - $fullPath is deleted');
                continue;
            }

            if (!fileMap.exists(file))
            {
                newFiles.push(file);
                fileMap.set(file, 1);
            }
        }

        newFiles.sort(function(a,b) return Reflect.compare(a, b));

        var dynObj  = {fonts: newFiles};

        PathHelper.mkdir(Path.join([Configuration.getData().OUTPUT, "vectorx"]));
        var output = Json.stringify(dynObj);
        File.saveContent(fontsManifestFile, output);

        PathHelper.mkdir(Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, "vectorx"]));
        var exportFile = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, "vectorx", "fonts.json"]);
        File.saveContent(exportFile, output);
    }

    private function getCurrentFonts(filename: String): Array<String>
    {
        if (!FileSystem.exists(filename))
        {
            LogHelper.info("", 'vectorx font collector - manifest not found $filename');
            return [];
        }

        var json = Json.parse(File.getContent(filename));

        if (json.fonts == null)
        {
            return [];
        }

        return json.fonts;
    }

}
