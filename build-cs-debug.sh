#!/usr/bin/env bash
haxe -main MainCs.hx -cp vectorx -cp examples/source -cp csharp -cs export-csharp -lib duell_aggx -D dll -D erase-generics -D vectorDebugDraw -v -debug -D real-position
cp export-csharp/bin/MainCs-Debug.* ~/develop/unity/cs_test/Assets