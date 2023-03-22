# Created by:           Brad Arrowood
# Created on:		    2023.03.16
# Last updated:         2023.03.22
# Script name:		    browser_cleaner.ps1
# Version:              1.3
# Description:		    This is meant to clear all cache from Edge, Chrome, and Firefox
#
# References:
# https://stackoverflow.com/questions/2085744/how-do-i-get-the-current-username-in-windows-powershell
# https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.3
# https://stackoverflow.com/questions/44503254/how-do-i-change-the-font-size-of-a-list-box-in-powershell
# https://social.technet.microsoft.com/Forums/scriptcenter/en-US/1167d538-7a66-44e1-be1d-9b267c4a5938/powershell-gui-questionagain-disable-resize-and-maximize?forum=ITCG
# https://learn.microsoft.com/en-us/dotnet/api/microsoft.windows.powershell.gui.internal.colornames?view=powershellsdk-1.1.0
# https://community.spiceworks.com/topic/2317726-powershell-script-to-clear-up-cache-cookies-on-a-active-chrome-session
# https://superuser.com/questions/1659971/remove-multiple-specific-named-folders-and-ther-subfolders-with-files-with-power

function prestart {

    # creating the details of the dialog box to appear and prompt the user before starting cleaning process
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Browser cleaner'
    $form.FormBorderStyle = 'None'
    $form.Size = New-Object System.Drawing.Size(310,200)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.FormBorderStyle = 'Fixed3D'
    $form.BackColor = 'Lavender'
    $form.ForeColor = 'Black'
    $form.Topmost = $true
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(70,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.Font = New-Object System.Drawing.Font("Neue Haas Grotesk Text Pro",12,[System.Drawing.FontStyle]::Regular)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(155,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.Font = New-Object System.Drawing.Font("Neue Haas Grotesk Text Pro",12,[System.Drawing.FontStyle]::Regular)
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    
    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(10,10)
    $label1.Size = New-Object System.Drawing.Size(280,65)
    $label1.Text = 'Please safely close all open browser windows.'
    $label1.Font = New-Object System.Drawing.Font("Neue Haas Grotesk Text Pro",12,[System.Drawing.FontStyle]::Regular)
    $label1.TextAlign = 'MiddleCenter'
    $form.Controls.Add($label1)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10,55)
    $label2.Size = New-Object System.Drawing.Size(280,65)
    $label2.Text = 'Select OK to continue.'
    $label2.Font = New-Object System.Drawing.Font("Neue Haas Grotesk Text Pro",12,[System.Drawing.FontStyle]::Regular)
    $label2.TextAlign = 'MiddleCenter'
    $form.Controls.Add($label2)
    
    $result = $form.ShowDialog()
    
    return $result

}

function kill_browser {
    
    # kills all running instances of all browsers
    taskkill /IM msedge.exe /F
    taskkill /IM chrome.exe /F
    taskkill /IM firefox.exe /F

}

function clear_cache {

    # gets the username of the person currently logged in, not who is running the script
    # it then removes the domain from the result to be used to navigate to the localappdata
    #$current_user = $(Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username
    #$current_user = $current_user.replace('HQY\','')
    
    # sets to localappdata path to a variable instead of trying to pull the user currently logged in to fill the file path
    # while the get current_user works locally, when run through Tanium it has issues. doing it this way works both ways
    $localappdata = $env:LOCALAPPDATA

    # setting the cache directories as variables
    $edge_cache = $localappdata + '\Microsoft\Edge\User Data\Default'
    $chrome_cache = $localappdata + '\Google\Chrome\User Data\Default'
    $firefox_cache = $localappdata + '\Mozilla\Firefox\Profiles'
    
    if (Test-Path $edge_cache) {

        # deleting multiple folders of cache and cookies in a single directory
        Get-ChildItem $edge_cache -Recurse -Force -Directory -Include 'Cache', 'Code Cache', 'DawnCache', 'GPUCache', 
            'IndexedDB', 'Local Storage', 'Service Worker', 'Storage' | Remove-Item -Recurse -Confirm:$false -Force
        
        # delete both files
        $edge_cookies_1 = $localappdata + '\Microsoft\Edge\User Data\Default\Network\Cookies'
        $edge_cookies_2 = $localappdata + '\Microsoft\Edge\User Data\Default\Network\Cookies-journal'
        
        Remove-Item $edge_cookies_1 -Force
        Remove-Item $edge_cookies_2 -Force

    }

    if (Test-Path $chrome_cache) {

        # deleting multiple folders of cache and cookies in a single directory
        Get-ChildItem $chrome_cache -Recurse -Force -Directory -Include 'Cache', 'Code Cache', 'DawnCache', 'GPUCache', 
            'IndexedDB', 'Local Storage', 'Service Worker', 'Storage' | Remove-Item -Recurse -Confirm:$false -Force

        # delete both files
        $chrome_cookies_1 = $localappdata + '\Google\Chrome\User Data\Default\Network\Cookies'
        $chrome_cookies_2 = $localappdata + '\Google\Chrome\User Data\Default\Network\Cookies-journal'
        
        Remove-Item $chrome_cookies_1 -Force
        Remove-Item $chrome_cookies_2 -Force

    }

    if (Test-Path $firefox_cache) {

        # deleting folders here kills Firefox and requires a complete uninstall then fresh install
        #$firefox_cache_2 = 'C:\Users\'+$current_user+'\AppData\Roaming\Mozilla\Firefox\Profiles'

        # delete all folders here
        Remove-Item $firefox_cache -Recurse -Force

    }

}

function post_notify {

    # creating the details of the dialog box to appear and prompt the user before starting cleaning process
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Browser cleaner'
    $form.FormBorderStyle = 'None'
    $form.Size = New-Object System.Drawing.Size(310,200)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.FormBorderStyle = 'Fixed3D'
    $form.BackColor = 'Lavender'
    $form.ForeColor = 'Black'
    $form.Topmost = $true
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(110,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.Font = New-Object System.Drawing.Font("Neue Haas Grotesk Text Pro",12,[System.Drawing.FontStyle]::Regular)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(5,15)
    $label.Size = New-Object System.Drawing.Size(280,55)
    $label.Text = 'Browser cache cleaning complete.'
    $label.Font = New-Object System.Drawing.Font("Neue Haas Grotesk Text Pro",12,[System.Drawing.FontStyle]::Regular)
    $label.TextAlign = 'MiddleCenter'
    $form.Controls.Add($label)
    
    $result = $form.ShowDialog()

    return $result

}

function main {
    
    $result_pre = prestart

    if ($result_pre -eq [System.Windows.Forms.DialogResult]::OK) {
        kill_browser
        Start-Sleep -Seconds 5
        clear_cache
        $result_post = post_notify

        if ($result_post -eq [System.Windows.Forms.DialogResult]::OK) {
            exit
        }
    }
    else {
        exit
    }

}

main
#kill_browser
#Start-Sleep -Seconds 5
#clear_cache
