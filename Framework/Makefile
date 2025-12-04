# Space Mission System Makefile

CC = gcc
CFLAGS = -std=c17 -Wall -Wextra -Werror -g -O0
LDFLAGS = -lm
TARGET = encrypt
# Source files
SOURCES = encryptFile.c decryptFile.c driver.c

# Default target - builds the executable
all: $(TARGET)

# Build target
$(TARGET): $(SOURCES) encrypt.h
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES) $(LDFLAGS)

# Build only (same as all)
build: $(TARGET)

# Clean up generated files
clean:
	@echo "Cleaning up..."
	@rm -f $(TARGET) *.o STUDENT_OUTPUT*.txt *.key *.bin test_*.txt
	@echo "Cleanup complete."

# Rebuild everything from scratch
rebuild: clean all
	@echo "Build complete. Run './$(TARGET)' to execute."

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make           - Build the program (autograder compatible)"
	@echo "  make build     - Build the program"
	@echo "  make clean     - Remove generated files"
	@echo "  make rebuild   - Clean and rebuild"
	@echo "  make help      - Show this help message"

.PHONY: all build clean rebuild help