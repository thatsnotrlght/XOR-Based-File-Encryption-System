## 1. Team & Contact Information

Group Members:
	* Samuel Artiste


---

## 2. Compilation & Execution Notes

Programming Environment:
	- Ocelot Server connection: ssh yourname@ocelot-bbhatkal.aul.fiu.edu
	- Compilation Command: The provided Makefile should be used.
	- Build Command: 'make' (Compiles all .c files into the 'encrypt' executable)
	- Execution Command: './encrypt'

---

## 3. Program Features & Implementation Details

This project implements a simplified symmetric encryption scheme using the XOR cipher and a matrix-based key stream, focusing on byte-by-byte file I/O and bitwise operations.

Core Functions Implemented:
	- **Key Stream Generation (encrypt):** Calculates cyclic matrix positions using the byte counter i and matrix dimension size: row = (i / size) % size and col = i % size.
	- **Encrypt Core logic:** Performs the encryption using the bitwise XOR operation: Cipher = Plaintext XOR Key
	- **Decrypt Core logic:** Uses the identical XOR operation as encryption (Plaintext = Ciphertext XOR Key) due to XOR's self-inverse property, ensuring perfect decryption.
	- **File I/O (encrypt):** Reading plaintext input in Text Mode and writes ciphertext output in Binary Write Mode
	- **File I/O (decrypt):** Reading encrypted input in Binary Read Mode to prevent data corruption and writes decrypted output in Text Mode.
	- **Defensive Programming:** Comprehensive validation of all input parameters (NULL checks, matrix size range check)

