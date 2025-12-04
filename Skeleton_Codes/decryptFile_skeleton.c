/*
 * decryptFile() - Student Implementation Template
 * 
 * Decrypt an encrypted file using XOR cipher with matrix-based key
 * 
 * PARAMETERS:
 *   inputFile  - Encrypted input filename (.bin file)
 *   outputFile - Decrypted output filename (plaintext)
 *   matrix     - 2D decryption key matrix (pre-loaded, same as encryption)
 *   size       - Matrix dimension (2, 3, or 4)
 * 
 * RETURNS:
 *   SUCCESS (1) on successful decryption
 *   FAILURE (0) on any error
 * 
 * REQUIREMENTS:
 *   - Validate all input parameters
 *   - Process file byte-by-byte using fgetc/fputc
 *   - Apply XOR operation with matrix values
 *   - Handle errors and cleanup properly
 * 
 * CRITICAL FILE MODES (⚠️ MANDATORY):
 *   Input:  fopen(inputFile, "rb") - BINARY READ MODE (REQUIRED!)
 *   Output: fopen(outputFile, "w")  - Text write mode
 * 
 *   ⚠️ You MUST use "rb" mode for reading encrypted .bin files!
 *      Encrypted data is binary and must be read in binary mode.
 *      Using "r" mode may corrupt data on some systems.
 * 
 * KEY INSIGHT:
 *   Since (A ⊕ B) ⊕ B = A, applying XOR twice returns original value
 *   This means encryption and decryption use the SAME operation!
 * 
 */

#include "encrypt.h"

int decryptFile(const char* inputFile, const char* outputFile, int** matrix, int size) {
    
    // TODO: Validate input parameters
    // Check for NULL pointers and valid size range
    
    
    // TODO: Open input file for reading (⚠️ BINARY mode "rb")
    // Check if fopen succeeded
    
    
    // TODO: Open output file for writing (text mode)
    // Check if fopen succeeded
    // If it fails, close input file first
    
    
    // TODO: Implement decryption loop
    // - Use fgetc() to read encrypted bytes
    // - Calculate matrix position (same as encryption)
    // - Track byte position (starts at 0, increments each byte)
    // - Apply XOR operation (same as encryption)
    // - Use fputc() to write decrypted bytes
    // - Handle fputc errors
    
    
    // TODO: Cleanup
    // Close both files
    
}