<<<<<<< HEAD
# Arogya Hyper Blockchain Implementation

This project is a Hyperledger Fabric-based blockchain solution for managing healthcare records securely and transparently. It includes chaincode, a dashboard, mock data, and scripts for interacting with the ledger.

## Features
- Patient record management on blockchain
- Consent and integrity verification scripts
- Dashboard for visualization and interaction
- Mock patient data for testing
- Docker-based deployment

## Folder Structure
```
chaincode/healthcc/         # Go chaincode for healthcare records
  ├── go.mod
  └── healthcc.go

dashboard/                  # Node.js dashboard application
  ├── Dockerfile
  ├── package.json
  └── server.js

data/
  └── mock_patients.json    # Sample patient data

fabric-scripts/             # Shell scripts for blockchain operations
  ├── decrypt_record.sh
  ├── load_mock_patients.sh
  ├── patient_consent.sh
  └── verify_integrity.sh

visuals/
  └── ledger_flow.html      # Ledger flow visualization

docker-base.yml             # Base Docker configuration

docker-compose.yml          # Docker Compose setup
README.md                   # Project documentation
```

## Setup Instructions
1. **Clone the repository:**
   ```sh
   git clone https://github.com/Sreejith-nair511/Block_chainImplementaion.git
   cd Block_chainImplementaion
   ```
2. **Start the services using Docker Compose:**
   ```sh
   docker-compose up --build
   ```
3. **Access the dashboard:**
   Open your browser and go to `http://localhost:3000` (or the port specified in your dashboard config).

## Usage
- Use the dashboard to interact with the blockchain and view patient records.
- Run scripts in `fabric-scripts/` for operations like loading mock data, verifying integrity, and managing consent.
- Chaincode logic is in `chaincode/healthcc/healthcc.go`.

## License
This project is licensed under the MIT License.
=======
ON system implementation 

>>>>>>> f6c947c8aaed7d5c75b94c60a1339308cf0ae5e6
