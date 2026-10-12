
$images = @{
    "https://www.themealdb.com/images/media/meals/wvqpwt1468339226.jpg" = "spinach-pesto-pasta.jpg"
    "https://www.themealdb.com/images/media/meals/vussxq1511882648.jpg" = "chicken-steak-mushroom.jpg"
    "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg" = "spicy-spaghetti.jpg"
    "https://www.themealdb.com/images/media/meals/sstssx1487349585.jpg" = "chicken-cafreal-rice.jpg"
    "https://www.themealdb.com/images/media/meals/ip5xtp1769779958.jpg" = "chicken-ramen.jpg"
    "https://www.themealdb.com/images/media/meals/xrttsx1487339558.jpg" = "keema-rice.jpg"
    "https://www.themealdb.com/images/media/meals/tyywsw1505930373.jpg" = "chicken-chakli.jpg"
    "https://www.themealdb.com/images/media/meals/qptpvt1487339892.jpg" = "pan-grilled-chicken.jpg"
    "https://www.themealdb.com/images/media/meals/syqypv1486981727.jpg" = "creamy-chicken-garlic-bread.jpg"
    "https://www.themealdb.com/images/media/meals/wuyd2h1765567838.jpg" = "chicken-rice-bowl.jpg"
    "https://www.themealdb.com/images/media/meals/xxpqsy1511452222.jpg" = "paneer-rice-bowl.jpg"
    "https://www.themealdb.com/images/media/meals/2wx8cm1763373419.jpg" = "keema-noodles.jpg"
    "https://www.themealdb.com/images/media/meals/wruvqv1511880994.jpg" = "chicken-steak-butter-rice.jpg"
}

$outputDir = "c:\Users\Bigyan\Downloads\TreatUp\food"
if (!(Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

foreach ($url in $images.Keys) {
    $filename = $images[$url]
    $filepath = Join-Path -Path $outputDir -ChildPath $filename
    try {
        Invoke-WebRequest -Uri $url -OutFile $filepath
        Write-Host "Downloaded: $filename"
    } catch {
        Write-Host "Failed to download $filename : $_"
    }
}
