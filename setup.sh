#!/bin/bash

# Arogya Healthcare Blockchain Setup Script
# This script sets up the complete Hyperledger Fabric network with all components

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Arogya Healthcare Blockchain Setup   ${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Make all scripts executable
echo -e "${YELLOW}🔧 Making scripts executable...${NC}"
chmod +x fabric-scripts/*.sh
echo -e "${GREEN}✅ Scripts made executable${NC}"

# Check dependencies
echo -e "${YELLOW}🔍 Checking dependencies...${NC}"

# Check Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker found${NC}"
else
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✅ Docker Compose found${NC}"
else
    echo -e "${RED}❌ Docker Compose not found. Please install Docker Compose first.${NC}"
    exit 1
fi

# Check jq
if command -v jq &> /dev/null; then
    echo -e "${GREEN}✅ jq found${NC}"
else
    echo -e "${YELLOW}⚠️  jq not found. Installing jq...${NC}"
    # Try to install jq based on the system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        echo -e "${RED}❌ Please install jq manually${NC}"
        exit 1
    fi
fi

echo

# Create necessary directories
echo -e "${YELLOW}📁 Creating directory structure...${NC}"
mkdir -p crypto-config/peerOrganizations/arogya.com/{ca,peers,users}
mkdir -p crypto-config/ordererOrganizations/arogya.com/orderers
mkdir -p channel-artifacts
mkdir -p logs
echo -e "${GREEN}✅ Directories created${NC}"

echo

# Start the network
echo -e "${CYAN}🚀 Starting Arogya Healthcare Blockchain Network...${NC}"
echo -e "${YELLOW}This may take a few minutes on first run...${NC}"

# Pull required Docker images
echo -e "${BLUE}📥 Pulling Hyperledger Fabric images...${NC}"
docker pull hyperledger/fabric-peer:latest
docker pull hyperledger/fabric-orderer:latest
docker pull hyperledger/fabric-ca:latest
docker pull hyperledger/fabric-tools:latest
docker pull couchdb:3.1.1

# Start the network
echo -e "${BLUE}🔗 Starting blockchain network...${NC}"
docker-compose up -d

# Wait for services to start
echo -e "${YELLOW}⏳ Waiting for services to initialize...${NC}"
sleep 30

# Check if services are running
echo -e "${CYAN}🔍 Checking service status...${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Blockchain network is running${NC}"
else
    echo -e "${RED}❌ Some services failed to start${NC}"
    docker-compose logs
    exit 1
fi

echo

# Load mock patient data
echo -e "${PURPLE}📊 Loading mock patient data...${NC}"
./fabric-scripts/load_mock_patients.sh

echo

# Display network information
echo -e "${BLUE}🌐 Network Information:${NC}"
echo -e "${YELLOW}  • Dashboard: http://localhost:3000${NC}"
echo -e "${YELLOW}  • Visualization: http://localhost/visuals/ledger_flow.html${NC}"
echo -e "${YELLOW}  • CouchDB Peer0: http://localhost:5984/_utils${NC}"
echo -e "${YELLOW}  • CouchDB Peer1: http://localhost:6984/_utils${NC}"

echo

# Display available commands
echo -e "${CYAN}🛠️  Available Commands:${NC}"
echo -e "${YELLOW}  • Load data: ./fabric-scripts/load_mock_patients.sh${NC}"
echo -e "${YELLOW}  • Verify integrity: ./fabric-scripts/verify_integrity.sh REC001${NC}"
echo -e "${YELLOW}  • Decrypt record: ./fabric-scripts/decrypt_record.sh REC001${NC}"
echo -e "${YELLOW}  • Patient consent: ./fabric-scripts/patient_consent.sh REC001 PAT001 sign${NC}"
echo -e "${YELLOW}  • Export audit: ./fabric-scripts/export_audit_json.sh${NC}"
echo -e "${YELLOW}  • Stop network: docker-compose down${NC}"

echo

echo -e "${GREEN}🎉 Arogya Healthcare Blockchain is ready!${NC}"
echo -e "${CYAN}Visit http://localhost:3000 to access the dashboard${NC}"
