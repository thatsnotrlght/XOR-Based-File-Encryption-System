/*####################################################
   DRIVER FILE - Complete Framework
   👀 Students please don't modify this file!
####################################################*/

#include "encrypt.h"

/* ========================================
 * UTILITY FUNCTION IMPLEMENTATIONS
 * ======================================== */

int** allocateMatrix(int size) {
    int** matrix = (int**)malloc(size * sizeof(int*));
    if (matrix == NULL) return NULL;
    
    for (int i = 0; i < size; i++) {
        matrix[i] = (int*)malloc(size * sizeof(int));
        if (matrix[i] == NULL) {
            for (int j = 0; j < i; j++) {
                free(matrix[j]);
            }
            free(matrix);
            return NULL;
        }
    }
    return matrix;
}

void freeMatrix(int** matrix, int size) {
    if (matrix == NULL) return;
    for (int i = 0; i < size; i++) {
        if (matrix[i] != NULL) {
            free(matrix[i]);
        }
    }
    free(matrix);
}

int loadMatrixFromFile(const char* filename, int*** matrix, int* size) {
    if (filename == NULL || matrix == NULL || size == NULL) {
        return FAILURE;
    }
    
    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "ERROR: Cannot open key file: %s\n", filename);
        return FAILURE;
    }
    
    if (fscanf(file, "%d", size) != 1) {
        fclose(file);
        return FAILURE;
    }
    
    if (*size < MIN_MATRIX_SIZE || *size > MAX_MATRIX_SIZE) {
        fclose(file);
        return FAILURE;
    }
    
    *matrix = allocateMatrix(*size);
    
    if (*matrix == NULL) {
        fclose(file);
        return FAILURE;
    }
    
    for (int i = 0; i < *size; i++) {
        for (int j = 0; j < *size; j++) {
            if (fscanf(file, "%d", &((*matrix)[i][j])) != 1) {
                freeMatrix(*matrix, *size);
                *matrix = NULL;
                fclose(file);
                return FAILURE;
            }
        }
    }
    
    fclose(file);
    return SUCCESS;
}

void printMatrix(int** matrix, int size, const char* name) {
    if (matrix == NULL) return;
    printf("%s:\n", name);
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printf("%3d ", matrix[i][j]);
        }
        printf("\n");
    }
}

int verifyFiles(const char* file1, const char* file2) {
    FILE* f1 = fopen(file1, "r");
    FILE* f2 = fopen(file2, "r");
    
    if (f1 == NULL || f2 == NULL) {
        if (f1) fclose(f1);
        if (f2) fclose(f2);
        return FAILURE;
    }
    
    int ch1, ch2;
    int match = SUCCESS;
    
    while ((ch1 = fgetc(f1)) != EOF) {
        ch2 = fgetc(f2);
        if (ch1 != ch2) {
            match = FAILURE;
            break;
        }
    }
    
    if (fgetc(f2) != EOF) {
        match = FAILURE;
    }
    
    fclose(f1);
    fclose(f2);
    return match;
}

/* ========================================
 * COMMAND EXECUTION
 * ======================================== */

int executeCommand(char* command) {
    char cmd[20];
    char inputFile[MAX_FILENAME_LENGTH];
    char keyFile[MAX_FILENAME_LENGTH];
    char outputFile[MAX_FILENAME_LENGTH];
    
    int numTokens = sscanf(command, "%s %s %s %s", cmd, inputFile, keyFile, outputFile);
    
    // VERIFY only needs 3 tokens (cmd, file1, file2)
    if (strcmp(cmd, "VERIFY") == 0) {
        if (numTokens < 3) {
            return FAILURE;
        }
        
        printf("VERIFY_START\n");
        printf("VERIFY:Comparing %s and %s\n", inputFile, keyFile);
        
        int result = verifyFiles(inputFile, keyFile);
        
        if (result == SUCCESS) {
            printf("VERIFY:Files match - Decryption successful!\n");
            printf("VERIFY:SUCCESS\n");
        } else {
            printf("VERIFY:Files do not match - Decryption failed!\n");
            printf("VERIFY:FAILURE\n");
        }
        printf("VERIFY_END\n");
        return result;
    }
    
    // ENCRYPT and DECRYPT need 4 tokens
    if (numTokens < 4) {
        return FAILURE;
    }
    
    int** matrix = NULL;
    int size = 0;
    
    if (loadMatrixFromFile(keyFile, &matrix, &size) != SUCCESS) {
        printf("LOAD_KEY:FAILURE - Could not load key file: %s\n", keyFile);
        return FAILURE;
    }
    
    int result = FAILURE;
    
    if (strcmp(cmd, "ENCRYPT") == 0) {
        printf("ENCRYPT_START\n");
        printf("ENCRYPT:Input=%s Key=%s Output=%s Size=%d\n", inputFile, keyFile, outputFile, size);
        
        result = encryptFile(inputFile, outputFile, matrix, size);
        
        if (result == SUCCESS) {
            printf("ENCRYPT:SUCCESS\n");
        } else {
            printf("ENCRYPT:FAILURE\n");
        }
        printf("ENCRYPT_END\n");
        
    } else if (strcmp(cmd, "DECRYPT") == 0) {
        printf("DECRYPT_START\n");
        printf("DECRYPT:Input=%s Key=%s Output=%s Size=%d\n", inputFile, keyFile, outputFile, size);
        
        result = decryptFile(inputFile, outputFile, matrix, size);
        
        if (result == SUCCESS) {
            printf("DECRYPT:SUCCESS\n");
        } else {
            printf("DECRYPT:FAILURE\n");
        }
        printf("DECRYPT_END\n");
    }
    
    freeMatrix(matrix, size);
    
    return result;
}

/* ========================================
 * TEST RUNNER
 * ======================================== */

void runTestFile(const char* testFile) {
    FILE* file = fopen(testFile, "r");
    if (file == NULL) {
        fprintf(stderr, "ERROR: Cannot open test file: %s\n", testFile);
        return;
    }
    
    printf("========================================\n");
    printf("Running Test File: %s\n", testFile);
    printf("========================================\n\n");
    
    char line[MAX_LINE_LENGTH];
    int commandNum = 0;
    
    while (fgets(line, sizeof(line), file) != NULL) {
        if (line[0] == '#' || line[0] == '\n') {
            continue;
        }
        
        line[strcspn(line, "\n")] = 0;
        
        commandNum++;
        printf("--- Command %d: %s ---\n", commandNum, line);
        executeCommand(line);
        printf("\n");
    }
    
    fclose(file);
    
    printf("========================================\n");
    printf("Test File Complete: %s\n", testFile);
    printf("========================================\n\n");
}

/* ========================================
 * MAIN FUNCTION
 * ======================================== */

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <testcases_file>\n", argv[0]);
        printf("Example: %s Testcases/simple/testcases_simple.txt\n", argv[0]);
        return 1;
    }
    
    printf("========================================\n");
    printf("XOR-Based Encryption System\n");
    printf("========================================\n\n");
    
    runTestFile(argv[1]);
    
    return 0;
}
