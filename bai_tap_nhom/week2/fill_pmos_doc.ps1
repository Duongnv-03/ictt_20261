$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$culture = [Globalization.CultureInfo]::InvariantCulture
$week2 = $PSScriptRoot
$sourceDoc = Join-Path $week2 '20261 - Practice 1 - Introduction to LTspice.docx'
$outputDoc = Join-Path $week2 '20261 - Practice 1 - Introduction to LTspice_PMOS_filled.docx'

function Read-OperatingPointLog {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Dimensions
    )

    $lines = Get-Content -LiteralPath $Path
    if ($lines -match 'syntax error|File not found') {
        throw "LTspice log error: $Path"
    }

    $values = @{}
    $names = @()
    foreach ($line in $lines) {
        if ($line -match '^Name:\s+(.*)$') {
            $names = $Matches[1].Trim() -split '\s+'
            continue
        }

        if ($line -match '^(Id|Vth|Gm):\s+(.*)$') {
            $field = $Matches[1]
            $tokens = $Matches[2].Trim() -split '\s+'
            for ($i = 0; $i -lt [Math]::Min($names.Count, $tokens.Count); $i++) {
                if (-not $values.ContainsKey($names[$i])) {
                    $values[$names[$i]] = [ordered]@{}
                }
                $values[$names[$i]][$field] = [double]::Parse($tokens[$i], $culture)
            }
        }
    }

    $rows = @()
    for ($i = 0; $i -lt $Dimensions.Count; $i++) {
        $name = 'M' + ($i + 1)
        if (-not $values.ContainsKey($name)) {
            throw "Missing data for $name in $Path"
        }
        $item = $values[$name]
        $length = [double]$Dimensions[$i].L
        $width = [double]$Dimensions[$i].W
        $overdrive = 5 - [Math]::Abs($item.Vth)
        if ($overdrive -le 0) {
            throw "Invalid VGS overdrive for $name in $Path"
        }
        $uCox = [Math]::Abs($item.Gm) * $length / ($width * $overdrive)
        $rows += [pscustomobject]@{
            Id = $item.Id
            Vth = $item.Vth
            Gm = $item.Gm
            UCox = $uCox
        }
    }
    return $rows
}

function Format-Scientific([double]$value) {
    return $value.ToString('0.000E+00', $culture)
}

function Format-Voltage([double]$value) {
    return $value.ToString('0.000', $culture)
}

function Set-CellText([System.Xml.XmlDocument]$Document, [System.Xml.XmlNamespaceManager]$Namespace, [System.Xml.XmlNode]$Cell, [string]$Text) {
    $wordUri = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    $paragraph = $Cell.SelectSingleNode('./w:p', $Namespace)
    if ($null -eq $paragraph) {
        throw 'Table cell paragraph was not found.'
    }

    foreach ($child in @($paragraph.SelectNodes('./w:r|./w:hyperlink|./w:fldSimple', $Namespace))) {
        [void]$paragraph.RemoveChild($child)
    }

    $run = $Document.CreateElement('w', 'r', $wordUri)
    $paragraphStyle = $paragraph.SelectSingleNode('./w:pPr/w:rPr', $Namespace)
    if ($null -ne $paragraphStyle) {
        [void]$run.AppendChild($paragraphStyle.CloneNode($true))
    }

    $textNode = $Document.CreateElement('w', 't', $wordUri)
    $textNode.InnerText = $Text
    [void]$run.AppendChild($textNode)
    [void]$paragraph.AppendChild($run)
}

$lengths = @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 100)
$lengthSweepDimensions = @($lengths | ForEach-Object { [pscustomobject]@{ L = [double]$_; W = 1.0 } })
$widthSweepDimensions = @($lengths | ForEach-Object { [pscustomobject]@{ L = 5.0; W = [double]$_ } })

$lengthSweep = Read-OperatingPointLog -Path (Join-Path $week2 'PMOS_L.log') -Dimensions $lengthSweepDimensions
$widthSweep = Read-OperatingPointLog -Path (Join-Path $week2 'PMOS_W.log') -Dimensions $widthSweepDimensions

if (Test-Path -LiteralPath $outputDoc) {
    Write-Output "Replacing the incomplete output copy: $outputDoc"
}
Copy-Item -LiteralPath $sourceDoc -Destination $outputDoc -Force

$zip = [IO.Compression.ZipFile]::Open($outputDoc, [IO.Compression.ZipArchiveMode]::Update)
try {
    $entry = $zip.GetEntry('word/document.xml')
    if ($null -eq $entry) {
        throw 'word/document.xml was not found in the Word file.'
    }

    $reader = [IO.StreamReader]::new($entry.Open(), [Text.Encoding]::UTF8, $true)
    try {
        $documentText = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }

    [xml]$document = $documentText
    $namespace = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $namespace.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    $tables = $document.SelectNodes('//w:tbl', $namespace)
    if ($tables.Count -lt 4) {
        throw "The Word file has $($tables.Count) tables; at least 4 are required."
    }

    $tableData = @{
        1 = $lengthSweep
        3 = $widthSweep
    }
    foreach ($tableIndex in @(1, 3)) {
        $table = $tables[$tableIndex]
        $rows = $table.SelectNodes('./w:tr', $namespace)
        $dataRows = $tableData[$tableIndex]
        if ($rows.Count -ne 23) {
            throw "Table $($tableIndex + 1) has $($rows.Count) rows; 23 are required."
        }
        for ($rowIndex = 0; $rowIndex -lt $dataRows.Count; $rowIndex++) {
            $cells = $rows[$rowIndex + 1].SelectNodes('./w:tc', $namespace)
            Set-CellText $document $namespace $cells[1] (Format-Scientific $dataRows[$rowIndex].Id)
            Set-CellText $document $namespace $cells[2] (Format-Voltage $dataRows[$rowIndex].Vth)
            Set-CellText $document $namespace $cells[3] (Format-Scientific $dataRows[$rowIndex].Gm)
            Set-CellText $document $namespace $cells[4] (Format-Scientific $dataRows[$rowIndex].UCox)
        }
    }

    $entry.Delete()
    $newEntry = $zip.CreateEntry('word/document.xml', [IO.Compression.CompressionLevel]::Optimal)
    $writer = [IO.StreamWriter]::new($newEntry.Open(), [Text.UTF8Encoding]::new($false))
    try {
        $document.Save($writer)
    }
    finally {
        $writer.Dispose()
    }
}
finally {
    $zip.Dispose()
}

Write-Output "Created: $outputDoc"
Write-Output "PMOS_L rows filled: $($lengthSweep.Count)"
Write-Output "PMOS_W rows filled: $($widthSweep.Count)"
