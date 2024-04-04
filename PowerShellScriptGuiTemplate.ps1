<#
.SYNOPSIS
PowerShell GUI Template for Interactive Scripts.

.DESCRIPTION
A template for creating interactive GUIs with PowerShell. This script is designed to simplify system management and automation tasks.

.EXAMPLE
PS > Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process; .\PowerShellScriptGuiTemplate.ps1

.NOTES
Author: Franck FERMAN
Version: 1.0.0

.LINK
https://github.com/franckferman/PowerShellScriptGuiTemplate
#>


$host.ui.RawUI.WindowTitle = "PowerShell GUI Template - Franck FERMAN"


function Show-Help {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Displays help information for the PowerShell GUI Template.

    .DESCRIPTION
    This function displays detailed help information on how to run and use the PowerShell GUI Template, including example usage and where to find more information.

    .EXAMPLE
    PS > Show-Help

    .LINK
    https://github.com/franckferman/PowerShellScriptGuiTemplate
    #>
    param()

    $helpText = @"
PowerShell GUI Template Help Menu
--------------------------------
To run the PowerShell GUI Template, there are no command-line parameters required. Simply execute the script, and the GUI will launch, allowing you to interact with the system management and automation tasks visually.

Example:
PS > Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process; .\PowerShellScriptGuiTemplate.ps1

This command temporarily sets the execution policy to Unrestricted for the current PowerShell session and runs the PowerShell GUI template script.

For more information and updates, visit:
https://github.com/franckferman/PowerShellScriptGuiTemplate
"@
    Write-Host $helpText
}


function Check-AdminRights {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    <#
    .SYNOPSIS
    Tests if the current user has administrator rights.

    .DESCRIPTION
    This function will determine if the current user is part of the Administrator role. It utilizes the .NET classes for Windows Security and Principal Windows Built-in Roles to make this determination.

    .EXAMPLE
    if (Check-AdminRights) {
        Write-Host "You are running as an administrator."
    } else {
        Write-Host "You are not running as an administrator."
    }
    #>

    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    $principal.IsInRole($adminRole)
}


function Pause-ForUser {
    [CmdletBinding()]
    Param(
        [string]$Message = 'Press enter to continue...'
    )

    <#
    .SYNOPSIS
    Pauses script execution until the user presses Enter.

    .DESCRIPTION
    Displays a message prompting the user to press Enter to continue. A custom message can be provided.

    .PARAMETER Message
    The message to display to the user during the pause.

    .EXAMPLE
    Pause-ForUser

    .EXAMPLE
    Pause-ForUser -Message 'Press Enter after completing the instructions.'
    #>

    Read-Host $Message
}


function Set-LocationPaths {
    [CmdletBinding()]
    param (
        [string]$BasePath = (Get-Location).Path,
        [string]$ImagesPath = "assets\img"
    )

    $global:WorkingPath = $BasePath
    $global:ImagesPath = Join-Path -Path $global:WorkingPath -ChildPath $ImagesPath
    
    if (-not (Test-Path -Path $global:ImagesPath)) {
        Write-Warning "Images path not found: $global:ImagesPath"
    }
}


