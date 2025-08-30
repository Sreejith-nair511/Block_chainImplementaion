package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// HealthRecord represents a patient health record with encryption
type HealthRecord struct {
	RecordID      string    `json:"recordId"`
	PatientID     string    `json:"patientId"`
	DoctorID      string    `json:"doctorId"`
	RawData       string    `json:"rawData"`       // Original patient data
	Hash          string    `json:"hash"`          // SHA-256 hash of rawData
	EncryptedData string    `json:"encryptedData"` // AES-256 encrypted rawData
	Hospital      string    `json:"hospital"`
	Timestamp     time.Time `json:"timestamp"`
	Source        string    `json:"source"`
	CreatedAt     time.Time `json:"createdAt"`
	UpdatedAt     time.Time `json:"updatedAt"`
}

// AuditLog represents an audit trail entry
type AuditLog struct {
	TxID      string    `json:"txId"`
	RecordID  string    `json:"recordId"`
	Action    string    `json:"action"`
	UserID    string    `json:"userId"`
	Timestamp time.Time `json:"timestamp"`
	Details   string    `json:"details"`
}

// SmartContract provides functions for managing health records
type SmartContract struct {
	contractapi.Contract
}

// Mock hospital encryption key (in production, this would be managed securely)
var hospitalKey = []byte("arogya-hospital-key-32-bytes!!")

// InitLedger initializes the ledger with sample data
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	log.Println("Initializing Arogya Health Ledger...")
	
	// Create initial audit log
	auditLog := AuditLog{
		TxID:      ctx.GetStub().GetTxID(),
		RecordID:  "SYSTEM",
		Action:    "INIT_LEDGER",
		UserID:    "SYSTEM",
		Timestamp: time.Now(),
		Details:   "Hyperledger Fabric network initialized",
	}
	
	auditJSON, _ := json.Marshal(auditLog)
	return ctx.GetStub().PutState("AUDIT_INIT", auditJSON)
}

