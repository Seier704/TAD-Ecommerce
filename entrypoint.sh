# Script de inicialización automático para la base de datos.

# Esperamos un momento para asegurarnos de que la BD esté receptiva 😏.
sleep 10

echo "--- Verificando estado del schema ECOMMERCE_FRAMEWORK... ---"

# Usamos SQL*Plus para PREGUNTAR si el usuario existe.
# El resultado lo guardamos en una variable.
USER_EXISTS=$(sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba <<EOF
  set heading off feedback off pagesize 0 verify off;
  select 'EXISTE' from dba_users where username = 'ECOMMERCE_FRAMEWORK';
  exit;
EOF
)

# Ahora, en la seguridad de nuestro script bash, tomamos la decisión.
# El -z "$USER_EXISTS" comprueba si la variable está vacía (o sea, si el usuario NO existe).
if [[ -z "$USER_EXISTS" ]]; then
  echo "--- Schema no encontrado. Iniciando creación por primera vez... ---"
  
  # --- PASO 1: Crear el Schema (Usuario ECOMMERCE_FRAMEWORK y sus permisos) ---
  echo "--> Ejecutando 01_crear_schema.sql como SYS..."
  sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba @/app/sql/01_crear_schema.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación del schema 😰. Revisa 01_crear_schema.sql."
    exit 1
  fi

  # --- PASO 2: Crear las Tablas (y el GRANT SELECT a SYS sobre USUARIOS) ---
  echo "--> Ejecutando 02_crear_tablas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/02_crear_tablas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de tablas 😭. Revisa 02_crear_tablas.sql."
    exit 1
  fi

  # --- PASO 3: Crear y compilar el Trigger de Logon del sistema ---
  # Este paso debe ejecutarse como SYSDBA y después de que 02_crear_tablas.sql haya creado la tabla USUARIOS
  # y otorgado el GRANT SELECT a SYS sobre ella.
  echo "--> Ejecutando 03_trigger_logon.sql como SYS (AS SYSDBA)..."
  sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba @/app/sql/03_trigger_logon.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación/compilación del trigger de logon 🚨. Revisa 03_trigger_logon.sql."
    exit 1
  fi

  # --- PASO 4: Insertar las Tiendas Iniciales ---
  echo "--> Ejecutando 04_insertar_tiendas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/04_insertar_tiendas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la inserción de tiendas. Revisa 04_insertar_tiendas.sql."
    exit 1
  fi

  # --- PASO 5: Crear Procedimientos Almacenados (ej. crear_usuario_aplicacion) ---
  echo "--> Ejecutando 05_procedimientos.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/05_procedimientos.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de procedimientos. Revisa 05_procedimientos.sql."
    exit 1
  fi

  # --- PASO 6: Insertar Usuarios Vendedores (llamando al procedimiento) ---
  echo "--> Ejecutando 06_insertar_usuarios_vendedores.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/06_insertar_usuarios_vendedores.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la inserción de usuarios vendedores. Revisa 06_insertar_usuarios_vendedores.sql."
    exit 1
  fi

  echo ""
    echo "✅ ¡Listaylor! ✅"
    echo "La base de datos ha sido inicializada y está lista para usarse. 😈"
    echo "Puedes conectarte con el usuario: ECOMMERCE_FRAMEWORK"
    echo "Pero la contraseña no te la puedo decir. 😭"

else
  # Si la variable USER_EXISTS tenía algo, significa que el usuario ya estaba.
  echo "--- El schema ya existe. No se hará nada. ---"
  echo "✅ ¡Listaylor! ✅"
  echo "La base de datos ha sido inicializada y está lista para usarse. 😈"
  echo "Puedes conectarte con el usuario: ECOMMERCE_FRAMEWORK"
  echo "Pero la contraseña no te la puedo decir. 😭"
fi