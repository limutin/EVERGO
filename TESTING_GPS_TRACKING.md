# 🧪 GPS Tracking Testing Guide

## Why Walking Room-to-Kitchen Doesn't Work

### GPS Accuracy Limitations:
- **Outdoors (clear sky):** 3-5 meters accuracy
- **Indoors:** 10-50+ meters accuracy (or no signal at all)
- **Room to kitchen:** Maybe 5-10 meters - **too small for GPS to detect**

### Your Code is Correct! ✅
```dart
distanceFilter: 5, // Update every 5 meters
```
This means GPS only fires updates when you move at least 5 meters.

**Walking room-to-kitchen = ~3-8 meters = Below GPS accuracy threshold**

---

## 🎯 How to Test GPS Tracking Properly

### Option 1: Use Android Emulator (Easiest) ⭐

#### Step 1: Start Android Emulator
```bash
flutter emulators --launch <emulator_id>
# or just open from Android Studio
```

#### Step 2: Simulate Location Changes
1. Click the **"..."** (Extended Controls) button in emulator
2. Go to **Location** tab
3. You'll see two options:

   **A. Single Point Mode:**
   - Enter latitude/longitude manually
   - Click "Send" to teleport there
   
   **B. Route Mode (Best for Testing):**
   - Load a GPX or KML route file
   - Click "Play Route" to simulate driving

#### Step 3: Test Your App
1. Login as driver
2. Start trip
3. Simulate route in emulator
4. Watch location update in real-time!

---

### Option 2: Walk Outside (Real Test)

#### Minimum Distance:
- Walk at least **50-100 meters** to see clear changes
- Open area (not between buildings)
- Wait 10-30 seconds after starting trip for GPS lock

#### Good Testing Routes:
- ✅ Around your block (200+ meters)
- ✅ Walk to nearby store
- ✅ Drive/ride short distance (500+ meters)
- ❌ Room to kitchen (too short!)
- ❌ Around house (GPS blocked by walls)

---

### Option 3: GPS Simulator App (Quick Test)

I'll create a testing utility for you that simulates movement along the Dipolog-Dapitan route.

---

## 🔍 How to Verify GPS is Working

### 1. Check Console Logs
You should see these prints when location updates:

```
✅ Location permissions granted
📍 Starting location tracking for driver: <id>, bus: <busId>
📍 New position: 8.496442, 123.795067 @ 0.0 m/s
✅ Location uploaded: 8.496442, 123.795067
```

### 2. Check Firebase Console
1. Open **Firebase Console**
2. Go to **Realtime Database**
3. Look at `/locations/{busId}`
4. You should see:
```json
{
  "locations": {
    "user_123": {
      "latitude": 8.496442,
      "longitude": 123.795067,
      "speed": 0,
      "heading": 0,
      "accuracy": 20.5,
      "lastUpdated": 1737487200000,
      "status": "idle"
    }
  }
}
```

### 3. Watch the Map
- Open commuter app on another device/emulator
- You should see the bus marker moving

---

## 🐛 Troubleshooting

### GPS Not Updating at All

#### Check 1: Permissions
```dart
// Add this to DriverActiveRouteScreen or Dashboard
ElevatedButton(
  onPressed: () async {
    final hasPermission = await Get.find<LocationService>()
        .checkAndRequestPermissions(context);
    print('Permission granted: $hasPermission');
  },
  child: Text('Test Permissions'),
)
```

#### Check 2: Location Services Enabled
```dart
// Check if device location is ON
final serviceEnabled = await Geolocator.isLocationServiceEnabled();
print('Location service enabled: $serviceEnabled');
```

#### Check 3: Position Stream
```dart
// Add to DriverController to debug
Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0, // Set to 0 for testing (update every meter)
  ),
).listen((position) {
  print('🟢 POSITION UPDATE: ${position.latitude}, ${position.longitude}');
  print('   Speed: ${position.speed} m/s');
  print('   Accuracy: ${position.accuracy} m');
  print('   Time: ${position.timestamp}');
});
```

---

### GPS Updates but Not Uploading to Firebase

#### Check Firebase Connectivity
```dart
// Test RTDB write
final ref = FirebaseDatabase.instance.ref('test');
await ref.set({'test': true, 'time': DateTime.now().toString()});
print('✅ Firebase RTDB write successful');
```

#### Check Bus ID
```dart
print('Bus ID: ${assignedBus.value?.id}');
print('Driver ID: ${currentUserId}');
```

---

### Location Uploads but Doesn't Show on Map

#### Check Commuter App is Listening
```dart
// In CommuterController
FirebaseDatabase.instance
  .ref('locations')
  .onValue
  .listen((event) {
    print('🔵 RTDB locations: ${event.snapshot.value}');
  });
```

---

## 🎮 Test Scenarios

### Scenario 1: Stationary (Idle)
- **Expected:** Speed = 0 km/h, status = "idle"
- **Test:** Start trip, don't move for 30 seconds
- **Result:** Location should update every 3 seconds with same coordinates

### Scenario 2: Moving Slowly (Walking)
- **Expected:** Speed = 3-5 km/h, status = "online"
- **Test:** Walk 100+ meters in open area
- **Result:** Coordinates change, speed shows 3-5

### Scenario 3: Moving Fast (Vehicle)
- **Expected:** Speed = 30-60 km/h, status = "online"
- **Test:** Drive/ride vehicle
- **Result:** Coordinates change rapidly, speed shows actual km/h