// AddRecord adds a new health record with encryption and hashing
func (s *SmartContract) AddRecord(ctx contractapi.TransactionContextInterface, recordID, patientID, doctorID, description, hospital, source string) error {
	// Check if record already exists
	existing, err := ctx.GetStub().GetState(recordID)
	if err != nil {
		return fmt.Errorf("failed to read from world state: %v", err)
	}
	if existing != nil {
		return fmt.Errorf("record %s already exists", recordID)
	}

	// Create raw data string
	rawData := fmt.Sprintf("Patient: %s, Doctor: %s, Description: %s, Hospital: %s", 
		patientID, doctorID, description, hospital)

	// Generate SHA-256 hash
	hash := sha256.Sum256([]byte(rawData))
	hashString := fmt.Sprintf("%x", hash)

	// Encrypt the raw data
	encryptedData, err := encryptAES(rawData, hospitalKey)
	if err != nil {
		return fmt.Errorf("failed to encrypt data: %v", err)
	}

	// Create health record
	record := HealthRecord{
		RecordID:      recordID,
		PatientID:     patientID,
		DoctorID:      doctorID,
		RawData:       rawData,
		Hash:          hashString,
		EncryptedData: encryptedData,
		Hospital:      hospital,
		Timestamp:     time.Now(),
		Source:        source,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	recordJSON, err := json.Marshal(record)
	if err != nil {
		return err
	}

	// Store the record
	err = ctx.GetStub().PutState(recordID, recordJSON)
	if err != nil {
		return err
	}

	// Create audit log
	auditLog := AuditLog{
		TxID:      ctx.GetStub().GetTxID(),
		RecordID:  recordID,
		Action:    "ADD_RECORD",
		UserID:    doctorID,
		Timestamp: time.Now(),
		Details:   fmt.Sprintf("Record added for patient %s at %s", patientID, hospital),
	}

	auditJSON, _ := json.Marshal(auditLog)
	auditKey := fmt.Sprintf("AUDIT_%s_%d", recordID, time.Now().Unix())
	ctx.GetStub().PutState(auditKey, auditJSON)

	return nil
}

// QueryRecord retrieves a health record by ID
func (s *SmartContract) QueryRecord(ctx contractapi.TransactionContextInterface, recordID string) (*HealthRecord, error) {
	recordJSON, err := ctx.GetStub().GetState(recordID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if recordJSON == nil {
		return nil, fmt.Errorf("record %s does not exist", recordID)
	}

	var record HealthRecord
	err = json.Unmarshal(recordJSON, &record)
	if err != nil {
		return nil, err
	}

	// Create audit log for query
	auditLog := AuditLog{
		TxID:      ctx.GetStub().GetTxID(),
		RecordID:  recordID,
		Action:    "QUERY_RECORD",
		UserID:    "SYSTEM",
		Timestamp: time.Now(),
		Details:   fmt.Sprintf("Record %s queried", recordID),
	}

	auditJSON, _ := json.Marshal(auditLog)
	auditKey := fmt.Sprintf("AUDIT_%s_%d", recordID, time.Now().Unix())
	ctx.GetStub().PutState(auditKey, auditJSON)

	return &record, nil
}

// VerifyIntegrity verifies the integrity of a record by checking its hash
func (s *SmartContract) VerifyIntegrity(ctx contractapi.TransactionContextInterface, recordID string) (bool, error) {
	record, err := s.QueryRecord(ctx, recordID)
	if err != nil {
		return false, err
	}

	// Recompute hash
	hash := sha256.Sum256([]byte(record.RawData))
	computedHash := fmt.Sprintf("%x", hash)

	// Compare with stored hash
	isValid := computedHash == record.Hash

	// Create audit log
	auditLog := AuditLog{
		TxID:      ctx.GetStub().GetTxID(),
		RecordID:  recordID,
		Action:    "VERIFY_INTEGRITY",
		UserID:    "SYSTEM",
		Timestamp: time.Now(),
		Details:   fmt.Sprintf("Integrity check: %t", isValid),
	}

	auditJSON, _ := json.Marshal(auditLog)
	auditKey := fmt.Sprintf("AUDIT_%s_%d", recordID, time.Now().Unix())
	ctx.GetStub().PutState(auditKey, auditJSON)

	return isValid, nil
}

// DecryptRecord decrypts the encrypted data of a record
func (s *SmartContract) DecryptRecord(ctx contractapi.TransactionContextInterface, recordID string) (string, error) {
	record, err := s.QueryRecord(ctx, recordID)
	if err != nil {
		return "", err
	}

	// Decrypt the data
	decryptedData, err := decryptAES(record.EncryptedData, hospitalKey)
	if err != nil {
		return "", fmt.Errorf("failed to decrypt data: %v", err)
	}

	// Create audit log
	auditLog := AuditLog{
		TxID:      ctx.GetStub().GetTxID(),
		RecordID:  recordID,
		Action:    "DECRYPT_RECORD",
		UserID:    "AUTHORIZED_USER",
		Timestamp: time.Now(),
		Details:   "Record decrypted for authorized access",
	}

	auditJSON, _ := json.Marshal(auditLog)
	auditKey := fmt.Sprintf("AUDIT_%s_%d", recordID, time.Now().Unix())
	ctx.GetStub().PutState(auditKey, auditJSON)

	return decryptedData, nil
}

// GetAllRecords returns all health records
func (s *SmartContract) GetAllRecords(ctx contractapi.TransactionContextInterface) ([]*HealthRecord, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("REC", "RECzzz")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var records []*HealthRecord
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var record HealthRecord
		err = json.Unmarshal(queryResponse.Value, &record)
		if err != nil {
			return nil, err
		}
		records = append(records, &record)
	}

	return records, nil
}

// GetAuditTrail returns audit trail for a specific record
func (s *SmartContract) GetAuditTrail(ctx contractapi.TransactionContextInterface, recordID string) ([]*AuditLog, error) {
	auditPrefix := fmt.Sprintf("AUDIT_%s", recordID)
	resultsIterator, err := ctx.GetStub().GetStateByRange(auditPrefix, auditPrefix+"zzz")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var auditLogs []*AuditLog
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var auditLog AuditLog
		err = json.Unmarshal(queryResponse.Value, &auditLog)
		if err != nil {
			return nil, err
		}
		auditLogs = append(auditLogs, &auditLog)
	}

	return auditLogs, nil
}

// Encryption helper functions
func encryptAES(plaintext string, key []byte) (string, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}

	ciphertext := gcm.Seal(nonce, nonce, []byte(plaintext), nil)
	return base64.StdEncoding.EncodeToString(ciphertext), nil
}

func decryptAES(ciphertext string, key []byte) (string, error) {
	data, err := base64.StdEncoding.DecodeString(ciphertext)
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonceSize := gcm.NonceSize()
	if len(data) < nonceSize {
		return "", fmt.Errorf("ciphertext too short")
	}

	nonce, ciphertext_bytes := data[:nonceSize], data[nonceSize:]
	plaintext, err := gcm.Open(nil, nonce, ciphertext_bytes, nil)
	if err != nil {
		return "", err
	}

	return string(plaintext), nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		log.Panicf("Error creating health chaincode: %v", err)
	}

	if err := chaincode.Start(); err != nil {
		log.Panicf("Error starting health chaincode: %v", err)
	}
}
