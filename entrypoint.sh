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
    echo "❌ ERROR: Falló la creación del schema. Revisa 01_crear_schema.sql."
    exit 1
  fi

  # --- PASO 2: Crear las Tablas ---
  echo "--> Ejecutando 02_crear_tablas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/02_crear_tablas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de tablas. Revisa 02_crear_tablas.sql."
    exit 1
  fi

  # --- PASO 3: Crear Roles (solo creación de roles) ---
  echo "--> Ejecutando 03_crear_roles_only.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/03_crear_roles.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de roles. Revisa 03_crear_roles_only.sql."
    exit 1
  fi

  # --- PASO 4: Crear y compilar el Trigger de Logon del sistema ---
  echo "--> Ejecutando 04_trigger_logon.sql como SYS (AS SYSDBA)..."
  sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba @/app/sql/04_trigger_logon.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación/compilación del trigger de logon. Revisa 04_trigger_logon.sql."
    exit 1
  fi

  # --- PASO 5: Insertar las Tiendas Iniciales ---
  echo "--> Ejecutando 05_insertar_tiendas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/05_insertar_tiendas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la inserción de tiendas. Revisa 05_insertar_tiendas.sql."
    exit 1
  fi

  # --- PASO 6: Crear Procedimientos Almacenados ---
  echo "--> Ejecutando 06_procedimientos.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/06_procedimientos.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de procedimientos. Revisa 06_procedimientos.sql."
    exit 1
  fi

  # --- PASO 7: Insertar Usuarios Vendedores (los roles ya existen del Paso 3) ---
  echo "--> Ejecutando 07_insertar_usuarios_vendedores.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/07_insertar_usuarios_vendedores.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la inserción de usuarios vendedores. Revisa 07_insertar_usuarios_vendedores.sql."
    exit 1
  fi

  # --- PASO 8: Optimización e Implementación de Vistas (RLS y DW) ---
  echo "--> Ejecutando 08_optimizar_vistas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/08_optimizar_vistas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la optimización de vistas. Revisa 08_optimizar_vistas.sql."
    exit 1
  fi

  # --- PASO 8.5: Asignar Permisos a Roles (ahora que las vistas existen) ---
  echo "--> Ejecutando 13_grant.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/13_grant.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la asignación de permisos sobre vistas. Revisa 13_grant.sql."
    exit 1
  fi

  # --- PASO 9: Crear Índices y Planes de Ejecución ---
  echo "--> Ejecutando 09_index_plan.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/09_index_plan.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de índices/planes. Revisa 09_index_plan.sql."
    exit 1
  fi

  # --- PASO 10: Crear Triggers (Funcionales y DW) ---
  echo "--> Ejecutando 10_triggers.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/10_triggers.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de triggers. Revisa 10_triggers.sql."
    exit 1
  fi

  # --- PASO 11: Poblar Usuarios (Clientes Comunes) ---
  echo "--> Ejecutando 11_poblar_usuarios.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/11_poblar_usuarios.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló el poblamiento de usuarios. Revisa 11_poblar_usuarios.sql."
    exit 1
  fi

  # --- PASO 12: Poblar Pedidos y Productos Aleatorios ---
  echo "--> Ejecutando 12_poblar_pedidos_productos.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/12_poblar_pedidos_productos.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló el poblamiento de pedidos/productos. Revisa 12_poblar_pedidos_productos.sql."
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
