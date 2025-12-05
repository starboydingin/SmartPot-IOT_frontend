# SmartPot Frontend Quick Setup

Write-Host "========================================" -ForegroundColor Green
Write-Host "SmartPot Flutter App Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Host "✓ Flutter found: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter not found. Please install Flutter first." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Get Flutter dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Configuration Required!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Please update lib/config/api_config.dart with your backend URL:" -ForegroundColor Cyan
Write-Host ""
Write-Host "For Android Emulator:" -ForegroundColor Yellow
Write-Host "  baseUrl = 'http://10.0.2.2:3000/api/v1'" -ForegroundColor White
Write-Host "  wsUrl = 'ws://10.0.2.2:3000'" -ForegroundColor White
Write-Host ""
Write-Host "For Physical Device:" -ForegroundColor Yellow
Write-Host "  1. Find your computer's IP address:" -ForegroundColor White
Write-Host "     Run: ipconfig (Windows) or ifconfig (Mac/Linux)" -ForegroundColor White
Write-Host "  2. Update baseUrl to: 'http://YOUR_IP:3000/api/v1'" -ForegroundColor White
Write-Host "  3. Update wsUrl to: 'ws://YOUR_IP:3000'" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To run the app:" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Make sure the backend server is running first!" -ForegroundColor Yellow
Write-Host ""
