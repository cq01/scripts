[string]$mkvtoolnix = "E:\Program\mkvtoolnix\mkvmerge.exe"
[string]$InputDir = "F:\Temp"
[string]$OutputDir = "F:\video\Chaos_Child_Love_Chu_Chu"
[string]$Temp ="$env:TEMP"
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
$OutputEncoding = $Utf8NoBomEncoding
[int]$i =0
    function DirFullname {
        param (
            $Dir
        )
        [Object]$In = (Get-ChildItem $Dir -Directory |Where-Object {$_.Name -notmatch '[^0-9]'}|Select-Object Name,FullName)
        $In|Add-Member -Name No -MemberType ScriptProperty {[int[]]$this.Name}
        [array]$Out = $In|Sort-Object No|Select-Object FullName
        return $Out.FullName
    }
function MakeMKV {
    param (
        [string]$mkvtoolnix,[string]$InputDir,[string]$OutputDir,[string]$Temp
    
    )
    New-Item $OutputDir
    [array]$InputDirectories=(DirFullname $InputDir)
    foreach ($SourcePath in $InputDirectories){
        [array]$SourcePaths = (DirFullname $SourcePath)
        foreach ($VedioDir in $SourcePaths){
            $i ++
            #import entry.json
            [string]$entryfile= $VedioDir +"\entry.json"
            [Object]$entry = (Get-Content $entryfile -Encoding utf8)|ConvertFrom-Json
            #download cover
            [string]$CoverFile=$Temp+"\"+$i+".jpg"
            Invoke-WebRequest  -UseBasicParsing -Uri $entry.cover -Method Get -OutFile $CoverFile
            #search blv
            if ($entry.type_tag -eq "lua.mp4.bapi.9") {
                [string]$blvDir=$VedioDir
                [string]$Inputmp4= $VedioDir +"\lua.mp4.bapi.9_remux.mp4"            }
            else {
                [string]$blvDir=$VedioDir+"\"+$entry.type_tag
                Set-Location $blvDir
                $InputFiles=(Get-ChildItem "*.flv","*.blv","*.mp4" -File |Where-Object {$_.BaseName -notmatch '[^0-9]'} |Sort-Object {'{0:d20}' -f [int]$_.BaseName}|Select-Object fullname)
                [array]$Inputmp4=$InputFiles.FullName
            }
            #make config
            if ($SourcePaths.Count -eq 1 ) {
                [string]$Title = $entry.title
            }
            else {
                [string]$Title = $entry.title + "_"+$entry.page_data.part
            }
            [string]$OutputFile= $OutputDir + "\" + '{0:d3}' -f $i +"_"+$Title +".mkv"
            [string]$danmakuFile= $VedioDir +"\danmaku.xml"
            [string]$indexFile = $blvDir + "\index.json"
            [array]$Part1= 
            "--ui-language",
            "zh_CN",
            "--output"
            [array]$Part2=
            "--language",
            "0:jpn",
            "--default-track",
            "0:yes",
            "--language",
            "1:jpn",
            "--cues",
            "1:all",
            "--default-track",
            "1:yes",
            "("
            [array]$Part3=
            ")",
            "--attachment-name",
            "danmaku.xml",
            "--attachment-mime-type",
            "application/xml",
            "--attach-file"
            [array]$part4=
            "--attachment-name",
            "entry.json",
            "--attachment-mime-type",
            "application/json",
            "--attach-file"
            [array]$part5=
            "--attachment-name",
            "index.json",
            "--attachment-mime-type",
            "application/json",
            "--attach-file"
            [array]$part6=
            "--attachment-name",
            "cover.jpg",
            "--attachment-mime-type",
            "image/jpeg",
            "--attach-file"
            [array]$part7=
            ,"--title"
            [array]$part8=
            "--track-order",
            "0:0,0:1"
            [array]$Whole=$Part1+$OutputFile+$Part2+$Inputmp4+$Part3+$danmakuFile+$part4+$entryfile+$part5+$indexFile+$part6+$CoverFile+$part7+$Title+$part8
            #output config
            [string]$OutJson=$Temp +"\"+$i+".json"
            $Whole|ConvertTo-Json | Out-File -FilePath $OutJson -Encoding utf8
            #make mkv
            &"$mkvtoolnix" @$OutJson
        }
    }    
        
}

MakeMKV -mkvtoolnix $mkvtoolnix -InputDir $InputDir -OutputDir $OutputDir -Temp $Temp
