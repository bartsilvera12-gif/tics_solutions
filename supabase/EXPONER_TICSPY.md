# Exponer el schema `ticspy` en PostgREST

Sin este paso el panel no puede leer ni escribir nada: PostgREST rechaza
cualquier consulta a `ticspy` con `PGRST106 · Invalid schema`.

No se puede hacer desde SQL en esta instancia. La lista de schemas la manda el
entorno de PostgREST, no el rol `authenticator`; escribirla con `ALTER ROLE`
**pisa** la del entorno y deja sin API a los más de cien proyectos que
comparten `api.neura.com.py`. Ya pasó una vez y se revirtió.

---

## 1. Dónde entrar

El servidor donde corre Supabase autoalojado. `api.neura.com.py` está detrás
de Cloudflare, así que hay que entrar por SSH al host real, no por el dominio.
La base responde en `187.77.247.54:6432`; el host de Supabase suele ser el
mismo, pero confirmalo con quien administra la infraestructura.

## 2. Qué archivo editar

El `.env` de la instalación de Supabase, el mismo que lee el
`docker-compose.yml`. Ubicación habitual:

```
/opt/supabase/docker/.env
```

Si no está ahí:

```bash
find / -name "docker-compose.yml" -path "*supabase*" 2>/dev/null
```

## 3. Nombre exacto de la variable

```
PGRST_DB_SCHEMAS
```

En algunas versiones del `docker-compose.yml` de Supabase la variable aparece
como `PGRST_DB_SCHEMAS: ${PGRST_DB_SCHEMAS}` dentro del servicio `rest`. Si
está escrita literal en el compose y no en el `.env`, hay que editarla ahí.

## 4. Respaldo antes de tocar nada

```bash
cp /opt/supabase/docker/.env /opt/supabase/docker/.env.bak.$(date +%F)
grep PGRST_DB_SCHEMAS /opt/supabase/docker/.env > ~/pgrst_db_schemas.anterior.txt
```

El valor actual completo, tal como lo devuelve PostgREST hoy, está en este
repositorio:

- `supabase/PGRST_DB_SCHEMAS.anterior.txt` — 118 schemas, valor a restaurar
- `supabase/PGRST_DB_SCHEMAS.nuevo.txt` — los mismos 118 más `ticspy`

La única diferencia entre los dos archivos es una línea: `ticspy` al final.

## 5. Cómo debe quedar

**No reemplazar la lista.** Agregar `,ticspy` al final del valor que ya está:

```
PGRST_DB_SCHEMAS=public, storage, graphql_public, tradexpar, ... , maxingpy, asl, dymaerp, vhconstrucciones, mc_store,ticspy
```

El contenido exacto está en `supabase/PGRST_DB_SCHEMAS.nuevo.txt`. Se puede
pegar entero después del `=`.

## 6. Qué servicio reiniciar

Solo PostgREST. **No** reiniciar PostgreSQL ni el resto del stack.

```bash
cd /opt/supabase/docker
docker compose up -d --force-recreate rest
```

El servicio se llama `rest` (imagen `postgrest/postgrest`). Si el compose de
esa instalación lo nombra distinto:

```bash
docker compose ps
```

## 7. Verificación

Los proyectos existentes tienen que seguir respondiendo 200:

```bash
ANON="<anon key>"
for s in public maxingpy herratec charme skvagency asunhome; do
  printf "%-12s " "$s"
  curl -s -o /dev/null -w "%{http_code}\n" \
    -H "apikey: $ANON" -H "Accept-Profile: $s" \
    https://api.neura.com.py/rest/v1/
done
```

Y `ticspy` tiene que pasar a responder:

```bash
curl -s -H "apikey: $ANON" -H "Accept-Profile: ticspy" \
  "https://api.neura.com.py/rest/v1/pages?select=route&limit=3"
```

Antes del cambio devuelve `PGRST106`. Después tiene que devolver un arreglo
JSON con las rutas del sitio.

## 8. Rollback

Si algo responde mal:

```bash
cp /opt/supabase/docker/.env.bak.<fecha> /opt/supabase/docker/.env
docker compose up -d --force-recreate rest
```

---

## Lo que ya está hecho del lado de la base

Los permisos no hay que tocarlos: la migración `005_ticspy_expose_schema.sql`
ya los aplicó y están verificados.

- `usage` sobre el schema para `anon`, `authenticated` y `service_role`
- `select` para `anon` y `authenticated`
- `insert`, `update`, `delete` para `authenticated`
- `execute` sobre `ticspy.is_admin()` e `is_super_admin()`
- privilegios por defecto para las tablas que se creen más adelante

Quién puede leer o escribir cada fila lo sigue decidiendo RLS, no estos
permisos.
