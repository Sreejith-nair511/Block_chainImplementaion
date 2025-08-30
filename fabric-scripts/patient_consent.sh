#!/bin/bash

# Patient Consent ZK Proof Simulation for Arogya Healthcare Blockchain
# This script simulates zero-knowledge proof for patient consent verification

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 <recordId> <patientId> [action]${NC}"
    echo -e "${YELLOW}Actions: sign, verify, revoke${NC}"
    echo -e "${YELLOW}Example: $0 REC001 PAT001 sign${NC}"
    echo -e "${YELLOW}Example: $0 REC001 PAT001 verify${NC}"
    exit 1
}

# Function to generate mock private/public key pair
generate_keypair() {
    local patient_id=$1
    
    # Mock private key (in real implementation, this would be securely generated and stored)
    PRIVATE_KEY="priv_${patient_id}_$(echo -n "$patient_id" | sha256sum | cut -c1-32)"
    
    # Mock public key derived from private key
    PUBLIC_KEY="pub_${patient_id}_$(echo -n "$PRIVATE_KEY" | sha256sum | cut -c1-32)"
    
    echo -e "${CYAN}🔑 Generated key pair for patient $patient_id${NC}"
    echo -e "${YELLOW}  Public Key: ${PUBLIC_KEY:0:20}...${NC}"
    echo -e "${BLUE}  Private Key: [PROTECTED - NOT DISPLAYED]${NC}"
}

# Function to create digital signature
create_signature() {
    local record_id=$1
    local patient_id=$2
    local timestamp=$3
    local private_key=$4
    
    # Create consent message
    local consent_message="CONSENT:$record_id:$patient_id:$timestamp:AUTHORIZED"
    
    # Simulate digital signature creation (ECDSA-like)
    local signature=$(echo -n "$consent_message$private_key" | sha256sum | cut -c1-64)
    
    echo "$signature"
}

# Function to verify signature
verify_signature() {
    local record_id=$1
    local patient_id=$2
    local timestamp=$3
    local signature=$4
    local public_key=$5
    
    # Recreate the consent message
    local consent_message="CONSENT:$record_id:$patient_id:$timestamp:AUTHORIZED"
    
    # Derive private key from public key for verification (mock implementation)
    local derived_private_key="priv_${patient_id}_$(echo -n "$patient_id" | sha256sum | cut -c1-32)"
    
    # Recompute signature
    local expected_signature=$(echo -n "$consent_message$derived_private_key" | sha256sum | cut -c1-64)
    
    if [ "$signature" = "$expected_signature" ]; then
        return 0  # Valid signature
    else
        return 1  # Invalid signature
    fi
}

# Function to perform ZK proof verification
zk_proof_verification() {
    local record_id=$1
    local patient_id=$2
    local signature=$3
    local public_key=$4
    
    echo -e "${PURPLE}🔮 Performing Zero-Knowledge Proof Verification...${NC}"
    echo
    
    echo -e "${CYAN}ZK Proof Process:${NC}"
    echo -e "${YELLOW}  1. Prover (Patient) claims: 'I consent to access record $record_id'${NC}"
    echo -e "${YELLOW}  2. Verifier (Doctor) challenges: 'Prove you are the authorized patient'${NC}"
    echo -e "${YELLOW}  3. Prover provides cryptographic proof without revealing private key${NC}"
    echo -e "${YELLOW}  4. Verifier confirms proof validity using public key${NC}"
    echo
    
    # Simulate ZK proof steps
    echo -e "${CYAN}Step 1: Commitment Phase${NC}"
    local commitment=$(echo -n "commit_$patient_id_$(date +%s)" | sha256sum | cut -c1-32)
    echo -e "${BLUE}  Commitment: $commitment${NC}"
    
    echo -e "${CYAN}Step 2: Challenge Phase${NC}"
    local challenge=$(shuf -i 1000-9999 -n 1)
    echo -e "${BLUE}  Challenge: $challenge${NC}"
    
    echo -e "${CYAN}Step 3: Response Phase${NC}"
    local response=$(echo -n "$signature$challenge" | sha256sum | cut -c1-32)
    echo -e "${BLUE}  Response: $response${NC}"
    
    echo -e "${CYAN}Step 4: Verification Phase${NC}"
    # Simulate verification computation
    sleep 1
    
    # In this simulation, we'll make it pass most of the time
    if [ $((RANDOM % 100)) -lt 95 ]; then
        echo -e "${GREEN}  ✅ ZK Proof VALID - Patient identity confirmed${NC}"
        echo -e "${GREEN}  ✅ Consent verified without revealing private information${NC}"
        return 0
    else
        echo -e "${RED}  ❌ ZK Proof INVALID - Verification failed${NC}"
        return 1
    fi
}

