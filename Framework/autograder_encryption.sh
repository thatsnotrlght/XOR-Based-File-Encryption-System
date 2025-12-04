#!/bin/bash

# ===============================================================================
# XOR-BASED FILE ENCRYPTION SYSTEM AUTOGRADER
# This script processes individual student submission
# Author: Dr. Bhargav Bhatkalkar, KFSCIS, Florida International University 
# ===============================================================================

echo "=========================================="
echo "  Encryption System Autograder"
echo "=========================================="
echo ""

# Initialize total scores
total_simple=0
total_moderate=0
total_rigorous=0

# Step 1: Check required files
echo "🔍 Checking required files..."
required_files=("encrypt.h" "encryptFile.c" "decryptFile.c" "driver.c")

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    echo "❌ ERROR: Missing files: ${missing_files[*]}"
    exit 1
fi

echo "✅ All required files found"

# Step 2: Build using Makefile
echo "🔨 Building encryption system..."
rm -f encrypt *.o ENCRYPTED.bin OUTPUT.txt 2>/dev/null

# Check if Makefile exists
if [ ! -f "Makefile" ] && [ ! -f "makefile" ]; then
    echo "❌ Makefile not found - 0 points awarded"
    echo ""
    echo "=========================================="
    echo "           AUTOGRADER RESULTS"
    echo "=========================================="
    echo "Compilation:              FAILED (no Makefile)"
    echo "Simple Test:              0/20 points"
    echo "Moderate Test:            0/30 points"
    echo "Rigorous Test:            0/40 points"
    echo "----------------------------------------"
    echo "AUTOGRADER TOTAL:         0/90 points"
    echo "AUTOGRADER PERCENTAGE:    0%"
    echo "=========================================="
    exit 1
fi

# Clean and build
if make clean >/dev/null 2>&1 && make 2>compile_errors.txt; then
    chmod +x encrypt 2>/dev/null
    echo "✅ Compilation successful"
    rm -f compile_errors.txt
else
    echo "❌ Compilation failed - 0 points awarded"
    echo "Compilation errors:"
    cat compile_errors.txt | head -20
    rm -f compile_errors.txt
    echo ""
    echo "=========================================="
    echo "           AUTOGRADER RESULTS"
    echo "=========================================="
    echo "Compilation:              FAILED"
    echo "Simple Test:              0/20 points"
    echo "Moderate Test:            0/30 points"
    echo "Rigorous Test:            0/40 points"
    echo "----------------------------------------"
    echo "AUTOGRADER TOTAL:         0/90 points"
    echo "AUTOGRADER PERCENTAGE:    0%"
    echo "=========================================="
    exit 1
fi

# Check if executable was created
if [ ! -f "encrypt" ]; then
    echo "❌ ERROR: encrypt executable not created by Makefile"
    exit 1
fi

echo ""

# ===============================================================================
# HELPER FUNCTIONS
# ===============================================================================

# Extract function results
extract_result() {
    local function_prefix="$1"
    local file="$2"
    
    if [[ ! -f "$file" ]]; then
        echo ""
        return
    fi
    
    grep "^${function_prefix}" "$file" 2>/dev/null || echo ""
}

