Write-Output "禁止将Windows识别为移动工作区"
[string]$choice = Read-Host "输入Y禁止将Windows识别为移动工作区，输入N将Windows识别为移动工作区，输入D删除值，输入其他退出"
if ($choice -eq "Y") {
    Set-ItemProperty HKLM:\SYSTEM\ControlSet001\Control -Name "PortableOperatingSystem" -Type DWord -Value 0
}
elseif ($choice -eq "N") {
    Set-ItemProperty HKLM:\SYSTEM\ControlSet001\Control -Name "PortableOperatingSystem" -Type DWord -Value 1
}
elseif ($choice -eq "D") {
    Remove-ItemProperty HKLM:\SYSTEM\ControlSet001\Control PortableOperatingSystem
}
else {
    Exit-PSSession
}