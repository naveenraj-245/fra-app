# Backend Setup Instructions

This backend service handles satellite analysis using Firebase and Google Earth Engine for FRA land claims.

## Prerequisites

- Python 3.8+
- Firebase project with Firestore enabled
- Google Earth Engine account

## Setup Steps

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key**
5. Download the JSON file
6. Rename it to `serviceAccountKey.json` and place it in the `backend` directory

⚠️ **IMPORTANT**: This file contains sensitive credentials. It's already added to `.gitignore` to prevent accidental commits.

### 3. Configure Google Earth Engine (First Time Only)

```bash
earthengine authenticate
```

Follow the prompts to authenticate with your Google account.

### 4. Run the Backend

```bash
python main.py
```

## What It Does

The backend:
- Listens for new claim submissions in Firestore (status: 'submitted')
- Retrieves polygon boundary coordinates
- Performs satellite imagery analysis using Google Earth Engine
- Updates claim status to 'review' with analysis results

## File Structure

```
backend/
├── main.py                    # Main backend script
├── requirements.txt           # Python dependencies
├── serviceAccountKey.json     # Firebase credentials (DO NOT COMMIT)
└── README.md                  # This file
```

## Troubleshooting

### "serviceAccountKey.json not found"
- Make sure you downloaded the Firebase service account key
- Place it in the `backend` directory
- Ensure the filename is exactly `serviceAccountKey.json`

### "Earth Engine Authentication required"
- Run `earthengine authenticate` in your terminal
- Follow the authentication flow
- Restart the script

### Import errors
- Ensure all dependencies are installed: `pip install -r requirements.txt`
- Consider using a virtual environment
