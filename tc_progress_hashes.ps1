clear
Write-Host `n`n`n`n`n`n`n

$pwfile = "passwords.txt"

. ".\CRC.ps1"

if (!(Test-Path "$pwfile" -PathType Leaf))
{
	Write-Host "File $pwfile is missing!"
	pause
	exit 1
}

$passwords = Get-Content "$pwfile"
$count = $passwords.Length
$tc = "c:\Program Files\TrueCrypt\TrueCrypt.exe"
$file = "container.tc"

if (!(Test-Path "$tc" -PathType Leaf))
{
	Write-Host "File $tc is missing!"
	pause
	exit 1
}

function suc($p) {
	Write-Host "Valid password: $p"
	Write-Output "$file`:$p" >> potfile.txt
	Write-Host -nonewline "Dismounting..."
	$process = (Start-Process -FilePath "$tc" -ArgumentList "/s /q /dz /f" -PassThru -Wait)
	Write-Host "done"
	[console]::beep(500,300)
	pause
	exit
}

function test($p) {
	$process = (Start-Process -FilePath "$tc" -ArgumentList "/a /s /q /l z /m ro /v $file /p $p" -PassThru -Wait)
	if ($process.ExitCode -eq 0)
	{
		suc($p)
	}
}

if (!(Test-Path $file -PathType Leaf))
{
	Write-Host "File $file is missing!"
	pause
	exit 1
}

$i = 0
Write-Host "Processing file: $file"
If (Test-Path z:\)
{
	Write-Host -nonewline "Dismounting..."
	$process = (Start-Process -FilePath "$tc" -ArgumentList "/s /q /dz /f" -PassThru -Wait)
	Write-Host "done"
}

foreach ($password in $passwords)
{
	test($password)

	$hash = [System.Text.Encoding]::ASCII.GetBytes($password) | Get-CRC32
	$hash = [System.Convert]::ToString($hash,16)
	while ($hash.length -lt 8) { $hash="0$hash" }
	test($hash)

	$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$ascii = [System.Text.Encoding]::ASCII.GetBytes($password)
	$hash = [System.BitConverter]::ToString($md5.ComputeHash($ascii))
	$hash = $hash -replace "-", ""
	$hash = $hash.ToLower()
	test($hash)

	$sha256 = new-object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
	$ascii = [System.Text.Encoding]::ASCII.GetBytes($password)
	$hash = [System.BitConverter]::ToString($sha256.ComputeHash($ascii))
	$hash = $hash -replace "-", ""
	$hash = $hash.ToLower()
	test($hash)

	$i++
	Write-Progress -Activity "Testing passwords" -status "$i/$count done, password: $password" -percentComplete ($i/$count*100)
}
pause
