Write-Output "此脚本为文件签名"
$Cert = Get-ChildItem Cert:\LocalMachine\My\_ #设置自己的证书路径
$File = Read-Host "输入要签名的文件"
Set-AuthenticodeSignature -Certificate $Cert -FilePath $args  -includeChain All -timeStampServer http://timestamp.verisign.com/scripts/timstamp.dll -HashAlgorithm sha256