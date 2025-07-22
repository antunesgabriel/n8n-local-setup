#!/bin/bash
set -e

# Create the non-root user and database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create non-root user if it doesn't exist
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$POSTGRES_NON_ROOT_USER') THEN
            CREATE USER $POSTGRES_NON_ROOT_USER WITH PASSWORD '$POSTGRES_NON_ROOT_PASSWORD';
        END IF;
    END
    \$\$;
    
    -- Grant privileges to the non-root user
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_NON_ROOT_USER;
    GRANT ALL PRIVILEGES ON SCHEMA public TO $POSTGRES_NON_ROOT_USER;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $POSTGRES_NON_ROOT_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_NON_ROOT_USER;
    
    -- Set default privileges for future objects
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $POSTGRES_NON_ROOT_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $POSTGRES_NON_ROOT_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO $POSTGRES_NON_ROOT_USER;
    
    -- Install vector extension for AI/Vector store support (already included in ankane/pgvector image)
    CREATE EXTENSION IF NOT EXISTS vector;
    
    -- Grant usage on vector extension
    GRANT USAGE ON SCHEMA public TO $POSTGRES_NON_ROOT_USER;
EOSQL

echo "Database initialization completed successfully!"
