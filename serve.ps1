$port = 8137
$root = "C:\Claude\prospr"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"
while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $response.Headers.Add("Accept-Ranges", "none")
        $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
        $response.Headers.Add("Pragma", "no-cache")
        $path = $request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        $filePath = Join-Path $root $path.TrimStart('/')
        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            if ($filePath -like "*.html") { $response.ContentType = "text/html; charset=utf-8" }
            elseif ($filePath -like "*.png") { $response.ContentType = "image/png" }
            elseif ($filePath -like "*.jpg" -or $filePath -like "*.jpeg") { $response.ContentType = "image/jpeg" }
            else { $response.ContentType = "application/octet-stream" }
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
        }
    } catch {
        Write-Host "Request error: $_"
    } finally {
        try { $response.OutputStream.Close() } catch {}
    }
}
