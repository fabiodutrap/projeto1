# PowerShell module for The Terminal Oracle game

$Global:TileSize = 32

function Get-TileBrush {
    param([char]$Tile)

    switch ($Tile) {
        '0' { return 'ForestGreen' }       # Grass
        '1' { return 'SaddleBrown' }       # Wall/Building
        '2' { return 'DodgerBlue' }        # Water
        '3' { return 'BurlyWood' }         # Path
        '4' { return 'DarkGreen' }         # Tree
        '5' { return 'Goldenrod' }         # Door
        '6' { return 'Gray' }              # Stone
        '7' { return 'Firebrick' }         # Roof
        default { return 'Magenta' }       # Debug color
    }
}

function Get-GameMap {
    @'
1111111111111111111111111
1000000000440000000000001
1000000000440000000000001
1000000000000000000000001
1000000000003333300000001
1000000000003111300000001
1000000000003151300000001
1000000000003333300000001
1000000000060000000000001
1000000000060000000000001
1000000000060000000000001
1111111000000000011111111
2222222100000000022222222
2222222100000000022222222
2222222100000000022222222
1111111000000000011111111
1000000000000000000000001
1000000000003333300000001
1000000000003111300000001
1000000000003151300000001
1000000000003333300000001
1000000000000000000000001
1000000000000000000000001
1000000000000000000000001
1111111111111171111111111
'@ -split "`n"
}

function New-GameWindow {
    Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, System.Speech

    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="The Terminal Oracle"
        Width="832" Height="832" ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen">
    <Canvas Name="GameCanvas" Background="Black"/>
</Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $canvas = $window.FindName("GameCanvas")
    return @{ Window = $window; Canvas = $canvas }
}

function New-Player {
    @{ X = 12; Y = 12 }
}

function Start-Narration {
    $speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speaker.SpeakAsync("You awaken in a strange and silent village.")
}

function Register-MovementHandler {
    param(
        $Window,
        $Canvas,
        [object]$Map,
        [hashtable]$PlayerPos
    )

    $Window.Add_KeyDown({
        param($sender, $e)

        $move = @{
            'W' = @{ X = 0;  Y = -1 }
            'S' = @{ X = 0;  Y = 1  }
            'A' = @{ X = -1; Y = 0  }
            'D' = @{ X = 1;  Y = 0  }
        }

        if ($move.ContainsKey($e.Key.ToString())) {
            $delta = $move[$e.Key.ToString()]
            $newX = $PlayerPos.X + $delta.X
            $newY = $PlayerPos.Y + $delta.Y

            if ($newY -ge 0 -and $newY -lt $Map.Count -and
                $newX -ge 0 -and $newX -lt $Map[$newY].Length -and
                $Map[$newY][$newX] -ne '1' -and $Map[$newY][$newX] -ne '4') {
                $PlayerPos.X = $newX
                $PlayerPos.Y = $newY
            }

            Draw-TileMap -Canvas $Canvas -Map $Map -PlayerPos $PlayerPos -TileSize $Global:TileSize
        }
    })
}

function Draw-TileMap {
    param(
        $Canvas,
        [object]$Map,
        [hashtable]$PlayerPos,
        [int]$TileSize
    )

    $Canvas.Children.Clear()

    for ($y = 0; $y -lt $Map.Count; $y++) {
        for ($x = 0; $x -lt $Map[$y].Length; $x++) {
            $tile = $Map[$y][$x]
            $brush = Get-TileBrush $tile

            $rect = New-Object Windows.Shapes.Rectangle
            $rect.Width = $TileSize
            $rect.Height = $TileSize
            $rect.Fill = $brush
            $rect.Stroke = [System.Windows.Media.Brushes]::Black
            $rect.StrokeThickness = 1

            [Windows.Controls.Canvas]::SetLeft($rect, $x * $TileSize)
            [Windows.Controls.Canvas]::SetTop($rect, $y * $TileSize)
            $Canvas.Children.Add($rect) | Out-Null
        }
    }

    $player = New-Object Windows.Controls.TextBlock
    $player.Text = "🧙"
    $player.FontSize = 24
    $player.Foreground = 'Red'
    [Windows.Controls.Canvas]::SetLeft($player, $PlayerPos.X * $TileSize + 4)
    [Windows.Controls.Canvas]::SetTop($player, $PlayerPos.Y * $TileSize + 2)
    $Canvas.Children.Add($player) | Out-Null
}

function Start-TerminalOracle {
    $ui        = New-GameWindow
    $window    = $ui.Window
    $canvas    = $ui.Canvas
    $map       = Get-GameMap
    $playerPos = New-Player

    Start-Narration
    Register-MovementHandler -Window $window -Canvas $canvas -Map $map -PlayerPos $playerPos

    Draw-TileMap -Canvas $canvas -Map $map -PlayerPos $playerPos -TileSize $Global:TileSize
    $window.ShowDialog() | Out-Null
}

Export-ModuleMember -Function Start-TerminalOracle
