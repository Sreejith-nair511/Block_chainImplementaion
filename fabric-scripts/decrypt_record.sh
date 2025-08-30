#!/bin/bash

# Decrypt Record Script for Arogya Healthcare Blockchain
# This script simulates decrypting a patient record using the hospital's private key

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 <recordId> [hospitalKey]${NC}"
    echo -e "${YELLOW}Example: $0 REC001${NC}"
    echo -e "${YELLOW}Example: $0 REC001 custom-hospital-key${NC}"
    exit 1
}

# Check if record ID is provided
if [ $# -lt 1 ]; then
    usage
fi

RECORD_ID=$1
HOSPITAL_KEY=${2:-"arogya-hospital-key-32-bytes!!"}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Arogya Record Decryption Utility     ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

echo -e "${YELLOW}🔍 Fetching encrypted record: $RECORD_ID${NC}"

# Simulate peer chaincode query to get the record
echo -e "${CYAN}Executing: peer chaincode query -C healthcare-channel -n healthcc -c '{\"Args\":[\"QueryRecord\",\"$RECORD_ID\"]}'${NC}"

# Mock response - in real implementation, this would call the actual peer command
cat << EOF > /tmp/encrypted_record.json
{
  "recordId": "$RECORD_ID",
  "patientId": "PAT001",
  "doctorId": "DOC101",
  "rawData": "Patient: PAT001, Doctor: DOC101, Description: Type 2 Diabetes Mellitus with HbA1c 8.2%. Patient on Metformin 500mg BD. Regular monitoring required., Hospital: AIIMS Delhi",
  "hash": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
  "encryptedData": "U2FsdGVkX1+vupppZksvRf5pq5g5XjFRIipRkwB0K1Y96Qsv2Lm+31cmzaAILwyt",
  "hospital": "AIIMS Delhi",
  "timestamp": "2023-03-15T10:30:00Z",
  "source": "ICMR Report 2023"
}
EOF

echo -e "${GREEN}✅ Record retrieved successfully${NC}"
echo

# Extract encrypted data
ENCRYPTED_DATA=$(jq -r '.encryptedData' /tmp/encrypted_record.json)
STORED_HASH=$(jq -r '.hash' /tmp/encrypted_record.json)
HOSPITAL=$(jq -r '.hospital' /tmp/encrypted_record.json)

echo -e "${YELLOW}🔐 Encrypted Data: ${ENCRYPTED_DATA:0:50}...${NC}"
echo -e "${YELLOW}🏥 Hospital: $HOSPITAL${NC}"
echo -e "${YELLOW}🔑 Using Hospital Key: ${HOSPITAL_KEY:0:10}...${NC}"
echo

# Simulate decryption process
echo -e "${CYAN}🔓 Decrypting record with AES-256-GCM...${NC}"
sleep 1

# Mock decryption - in real implementation, this would use actual AES decryption
DECRYPTED_DATA="Patient: PAT001, Doctor: DOC101, Description: Type 2 Diabetes Mellitus with HbA1c 8.2%. Patient on Metformin 500mg BD. Regular monitoring required., Hospital: AIIMS Delhi"

echo -e "${GREEN}✅ Decryption successful!${NC}"
echo

# Display decrypted information
echo -e "${BLUE}📋 Decrypted Patient Information:${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Parse and display the decrypted data
IFS=',' read -ra ADDR <<< "$DECRYPTED_DATA"
for i in "${ADDR[@]}"; do
    # Clean up the field
    field=$(echo "$i" | sed 's/^[[:space:]]*//')
    echo -e "${YELLOW}  $field${NC}"
done

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Verify integrity
echo -e "${CYAN}🔍 Verifying data integrity...${NC}"
COMPUTED_HASH=$(echo -n "$DECRYPTED_DATA" | sha256sum | cut -d' ' -f1)

echo -e "${YELLOW}Stored Hash:   $STORED_HASH${NC}"
echo -e "${YELLOW}Computed Hash: $COMPUTED_HASH${NC}"

if [ "$STORED_HASH" = "$COMPUTED_HASH" ]; then
    echo -e "${GREEN}✅ INTEGRITY VERIFIED - Record is authentic${NC}"
else
    echo -e "${RED}❌ INTEGRITY FAILED - Record may have been tampered with${NC}"
fi

echo

# Simulate audit log entry
echo -e "${CYAN}📝 Creating audit log entry...${NC}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TX_ID="tx_$(date +%s)_$(shuf -i 1000-9999 -n 1)"

echo -e "${BLUE}Audit Entry:${NC}"
echo -e "${YELLOW}  Transaction ID: $TX_ID${NC}"
echo -e "${YELLOW}  Action: DECRYPT_RECORD${NC}"
echo -e "${YELLOW}  Record ID: $RECORD_ID${NC}"
echo -e "${YELLOW}  User: AUTHORIZED_DOCTOR${NC}"
echo -e "${YELLOW}  Timestamp: $TIMESTAMP${NC}"
echo -e "${YELLOW}  Status: SUCCESS${NC}"

echo

# Security notice
echo -e "${RED}🔒 SECURITY NOTICE:${NC}"
echo -e "${YELLOW}  • This decryption was logged for audit purposes${NC}"
echo -e "${YELLOW}  • Access is restricted to authorized healthcare personnel${NC}"
echo -e "${YELLOW}  • Patient data is protected under healthcare privacy regulations${NC}"

# Cleanup
rm -f /tmp/encrypted_record.json

echo
echo -e "${GREEN}🎉 Decryption process completed successfully!${NC}"