# Compare outputs
compare_outputs() {
    local student_data="$1"
    local expected_data="$2"
    
    if [[ -z "$expected_data" ]]; then
        echo "0"
        return
    fi
    
    if [[ -z "$student_data" ]]; then
        echo "0"
        return
    fi
    
    local -a expected_lines
    local -a student_lines
    
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ -n "$line" ]]; then
            expected_lines+=("$line")
        fi
    done <<< "$expected_data"
    
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ -n "$line" ]]; then
            student_lines+=("$line")
        fi
    done <<< "$student_data"
    
    if [[ ${#student_lines[@]} -ne ${#expected_lines[@]} ]]; then
        echo "0"
        return
    fi
    
    if [[ ${#expected_lines[@]} -eq 0 ]]; then
        echo "100"
        return
    fi
    
    local correct_count=0
    for ((i=0; i<${#expected_lines[@]}; i++)); do
        if [[ "${student_lines[i]}" == "${expected_lines[i]}" ]]; then
            correct_count=$((correct_count + 1))
        fi
    done
    
    local percentage=$(( (correct_count * 100) / ${#expected_lines[@]} ))
    echo "$percentage"
}

# Show differences
show_differences() {
    local student_data="$1"
    local expected_data="$2"
    local function_name="$3"
    
    echo ""
    echo "   🔍 DETAILED ANALYSIS for $function_name:"
    echo "   =========================================="
    
    local -a expected_lines
    local -a student_lines
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            expected_lines+=("$line")
        fi
    done <<< "$expected_data"
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            student_lines+=("$line")
        fi
    done <<< "$student_data"
    
    echo "   📊 EXPECTED OUTPUT (${#expected_lines[@]} lines):"
    for i in "${!expected_lines[@]}"; do
        printf "   %2d: %s\n" $((i+1)) "${expected_lines[i]}"
    done
    
    echo ""
    echo "   📊 YOUR OUTPUT (${#student_lines[@]} lines):"
    for i in "${!student_lines[@]}"; do
        printf "   %2d: %s\n" $((i+1)) "${student_lines[i]}"
    done
    
    echo ""
    echo "   🔍 LINE-BY-LINE COMPARISON:"
    
    local max_lines=${#expected_lines[@]}
    if [[ ${#student_lines[@]} -gt $max_lines ]]; then
        max_lines=${#student_lines[@]}
    fi
    
    local mismatches=0
    
    for ((i=0; i<max_lines; i++)); do
        local expected_line="${expected_lines[i]:-}"
        local student_line="${student_lines[i]:-}"
        
        if [[ "$expected_line" == "$student_line" ]]; then
            printf "   %2d: ✅ MATCH\n" $((i+1))
        else
            printf "   %2d: ❌ DIFF\n" $((i+1))
            printf "        Expected: '%s'\n" "$expected_line"
            printf "        Your:     '%s'\n" "$student_line"
            mismatches=$((mismatches + 1))
        fi
    done
    
    echo ""
    echo "   📈 SUMMARY: $mismatches mismatches out of $max_lines lines"
    
    if [[ $mismatches -gt 0 ]]; then
        echo "   💡 DEBUGGING HINTS:"
        case $function_name in
            "ENCRYPT")
                echo "      - Check XOR operation: encrypted = plain ^ matrix[row][col]"
                echo "      - Verify matrix position: row = (i/size)%size, col = i%size"
                echo "      - Ensure fputc() writes to binary file"
                echo "      - Check byte-by-byte processing with fgetc()"
                ;;
            "DECRYPT")
                echo "      - Decryption uses SAME XOR operation as encryption"
                echo "      - Check matrix position calculation matches encryption"
                echo "      - Ensure input file opened in binary mode (rb)"
                echo "      - Verify output matches original input exactly"
                ;;
        esac
    fi
    
    echo "   =========================================="
    echo ""
}

# ===============================================================================
# FUNCTION: Test a single level
# ===============================================================================
test_level() {
    local TEST_LEVEL="$1"
    local MAX_POINTS="$2"
    
    echo "=========================================="
    echo "  Testing: $TEST_LEVEL (Max: $MAX_POINTS points)"
    echo "=========================================="
    
    local TESTCASE_FILE="Testcases/$TEST_LEVEL/testcases_${TEST_LEVEL}.txt"
    local EXPECTED_FILE="Testcases/$TEST_LEVEL/EXPECTED_OUTPUT.txt"
    local input_file=""
    
    # Determine input file
    if [ "$TEST_LEVEL" == "simple" ]; then
        input_file="Testcases/simple/INPUT1.txt"
    elif [ "$TEST_LEVEL" == "moderate" ]; then
        input_file="Testcases/moderate/INPUT2.txt"
    elif [ "$TEST_LEVEL" == "rigorous" ]; then
        input_file="Testcases/rigorous/INPUT3.txt"
    fi
    
    # Check test files exist
    if [ ! -f "$TESTCASE_FILE" ]; then
        echo "❌ ERROR: Test file not found: $TESTCASE_FILE"
        return 0
    fi
    
    if [ ! -f "$EXPECTED_FILE" ]; then
        echo "❌ ERROR: Expected output file not found: $EXPECTED_FILE"
        return 0
    fi
    
    if [ ! -f "$input_file" ]; then
        echo "❌ ERROR: Input file not found: $input_file"
        return 0
    fi
    
    # Clean previous test outputs
    rm -f ENCRYPTED.bin OUTPUT.txt STUDENT_OUTPUT.txt STUDENT_OUTPUT_RAW.txt 2>/dev/null
    
    echo "🚀 Running $TEST_LEVEL test..."
    
    # Generate student output with timeout protection
    if timeout 30 ./encrypt "$TESTCASE_FILE" > STUDENT_OUTPUT_RAW.txt 2>&1; then
        echo "✅ Encryption system executed"
        # Remove trailing newline
        printf '%s' "$(cat STUDENT_OUTPUT_RAW.txt)" > STUDENT_OUTPUT.txt
        rm STUDENT_OUTPUT_RAW.txt
    else
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo "❌ System timed out (possible infinite loop)"
        else
            echo "❌ System crashed or failed"
        fi
        echo "Score: 0/$MAX_POINTS points"
        echo "=========================================="
        echo ""
        return 0
    fi
    
    echo ""
    
    # Initialize scores for this level
    local encrypt_score=0
    local decrypt_score=0
    local encrypt_match=0
    local decrypt_match=0
    
    # Grade ENCRYPT output
    echo "   Testing encryptFile()..."
    local student_encrypt=$(extract_result "ENCRYPT" "STUDENT_OUTPUT.txt")
    local expected_encrypt=$(extract_result "ENCRYPT" "$EXPECTED_FILE")
    
    if [[ -n "$expected_encrypt" ]]; then
        if [[ -n "$student_encrypt" ]]; then
            encrypt_match=$(compare_outputs "$student_encrypt" "$expected_encrypt")
            encrypt_score=$(( (MAX_POINTS * encrypt_match) / 200 ))  # Half the points
        else
            encrypt_match=0
            encrypt_score=0
        fi
    else
        encrypt_match=0
        encrypt_score=0
    fi
    
    if [[ $encrypt_match -eq 100 ]]; then
        echo "   ✅ encryptFile: Perfect output match"
    elif [[ $encrypt_match -ge 80 ]]; then
        echo "   🟡 encryptFile: Good output match ($encrypt_match%)"
        show_differences "$student_encrypt" "$expected_encrypt" "ENCRYPT"
    else
        echo "   ❌ encryptFile: Output mismatch ($encrypt_match%)"
        show_differences "$student_encrypt" "$expected_encrypt" "ENCRYPT"
    fi
    
    # Grade DECRYPT output
    echo "   Testing decryptFile()..."
    local student_decrypt=$(extract_result "DECRYPT" "STUDENT_OUTPUT.txt")
    local expected_decrypt=$(extract_result "DECRYPT" "$EXPECTED_FILE")
    
    if [[ -n "$expected_decrypt" ]]; then
        if [[ -n "$student_decrypt" ]]; then
            decrypt_match=$(compare_outputs "$student_decrypt" "$expected_decrypt")
            decrypt_score=$(( (MAX_POINTS * decrypt_match) / 200 ))  # Half the points
        else
            decrypt_match=0
            decrypt_score=0
        fi
    else
        decrypt_match=0
        decrypt_score=0
    fi
    
    if [[ $decrypt_match -eq 100 ]]; then
        echo "   ✅ decryptFile: Perfect output match"
    elif [[ $decrypt_match -ge 80 ]]; then
        echo "   🟡 decryptFile: Good output match ($decrypt_match%)"
        show_differences "$student_decrypt" "$expected_decrypt" "DECRYPT"
    else
        echo "   ❌ decryptFile: Output mismatch ($decrypt_match%)"
        show_differences "$student_decrypt" "$expected_decrypt" "DECRYPT"
    fi
    
    # Check VERIFY result
    local student_verify=$(extract_result "VERIFY:SUCCESS" "STUDENT_OUTPUT.txt")
    if [[ -n "$student_verify" ]]; then
        echo "   ✅ VERIFY: Files match - encryption/decryption cycle successful!"
    else
        echo "   ⚠️  VERIFY: Files don't match - decryption may not be correct"
    fi
    
    echo ""
    echo "🔍 Verifying Actual Files (Anti-Cheat Check)..."
    
    # STRONG ANTI-CHEAT CHECK 1: ENCRYPTED.bin exists
    if [ ! -f "ENCRYPTED.bin" ]; then
        echo "   ❌ ENCRYPTED.bin not created - encryptFile() may be hardcoded"
        encrypt_score=0
    else
        echo "   ✅ ENCRYPTED.bin created"
        
        # STRONG ANTI-CHEAT CHECK 2: ENCRYPTED.bin is NOT identical to input
        if diff -q "$input_file" "ENCRYPTED.bin" >/dev/null 2>&1; then
            echo "   ❌ ENCRYPTED.bin identical to input - NO ENCRYPTION PERFORMED!"
            encrypt_score=0
        else
            echo "   ✅ ENCRYPTED.bin differs from input - encryption performed"
            
            # Check not empty
            local enc_size=$(wc -c < "ENCRYPTED.bin" 2>/dev/null || echo 0)
            if [ "$enc_size" -eq 0 ]; then
                echo "   ❌ ENCRYPTED.bin is empty"
                encrypt_score=0
            else
                echo "   ✅ ENCRYPTED.bin has content ($enc_size bytes)"
            fi
        fi
    fi
    
    # STRONG ANTI-CHEAT CHECK 3: OUTPUT.txt matches INPUT exactly
    if [ ! -f "OUTPUT.txt" ]; then
        echo "   ❌ OUTPUT.txt not created - decryptFile() may be hardcoded"
        decrypt_score=0
    else
        echo "   ✅ OUTPUT.txt created"
        
        # Byte-by-byte comparison
        if diff -q "$input_file" "OUTPUT.txt" >/dev/null 2>&1; then
            echo "   ✅ OUTPUT.txt matches INPUT - decryption verified!"
        else
            echo "   ❌ OUTPUT.txt does NOT match INPUT - decryption failed!"
            echo ""
            echo "   First 5 lines of INPUT:"
            head -5 "$input_file" 2>/dev/null | sed 's/^/      /'
            echo ""
            echo "   First 5 lines of OUTPUT:"
            head -5 "OUTPUT.txt" 2>/dev/null | sed 's/^/      /'
            decrypt_score=0
        fi
    fi
    
    # Calculate total score for this level
    local level_score=$((encrypt_score + decrypt_score))
    
    echo ""
    echo "📊 $TEST_LEVEL Test Score: $level_score/$MAX_POINTS points"
    echo "=========================================="
    echo ""
    
    return $level_score
}

# ===============================================================================
# RUN ALL THREE TEST LEVELS
# ===============================================================================

echo "🧪 Starting comprehensive testing (all 3 levels)..."
echo ""

# Test 1: Simple (20 points)
test_level "simple" 20
total_simple=$?

# Test 2: Moderate (30 points)
test_level "moderate" 30
total_moderate=$?

# Test 3: Rigorous (40 points)
test_level "rigorous" 40
total_rigorous=$?

# Calculate final totals
total_score=$((total_simple + total_moderate + total_rigorous))
max_total=90
percentage=$(( (total_score * 100) / max_total ))

# ===============================================================================
# FINAL RESULTS
# ===============================================================================

echo ""
echo "=========================================="
echo "         FINAL AUTOGRADER RESULTS"
echo "=========================================="
echo "Simple Test:              $total_simple/20 points"
echo "Moderate Test:            $total_moderate/30 points"
echo "Rigorous Test:            $total_rigorous/40 points"
echo "----------------------------------------"
echo "AUTOGRADER TOTAL:         $total_score/90 points"
echo "AUTOGRADER PERCENTAGE:    $percentage%"
echo "----------------------------------------"
echo "Manual Grading:           /10 points (Code Quality, Comments, README)"
echo "FINAL TOTAL:              /100 points"
echo "=========================================="

echo ""

# Grade classification
if [[ $total_score -eq 90 ]]; then
    echo "🎉 PERFECT! All tests passed!"
elif [[ $total_score -ge 72 ]]; then
    echo "🌟 EXCELLENT! Outstanding implementation!"
elif [[ $total_score -ge 63 ]]; then
    echo "👍 VERY GOOD! Strong implementation!"
elif [[ $total_score -ge 54 ]]; then
    echo "✅ GOOD! Solid work!"
elif [[ $total_score -ge 45 ]]; then
    echo "⚠️  SATISFACTORY! Needs improvement!"
else
    echo "❌ NEEDS SIGNIFICANT WORK!"
fi

echo ""

if [[ -f "STUDENT_OUTPUT.txt" ]]; then
    echo "📄 Debug files available for review"
fi

echo ""

# Exit with appropriate code
if [[ $percentage -ge 70 ]]; then
    exit 0
else
    exit 1
fi