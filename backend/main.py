import firebase_admin
from firebase_admin import credentials, firestore
import ee
import time

# ==========================================
# 1. SETUP & CONNECTIONS
# ==========================================

# Connect to Firebase
# Ensure 'serviceAccountKey.json' is in the same folder as this script
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
print("🔥 Firebase Connected!")

# Connect to Google Earth Engine
# UPDATED: We explicitly set the project ID here
MY_PROJECT_ID = 'ai-powered-fra'
ee_enabled = False

try:
    ee.Initialize(project=MY_PROJECT_ID)
    print("🌍 Google Earth Engine Connected!")
    ee_enabled = True
except Exception as e:
    print(f"⚠️ Earth Engine not available: {e}")
    print("📝 To enable Earth Engine:")
    print("   1. Visit https://console.developers.google.com/apis/api/earthengine.googleapis.com/overview?project=ai-powered-fra")
    print("   2. Click 'Enable API'")
    print("   3. Restart this script")
    print("\n⚠️ Continuing without Earth Engine - claims will be auto-approved for testing\n")

# ==========================================
# 2. THE SATELLITE BRAIN (2005 Analysis)
# ==========================================
def check_vegetation_history(polygon_coords):
    """
    Checks if the land was forest in 2005 using Landsat 7 data.
    """
    print("   🛰️  Contacting Satellite Archives...")

    # A. Define the Land Boundary (Region of Interest)
    roi = ee.Geometry.Polygon(polygon_coords)

    # B. Load 2005 Satellite Imagery (Landsat 7)
    # We use Surface Reflectance data for accuracy
    dataset = ee.ImageCollection('LANDSAT/LE07/C02/T1_L2') \
        .filterDate('2005-01-01', '2005-12-31') \
        .filterBounds(roi)

    # C. Create a Cloud-Free Image (Median Composite)
    # This removes clouds by taking the median pixel value over the whole year
    image = dataset.median().clip(roi)

    # D. Calculate NDVI (Normalized Difference Vegetation Index)
    # Formula: (NIR - Red) / (NIR + Red)
    # For Landsat 7: NIR is Band 4 ('SR_B4'), Red is Band 3 ('SR_B3')
    ndvi = image.normalizedDifference(['SR_B4', 'SR_B3']).rename('NDVI')

    # E. Calculate the Average Vegetation for this Plot
    # We use a reducer to get a single number for the whole polygon
    stats = ndvi.reduceRegion(
        reducer=ee.Reducer.mean(),
        geometry=roi,
        scale=30,  # Landsat resolution is 30 meters
        maxPixels=1e9
    )

    # F. Get the Result (Value between -1 and 1)
    avg_ndvi = stats.get('NDVI').getInfo()

    if avg_ndvi is None:
        print("   ⚠️  No satellite data found for this area (might be too small).")
        return 0.0

    return avg_ndvi

# ==========================================
# 3. THE PROCESSING LOOP
# ==========================================
def process_claim(doc):
    data = doc.to_dict()
    claim_id = doc.id
    beneficiary = data.get('beneficiary', {}).get('fullName', 'Unknown')
    
    print(f"\n📄 Processing Claim: {claim_id} ({beneficiary})")

    # 1. Get Coordinates from Firestore
    raw_points = data.get('landData', {}).get('boundary', [])
    if not raw_points:
        print("   ❌ No boundary points found. Skipping.")
        return

    # 2. Convert to GEE Format [[Lng, Lat], [Lng, Lat]...]
    # Important: Firestore is (Lat, Lng), GEE requires (Lng, Lat)
    gee_polygon = []
    for p in raw_points:
        gee_polygon.append([p.longitude, p.latitude])
    
    # Close the loop (first point = last point)
    if gee_polygon:
        gee_polygon.append(gee_polygon[0])

    # 3. 🛡️ RUN THE SATELLITE CHECK
    if ee_enabled:
        try:
            ndvi_score = check_vegetation_history(gee_polygon)
            print(f"   🌿 2005 Vegetation Score (NDVI): {ndvi_score:.3f}")

            # 4. The Verdict Logic
            # NDVI > 0.4 usually indicates dense vegetation/forest
            new_status = 'rejected'
            ai_note = ''

            if ndvi_score > 0.4:
                new_status = 'approved' # Or 'verified'
                ai_note = f"✅ Strong evidence of forest in 2005 (NDVI: {ndvi_score:.2f})"
                print("   ✅ MATCH: This land was likely forest in 2005.")
            elif ndvi_score > 0.2:
                new_status = 'review'
                ai_note = f"⚠️ Moderate vegetation. Human verification needed. (NDVI: {ndvi_score:.2f})"
                print("   ⚠️ UNSURE: Partial vegetation detected.")
            else:
                new_status = 'rejected'
                ai_note = f"❌ Low evidence of forest in 2005 (NDVI: {ndvi_score:.2f})"
                print("   ❌ MISMATCH: Land appears barren or built-up in 2005.")
        except Exception as e:
            print(f"   ❌ Satellite analysis error: {e}")
            new_status = 'review'
            ai_note = f"⚠️ Analysis failed - manual review required"
    else:
        print("   ⚠️ Earth Engine unavailable - auto-approving for testing")
        new_status = 'review'
        ai_note = "⚠️ Approved for testing (Earth Engine not configured)"

    # 5. Update Firebase
    try:
        update_data = {
            'status': new_status,
            'aiVerification': {
                'note': ai_note,
                'verifiedAt': firestore.SERVER_TIMESTAMP
            }
        }
        db.collection('claims').document(claim_id).update(update_data)
        print(f"   🚀 Database Updated: Status set to '{new_status}'")

    except Exception as e:
        print(f"   ❌ Analysis Failed: {e}")

# ==========================================
# 4. MAIN LISTENER
# ==========================================
def main():
    print("📡 Listening for new 'submitted' claims...")
    
    # Create a real-time listener on the database
    # We watch for claims where status is 'submitted'
    claims_ref = db.collection('claims').where(filter=firestore.FieldFilter('status', '==', 'submitted'))
    
    # Callback function that runs whenever database changes
    def on_snapshot(col_snapshot, changes, read_time):
        for change in changes:
            if change.type.name == 'ADDED':
                process_claim(change.document)

    # Attach the listener
    query_watch = claims_ref.on_snapshot(on_snapshot)

    # Keep the script running forever
    while True:
        time.sleep(1)

if __name__ == "__main__":
    main()