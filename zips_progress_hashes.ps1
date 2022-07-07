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
$7ZipPath = "C:\Program Files\7-Zip\7z.exe"

if (!(Test-Path "$7ZipPath" -PathType Leaf))
{
	Write-Host "File $7ZipPath is missing!"
	pause
	exit 1
}

function suc($p) {
	Write-Host "Valid password: $p"
	Write-Output "$_`:$password" >> potfile.txt
	[console]::beep(500,300)
	pause
	exit
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
	Write-Host Processing file $_
	foreach ($password in $passwords)
	{
		& $7ZipPath "t" $_ "-p$password" > $null 2> $null
		if ($?)
		{
			suc($password)
		}
		$hash = [System.Text.Encoding]::ASCII.GetBytes($password) | Get-CRC32
		$hash = [System.Convert]::ToString($hash,16)
		while ($hash.length -lt 8) { $hash="0$hash" }
		& $7ZipPath "t" $_ "-p$hash" > $null 2> $null
		if ($?)
		{
			suc($password)
		}
		$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
		$ascii = [System.Text.Encoding]::ASCII.GetBytes($password)
		$hash = [System.BitConverter]::ToString($md5.ComputeHash($ascii))
		$hash = $hash -replace "-", ""
		$hash = $hash.ToLower()
		& $7ZipPath "t" $_ "-p$hash" > $null 2> $null
		if ($?)
		{
			suc($password)
		}
		$sha256 = new-object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
		$ascii = [System.Text.Encoding]::ASCII.GetBytes($password)
		$hash = [System.BitConverter]::ToString($sha256.ComputeHash($ascii))
		$hash = $hash -replace "-", ""
		$hash = $hash.ToLower()
		& $7ZipPath "t" $_ "-p$hash" > $null 2> $null
		if ($?)
		{
			suc($password)
		}
		$i++
		Write-Progress -Activity "Testing passwords" -status "$i/$count done, password: $password" -percentComplete ($i/$count*100)
	}
}
pause
