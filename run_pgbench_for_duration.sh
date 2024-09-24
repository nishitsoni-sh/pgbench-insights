#!/bin/bash

# Load environment variables from config file
if [[ -f "./pgbench_env.conf" ]]; then
  source ./pgbench_env.conf
else
  echo "Environment config file pgbench_env.conf not found!"
  exit 1
fi

# Validate parameters
if [[ -z "$1" || -z "$2" || "$1" -le 0 || "$2" -le 0 ]]; then
  echo "Usage: $0 <number_of_clients> <duration_in_seconds>"
  exit 1
fi

# Capture parameters
CLIENTS=$1
DURATION=$2
CSV_FILE="sql_weights.csv"

# Check if CSV file exists
if [[ ! -f $CSV_FILE ]]; then
  echo "CSV file $CSV_FILE not found!"
  exit 1
fi

# Generate a timestamp for the log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="log/pgbench_output_${TIMESTAMP}.log"

# Initialize the pgbench command using environment variables
PGBENCH_CMD="pgbench -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -n -c $CLIENTS -T $DURATION"

# Read the CSV file and construct the pgbench command
while IFS=',' read -r table_name file_name weight
do
  # Skip empty lines or lines that start with a comment
  [[ -z "$table_name" || "$table_name" =~ ^# ]] && continue

  # Construct the full path for the SQL file
  sql_file_path="sql_statements/${table_name}/${file_name}"

  # Check if the SQL file exists
  if [[ ! -f $sql_file_path ]]; then
    echo "SQL file $sql_file_path not found! Skipping..." | tee -a "$LOG_FILE"
    continue
  fi

  # Append each SQL file with its weight to the pgbench command
  PGBENCH_CMD+=" -f ${sql_file_path}@${weight}"
done < "$CSV_FILE"

# Append output redirection to the command
PGBENCH_CMD+=" > \"$LOG_FILE\" 2>&1"

# Log and execute the constructed command
echo "Running load testing with $CLIENTS clients for $DURATION seconds on host $PGHOST" | tee -a "$LOG_FILE"
echo "Command: $PGBENCH_CMD" | tee -a "$LOG_FILE"
eval $PGBENCH_CMD

# Capture the exit status
EXIT_STATUS=$?

# Log the end of the load test
if [ $EXIT_STATUS -eq 0 ]; then
  echo "Load testing completed successfully" | tee -a "$LOG_FILE"
else
  echo "Load testing failed with exit status $EXIT_STATUS" | tee -a "$LOG_FILE"
fi