Add-Type -AssemblyName System.Drawing
$root=$PSScriptRoot
$bg=[System.Drawing.Color]::FromArgb(12,17,23)
$white=[System.Drawing.Brushes]::WhiteSmoke
$muted=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(174,191,204))
$title=New-Object System.Drawing.Font('Segoe UI',25,[System.Drawing.FontStyle]::Bold)
$label=New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold)
$small=New-Object System.Drawing.Font('Segoe UI',14)

function New-Board($width,$height) {
    $bitmap=New-Object System.Drawing.Bitmap($width,$height)
    $g=[System.Drawing.Graphics]::FromImage($bitmap)
    $g.Clear($bg)
    $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.TextRenderingHint=[System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @{bitmap=$bitmap;g=$g}
}
function Panel($board,$name,$x,$y,$w,$h) {
    $img=[System.Drawing.Image]::FromFile((Join-Path $root $name))
    $board.g.DrawImage($img,[System.Drawing.Rectangle]::new($x,$y,$w,$h))
    $img.Dispose()
}
function Save-Board($board,$name) {
    $board.bitmap.Save((Join-Path $root $name),[System.Drawing.Imaging.ImageFormat]::Png)
    $board.g.Dispose();$board.bitmap.Dispose()
}

$b=New-Board 1600 1235
$b.g.DrawString('Comparación de cuerpo · Blender 5.2.2',$title,$white,32,18)
$b.g.DrawString('Altura normalizada a 1,80 m · misma cámara, luz y material mate',$small,$muted,34,67)
$b.g.DrawString('ACTUAL · pose temporal de comparación',$label,$white,40,111)
$b.g.DrawString('CANDIDATO · Blender Studio / CC0',$label,$white,835,111)
Panel $b 'current_common_apose_front.png' 0 153 800 1000
Panel $b 'studio_front.png' 800 153 800 1000
$b.g.DrawString('A-pose aproximada. Actual con ropa base; candidato con cobertura provisional en pelvis.',$small,$muted,34,1161)
$b.g.DrawString('La base candidata viene sin rig ni pesos. Estas imágenes evalúan forma; no acreditan animación ni integración.',$small,$muted,34,1191)
Save-Board $b 'body_comparison.png'

$b=New-Board 1600 1040
$b.g.DrawString('Manos integrales del cuerpo · comparación de geometría',$title,$white,32,18)
$b.g.DrawString('Misma escala y material. Cada recorte se orienta de forma rígida; no se remodelaron los dedos.',$small,$muted,34,67)
$b.g.DrawString('ACTUAL · correctivo de agarre aplicado',$label,$white,40,111)
$b.g.DrawString('CANDIDATO · Blender Studio / CC0',$label,$white,835,111)
Panel $b 'current_hand_aligned_A.png' 0 153 800 800
Panel $b 'studio_hand_aligned_A.png' 800 153 800 800
$b.g.DrawString('El óvalo y la deformación de los dedos siguen visibles en la malla actual sin texturas ni animación.',$small,$muted,34,971)
$b.g.DrawString('La mano candidata pertenece al cuerpo completo; no se propone injertar una mano aislada.',$small,$muted,34,1001)
Save-Board $b 'hands_comparison.png'

$b=New-Board 1600 1040
$b.g.DrawString('Diagnóstico del óvalo dorsal · mismo generador del personaje',$title,$white,32,18)
$b.g.DrawString('Ensayo en memoria de Blender. La fuente y el GLB de producción conservan su estado.',$small,$muted,34,67)
$b.g.DrawString('CON correctivo de contacto',$label,$white,40,111)
$b.g.DrawString('SIN correctivo de contacto',$label,$white,835,111)
Panel $b 'current_hand_aligned_A.png' 0 153 800 800
Panel $b 'current_no_contact_hand_aligned_A.png' 800 153 800 800
$b.g.DrawString('Al omitir grip_contact desaparece el óvalo: el correctivo de contacto deforma el dorso en reposo.',$small,$muted,34,971)
$b.g.DrawString('Omitirlo no resuelve todavía proporciones, rig ni agarre. Este ensayo identifica una causa concreta.',$small,$muted,34,1001)
Save-Board $b 'contact_diagnostic.png'

$title.Dispose();$label.Dispose();$small.Dispose();$muted.Dispose()
Write-Output 'COMPARISON_BOARDS_OK'
