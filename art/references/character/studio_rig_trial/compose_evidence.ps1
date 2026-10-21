Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
$root = $PSScriptRoot
$bg = [System.Drawing.Color]::FromArgb(12,17,23)
$white = [System.Drawing.Brushes]::WhiteSmoke
$muted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(174,191,204))
$title = [System.Drawing.Font]::new('Segoe UI',24,[System.Drawing.FontStyle]::Bold)
$label = [System.Drawing.Font]::new('Segoe UI',17,[System.Drawing.FontStyle]::Bold)
$small = [System.Drawing.Font]::new('Segoe UI',14)
function Board($width,$height) {
    $bmp = [System.Drawing.Bitmap]::new($width,$height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear($bg)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @{bmp=$bmp;g=$g}
}
function Panel($b,$name,$x,$y,$w,$h) {
    $img = [System.Drawing.Image]::FromFile((Join-Path $root $name))
    $b.g.DrawImage($img,[System.Drawing.Rectangle]::new($x,$y,$w,$h))
    $img.Dispose()
}
function Save($b,$name) {
    $b.bmp.Save((Join-Path $root $name),[System.Drawing.Imaging.ImageFormat]::Png)
    $b.g.Dispose(); $b.bmp.Dispose()
}
$b = Board 1440 770
$b.g.DrawString('Prueba de rig · Blender Studio en Godot',$title,$white,28,17)
$b.g.DrawString('Malla original a 1,80 m · rig propio · material neutro · aceptación visual pendiente',$small,$muted,30,64)
foreach ($item in @(@('Reposo relajado','rest_front.png'),@('Hombro y codo','shoulder_three_quarter.png'),@('Marcha de diagnóstico','walk_04.png'))) {
    $i = [array]::IndexOf(@('Reposo relajado','Hombro y codo','Marcha de diagnóstico'),$item[0])
    $b.g.DrawString($item[0],$label,$white,[single]($i*480+24),[single]110)
    Panel $b $item[1] ($i*480) 155 480 550
}
$b.g.DrawString('La cobertura pélvica es una máscara de estudio. El ciclo no es la animación final de juego.',$small,$muted,30,730)
Save $b 'rig_overview.png'
$b = Board 1440 795
$b.g.DrawString('Mano abierta y sujeción · revisión cercana',$title,$white,28,17)
$b.g.DrawString('El cuerpo conserva sus manos originales. Las poses se aplican con huesos; no hay escultura fija para el mango.',$small,$muted,30,64)
$labels = @('Mano relajada','Agarre · palma','Agarre · dorso')
$files = @('rest_hand_oblique.png','grip_hand_palm.png','grip_hand_dorsal.png')
for ($i=0;$i -lt 3;$i++) {
    $b.g.DrawString($labels[$i],$label,$white,[single]($i*480+24),[single]110)
    Panel $b $files[$i] ($i*480) 155 480 550
}
$b.g.DrawString('El pulgar, los pliegues de flexión y la transición al agarre requieren más trabajo de rig/pesos.',$small,$muted,30,730)
$b.g.DrawString('La ausencia de cruces con el mango no acredita por sí sola una mano natural ni lista para producción.',$small,$muted,30,760)
Save $b 'hand_review.png'

# WPF writes a real timed GIF; no external media utility is required.
$encoder = [System.Windows.Media.Imaging.GifBitmapEncoder]::new()
for ($i=0;$i -lt 16;$i++) {
    $path = Join-Path $root ('walk_{0:d2}.png' -f $i)
    $source = [System.Windows.Media.Imaging.BitmapImage]::new()
    $source.BeginInit()
    $source.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $source.UriSource = [Uri]::new($path)
    $source.DecodePixelWidth = 480
    $source.EndInit()
    $metadata = [System.Windows.Media.Imaging.BitmapMetadata]::new('gif')
    $metadata.SetQuery('/grctlext/Delay',[UInt16]12)
    $metadata.SetQuery('/grctlext/Disposal',[byte]2)
    if ($i -eq 0) {
        $metadata.SetQuery('/appext/application',[System.Text.Encoding]::ASCII.GetBytes('NETSCAPE2.0'))
        $metadata.SetQuery('/appext/data',[byte[]]@(3,1,0,0,0))
    }
    $frame = [System.Windows.Media.Imaging.BitmapFrame]::Create($source,$null,$metadata,$null)
    $encoder.Frames.Add($frame)
}
$stream = [System.IO.File]::Create((Join-Path $root 'walk.gif'))
try { $encoder.Save($stream) } finally { $stream.Dispose() }
# WPF can discard per-frame timing when encoding from PNG BitmapImages.
# Preserve the encoded image/palette blocks and write explicit GIF89a timing.
$gifPath = Join-Path $root 'walk.gif'
$bytes = [System.IO.File]::ReadAllBytes($gifPath)
$out = [System.IO.MemoryStream]::new()
$offset = 13
if ($bytes[10] -band 128) { $offset += 3 * [Math]::Pow(2,($bytes[10] -band 7)+1) }
$out.Write($bytes,0,$offset)
$loop = [byte[]]@(33,255,11) + [Text.Encoding]::ASCII.GetBytes('NETSCAPE2.0') + [byte[]]@(3,1,0,0,0)
$out.Write($loop,0,$loop.Length)
$frames = 0
while ($offset -lt $bytes.Length) {
    $start = $offset
    $tag = $bytes[$offset]
    if ($tag -eq 59) { $out.WriteByte(59); break }
    if ($tag -eq 33) {
        $labelCode = $bytes[$offset+1]
        $offset += 2
        do { $size = $bytes[$offset]; $offset += 1+$size } while ($size -gt 0)
        if ($labelCode -ne 249 -and $labelCode -ne 255) { $out.Write($bytes,$start,$offset-$start) }
    } elseif ($tag -eq 44) {
        $packed = $bytes[$offset+9]
        $offset += 10
        if ($packed -band 128) { $offset += 3 * [Math]::Pow(2,($packed -band 7)+1) }
        $offset++ # LZW minimum code size.
        do { $size = $bytes[$offset]; $offset += 1+$size } while ($size -gt 0)
        $timing = [byte[]]@(33,249,4,8,12,0,0,0)
        $out.Write($timing,0,$timing.Length)
        $out.Write($bytes,$start,$offset-$start)
        $frames++
    } else { throw "Unexpected GIF block $tag at $offset" }
}
if ($frames -ne 16) { throw "Expected 16 GIF frames, found $frames" }
[System.IO.File]::WriteAllBytes($gifPath,$out.ToArray())
$out.Dispose()
$title.Dispose();$label.Dispose();$small.Dispose();$muted.Dispose()
Write-Output 'STUDIO_EVIDENCE_OK'
