# (C) 2019 Piotr Biesiada
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
$7ZipPath = "C:\Program Files\7-Zip\7z.exe"

if (!(Test-Path "$7ZipPath" -PathType Leaf))
{
	Write-Host "File $7ZipPath is missing!"
	pause
	exit 1
}

$files=0
Get-ChildItem "." -Filter *.zip |
Foreach-Object {
	$files++
}
Write-Host "Files found: $files"

Get-ChildItem "." -Filter *.zip |
Foreach-Object {
	$i = 0
	$sw = [Diagnostics.Stopwatch]::StartNew()
	Write-Host "Processing file: $_"
	foreach ($password in $passwords)
	{
		& $7ZipPath "t" $_ "-p$password" > $null 2> $null
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
