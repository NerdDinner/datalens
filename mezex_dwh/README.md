pip install pandas sqlalchemy psycopg2-binary

C:/Users/user/AppData/Local/Programs/Python/Python314/python.exe -m pip install pg8000


Восстановление на новом месте
docker exec -i datalens-postgres psql -U pg-user -d pg-meta-manager-db < datalens_meta_manager.sql
docker exec -i datalens-postgres psql -U pg-user -d pg-auth-db < datalens_auth.sql
docker exec -i datalens-postgres psql -U pg-user -d pg-us-db < datalens_us.sql