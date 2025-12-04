#!/bin/bash

# ===============================================================================
# XOR-BASED FILE ENCRYPTION SYSTEM BATCHGRADER
# This script processes all student submissions and generates grade files
# Author: Dr. Bhargav Bhatkalkar, KFSCIS, Florida International University  
# ===============================================================================

echo "=========================================================================="
echo "        XOR-Based Encryption System - Batch Grading"
echo "=========================================================================="
echo "Date: $(date)"
echo ""

# Check if autograder exists
if [ ! -f "autograder_encryption.sh" ]; then
    echo "❌ ERROR: autograder_encryption.sh not found!"
    exit 1
fi

# Check framework files
REQUIRED_FILES=("driver.c" "encrypt.h" "Makefile")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ ERROR: Required framework file '$file' not found!"
        exit 1
    fi
done

chmod +x autograder_encryption.sh

# Create results directory
RESULTS_DIR="GRADING_RESULTS"
mkdir -p "$RESULTS_DIR"

# Summary and log files
SUMMARY_FILE="$RESULTS_DIR/GRADING_SUMMARY.txt"
LOG_FILE="$RESULTS_DIR/batch_grading.log"

echo "XOR-Based Encryption System - Grading Summary" > "$SUMMARY_FILE"
echo "Generated: $(date)" >> "$SUMMARY_FILE"
echo "=================================================================" >> "$SUMMARY_FILE"
echo >> "$SUMMARY_FILE"

echo "Batch Grading Log - $(date)" > "$LOG_FILE"
echo "=================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# Counters
TOTAL_STUDENTS=0
SUCCESSFUL_GRADES=0
FAILED_GRADES=0
PERFECT_SCORES=0
COMPILATION_FAILURES=0

# Required student files
REQUIRED_C_FILES=("encryptFile.c" "decryptFile.c")

log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

extract_student_name() {
    local filename="$1"
    local base_name=$(basename "$filename" .zip)
    
    if [[ "$base_name" =~ ^[Aa]4[_\-\.]([A-Za-z]+[_\-\s]+[A-Za-z]+) ]]; then
        echo "${BASH_REMATCH[1]}" | tr '_-' ' '
    elif [[ "$base_name" =~ ^([A-Za-z]+[_\-\s]+[A-Za-z]+) ]]; then
        echo "${BASH_REMATCH[1]}" | tr '_-' ' '
    else
        echo "$base_name" | tr '_-' ' '
    fi
}

