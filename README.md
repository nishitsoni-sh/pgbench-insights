# pgbench Load Testing

## Overview

This project provides a setup to perform load testing on the PostgreSQL database of insights, using `pgbench`. It enables custom SQL scripts with weighted execution to simulate real-world scenarios.

## Project Structure

- **`run_pgbench.sh`**: Main script to execute the load tests.
- **`sql_weights.csv`**: Defines the SQL files and their respective weights for the test.
- **`sql_statements/`**: Directory containing SQL scripts categorized by table name.
- **`log/`**: Directory storing output logs from the `pgbench` runs.

## Usage

1. **Setup**: Ensure PostgreSQL is setup. `pgbench` comes with the package.
2. **Prepare SQL Files**: Place SQL scripts in the corresponding directories under `sql_statements/`.
3. **Edit `sql_weights.csv`**: Define the table name, SQL file, and weight for each query.

4. **Run the Test**:

   ```bash
   ./run_pgbench.sh <number_of_clients> <duration_in_seconds>
   ```
   For e.g.
   ```bash
   ./run_pgbench.sh 10 60
   ```
5. **Review Logs**: Check the log/ directory for detailed output.

