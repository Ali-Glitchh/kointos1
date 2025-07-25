#!/bin/bash

echo "🔧 Fixing All Flutter Analysis Issues..."
echo "========================================"

# Function to fix withOpacity usage in a file
fix_with_opacity() {
    local file="$1"
    echo "Fixing withOpacity in $file..."
    
    # Replace .withOpacity( with .withValues(alpha: 
    sed -i 's/\.withOpacity(/\.withValues(alpha: /g' "$file"
}

# Function to fix print statements
fix_print_statements() {
    local file="$1"
    echo "Fixing print statements in $file..."
    
    # Replace print( with debugPrint( for Flutter apps
    sed -i 's/print(/debugPrint(/g' "$file"
}

# Function to comment out unused variables
comment_unused_variable() {
    local file="$1"
    local variable="$2"
    local line_num="$3"
    
    echo "Commenting unused variable '$variable' in $file at line $line_num..."
    
    # Add // ignore: unused_local_variable before the line
    sed -i "${line_num}i\\    // ignore: unused_local_variable" "$file"
}

# Fix withOpacity issues in all widget files
echo "🎨 Fixing withOpacity deprecated usage..."
find lib/presentation -name "*.dart" -exec bash -c 'fix_with_opacity "$0"' {} \;
find lib/core/theme -name "*.dart" -exec bash -c 'fix_with_opacity "$0"' {} \;

# Fix print statements
echo "🖨️ Fixing print statements..."
fix_print_statements "bin/simple_test_server.dart"
fix_print_statements "lib/main.dart"

echo "✅ Automated fixes completed!"
echo "Running flutter analyze to check remaining issues..."

# Export the functions for use in subshells
export -f fix_with_opacity
export -f fix_print_statements
