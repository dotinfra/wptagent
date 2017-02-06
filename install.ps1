$Path = 'HKCU:\Control Panel\Desktop'

Try {
  $CurrentVal = Get-ItemProperty -Path $Path -Name ScreenSaveActive
  Write-Output $CurrentVal
} Catch {
  $CurrentVal = False
} Finally {
  if ($CurrentVal.ScreenSaveActive -ne 0) {
    Set-ItemProperty -Path $Path -Name ScreenSAveActive -Value 0
    Write-Output "Screensaver Disabled."
  } Else {
    Write-Output "ScreenSaver Already Disabled."
  }
}

$CurrentVal = POWERCFG /QUERY SCHEME_BALANCED SUB_VIDEO | Select-String -pattern "Current AC Power Setting Index:"

If ($CurrentVal -like "*0x00000000*") {
  Write-Output "Display Timeout already set to Never."
} Else {
  POWERCFG /CHANGE -monitor-timeout-ac 0
  Write-Output "Display Timeout set to Never."
}

$Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

Try {
  $CurrentVal = Get-ItemProperty -Path $Path -Name ConsentPromptBehaviorAdmin
  Write-Output $CurrentVal
} Catch {
  $CurrentVal = False
} Finally {
  if ($CurrentVal.ConsentPromptBehaviorAdmin -ne 0) {
    Set-ItemProperty -Path $Path -Name ConsentPromptBehaviorAdmin -Value 0
    Write-Output "UAC Disabled."
  } Else {
    Write-Output "UAC Already Disabled."
  }
}

$useplatformclock = bcdedit | Select-String -pattern "useplatformclock        Yes"

if ($useplatformclock) {
  Write-Output "Platform Clock Already Enabled."
} Else {
  bcdedit /set  useplatformclock true
  Write-Output "Platform Clock Enabled."
}

$Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability'

Try {
  $CurrentVal = Get-ItemProperty -Path $Path -Name ShutdownReasonUI
  Write-Output $CurrentVal
} Catch {
  $CurrentVal = False
} Finally {
  if ($CurrentVal.ShutdownReasonUI -ne 0) {
    Set-ItemProperty -Path $Path -Name ShutdownReasonUI -Value 0
    Write-Output "Shutdown Event Tracker Disabled."
  } Else {
    Write-Output "ShutDown Event Tracker Already Disabled."
  }
}


$InstallDir = "C:\webpagetest"
$ScriptDir = "C:\Users\IEUser"
$TempDir = "C:\wpttemp"
$URL = "https://github.com/WPO-Foundation/webpagetest/releases/download/WebPageTest-3.0/webpagetest_3.0.zip"
$ZipFile = "$TempDir\webpagetest_3.0.zip"

If (Test-Path $InstallDir -pathType container) {
  Write-Output "Dir WebPageTest already created."
} Else {
  New-Item $InstallDir -type directory
  Write-Output "Dir WebPageTest created."
}

If (Test-Path $TempDir -pathType container) {
  Write-Output "Dir Temp WebPageTest already created."
} Else {
  New-Item $TempDir -type directory
  Write-Output "Dir Temp WebPageTest created."
}

function Expand-ZIPFile($file, $destination) {

  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)

  foreach($item in $zip.items()) {
    $shell.Namespace($destination).copyhere($item)
  }
}

$TestDir = "$InstallDir\agent"

If (Test-Path $TestDir -pathType container) {
  Write-Output "WebPageTest already installed."
} Else {
  $WebClient = New-Object System.Net.WebClient
  $WebClient.DownloadFile($URL,$ZipFile)
  Expand-ZIPFile -File $ZipFile -Destination $InstallDir
  Write-Output "WebPageTest installed."
}

$Installed = Test-Path "C:\Program Files (x86)\AviSynth 2.5" -pathType container

If ($Installed) {
  Write-Output "AviSynth already installed."
} Else {
  & "$InstallDir\agent\Avisynth_258.exe" /S
  Write-Output "AviSynth installed."
}


$testsigning = bcdedit | Select-String -pattern "testsigning             Yes"

if ($testsigning) {
  Write-Output "Test Signing Already Enabled."
} Else {
  bcdedit /set TESTSIGNING ON
  Write-Output "Test Signing Enabled."
}

If (Test-Path $InstallDir\agent\dummynet\netipfw.inf) {
  Write-Output "Dummynet already installed."
} Else {
  Copy-Item $InstallDir\agent\dummynet\32bit\* $InstallDir\agent\dummynet\
  "$ScriptDir\mindinst.exe $InstallDir\agent\dummynet\netipfw.inf -i -s"
  Write-Output "Dummynet installed."
}
