# 🔐 Firebase Security Rules Deployment Guide

## Overview
This guide explains how to deploy the secure Firebase rules for Evergo Bus Tracker.

⚠️ **IMPORTANT:** The current Firebase rules are OPEN (allow all read/write). You MUST deploy these secure rules before launching to production.

---

## 📋 Files to Deploy

### 1. Firestore Security Rules
**File:** `firestore.rules`
**Location in Firebase Console:** Firestore Database → Rules

### 2. Realtime Database Security Rules
**File:** `database.rules.json`
**Location in Firebase Console:** Realtime Database → Rules

---

## 🚀 Deployment Methods

### Method 1: Firebase Console (Easiest)

#### Deploy Firestore Rules:
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **evergo-1d57e**
3. Go to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules`
5. Paste into the editor
6. Click **Publish**
7. Confirm the deployment

#### Deploy RTDB Rules:
1. In Firebase Console, go to **Realtime Database** → **Rules** tab
2. Copy the contents of `database.rules.json`
3. Paste into the editor
4. Click **Publish**
5. Confirm the deployment

---

### Method 2: Firebase CLI (Automated)

#### Prerequisites:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project (if not already done)
firebase init
```

#### Deploy Rules:
```bash
# Deploy Firestore rules only
firebase deploy --only firestore:rules

# Deploy RTDB rules only
firebase deploy --only database

# Deploy both at once
firebase deploy --only firestore:rules,database
```

---

## 🔍 What These Rules Do

### Firestore Rules (`firestore.rules`)

#### Users Collection:
- ✅ Any authenticated user can **read** any profile
- ✅ Users can only **create/update** their own profile
- ❌ Users cannot **delete** profiles

#### Buses Collection:
- ✅ Any authenticated user can **read** bus data
- ✅ Drivers can only **update** their own bus
- ❌ Cannot delete buses from client

#### Routes Collection:
- ✅ **Public read** access (no auth required)
- ❌ **No write** access from client (admin only)

#### Trips Collection:
- ✅ Authenticated users can **read** all trips
- ✅ Drivers can **create/update** their own trips
- ❌ Cannot delete trips

#### Notifications Collection:
- ✅ Users can only **read** their own notifications
- ❌ **No write** from client (server-side only)

### RTDB Rules (`database.rules.json`)

#### Locations Path:
- ✅ **Public read** for all locations (so commuters can see buses)
- ✅ Drivers can only **write** to their own bus location
- ✅ **Validates** data structure (must have: latitude, longitude, speed, heading, timestamp)

---

## ✅ Testing After Deployment

### Test 1: Driver Can Update Own Bus
```dart
// Should succeed
await FirebaseFirestore.instance
  .collection('buses')
  .doc(currentUserId)
  .update({'passengerCount': 10});
```

### Test 2: Driver Cannot Update Other's Bus
```dart
// Should fail with permission-denied
await FirebaseFirestore.instance
  .collection('buses')
  .doc('someOtherDriverId')
  .update({'passengerCount': 10});
```

### Test 3: Unauthenticated Cannot Read Users
```dart
// Should fail if not authenticated
await FirebaseFirestore.instance
  .collection('users')
  .doc('someUserId')
  .get();
```

### Test 4: Driver Can Write Location
```dart
// Should succeed for own bus
await FirebaseDatabase.instance
  .ref('locations/$currentBusId')
  .set({
    'latitude': 8.5,
    'longitude': 123.4,
    'speed': 60.0,
    'heading': 90.0,
    'timestamp': ServerValue.timestamp,
  });
```

---

## 🚨 Before Production Launch Checklist

- [ ] Deploy Firestore security rules
- [ ] Deploy RTDB security rules
- [ ] Test driver can update own bus
- [ ] Test driver cannot update other's bus
- [ ] Test commuter can read buses
- [ ] Test location writes work for drivers
- [ ] Test location reads work for everyone
- [ ] Remove or protect `/admin/seed-data` route
- [ ] Test on real devices with production Firebase

---

## 🛠️ Troubleshooting

### Error: "PERMISSION_DENIED"
**Cause:** Rules are too restrictive or user not authenticated
**Solution:** 
1. Check user is logged in
2. Verify `request.auth.uid` matches resource owner
3. Check Firebase Console → Authentication to see active users

### Error: "Missing or insufficient permissions"
**Cause:** Firestore rules blocking the operation
**Solution:**
1. Check Firebase Console → Firestore → Rules tab
2. Look at the "Rules Playground" to test queries
3. Verify the document structure matches rule expectations

### Error: "VALIDATION_ERROR" (RTDB)
**Cause:** Data doesn't match `.validate` rules
**Solution:** Ensure location data includes all required fields:
- latitude (number)
- longitude (number)
- speed (number)
- heading (number)
- timestamp (number)

---

## 📝 Notes

### Production vs Development
You may want different rules for development:
- Development: More permissive (easier testing)
- Production: Strict rules (as provided)

To manage this, you can:
1. Use different Firebase projects
2. Or use Firebase CLI with different rule files

### Monitoring Access
After deployment:
1. Go to Firebase Console
2. Check **Firestore** → **Usage** tab
3. Check **Realtime Database** → **Usage** tab
4. Monitor for unusual patterns or denied requests

---

## 🔗 Useful Links

- [Firestore Security Rules Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [RTDB Security Rules Docs](https://firebase.google.com/docs/database/security)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)

---

**Last Updated:** January 21, 2025  
**Status:** Ready for deployment  
**Priority:** ⚠️ **CRITICAL** before public launch
