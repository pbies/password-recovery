# © 2018 Piotr Biesiada
clear
Write-Host `n`n`n`n`n`n`n

$pwfile = "passwords.txt"

if (!(Test-Path "$pwfile" -PathType Leaf))
{
	Write-Host "File $pwfile is missing!"
	pause
	exit 1
}

$passwords = Get-Content "$pwfile"
$count = $passwords.Length
# $rar = "c:\Program Files\WinRAR\WinRAR.exe"
# $rar = "c:\Program Files\WinRAR\Rar.exe"
$rar = "c:\Program Files\WinRAR\UnRAR.exe"

if (!(Test-Path "$rar" -PathType Leaf))
{
	Write-Host "File $rar is missing!"
	pause
	exit 1
}

$files=0
Get-ChildItem "." -Filter *.rar |
Foreach-Object {
	$files++
}
Write-Host "Files found: $files"

Get-ChildItem "." -Filter *.rar |
Foreach-Object {
	$i = 0
	$sw = [Diagnostics.Stopwatch]::StartNew()
	Write-Host "Processing file: $_"
	foreach ($password in $passwords)
	{
		& "$rar" 't' '/inul' "$_" "/p$password"
		if ($?)
		{
			Write-Host "Valid password: $password"
			Write-Output "$_`:$password" >> potfile.txt
			[console]::beep(500,300)
			$sw.Stop()
			Write-Host time = $sw.Elapsed.ToString()
			pause
			exit
		}
		$i++
		Write-Progress -Activity "Testing passwords" -status "$i/$count done, password: $password" -percentComplete ($i/$count*100)
	}
	$sw.Stop()
	Write-Host time = $sw.Elapsed.ToString()
}
pause
