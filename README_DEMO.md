# Arogya Hyperledger Fabric Demo

This document provides instructions for demonstrating the Arogya healthcare blockchain system using Hyperledger Fabric.

## Prerequisites

- Hyperledger Fabric network running
- Chaincode deployed and instantiated
- Required dependencies: `jq` for JSON processing

## Preloading Mock Data

The system includes 50 realistic patient records based on common healthcare conditions in India. These records can be preloaded into the blockchain for demonstration purposes.

### Loading Mock Patient Records

Run the following command to insert 50 realistic patient records into the blockchain ledger:

```bash
./fabric-scripts/load_mock_patients.sh
```

This script will:
- Read patient data from `data/mock_patients.json`
- Process each of the 50 patient records
- Call `./fabric-scripts/invoke_add_record.sh` for each record
- Display progress messages showing which records are being added
- Include a small delay between each transaction to avoid overwhelming the peer CLI

**Sample output:**
```
========================================
  Loading Mock Patients to Blockchain  
========================================

Found 50 patient records to load

[1/50] Processing: REC001
Patient: Aarav Sharma | Condition: Type 2 Diabetes
✓ Added REC001 for Aarav Sharma (Type 2 Diabetes)

[2/50] Processing: REC002
Patient: Kavya Nair | Condition: Hypertension Stage 2
✓ Added REC002 for Kavya Nair (Hypertension Stage 2)
...
```

### Mock Data Details

The mock dataset includes:
- **50 patient records** with realistic Indian names
- **Common conditions** seen in Indian healthcare: diabetes, hypertension, TB, maternal health, dengue, cardiac issues, cancer, mental health conditions
- **Major hospitals** across India: AIIMS Delhi, Apollo Chennai, Fortis Bangalore, Safdarjung Hospital, CMC Vellore, PGIMER Chandigarh, etc.
- **Timestamps** spread over 2023-2025 period
- **Authoritative sources**: ICMR Report 2023, WHO India 2024, Govt. EHR Dataset (anonymized)

### Viewing Loaded Data

After loading the mock data, you can:

1. **Export full audit history** to see all loaded records:
   ```bash
   ./fabric-scripts/export_audit_json.sh
   ```

2. **Query specific records** by record ID:
   ```bash
   ./fabric-scripts/query_record.sh REC001
   ./fabric-scripts/query_record.sh REC025
   ```

3. **Search by patient ID**:
   ```bash
   ./fabric-scripts/query_by_patient.sh PAT001
   ```

### Sample Record Structure

Each mock patient record contains:
```json
{
  "recordId": "REC001",
  "patientName": "Aarav Sharma",
  "patientId": "PAT001",
  "doctorId": "DOC101",
  "description": "Type 2 Diabetes Mellitus with HbA1c 8.2%. Patient on Metformin 500mg BD. Regular monitoring required.",
  "hospital": "AIIMS Delhi",
  "timestamp": "2023-03-15T10:30:00Z",
  "source": "ICMR Report 2023"
}
```

## Demo Workflow

1. **Start the Fabric network** and deploy chaincode
2. **Load mock data**: `./fabric-scripts/load_mock_patients.sh`
3. **Verify data loading**: `./fabric-scripts/export_audit_json.sh`
4. **Demonstrate queries**: Query specific records, patients, or doctors
5. **Show audit trail**: Display the immutable audit history for healthcare records
6. **Add new records**: Demonstrate adding new patient records in real-time
7. **Update records**: Show how record updates create new blockchain entries while preserving history

## Troubleshooting

- Ensure the Hyperledger Fabric network is running before loading data
- Check that `jq` is installed for JSON processing
- Verify that `fabric-scripts/invoke_add_record.sh` exists and is executable
- If loading fails, check peer logs for detailed error messages
- Use `chmod +x fabric-scripts/*.sh` to make scripts executable if needed

## Performance Notes

- The loading script includes 0.2-second delays between transactions
- Loading 50 records typically takes 10-15 seconds
- For production use, consider batch loading mechanisms for better performance
- Monitor peer resource usage during bulk loading operations
