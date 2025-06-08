# 💎 Pearl & Prestige - Flutter E-commerce App

A luxury fashion e-commerce mobile app with smart battery monitoring and network connectivity features.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.5.0+)
- Android Studio or VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/pearl_prestige_app.git
cd pearl_prestige_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## ⚙️ Configuration

### Update API URLs

Replace `https://pearlprestige.shop/api` with your API URL in these files:

**lib/services/api_service.dart:**
```dart
static const String baseUrl = 'YOUR_API_URL_HERE';
```

**lib/providers/auth_provider.dart:**
```dart
static const String _baseUrl = 'YOUR_API_URL_HERE';
```

**lib/providers/cart_provider.dart:**
```dart
static const String _baseUrl = 'YOUR_API_URL_HERE';
```

**lib/providers/products_provider.dart:**
```dart
static const String _baseUrl = 'YOUR_API_URL_HERE';
```

### For Local Development

Use these URLs for testing:
- **Android Emulator:** `http://10.0.2.2:8000/api`
- **iOS Simulator:** `http://localhost:8000/api`
- **Physical Device:** `http://YOUR_COMPUTER_IP:8000/api`

## 🔌 Backend Requirements

Your Laravel API must have these endpoints:

```bash
# Authentication
POST /api/register
POST /api/login
POST /api/logout

# Products
GET /api/products
GET /api/products?category={category}
GET /api/products?search={query}

# Cart
GET /api/cart
POST /api/cart/add
PUT /api/cart/{id}
DELETE /api/cart/{id}
```

### Sample Product Response Format:
```json
{
  "products": [
    {
      "id": 1,
      "name": "Product Name",
      "price": "99.99",
      "description": "Product description",
      "category": "Women",
      "image_url": "https://example.com/image.jpg",
      "stock_quantity": 10
    }
  ]
}
```

## ✨ Features

- **E-commerce:** Browse, search, cart, checkout
- **Authentication:** Login/register with JWT
- **Battery Monitoring:** Smart cart saving when battery low
- **Network Monitoring:** Real-time connection status
- **Offline Support:** Local cart storage
- **Dark/Light Theme:** User preference switching

## 🐛 Troubleshooting

**App won't start:**
```bash
flutter doctor
flutter clean
flutter pub get
```

**API not working:**
- Check API URL is correct
- Verify backend is running
- Check network permissions in AndroidManifest.xml

**Build errors:**
```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Testing

1. **Open app** → See network/battery icons in top-right
2. **Turn airplane mode on/off** → Test network features
3. **Browse products** → Test API connection
4. **Add to cart** → Test cart functionality
5. **Create account** → Test authentication

## 📄 License

MIT License - Free to use and modify.