function Create-Form {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$FormTitle,

        [ValidateNotNull()]
        [System.Drawing.Size]$FormSize,

        [string]$IconPath,

        [string]$BackgroundImagePath,

        [System.Drawing.Size]$MaximumSize,

        [System.Drawing.Size]$MinimumSize,

        [ValidateSet("CenterScreen", "Manual", "CenterParent", "WindowShowDialefaultLocation", "WindowShowDialefaultBounds")]
        [string]$StartPosition = "CenterScreen",

        [bool]$Topmost = $True
    )

    <#
    .SYNOPSIS
    Creates and returns a Windows Form with the specified properties.

    .DESCRIPTION
    This function creates a Windows Form with custom properties such as title, size, icons, and background image.

    .PARAMETER FormTitle
    The title of the form.

    .PARAMETER FormSize
    The size of the form.

    .PARAMETER IconPath
    Path to the form's icon file.

    .PARAMETER BackgroundImagePath
    Path to the form's background image.

    .PARAMETER MaximumSize
    Maximum size of the form.

    .PARAMETER MinimumSize
    Minimum size of the form.

    .PARAMETER StartPosition
    Starting position of the form.

    .PARAMETER Topmost
    Whether the form should be topmost.

    .EXAMPLE
    $form = Create-Form -FormTitle "My Form" -FormSize (New-Object System.Drawing.Size(400,300)) -Topmost $True
    $form.ShowDialog()
    #>

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $FormTitle
    $form.Size = $FormSize
    $form.MaximumSize = $MaximumSize
    $form.MinimumSize = $MinimumSize
    $form.StartPosition = $StartPosition
    $form.Topmost = $Topmost

    if ($IconPath) {
        $form.Icon = New-Object System.Drawing.Icon ($IconPath)
    }

    if ($BackgroundImagePath) {
        $form.BackgroundImage = [System.Drawing.Image]::FromFile($BackgroundImagePath)
        $form.BackgroundImageLayout = "Center"
    }

    return $form
}


function Create-Button {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Form]$ParentForm,

        [Parameter(Mandatory = $true)]
        [System.Drawing.Size]$Location,

        [Parameter(Mandatory = $true)]
        [System.Drawing.Size]$Size,

        [Parameter(Mandatory = $false)]
        [string]$Text = "",

        [Parameter(Mandatory = $false)]
        [string]$BackgroundImagePath
    )

    <#
    .SYNOPSIS
    Creates a button on a Windows Form.

    .DESCRIPTION
    This function creates a new button with specified properties and adds it to the provided form. Optionally, a background image can be set for the button.

    .PARAMETER ParentForm
    The form on which the button will be placed.

    .PARAMETER Location
    The location of the button on the form.

    .PARAMETER Size
    The size of the button.

    .PARAMETER Text
    The text displayed on the button. If not specified, the button will not display text.

    .PARAMETER BackgroundImagePath
    Path to an image file that will be used as the button's background. This parameter is optional.

    .EXAMPLE
    $form = New-Object System.Windows.Forms.Form
    Create-Button -ParentForm $form -Location New-Object System.Drawing.Size(10,10) -Size New-Object System.Drawing.Size(100,50) -Text "Click Me" -OnClickAction { Write-Host "Button clicked" }
    #>

    $button = New-Object System.Windows.Forms.Button
    $button.Location = $Location
    $button.Size = $Size
    $button.Text = $Text

    if ($BackgroundImagePath -and (Test-Path -Path $BackgroundImagePath)) {
        $button.BackgroundImage = [System.Drawing.Image]::FromFile($BackgroundImagePath)
        $button.BackgroundImageLayout = "Center"
    } elseif ($BackgroundImagePath) {
        Write-Warning "Background image path does not exist: $BackgroundImagePath"
    }

    $button.Add_Click($OnClickAction)
    $ParentForm.Controls.Add($button)

    return $button
}


