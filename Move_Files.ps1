<#
        .SYNOPSIS
        Moves the *_sig.txt files to a destination folder depending on the folder id
        Developer - K.Janarthanan

        .DESCRIPTION
        Moves the *_sig.jpg files to a destination folder depending on the folder id
        Date - 28/08/2021

        .PARAMETER Name
        Folder_Location - Path to the root destination folder where subfolder with IDs located
        Files_Location - Path to the files folder location

        .OUTPUTS
        Log file with name Files_Move.log in the same directory of the script

        .EXAMPLE
        PS> \Move_Files.ps1 -Folders_Location E:\Destination_Folder -Files_Location E:\Source_Files

#>

[CmdletBinding()]
param (
    [String]$Folders_Location="E:\Destination_Folder",
    [String]$Files_Location="E:\Source_Files"
)

$Global:LogFile = "$PSScriptRoot\Files_Move.log" #Log file location
function Write-Log #Function for logging
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Validateset("INFO","ERR","WARN")]
        [string]$Type="INFO"
    )

    $DateTime = Get-Date -Format "MM-dd-yyyy HH:mm:ss"
    $FinalMessage = "[{0}]::[{1}]::[{2}]" -f $DateTime,$Type,$Message

    #Storing the output in the log file
    $FinalMessage | Out-File -FilePath $LogFile -Append

    if($Type -eq "ERR")
    {
        Write-Host "$FinalMessage" -ForegroundColor Red
    }
    else 
    {
        Write-Host "$FinalMessage" -ForegroundColor Green
    }
}

try 
{
    Write-Log "Script Started"

    #Check the path and throw error if not existing
    if(-Not (Test-Path $Folders_Location))
    {
        throw "Unable to find the folder $Folders_Location"
    }

    #Check the path and throw error if not existing
    if(-Not (Test-Path $Files_Location))
    {
        throw "Unable to find the folder $Files_Location"
    }

    #Get all files from the source folder
    $All_Files = Get-ChildItem -Path $Files_Location -Filter "*_sig.txt" -Recurse -Force -EA Stop

    Write-Log "Total count of source file is $($All_Files.Count)"

    #Loop all files
    foreach($File in $All_Files)
    {

        Write-Log "Working on File $($File.Name)"

        try
        {
            #Split the file name and get the numeric part of the name
            [int] $File_ID = ($File.Name).Split("_sig.txt")[0]

            #Divide the number by 5000 and approximate it to upper ceiling limit and multiply back by 5000
            $Folder_To_Move = [math]::Ceiling($File_ID/5000)*5000

            #Append the folder id to get the full destination path
            $Final_Folder = "$Folders_Location\$Folder_To_Move"

            Write-Log "Folder to be moved - $Final_Folder"

            #Check the path and throw error if not existing
            if(-Not (Test-Path $Final_Folder))
            {
                throw "Folder $Final_Folder is not found. Therefore unable to move the file"
            }

            #Move the file to destination folder
            Move-Item -Path $File.FullName -Destination $Final_Folder -Force -EA Stop
            Write-Log "Successfully moved the file to destination folder"
        }
        catch
        {
            Write-Log "Failed processing File $($File.Name) with error $_" -Type ERR
        }       
    }

    Write-Log "Script Ended"
}
catch 
{
    Write-Log "$_" -Type ERR    
}