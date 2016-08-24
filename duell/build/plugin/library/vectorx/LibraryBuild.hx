/*
 * Copyright (c) 2003-2016 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package duell.build.plugin.library.vectorx;

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
            LogHelper.info("", 'vecrorx - Processing changed folder $folder');

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

                LogHelper.info("", 'vectrox font collector - Processing changed file $file');
                changedFontFiles.push(Path.join([folder, file]));
            }
        }

        trace(changedFontFiles);
        throw "Debug";
    }

}
