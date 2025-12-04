/*####################################################
   HEADER FILE
   👀 Students please don't modify this file! 
####################################################*/

#ifndef ENCRYPT_H
#define ENCRYPT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ========================================
 * SYSTEM CONSTANTS AND LIMITS
 * ======================================== */
#define MIN_MATRIX_SIZE 2
#define MAX_MATRIX_SIZE 8
#define SUCCESS 1
#define FAILURE 0

#define MAX_FILENAME_LENGTH 256
#define MAX_LINE_LENGTH 1024

/* ========================================
 * STUDENT FUNCTION PROTOTYPES
 * 👀 Students implement only these 2 functions
 * ======================================== */

/* FUNCTION 1: File Encryption
 * Encrypt plaintext file using XOR with matrix values
 * Uses character-by-character I/O (fgetc/fputc)
 * Returns: SUCCESS or FAILURE
 */
int encryptFile(const char* inputFile, const char* outputFile, int** matrix, int size);

/* FUNCTION 2: File Decryption
 * Decrypt ciphertext file using XOR with matrix values
 * Uses character-by-character I/O (fgetc/fputc)
 * Returns: SUCCESS or FAILURE
 * Note: XOR encryption is symmetric - same operation as encryption!
 */
int decryptFile(const char* inputFile, const char* outputFile, int** matrix, int size);

/* ========================================
 * UTILITY FUNCTIONS (PROVIDED IN DRIVER)
 * ⚠️Students don't implement these
 * ======================================== */
int** allocateMatrix(int size);
void freeMatrix(int** matrix, int size);
int loadMatrixFromFile(const char* filename, int*** matrix, int* size);
void printMatrix(int** matrix, int size, const char* name);
int verifyFiles(const char* file1, const char* file2);

#endif /* ENCRYPT_H */