create_clean_name() {
    echo "$1" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

# Process ZIP files
shopt -s nullglob
zip_files=(*.zip)

if [ ${#zip_files[@]} -eq 0 ]; then
    echo "❌ No ZIP files found"
    exit 1
fi

log_message "Found ${#zip_files[@]} submission(s)"
log_message ""

for zip_file in "${zip_files[@]}"; do
    TOTAL_STUDENTS=$((TOTAL_STUDENTS + 1))
    
    STUDENT_NAME=$(extract_student_name "$zip_file")
    CLEAN_NAME=$(create_clean_name "$STUDENT_NAME")
    
    if [[ -z "$STUDENT_NAME" ]]; then
        STUDENT_NAME=$(basename "$zip_file" .zip)
        CLEAN_NAME=$(create_clean_name "$STUDENT_NAME")
    fi
    
    log_message "Processing: $STUDENT_NAME ($zip_file)"
    
    TEMP_DIR="temp_${CLEAN_NAME}_$$"
    mkdir -p "$TEMP_DIR"
    
    log_message "  📦 Extracting..."
    if ! unzip -q "$zip_file" -d "$TEMP_DIR" 2>/dev/null; then
        log_message "  ❌ Extraction failed"
        echo "$STUDENT_NAME: EXTRACTION_FAILED" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        rm -rf "$TEMP_DIR"
        continue
    fi
    
    log_message "  🔍 Searching for required files..."
    FOUND_FILES=()
    MISSING_FILES=()
    
    for required_file in "${REQUIRED_C_FILES[@]}"; do
        found_file=$(find "$TEMP_DIR" -name "$required_file" -type f | head -1)
        if [ -n "$found_file" ]; then
            FOUND_FILES+=("$required_file:$found_file")
            log_message "    ✅ Found: $required_file"
        else
            MISSING_FILES+=("$required_file")
            log_message "    ❌ Missing: $required_file"
        fi
    done
    
    if [ ${#MISSING_FILES[@]} -gt 0 ]; then
        log_message "  ❌ Missing files: ${MISSING_FILES[*]}"
        echo "$STUDENT_NAME: MISSING_FILES - ${MISSING_FILES[*]}" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        rm -rf "$TEMP_DIR"
        continue
    fi
    
    log_message "  📋 Copying files..."
    for file_info in "${FOUND_FILES[@]}"; do
        file_name=$(echo "$file_info" | cut -d':' -f1)
        file_path=$(echo "$file_info" | cut -d':' -f2)
        
        if ! cp "$file_path" "./$file_name"; then
            log_message "  ❌ Copy failed: $file_name"
            echo "$STUDENT_NAME: COPY_FAILED" >> "$SUMMARY_FILE"
            FAILED_GRADES=$((FAILED_GRADES + 1))
            rm -rf "$TEMP_DIR"
            continue 2
        fi
    done
    
    # Check for README file with flexible case-insensitive matching
    README_FOUND=false
    README_FILE_FOUND=""

    # Find any file with "readme" in name (case-insensitive)
    readme_candidates=$(find "$TEMP_DIR" -type f -iname "*readme*" 2>/dev/null)
    
    if [ -n "$readme_candidates" ]; then
        # Priority: PDF > DOCX > TXT > MD > No extension > Any other
        
        # Try PDF first
        found_readme=$(echo "$readme_candidates" | grep -i '\.pdf' | head -1)
        
        # Try DOCX
        if [ -z "$found_readme" ]; then
            found_readme=$(echo "$readme_candidates" | grep -i '\.docx' | head -1)
        fi
        
        # Try TXT
        if [ -z "$found_readme" ]; then
            found_readme=$(echo "$readme_candidates" | grep -i '\.txt' | head -1)
        fi
        
        # Try MD
        if [ -z "$found_readme" ]; then
            found_readme=$(echo "$readme_candidates" | grep -i '\.md' | head -1)
        fi
        
        # Try no extension (README, readme)
        if [ -z "$found_readme" ]; then
            found_readme=$(echo "$readme_candidates" | grep -iE '/readme$' | head -1)
        fi
        
        # # Take any file with readme in name
        # if [ -z "$found_readme" ]; then
        #     found_readme=$(echo "$readme_candidates" | head -1)
        # fi
        
        if [ -n "$found_readme" ]; then
            README_FOUND=true
            README_FILE_FOUND="$found_readme"
            log_message "    ✅ Found README: $(basename "$README_FILE_FOUND")"
        fi
    fi
    
    if [ "$README_FOUND" = false ]; then
        log_message "  ❌ ERROR: Missing README file"
        echo "$STUDENT_NAME: MISSING_README - No README file found" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        rm -rf "$TEMP_DIR"
        echo ""
        continue
    fi
    
    
    # Create grade report
    GRADE_FILE="$RESULTS_DIR/${CLEAN_NAME}_Grade.txt"
    log_message "  🎯 Running autograder..."
    
    {
        echo "=========================================================================="
        echo "              GRADE REPORT FOR: $STUDENT_NAME"
        echo "=========================================================================="
        echo "Submission: $zip_file"
        echo "Graded: $(date)"
        echo ""
    } > "$GRADE_FILE"
    
    # Run autograder
    AUTOGRADER_OUTPUT=$(timeout 30 ./autograder_encryption.sh 2>&1)
    AUTOGRADER_EXIT_CODE=$?
    
    echo "$AUTOGRADER_OUTPUT" >> "$GRADE_FILE"
    
    if [ $AUTOGRADER_EXIT_CODE -eq 0 ]; then
        log_message "  ✅ Grading completed"
        
        AUTOGRADER_TOTAL=$(echo "$AUTOGRADER_OUTPUT" | grep "AUTOGRADER TOTAL:" | grep -o '[0-9]\+/[0-9]\+' | head -1)
        PERCENTAGE=$(echo "$AUTOGRADER_OUTPUT" | grep "AUTOGRADER PERCENTAGE:" | grep -o '[0-9]\+%' | head -1)
        
        if [ -n "$AUTOGRADER_TOTAL" ]; then
            echo "$STUDENT_NAME: $AUTOGRADER_TOTAL ($PERCENTAGE)" >> "$SUMMARY_FILE"
            log_message "  📊 Score: $AUTOGRADER_TOTAL ($PERCENTAGE)"
            
            if [[ "$PERCENTAGE" == "100%" ]]; then
                PERFECT_SCORES=$((PERFECT_SCORES + 1))
            fi
        fi
        
        SUCCESSFUL_GRADES=$((SUCCESSFUL_GRADES + 1))
        
    elif [ $AUTOGRADER_EXIT_CODE -eq 124 ]; then
        log_message "  ⏱️  Timeout"
        echo "$STUDENT_NAME: TIMEOUT" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
    else
        log_message "  ❌ Code error"
        echo "$STUDENT_NAME: CODE_ERROR" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    for file in "${REQUIRED_C_FILES[@]}"; do
        rm -f "$file" 2>/dev/null
    done
    rm -f STUDENT_OUTPUT.txt encrypt *.o ENCRYPTED.bin OUTPUT.txt 2>/dev/null
    
    log_message "  💾 Grade saved: $GRADE_FILE"
    log_message ""
done

# Final statistics
echo >> "$SUMMARY_FILE"
echo "=================================================================" >> "$SUMMARY_FILE"
echo "                    GRADING STATISTICS" >> "$SUMMARY_FILE"
echo "=================================================================" >> "$SUMMARY_FILE"
echo "Total Students: $TOTAL_STUDENTS" >> "$SUMMARY_FILE"
echo "Successfully Graded: $SUCCESSFUL_GRADES" >> "$SUMMARY_FILE"
echo "Failed: $FAILED_GRADES" >> "$SUMMARY_FILE"
echo "Perfect Scores: $PERFECT_SCORES" >> "$SUMMARY_FILE"
echo "Compilation Failures: $COMPILATION_FAILURES" >> "$SUMMARY_FILE"

if [ $TOTAL_STUDENTS -gt 0 ]; then
    echo "Success Rate: $(( (SUCCESSFUL_GRADES * 100) / TOTAL_STUDENTS ))%" >> "$SUMMARY_FILE"
fi

echo "=========================================================================="
echo "                    BATCH GRADING COMPLETE"
echo "=========================================================================="
echo "📊 Total: $TOTAL_STUDENTS"
echo "✅ Successful: $SUCCESSFUL_GRADES"
echo "❌ Failed: $FAILED_GRADES"
echo "🌟 Perfect: $PERFECT_SCORES"
echo "📁 Results: $RESULTS_DIR/"
echo "=========================================================================="

exit 0