# Main script logic
if [ $# -lt 2 ]; then
    usage
fi

RECORD_ID=$1
PATIENT_ID=$2
ACTION=${3:-"sign"}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Arogya ZK Proof Consent System       ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

case $ACTION in
    "sign")
        echo -e "${YELLOW}📝 Creating patient consent signature...${NC}"
        echo
        
        # Generate keypair
        generate_keypair "$PATIENT_ID"
        echo
        
        # Create timestamp
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        
        # Create signature
        echo -e "${CYAN}✍️  Signing consent for record access...${NC}"
        SIGNATURE=$(create_signature "$RECORD_ID" "$PATIENT_ID" "$TIMESTAMP" "$PRIVATE_KEY")
        
        # Store consent (simulate blockchain storage)
        CONSENT_FILE="/tmp/consent_${RECORD_ID}_${PATIENT_ID}.json"
        cat > "$CONSENT_FILE" << EOF
{
  "recordId": "$RECORD_ID",
  "patientId": "$PATIENT_ID",
  "publicKey": "$PUBLIC_KEY",
  "signature": "$SIGNATURE",
  "timestamp": "$TIMESTAMP",
  "status": "ACTIVE",
  "consentMessage": "I, patient $PATIENT_ID, hereby consent to authorized healthcare providers accessing my medical record $RECORD_ID for treatment purposes."
}
EOF
        
        echo -e "${GREEN}✅ Consent signature created successfully${NC}"
        echo -e "${BLUE}📋 Consent Details:${NC}"
        echo -e "${YELLOW}  Record ID: $RECORD_ID${NC}"
        echo -e "${YELLOW}  Patient ID: $PATIENT_ID${NC}"
        echo -e "${YELLOW}  Timestamp: $TIMESTAMP${NC}"
        echo -e "${YELLOW}  Signature: ${SIGNATURE:0:20}...${NC}"
        echo -e "${YELLOW}  Status: ACTIVE${NC}"
        ;;
        
    "verify")
        echo -e "${YELLOW}🔍 Verifying patient consent...${NC}"
        echo
        
        # Load consent from storage
        CONSENT_FILE="/tmp/consent_${RECORD_ID}_${PATIENT_ID}.json"
        
        if [ ! -f "$CONSENT_FILE" ]; then
            echo -e "${RED}❌ No consent found for record $RECORD_ID and patient $PATIENT_ID${NC}"
            echo -e "${YELLOW}💡 Please run: $0 $RECORD_ID $PATIENT_ID sign${NC}"
            exit 1
        fi
        
        # Extract consent data
        STORED_SIGNATURE=$(jq -r '.signature' "$CONSENT_FILE")
        STORED_PUBLIC_KEY=$(jq -r '.publicKey' "$CONSENT_FILE")
        STORED_TIMESTAMP=$(jq -r '.timestamp' "$CONSENT_FILE")
        CONSENT_STATUS=$(jq -r '.status' "$CONSENT_FILE")
        
        echo -e "${BLUE}📋 Loaded consent information:${NC}"
        echo -e "${YELLOW}  Patient ID: $PATIENT_ID${NC}"
        echo -e "${YELLOW}  Record ID: $RECORD_ID${NC}"
        echo -e "${YELLOW}  Status: $CONSENT_STATUS${NC}"
        echo -e "${YELLOW}  Signed: $STORED_TIMESTAMP${NC}"
        echo
        
        if [ "$CONSENT_STATUS" != "ACTIVE" ]; then
            echo -e "${RED}❌ Consent is not active (Status: $CONSENT_STATUS)${NC}"
            exit 1
        fi
        
        # Verify signature
        echo -e "${CYAN}🔐 Verifying digital signature...${NC}"
        if verify_signature "$RECORD_ID" "$PATIENT_ID" "$STORED_TIMESTAMP" "$STORED_SIGNATURE" "$STORED_PUBLIC_KEY"; then
            echo -e "${GREEN}✅ Digital signature is valid${NC}"
        else
            echo -e "${RED}❌ Digital signature verification failed${NC}"
            exit 1
        fi
        
        echo
        
        # Perform ZK proof verification
        if zk_proof_verification "$RECORD_ID" "$PATIENT_ID" "$STORED_SIGNATURE" "$STORED_PUBLIC_KEY"; then
            echo
            echo -e "${GREEN}🎉 CONSENT VERIFIED - Access authorized${NC}"
            echo -e "${GREEN}✅ Patient identity confirmed via zero-knowledge proof${NC}"
            echo -e "${GREEN}✅ No private information was revealed during verification${NC}"
            
            # Log successful verification
            echo -e "${CYAN}📝 Logging consent verification...${NC}"
            VERIFICATION_LOG="/tmp/consent_verification_log.txt"
            echo "[$(date)] CONSENT_VERIFIED - Record: $RECORD_ID, Patient: $PATIENT_ID, Status: SUCCESS" >> "$VERIFICATION_LOG"
            
        else
            echo
            echo -e "${RED}❌ CONSENT VERIFICATION FAILED${NC}"
            echo -e "${RED}🚫 Access denied - ZK proof verification failed${NC}"
            
            # Log failed verification
            VERIFICATION_LOG="/tmp/consent_verification_log.txt"
            echo "[$(date)] CONSENT_FAILED - Record: $RECORD_ID, Patient: $PATIENT_ID, Status: FAILED" >> "$VERIFICATION_LOG"
        fi
        ;;
        
    "revoke")
        echo -e "${YELLOW}🚫 Revoking patient consent...${NC}"
        
        CONSENT_FILE="/tmp/consent_${RECORD_ID}_${PATIENT_ID}.json"
        
        if [ ! -f "$CONSENT_FILE" ]; then
            echo -e "${RED}❌ No consent found to revoke${NC}"
            exit 1
        fi
        
        # Update consent status
        jq '.status = "REVOKED" | .revokedAt = "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"' "$CONSENT_FILE" > "${CONSENT_FILE}.tmp"
        mv "${CONSENT_FILE}.tmp" "$CONSENT_FILE"
        
        echo -e "${GREEN}✅ Consent revoked successfully${NC}"
        echo -e "${YELLOW}⚠️  All future access attempts will be denied${NC}"
        ;;
        
    *)
        echo -e "${RED}❌ Invalid action: $ACTION${NC}"
        usage
        ;;
esac

echo
echo -e "${PURPLE}🔒 Zero-Knowledge Proof Benefits:${NC}"
echo -e "${YELLOW}  • Patient privacy is preserved${NC}"
echo -e "${YELLOW}  • No sensitive information is revealed${NC}"
echo -e "${YELLOW}  • Cryptographic proof of identity${NC}"
echo -e "${YELLOW}  • Consent can be verified without exposing private keys${NC}"

echo
echo -e "${GREEN}🎉 ZK Proof consent process completed!${NC}"
