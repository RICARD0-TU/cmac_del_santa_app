-- ============================================================================
-- Politicas de escritura necesarias para App Clientes
-- Ejecutar despues de 01_schema.
-- ============================================================================

drop policy if exists notificaciones_update_owner on public.notificaciones;
create policy notificaciones_update_owner on public.notificaciones
for update
using (
  exists (
    select 1
    from public.clientes c
    where c.id = cliente_id
      and c.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.clientes c
    where c.id = cliente_id
      and c.user_id = auth.uid()
  )
);