function Get-MainForm {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Creates and displays the main GUI form for the PowerShell Script GUI Template.

    .DESCRIPTION
    This function initializes the main GUI form using predefined settings and controls, including buttons for various actions like renaming a computer, showing examples, and providing redirection to a website.

    .EXAMPLE
    Get-MainForm
    This example executes the function to create and display the main GUI form.
    #>
    param()

    $MainForm = Create-Form -FormTitle "PowerShell Script GUI Template" `
        -FormSize (New-Object System.Drawing.Size(400, 600)) `
        -MaximumSize (New-Object System.Drawing.Size(400, 600)) `
        -MinimumSize (New-Object System.Drawing.Size(400, 600)) `
        -StartPosition "CenterScreen" `
        -Topmost $True `
        -IconPath "$global:ImagesPath\icon.ico" `
        -BackgroundImagePath "$global:ImagesPath\bg.jpg"

    $banner = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(80, 20)) `
        -Size (New-Object System.Drawing.Size(250, 50)) `
        -Text "" `
        -BackgroundImagePath "$global:ImagesPath/banner.png"

    $banner.Add_Click({ [console]::beep(500, 100) })
    $banner.BackColor = [System.Drawing.Color]::FromName("Transparent")

    $RenameComputerBtn = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(100, 100)) `
        -Size (New-Object System.Drawing.Size(200, 50)) `
        -Text "Renaming the computer"

    $MainForm.Controls.Add($RenameComputerBtn)
    $RenameComputerBtn.BackColor = [System.Drawing.Color]::FromName("Gray")
    $RenameComputerBtn.Add_Click({ [console]::beep(300, 100); Rename-Computer })


    function Rename-Computer {
        Write-Host "Ongoing action: Launching Rename-Computer." -ForegroundColor Green

        $RenameComputer_Form = Create-Form -FormTitle "Rename Computer - PowerShell Script GUI Template" `
            -FormSize (New-Object System.Drawing.Size(335, 200)) `
            -MaximumSize (New-Object System.Drawing.Size(335, 200)) `
            -MinimumSize (New-Object System.Drawing.Size(335, 200)) `
            -StartPosition "CenterScreen" `
            -Topmost $True `
            -IconPath "$global:ImagesPath\icon.ico" `
            -BackgroundImagePath "$global:ImagesPath\rc.jpg"

        $AcceptBtn = Create-Button -ParentForm $MainForm `
            -Location (New-Object System.Drawing.Size(85, 100)) `
            -Size (New-Object System.Drawing.Size(75, 25)) `
            -Text "Accept" `

        $AcceptBtn.BackColor = [System.Drawing.Color]::FromName("Gray")

        $RenameComputer_Form.AcceptButton = $AcceptBtn
        $RenameComputer_Form.Controls.Add($AcceptBtn)

        $AcceptBtn.Add_Click({
                $inputText = $MainTextBox.Text
                if ([string]::IsNullOrWhiteSpace($inputText)) {
                    [System.Windows.Forms.MessageBox]::Show("Please enter a valid computer number.", "Input Validation Failed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
                else {
                    $RenameComputer_Form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $RenameComputer_Form.Close()
                }
            })

        $CancelBtn = Create-Button -ParentForm $MainForm `
            -Location (New-Object System.Drawing.Size(170, 100)) `
            -Size (New-Object System.Drawing.Size(75, 25)) `
            -Text "Cancel" `

        $CancelBtn.BackColor = [System.Drawing.Color]::FromName("Gray")

        $CancelBtn.Add_Click({
                $RenameComputer_Form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                $RenameComputer_Form.Close()
            })

        $RenameComputer_Form.CancelButton = $CancelBtn
        $RenameComputer_Form.Controls.Add($CancelBtn)

        $MainLabel = New-Object System.Windows.Forms.Label
        $MainLabel.ForeColor = [System.Drawing.Color]::FromName("Gray")
        $MainLabel.BackColor = [System.Drawing.Color]::FromName("Transparent")
        $MainLabel.Location = New-Object System.Drawing.Point(65, 30)
        $MainLabel.Size = New-Object System.Drawing.Size(186, 20)
        $MainLabel.Text = 'Computer number (example: 15242)'
        $RenameComputer_Form.Controls.Add($MainLabel)

        $MainTextBox = New-Object System.Windows.Forms.TextBox
        $MainTextBox.Location = New-Object System.Drawing.Point(110, 60)
        $MainTextBox.Size = New-Object System.Drawing.Size(100, 20)
        $RenameComputer_Form.Controls.Add($MainTextBox)
        $RenameComputer_Form.Topmost = $true
        $RenameComputer_Form.Add_Shown({ $MainTextBox.Select() })
        $RenameComputer_Form.Icon = $MainIcon

        $rcImage = [System.Drawing.Image]::FromFile("$ImagesPath\rc.jpg")
        $RenameComputer_Form.BackgroundImage = $rcImage
        $RenameComputer_Form.BackgroundImageLayout = "Center"

        $ShowDial = $RenameComputer_Form.ShowDialog()
        if ($ShowDial -eq [System.Windows.Forms.DialogResult]::OK) {
            $Computer_Name = $MainTextBox.Text
            Write-Host "Info: The name chosen is $Computer_Name." -ForegroundColor Green
        }
    }


    $Example_1_Button = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(100, 180)) `
        -Size (New-Object System.Drawing.Size(200, 50)) `
        -Text "Example 1" `

    $Example_1_Button.BackColor = [System.Drawing.Color]::FromName("Gray")

    $MainForm.Controls.Add($Example_1_Button)
 
    $Example_1_Button.Add_Click({ [console]::beep(300, 100); Write-Host "Info: This is an example." -ForegroundColor Green })


    $Example_2_Button = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(100, 260)) `
        -Size (New-Object System.Drawing.Size(200, 50)) `
        -Text "Example 2" `

    $Example_2_Button.BackColor = [System.Drawing.Color]::FromName("Gray")

    $MainForm.Controls.Add($Example_2_Button)
 
    $Example_2_Button.Add_Click({ [console]::beep(300, 100); Write-Host "Info: This is another example." -ForegroundColor Green })


    $Example_3_Button = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(100, 340)) `
        -Size (New-Object System.Drawing.Size(200, 50)) `
        -Text "Example 3" `

    $Example_3_Button.BackColor = [System.Drawing.Color]::FromName("Gray")

    $MainForm.Controls.Add($Example_3_Button)
 
    $Example_3_Button.Add_Click({ [console]::beep(300, 100); Write-Host "This is yet another example." -ForegroundColor Green })


    $Website_Redirect_Button = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(100, 420)) `
        -Size (New-Object System.Drawing.Size(200, 50)) `
        -Text "Redirect to a website" `

    $Website_Redirect_Button.BackColor = [System.Drawing.Color]::FromName("Gray")

    $MainForm.Controls.Add($Website_Redirect_Button)
 
    $Website_Redirect_Button.Add_Click({ [console]::beep(300, 100); Write-Host "Action: Redirection to my website." -ForegroundColor Green; Start-Process -WindowStyle Maximized "https://franckferman.fr" })


    $AboutBtn = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(100, 500)) `
        -Size (New-Object System.Drawing.Size(50, 50)) `
        -Text "" `

    $AboutBtn.Add_Click({
            Start-Process -File '.\assets\audio\fsociety.mp3' -WindowStyle Minimized
            Write-Host "Info: Script created by Franck FERMAN (contact@franckferman.fr)." -ForegroundColor Green
            [System.Windows.Forms.MessageBox]::Show("Script created by Franck FERMAN (contact@franckferman.fr)", "PowerShell Script GUI Template", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
        })

    $MainForm.Controls.Add($AboutBtn)
    $AboutBtn.BackColor = [System.Drawing.Color]::FromName("Transarent")

    $aboutImage = [System.Drawing.Image]::FromFile("$ImagesPath/about.png")
    $AboutBtn.BackgroundImage = $aboutImage
    $AboutBtn.BackgroundImageLayout = "Stretch"


    $QuitBtn = Create-Button -ParentForm $MainForm `
        -Location (New-Object System.Drawing.Size(250, 500)) `
        -Size (New-Object System.Drawing.Size(50, 50)) `
        -Text "" `

    $QuitBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $MainForm.Controls.Add($QuitBtn)
    $QuitBtn.BackColor = [System.Drawing.Color]::FromName("Transarent")

    $QuitImg = [System.Drawing.Image]::FromFile("$ImagesPath/quit.png")
    $QuitBtn.BackgroundImage = $QuitImg
    $QuitBtn.BackgroundImageLayout = "Stretch"

    $MainForm.ShowDialog() | Out-Null
}


function main {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Entry point for the PowerShell GUI application.

    .DESCRIPTION
    This function serves as the main entry point for the PowerShell GUI application. It checks for administrator rights before launching the main GUI form. If the current user does not have administrator rights, the script will exit and provide a relevant error message.

    .EXAMPLE
    main
    Executes the main function to start the GUI application. This command should be run in a PowerShell session with administrator rights.
    #>
    param()

    if (-not (Check-AdminRights)) {
        Write-Error "This script requires administrator rights."
        return
    }

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    Set-LocationPaths

    Get-MainForm
}


if ($Help) {
    Show-Help
} else {
    main
}
