# © 2018 Piotr Biesiada
function Get-CRC32 {
    <#
        .SYNOPSIS
            Calculate CRC.
        .DESCRIPTION
            This function calculates the CRC of the input data using the CRC32 algorithm.
        .EXAMPLE
            Get-CRC32 $data
        .EXAMPLE
            $data | Get-CRC32
        .NOTES
            C to PowerShell conversion based on code in https://www.w3.org/TR/PNG/#D-CRCAppendix
            Author: Øyvind Kallstad
            Date: 06.02.2017
            Version: 1.0
        .INPUTS
            byte[]
        .OUTPUTS
            uint32
        .LINK
            https://communary.net/
        .LINK
            https://www.w3.org/TR/PNG/#D-CRCAppendix
    #>
    [CmdletBinding()]
    param (
        # Array of Bytes to use for CRC calculation
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]$InputObject
    )

    Begin {

        function New-CrcTable {
            [uint32]$c = $null
            $crcTable = New-Object 'System.Uint32[]' 256

            for ($n = 0; $n -lt 256; $n++) {
                $c = [uint32]$n
                for ($k = 0; $k -lt 8; $k++) {
                    if ($c -band 1) {
                        $c = (0xEDB88320 -bxor ($c -shr 1))
                    }
                    else {
                        $c = ($c -shr 1)
                    }
                }
                $crcTable[$n] = $c
            }

            Write-Output $crcTable
        }

        function Update-Crc ([uint32]$crc, [byte[]]$buffer, [int]$length) {
            [uint32]$c = $crc

            if (-not($script:crcTable)) {
                $script:crcTable = New-CrcTable
            }

            for ($n = 0; $n -lt $length; $n++) {
                $c = ($script:crcTable[($c -bxor $buffer[$n]) -band 0xFF]) -bxor ($c -shr 8)
            }

            Write-output $c
        }

        $dataArray = @()
    }

    Process {
        foreach ($item  in $InputObject) {
            $dataArray += $item
        }
    }

    End {
        $inputLength = $dataArray.Length
        Write-Output ((Update-Crc -crc 0xffffffffL -buffer $dataArray -length $inputLength) -bxor 0xffffffffL)
    }
}

### MAIN PROGRAM ###

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
		Write-Progress -Activity "Testing passwords" -status "$i/$count done" -percentComplete ($i/$count*100)
	}
}
pause
