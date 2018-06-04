clear
Write-Host `n`n`n`n`n`n`n

$passwords = Get-Content "passwords.txt"
$count = $passwords.Length
# $rar = "c:\Program Files\WinRAR\WinRAR.exe"
# $rar = "c:\Program Files\WinRAR\Rar.exe"
$rar = "c:\Program Files\WinRAR\UnRAR.exe"

Get-ChildItem "." -Filter *.rar |
Foreach-Object {
	$i = 0
	$sw = [Diagnostics.Stopwatch]::StartNew()
	Write-Host Processing file: $_
	foreach ($password in $passwords)
	{
		& "$rar" 't' '/inul' "$_" "/p$password"
		if ($?)
		{
			Write-Host "Valid password:"$password
			[console]::beep(500,300)
			$sw.Stop()
			Write-Host time = $sw.Elapsed.ToString()
			pause
			exit
		}
		$i++
		Write-Progress -Activity "Testing passwords" -status "$i/$count done" -percentComplete ($i/$count*100)
	}
	$sw.Stop()
	Write-Host time = $sw.Elapsed.ToString()
}
pause
