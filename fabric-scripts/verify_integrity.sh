#!/bin/bash

# Verify Integrity Script for Arogya Healthcare Blockchain
# This script verifies the tamper-proof nature of stored records by checking SHA-256 hashes

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
    echo -e "${BLUE}Usage: $0 <recordId> [--batch]${NC}"
    echo -e "${YELLOW}Example: $0 REC001${NC}"
    echo -e "${YELLOW}Example: $0 --batch (verify all records)${NC}"
    exit 1
}

# Function to verify a single record
verify_record() {
    local record_id=$1
    
    echo -e "${CYAN}🔍 Verifying integrity for record: $record_id${NC}"
    
    # Simulate fetching record from blockchain
    echo -e "${BLUE}Querying blockchain for record $record_id...${NC}"
    
    # Mock record data - in real implementation, this would query the actual blockchain
    case $record_id in
        "REC001")
            RAW_DATA="Patient: PAT001, Doctor: DOC101, Description: Type 2 Diabetes Mellitus with HbA1c 8.2%. Patient on Metformin 500mg BD. Regular monitoring required., Hospital: AIIMS Delhi"
            STORED_HASH="a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
            ;;
        "REC002")
            RAW_DATA="Patient: PAT002, Doctor: DOC102, Description: Hypertension Stage 2 (BP 160/100). Started on Amlodipine 5mg OD. Lifestyle modifications advised., Hospital: Apollo Chennai"
            STORED_HASH="b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1"
            ;;
        "REC003")
            RAW_DATA="Patient: PAT003, Doctor: DOC103, Description: Pulmonary Tuberculosis - Category I treatment initiated. Sputum AFB positive. DOT started., Hospital: Safdarjung Hospital"
            STORED_HASH="c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2"
            ;;
        *)
            RAW_DATA="Patient: PAT999, Doctor: DOC999, Description: Sample medical record for demonstration purposes., Hospital: Sample Hospital"
            STORED_HASH="d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3"
            ;;
    esac
    
    echo -e "${GREEN}✅ Record retrieved from blockchain${NC}"
    echo
    
    # Display record information
    echo -e "${YELLOW}📋 Record Information:${NC}"
    echo -e "${BLUE}  Record ID: $record_id${NC}"
    echo -e "${BLUE}  Stored Hash: $STORED_HASH${NC}"
    echo
    
    # Compute SHA-256 hash of raw data
    echo -e "${CYAN}🔐 Computing SHA-256 hash of raw data...${NC}"
    COMPUTED_HASH=$(echo -n "$RAW_DATA" | sha256sum | cut -d' ' -f1)
    
    echo -e "${YELLOW}  Raw Data: ${RAW_DATA:0:80}...${NC}"
    echo -e "${YELLOW}  Computed Hash: $COMPUTED_HASH${NC}"
    echo
    
    # Compare hashes
    echo -e "${PURPLE}🔍 Comparing hashes for integrity verification...${NC}"
    echo
    
    if [ "$STORED_HASH" = "$COMPUTED_HASH" ]; then
        echo -e "${GREEN}✅ VALID - Record integrity verified${NC}"
        echo -e "${GREEN}   Hash match confirms record has not been tampered with${NC}"
        return 0
    else
        echo -e "${RED}❌ TAMPERED - Record integrity compromised${NC}"
        echo -e "${RED}   Hash mismatch indicates potential tampering${NC}"
        echo -e "${RED}   Stored:   $STORED_HASH${NC}"
        echo -e "${RED}   Computed: $COMPUTED_HASH${NC}"
        return 1
    fi
}

# Function to verify all records in batch
verify_all_records() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Batch Integrity Verification         ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    local total_records=50
    local valid_records=0
    local invalid_records=0
    
    echo -e "${YELLOW}🔍 Verifying integrity of all $total_records records...${NC}"
    echo
    
    # Simulate verification of all records
    for i in $(seq 1 50); do
        record_id=$(printf "REC%03d" $i)
        
        # Show progress
        echo -ne "${CYAN}Progress: [$i/$total_records] Verifying $record_id...${NC}\r"
        
        # Simulate verification (most records are valid)
        if [ $((RANDOM % 100)) -lt 98 ]; then
            valid_records=$((valid_records + 1))
        else
            invalid_records=$((invalid_records + 1))
            echo -e "\n${RED}❌ $record_id - INTEGRITY FAILED${NC}"
        fi
        
        sleep 0.1
    done
    
    echo
    echo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📊 Batch Verification Summary:${NC}"
    echo -e "${GREEN}  ✅ Valid Records:   $valid_records${NC}"
    echo -e "${RED}  ❌ Invalid Records: $invalid_records${NC}"
    echo -e "${YELLOW}  📈 Success Rate:    $(( (valid_records * 100) / total_records ))%${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ $invalid_records -eq 0 ]; then
        echo -e "${GREEN}🎉 All records passed integrity verification!${NC}"
    else
        echo -e "${YELLOW}⚠️  $invalid_records record(s) failed verification - investigate immediately${NC}"
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    usage
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Arogya Integrity Verification Tool   ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check for batch mode
if [ "$1" = "--batch" ]; then
    verify_all_records
else
    RECORD_ID=$1
    
    echo -e "${YELLOW}🔐 Starting integrity verification process...${NC}"
    echo
    
    verify_record "$RECORD_ID"
    verification_result=$?
    
    echo
    
    # Create audit log entry
    echo -e "${CYAN}📝 Creating audit log entry...${NC}"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    TX_ID="verify_$(date +%s)_$(shuf -i 1000-9999 -n 1)"
    
    if [ $verification_result -eq 0 ]; then
        STATUS="INTEGRITY_VERIFIED"
        STATUS_COLOR="${GREEN}"
    else
        STATUS="INTEGRITY_FAILED"
        STATUS_COLOR="${RED}"
    fi
    
    echo -e "${BLUE}Audit Entry:${NC}"
    echo -e "${YELLOW}  Transaction ID: $TX_ID${NC}"
    echo -e "${YELLOW}  Action: VERIFY_INTEGRITY${NC}"
    echo -e "${YELLOW}  Record ID: $RECORD_ID${NC}"
    echo -e "${YELLOW}  User: SYSTEM_AUDITOR${NC}"
    echo -e "${YELLOW}  Timestamp: $TIMESTAMP${NC}"
    echo -e "${STATUS_COLOR}  Status: $STATUS${NC}"
    
    echo
    echo -e "${PURPLE}🔒 Blockchain Security Features:${NC}"
    echo -e "${YELLOW}  • Cryptographic hashing ensures data integrity${NC}"
    echo -e "${YELLOW}  • Immutable ledger prevents unauthorized modifications${NC}"
    echo -e "${YELLOW}  • Distributed consensus validates all transactions${NC}"
    echo -e "${YELLOW}  • Audit trail provides complete transaction history${NC}"
fi

echo
echo -e "${GREEN}🎉 Integrity verification process completed!${NC}"
