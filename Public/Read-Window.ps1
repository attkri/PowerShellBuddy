function Read-Window {
    [CmdletBinding(SupportsShouldProcess=$false)]
    <#
        .Synopsis
            Opens a simple input dialog.

        .EXAMPLE
            Read-Window -Title "Find old files" -Message "Older than which date?" -Default "2010-01-01"
    #>
    [OutputType([PSCustomObject])]
    Param
    (
        # Dialog title.
        [Parameter(Position=0)]
        [string]$Title = 'Title',

        # Prompt text displayed in the dialog.
        [Parameter(Position=1)]
        [string]$Message = 'Prompt',

        # Default value shown in the input box.
        [Parameter(Position=2)]
        [string]$Default = [string]::Empty
    )

    Begin
    {
        if (-not $IsWindows) {
            throw 'Read-Window is currently supported on Windows only.'
        }

        Add-Type -AssemblyName PresentationFramework
        Add-Type -AssemblyName System
        $script:UserResult = [string]::Empty
    }

    Process
    {
        [xml]$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    FocusManager.FocusedElement="{Binding ElementName=InputTextBox}"
    Height="160"
    Width="400">
<Grid Margin="15">
	<Grid.RowDefinitions>
		<RowDefinition Height="AUTO" />
		<RowDefinition Height="AUTO" />
		<RowDefinition Height="AUTO" />
	</Grid.RowDefinitions>
	<TextBlock x:Name="MessageTextBlock" Grid.Row="0" Margin="0 0 0 15" />
	<TextBox x:Name="InputTextBox" Grid.Row="1" Margin="0 0 0 15" />
	<Button x:Name="OKButton" Grid.Row="2" Content="OK" HorizontalAlignment="Right" Width="80" Margin="0 0 90 0" IsDefault="True" />
	<Button x:Name="CancelButton" Grid.Row="2" Content="CANCEL" HorizontalAlignment="Right" Width="80" IsCancel="True"  />
</Grid>
</Window>
"@
        $Reader = New-Object System.Xml.XmlNodeReader $Xaml
        $Windows = [System.Windows.Markup.XamlReader]::Load($Reader)
        $Windows.Title = $Title

        $MessageTextBlock = $Windows.FindName("MessageTextBlock")
        $MessageTextBlock.Text = $Message

        $InputTextBox = $Windows.FindName("InputTextBox")
        $InputTextBox.Text = $Default

        $OkButton = $Windows.FindName("OKButton")
        $OkButton.Add_Click({
            $script:UserResult = $InputTextBox.Text
            $Windows.DialogResult =$true})
    }

    End
    {
        $DialogResult = $Windows.ShowDialog()
        New-Object PSCustomObject -Property ([ordered]@{
            DialogResult = $DialogResult;
            UserResult = $script:UserResult})
    }
}
