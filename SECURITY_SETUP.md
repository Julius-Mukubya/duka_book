# Security Setup Guide

## Exposed Credentials - URGENT ACTION REQUIRED

The following sensitive credentials were exposed in commits and have been removed:

### 1. Firebase API Keys (lib/firebase_options.dart)
- **Status**: ✅ Replaced with environment variables
- **Previous exposure**: Web, Android, and iOS API keys
- **Action**: Use `String.fromEnvironment()` to load keys from environment

### 2. Google Services Configuration (android/app/google-services.json)
- **Status**: ✅ Moved to .gitignore
- **Template created**: `android/app/google-services.json.example`
- **Action**: Never commit the actual file, only use example as reference

### 3. Firebase Service Account Key (scripts/service-account.json)
- **Status**: ✅ Moved to .gitignore  
- **Template created**: `scripts/service-account.json.example`
- **Action**: Only authorized developers should have access

## Setup for Development

### Step 1: Regenerate Firebase Configuration
```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Regenerate Firebase configuration for your project
flutterfire configure --project=dukabook-ff425
```

This will recreate the proper configuration files with your credentials.

### Step 2: Set Environment Variables (Local Development)

For local development, create a `.env.local` file (not committed):
```
FIREBASE_WEB_API_KEY=your_web_api_key
FIREBASE_WEB_APP_ID=your_web_app_id
FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=dukabook-ff425
FIREBASE_AUTH_DOMAIN=dukabook-ff425.firebaseapp.com
FIREBASE_STORAGE_BUCKET=dukabook-ff425.firebasestorage.app
FIREBASE_IOS_BUNDLE_ID=com.example.dukaBook
```

### Step 3: Running the App

**Option A: Via FlutterFire CLI (Recommended)**
```bash
flutterfire configure
flutter run
```

**Option B: Manual Environment Variables**
```bash
flutter run --dart-define-from-file=.env.local
```

### Step 4: Setting Up Scripts

For scripts that need the service account key:
1. Get the service account key from Firebase Console
2. Save it locally as `scripts/service-account.json` (not committed)
3. Use `scripts/service-account.json.example` as reference only

## Critical Actions Required

1. **Invalidate Exposed API Keys** ⚠️
   - Go to Firebase Console → Settings → API Keys
   - Delete or regenerate all exposed keys listed below
   - Create new keys for development/production

2. **Revoke Service Account** ⚠️
   - Go to Google Cloud Console
   - Find the exposed service account
   - Create a new service account and update all references

3. **Check Git History**
   - Search commits for any other exposed credentials
   - Consider using `git-filter-repo` or `BFG Repo Cleaner` to remove from history
   - Force push only if it's a private repository

## Exposed Keys (INVALIDATE IMMEDIATELY)

### Firebase API Keys:
- **Web**: `AIzaSyBXFn_9pHJiuG18GMKm-_R465KR15BnB-E`
- **Android**: `AIzaSyCkfLWj2un5tzlDPO-oUpEancgJRepWzVI`
- **iOS**: `AIzaSyA7gnF8-dcIlsNL7vmFdfmxzIcT1Ffq07o`

### Service Account:
- **Email**: `firebase-adminsdk-fbsvc@dukabook-ff425.iam.gserviceaccount.com`
- **Private Key ID**: `f827c0d71da883fbb29e52c70c5b3370eee84abe`

## Best Practices

1. **Never commit credentials** - Use .gitignore for sensitive files
2. **Use environment variables** - Load credentials from environment
3. **Use secret management tools** - For CI/CD pipelines (GitHub Secrets, Firebase Secrets Manager)
4. **Regular audits** - Periodically check for exposed credentials
5. **Code reviews** - Have another developer review before commits
6. **Use Git hooks** - Consider using `git-secrets` to prevent accidental commits

## References

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Security Best Practices](https://firebase.google.com/docs/database/security)
- [12 Factor App - Config](https://12factor.net/config)
- [git-secrets](https://github.com/awslabs/git-secrets)
