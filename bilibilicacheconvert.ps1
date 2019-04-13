<#
Copyright 2018 cq01

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
#>
<#
本脚本可以将bilibili缓存合并后继续被bilbili识别（安卓，至少目前可以（5.28））
本脚本需要ffmpeg，不会压缩视频
本脚本需缓存文件（*.flv或*.blv或*.mp4,entry.json,danmaku.xml)完整且源文件夹无其他上述扩展名文件，否则可能发生未知错误
如修改本脚本，请保持脚本编码为UTF-8 with BOM，否则可能出现未知错误
#>
[string]$ffmpeg =  "C:\Program Files\ffmpeg\bin\ffmpeg.exe"#改为自己的ffmpeg.exe地址
[string]$InputPath= "C:\Temp" #"H:\Android\data\tv.danmaku.bili\download\19801561"#改为你要转换的文件夹
[string]$OutputPath= "E:\Temp" #"F:\Mate8_backup\Android\data\tv.danmaku.bili\download\19801561"#改为你要输出的文件夹
[string]$TempFile ="$env:TEMP\list.txt"#临时文件地址，可不改
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
$OutputEncoding = $Utf8NoBomEncoding
#生成entry.json 
function DirFullname {
    param (
        $Dir
    )
    [Object]$In = (Get-ChildItem $Dir -Directory |Where-Object {$_.Name -notmatch '[^0-9]'}|Select-Object Name,FullName)
    $In|Add-Member -Name No -MemberType ScriptProperty {[int[]]$this.Name}
    [array]$Out = $In|Sort-Object No|Select-Object FullName
    return $Out.FullName
}
function EntryjsonChange  {
    param (
        [string]$InputDirectory,[string]$OutputDirectory
    )
    $InputJson="$InputDirectory\entry.json"
	$OuputJson="$OutputDirectory\entry.json"
    $RAW= [System.IO.File]::ReadAllText($InputJson, $Utf8NoBomEncoding)
    $Json=$RAW|ConvertFrom-Json
    $Inputindex = $InputDirectory+"\" +$Json.type_tag+"\index.json"
    [string]$type_tag= $Json.type_tag
    $Json.type_tag ="lua.mp4.bapi.9"
    #[string]$Text=$Json|ConvertTo-Json
	[string]$Text = "$Raw" -replace "`"type_tag`":`".*?`"","`"type_tag`":`"lua.mp4.bapi.9`""
    [System.IO.File]::WriteAllText($OuputJson, $Text, $Utf8NoBomEncoding)
    Copy-Item $Inputindex -Destination $OutputDirectory
    return $type_tag
}

#生成ffmpeg合并所需的文件
function MakelistFile {
    param (
        [System.Object]$FileList
    )
    [string]$Text =$null
    foreach ($Line in $FileList.fullname) {
        $Text += "file '$line'`n"
    }
    [System.IO.File]::WriteAllText($TempFile, $Text, $Utf8NoBomEncoding)
}
#生成视频
function MakeMp4 {
    param (
        [string]$InputDirectory,[string]$OutputDirectory,[string]$type_tag
    )
    [string]$OutputFile = "$OutputDirectory"+"\lua.mp4.bapi.9_remux.mp4"
    Set-Location "$InputDirectory\$type_tag"
    $InputFiles=(Get-ChildItem "*.flv","*.blv","*.mp4" -File |Where-Object {$_.BaseName -notmatch '[^0-9]'}|Sort-Object {'{0:d20}' -f [int]$_.basename}|Select-Object fullname)#如果文件名长度超过四位数请修改{0:d10}
    if ($InputFiles.Count -eq 1) {
        &"$ffmpeg" -i $InputFiles.fullname -c copy $OutputFile
    }
    else {
        MakelistFile -FileList $InputFiles
        &"$ffmpeg" -f concat -safe 0 -i $TempFile -c copy $OutputFile
    }
}
#脚本功能集合，如有需要，直接调用此函数，$InputSecondPath是输入目录，$OutputSecondPath是输出目录
function DirectoryCreat {
    param (
        [string]$InputSecondPath,[string]$OutputSecondPath
    )
    $InputDirectories=(DirFullname $InputSecondPath)
    foreach ($SourcePath in $InputDirectories){
        [string]$TargetPath= "$OutputSecondPath"+"\"+"$((Get-Item $SourcePath).Name)"
        New-Item -Path $TargetPath -ItemType Directory
        Copy-Item -Path "$SourcePath\danmaku.xml" -Destination "$TargetPath\danmaku.xml"
        [string]$type_tag =(EntryjsonChange -InputDirectory $SourcePath -OutputDirectory $TargetPath)
        MakeMp4 -InputDirectory $SourcePath -OutputDirectory $TargetPath -type_tag $type_tag
    }
}
function ListDir {
    param (
        $InputFirstPath,$OutputFristPath
    )
    $InputFirstPaths=(DirFullname $InputFirstPath)
    foreach ($InputSecondPath in $InputFirstPaths) {
        [string]$OutputSecondPath= "$OutputFristPath"+"\"+"$((Get-Item $inputsecondpath ).Name)"
        DirectoryCreat -InputSecondPath $InputSecondPath -OutputSecondPath $OutputSecondPath

    }
}
ListDir -InputFirstPath $InputPath -OutputFristPath $OutputPath
#DirectoryCreat -InputSecondPath $InputPath -OutputSecondPath $OutputPath
Remove-Item $TempFile