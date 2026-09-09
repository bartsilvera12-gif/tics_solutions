-- =====================================================================
--  Tic's Solutions — 011: dejar escribir el registro de actividad
-- =====================================================================
--  La tabla audit_logs existia desde el principio y la pantalla Actividad
--  la leia, pero nadie escribia nunca: la unica politica era de lectura.
--  La pantalla mostraba "sin movimientos" para siempre.
--
--  Se permite insertar, no modificar ni borrar. Un registro que se puede
--  editar despues no sirve para lo que existe: contar que paso. Lo mismo
--  con el borrado, que ademas dejaria huecos sin explicacion.
--
--  Quien escribe queda fijado por la base y no por el navegador: el
--  admin_user_id tiene que ser el de quien esta con la sesion abierta. Sin
--  esa condicion, una persona podria firmar un cambio con el nombre de otra.
-- =====================================================================

drop policy if exists admin_escritura on ticspy.audit_logs;
create policy admin_escritura on ticspy.audit_logs
  for insert with check (
    ticspy.is_admin() and admin_user_id = auth.uid()
  );