---

## 📱 Device-Specific Tips

### Android:
- Enable **High Accuracy** mode: Settings → Location → Mode → High Accuracy
- Disable **Battery Optimization** for Evergo: Settings → Apps → Evergo → Battery → Unrestricted
- Grant **"Allow all the time"** permission for background tracking

### iOS:
- Enable **Precise Location**: Settings → Evergo → Location → Precise Location (ON)
- Grant **"Always"** permission: Settings → Evergo → Location → Always

### Emulator:
- Extended Controls → Location → Play Route
- Or use `adb emu geo fix <lng> <lat>` command

---

## 🚗 Realistic Route Simulation

### Dipolog → Dapitan Route Coordinates

```
Dipolog City Hall: 8.5893° N, 123.3417° E
→ Rizal Avenue: 8.6024° N, 123.3500° E
→ Polanco: 8.6500° N, 123.4000° E
→ Piñan: 8.7000° N, 123.4500° E
→ Dapitan City: 8.6600° N, 123.4229° E
```

### Create GPX File for Emulator:
```xml
<?xml version="1.0"?>
<gpx version="1.1">
  <trk>
    <name>Dipolog to Dapitan</name>
    <trkseg>
      <trkpt lat="8.5893" lon="123.3417"><ele>10</ele></trkpt>
      <trkpt lat="8.6024" lon="123.3500"><ele>12</ele></trkpt>
      <trkpt lat="8.6500" lon="123.4000"><ele>15</ele></trkpt>
      <trkpt lat="8.7000" lon="123.4500"><ele>18</ele></trkpt>
      <trkpt lat="8.6600" lon="123.4229"><ele>20</ele></trkpt>
    </trkseg>
  </trk>
</gpx>
```

Save as `dipolog_dapitan_route.gpx`, then load in emulator.

---

## 🎯 Quick Test Checklist

### Before Starting:
- [ ] Location services enabled on device
- [ ] Permission granted ("Allow all the time")
- [ ] Firebase connected
- [ ] User logged in as driver
- [ ] Bus assigned to driver

### During Trip:
- [ ] Console shows "Location permissions granted"
- [ ] Console shows "Starting location tracking"
- [ ] Console shows "New position" every few seconds
- [ ] Console shows "Location uploaded" every 3 seconds
- [ ] Firebase RTDB `/locations/{busId}` updates
- [ ] Commuter app shows bus marker on map

### After Walking 100m:
- [ ] Latitude/longitude changed in console
- [ ] Speed shows > 0 (if moving)
- [ ] Bus marker moved on map

---

## 💡 Pro Testing Tips

### 1. Lower Distance Filter for Testing
Temporarily change in `location_service.dart`:
```dart
distanceFilter: 0, // Update every meter (instead of 5)
```
This makes GPS more sensitive for testing. **Revert to 5 for production.**

### 2. Add Debug Overlay
Show current GPS on screen:
```dart
Positioned(
  top: 50,
  left: 10,
  child: Container(
    padding: EdgeInsets.all(8),
    color: Colors.black54,
    child: Obx(() => Text(
      'Lat: ${ctrl.currentPosition.value.latitude.toStringAsFixed(6)}\n'
      'Lng: ${ctrl.currentPosition.value.longitude.toStringAsFixed(6)}\n'
      'Speed: ${ctrl.currentSpeed.value.toStringAsFixed(1)} km/h',
      style: TextStyle(color: Colors.white, fontSize: 12),
    )),
  ),
)
```

### 3. Mock Location (Dev Only)
For quick testing, you can temporarily override:
```dart
// In location_service.dart startTracking()
Timer.periodic(const Duration(seconds: 3), (timer) {
  // TESTING ONLY - simulates movement
  _uploadLocationToFirebase(
    driverId,
    busId,
    Position(
      latitude: 8.5893 + (timer.tick * 0.001), // Move north
      longitude: 123.3417 + (timer.tick * 0.001), // Move east
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      heading: 45,
      speed: 40 / 3.6, // 40 km/h
      speedAccuracy: 1,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    ),
  );
});
```

---

## ✅ Expected Behavior Summary

| Condition | GPS Update | Firebase Upload | Speed | Status |
|-----------|------------|----------------|-------|--------|
| Stationary | Every 10s | Every 3s | 0 km/h | idle |
| Walking (indoors) | Rarely | Every 3s (same coords) | 0 km/h | idle |
| Walking (outdoors) | Every 5m | Every 3s | 3-5 km/h | online |
| Driving | Every 5m | Every 3s | 30-60 km/h | online |

---

## 🎉 Your Code is Working If...

✅ You see console logs: "📍 New position" and "✅ Location uploaded"  
✅ Firebase RTDB `/locations/{busId}` updates every 3 seconds  
✅ Coordinates change when you move **outdoors for 50+ meters**  
✅ Commuter app shows bus marker on map  

**Indoor movement (room to kitchen) will NOT update coordinates - this is normal GPS behavior!**

---

## 🚀 Next: I'll Create a GPS Simulator

I can create a testing screen that simulates movement along the Dipolog-Dapitan route so you can test without going outside. Want me to build that?

---

*GPS works perfectly! You just need to test it at the right scale (50+ meters outdoors, or use emulator/simulator).*
