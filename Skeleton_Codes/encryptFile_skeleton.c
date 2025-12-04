/*
 * encryptFile() - Student Implementation Templete 
 * 
 * Encrypt a plaintext file using XOR cipher with matrix-based key
 * 
 * PARAMETERS:
 *   inputFile  - Plaintext input filename
 *   outputFile - Encrypted output filename (.bin file)
 *   matrix     - 2D encryption key matrix (pre-loaded)
 *   size       - Matrix dimension (2, 3, or 4)
 * 
 * RETURNS:
 *   SUCCESS (1) on successful encryption
 *   FAILURE (0) on any error
 * 
 * REQUIREMENTS:
 *   - Validate all input parameters
 *   - Process file byte-by-byte using fgetc/fputc
 *   - Apply XOR operation with matrix values
 *   - Handle errors and cleanup properly
 * 
 * CRITICAL FILE MODES (⚠️ MANDATORY):
 *   Input:  fopen(inputFile, "r")   - Text read mode
 *   Output: fopen(outputFile, "wb") - BINARY WRITE MODE (REQUIRED!)
 * 
 *   ⚠️ You MUST use "wb" mode for encrypted output file!
 *      Encrypted data is binary and must be written in binary mode.
 *      Using "w" mode will corrupt the encrypted data.
 * 
 */

#include "encrypt.h"

int encryptFile(const char* inputFile, const char* outputFile, int** matrix, int size) {
    
    // TODO: Validate input parameters
    // Check for NULL pointers and valid size range
    
    
    // TODO: Open input file for reading (text mode)
    // Check if fopen succeeded
    
    
    // TODO: Open output file for writing (⚠️ BINARY mode "wb")
    // Check if fopen succeeded
    // If it fails, close input file first
    
    
    // TODO: Implement encryption loop
    // - Use fgetc() to read bytes
    // - Calculate matrix position for each byte
    // - Track byte position (starts at 0, increments each byte)
    // - Apply XOR operation
    // - Use fputc() to write encrypted bytes
    // - Handle fputc errors
    
    
    // TODO: Cleanup
    // Close both files
}