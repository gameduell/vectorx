#!/usr/bin/env bash
haxe -main csharp.MainCs -cp vectorx -cp examples/source -cp csharp -cs Export/csharp -lib duell_aggx -D dll -D erase-generics -D vectorDebugDraw -v -debug -D real-position
cp Export/csharp/bin/MainCs-Debug.* ~/develop/unity/cs_test/Assets