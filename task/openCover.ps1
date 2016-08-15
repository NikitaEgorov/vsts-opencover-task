[CmdletBinding()]
param(
	#[string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $opencoverExe,
	[string] $opencoverExe,
	# [string] $reportGeneratorExe,
	[string] $target = "$PWD\NUnit-2.6.4\bin\nunit-console.exe",
	[string] $targetargs = "Domain.Tests.Unit.dll /framework=4.0 /noshadow /nologo /out:TestResult.txt /err:StdErr.txt",
    [string] $output,
    [string] $registerUser = "true",
    [string] $filter = "+[BLL]* +[Domain]* -[*Tests.Unit]*",
    [string] $excludebyfile = "*\*Generated.cs"
    # [string] $reportTypes
)

Write-Output "Open Cover Task Version: 0.1.0"
Write-Output "OpenCover path: $opencoverExe"
# Write-Output "ReportGenerator path: $reportGeneratorExe"
Write-Output "Target: $target"
Write-Output "Output: $output"
Write-Output "RegisterUser: $registerUser"
# Write-Output "reportTypes: $reportTypes"

[bool]$registerUser = $registerUser -eq 'true'

if([string]::IsNullOrEmpty($opencoverExe)){
	$opencoverExe = "$PWD\opencover.4.6.519\OpenCover.Console.exe"
}
if([string]::IsNullOrEmpty($reportGeneratorExe)){
	$reportGeneratorExe = "ReportGenerator_2.4.5.0\bin\ReportGenerator.exe"
}


if (!(Test-Path $opencoverExe))
{
    Write-Error "File '$opencoverExe' not found."
    return
}

if (!(Test-Path $target))
{
    Write-Error "File '$target' not found."
    return
}


$exeArgs = @()

$exeArgs+="-target:""$target""" 

$exeArgs+='-targetargs:"' + $targetargs + '"'

if($registerUser) {
	$exeArgs+="-register:user"
}

if(![string]::IsNullOrEmpty($excludebyfile)) {
	$exeArgs+="-excludebyfile:""$excludebyfile"""
}

if(![string]::IsNullOrEmpty($filter)) {
	$exeArgs+="-filter:""$filter"""
}

$exeArgs+="-hideskipped:All"
$exeArgs+="-skipautoprops"
$exeArgs+="-returntargetcode"
$exeArgs+="-output:$PWD\coverage-output.xml"

[string] $exeArgsAsString = [system.String]::Join(" ", $exeArgs)

Write-Host "args: $exeArgsAsString"
Write-Host "opencoverExe: $opencoverExe"

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $opencoverExe
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = $exeArgsAsString

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()

Write-Host "stdout: $stdout"
Write-Host "stderr: $stderr"
Write-Host ("exit code: {0}" -f $p.ExitCode)