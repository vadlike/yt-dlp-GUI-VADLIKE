Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === PATHS ===
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ytDlpPath = Join-Path $scriptDir "yt-dlp.exe"
$cookiePath = Join-Path $scriptDir "cookie.txt"

if (-not (Test-Path $ytDlpPath)) {
    [System.Windows.Forms.MessageBox]::Show("yt-dlp.exe not found in the script directory!", "Error", "OK", "Error")
    exit
}

# === GUI ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "YT-DLP GUI VADLIKE - Download Video/Playlist"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"

# === URL ===
$urlLabel = New-Object System.Windows.Forms.Label
$urlLabel.Text = "Link:"
$urlLabel.Location = New-Object System.Drawing.Point(10, 20)
$urlLabel.Size = New-Object System.Drawing.Size(130, 20)
$form.Controls.Add($urlLabel)

$urlBox = New-Object System.Windows.Forms.TextBox
$urlBox.Location = New-Object System.Drawing.Point(150, 20)
$urlBox.Size = New-Object System.Drawing.Size(420, 20)
$form.Controls.Add($urlBox)

# === QUALITY ===
$qualityLabel = New-Object System.Windows.Forms.Label
$qualityLabel.Text = "Quality:"
$qualityLabel.Location = New-Object System.Drawing.Point(10, 60)
$qualityLabel.Size = New-Object System.Drawing.Size(130, 20)
$form.Controls.Add($qualityLabel)

$qualityBox = New-Object System.Windows.Forms.ComboBox
$qualityBox.Location = New-Object System.Drawing.Point(150, 60)
$qualityBox.Size = New-Object System.Drawing.Size(300, 20)
$qualityBox.DropDownStyle = 'DropDownList'
$qualityBox.Items.AddRange(@(
    "best",
    "bestvideo+bestaudio",
    "2160p (4K)",
    "1440p (QHD)",
    "1080p",
    "720p",
    "480p",
    "360p",
    "240p",
    "144p",
    "audio-only (best)",
    "audio-only (192k)",
    "audio-only (128k)"
))
$qualityBox.SelectedIndex = 0
$form.Controls.Add($qualityBox)

# === FOLDER ===
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Text = "Download Folder:"
$pathLabel.Location = New-Object System.Drawing.Point(10, 100)
$pathLabel.Size = New-Object System.Drawing.Size(130, 20)
$form.Controls.Add($pathLabel)

$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.Location = New-Object System.Drawing.Point(150, 100)
$pathBox.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($pathBox)

$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "Browse..."
$browseBtn.Location = New-Object System.Drawing.Point(520, 98)
$browseBtn.Size = New-Object System.Drawing.Size(50, 24)
$browseBtn.Add_Click({
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderDialog.ShowDialog() -eq "OK") {
        $pathBox.Text = $folderDialog.SelectedPath
    }
})
$form.Controls.Add($browseBtn)

# === COOKIES ===
$cookieCheckBox = New-Object System.Windows.Forms.CheckBox
$cookieCheckBox.Text = "Use cookie.txt"
$cookieCheckBox.Checked = $true
$cookieCheckBox.Location = New-Object System.Drawing.Point(150, 140)
$form.Controls.Add($cookieCheckBox)

# === DOWNLOAD BUTTON ===
$downloadBtn = New-Object System.Windows.Forms.Button
$downloadBtn.Text = "Download"
$downloadBtn.Location = New-Object System.Drawing.Point(240, 190)
$downloadBtn.Size = New-Object System.Drawing.Size(100, 35)
$downloadBtn.Add_Click({
    $url = $urlBox.Text.Trim()
    $quality = $qualityBox.SelectedItem
    $outPath = $pathBox.Text.Trim()
    $useCookies = $cookieCheckBox.Checked

    if ([string]::IsNullOrWhiteSpace($url) -or -not (Test-Path $outPath)) {
        [System.Windows.Forms.MessageBox]::Show("Enter a valid link and select a folder.", "Error", "OK", "Error")
        return
    }

    if ($useCookies -and -not (Test-Path $cookiePath)) {
        [System.Windows.Forms.MessageBox]::Show("cookie.txt file not found!", "Error", "OK", "Error")
        return
    }

    switch ($quality) {
        "best"                     { $format = "best" }
        "bestvideo+bestaudio"     { $format = "bestvideo+bestaudio" }
        "2160p (4K)"              { $format = "bv[height=2160]+ba/b[height=2160]" }
        "1440p (QHD)"             { $format = "bv[height=1440]+ba/b[height=1440]" }
        "1080p"                   { $format = "bv[height=1080]+ba/b[height=1080]" }
        "720p"                    { $format = "bv[height=720]+ba/b[height=720]" }
        "480p"                    { $format = "bv[height=480]+ba/b[height=480]" }
        "360p"                    { $format = "bv[height=360]+ba/b[height=360]" }
        "240p"                    { $format = "bv[height=240]+ba/b[height=240]" }
        "144p"                    { $format = "bv[height=144]+ba/b[height=144]" }
        "audio-only (best)"       { $format = "bestaudio" }
        "audio-only (192k)"       { $format = "bestaudio[abr=192]" }
        "audio-only (128k)"       { $format = "bestaudio[abr=128]" }
        default                   { $format = "best" }
    }

    $arguments = @()
    if ($useCookies) {
        $arguments += "--cookies", $cookiePath
    }

    $arguments += "-f", $format
    $arguments += "--merge-output-format", "mp4"
    $arguments += "-P", $outPath
    $arguments += $url

    Start-Process -FilePath $ytDlpPath -ArgumentList $arguments -NoNewWindow
    [System.Windows.Forms.MessageBox]::Show("Download started.", "Success", "OK", "Information")
})
$form.Controls.Add($downloadBtn)

# === ABOUT BUTTON ===
$aboutBtn = New-Object System.Windows.Forms.Button
$aboutBtn.Text = "About"
$aboutBtn.Location = New-Object System.Drawing.Point(490, 330)
$aboutBtn.Size = New-Object System.Drawing.Size(80, 25)
$aboutBtn.Add_Click({
    Start-Process "https://github.com/vadlike/yt-dlp-GUI-VADLIKE" 
})
$form.Controls.Add($aboutBtn)

# === START ===
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()