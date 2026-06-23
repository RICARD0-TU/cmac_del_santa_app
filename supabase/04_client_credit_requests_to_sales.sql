-- ============================================================================
-- Enviar solicitudes de App Clientes hacia Fuerza de Ventas
-- Ejecutar despues de 01_schema, 02_seed y 03_client_operations.
-- ============================================================================

create or replace function public.enviar_solicitud_cliente(
  p_monto numeric,
  p_plazo integer,
  p_destino text,
  p_cuota numeric
)
returns public.solicitudes_credito
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cliente_id uuid;
  v_asesor_id uuid;
  v_agencia_id uuid;
  v_solicitud public.solicitudes_credito;
begin
  v_cliente_id := public.cliente_actual_id();
  if v_cliente_id is null then
    raise exception 'Cliente no encontrado para el usuario autenticado';
  end if;

  if p_monto <= 0 then
    raise exception 'El monto debe ser mayor a cero';
  end if;

  if p_plazo <= 0 then
    raise exception 'El plazo debe ser mayor a cero';
  end if;

  select a.id, a.agencia_id
  into v_asesor_id, v_agencia_id
  from public.asesores a
  where a.activo = true
  order by a.created_at
  limit 1;

  if v_asesor_id is null then
    raise exception 'No existe asesor activo para asignar la solicitud';
  end if;

  insert into public.solicitudes_credito (
    cliente_id, asesor_id, agencia_id, canal, monto_solicitado,
    plazo_meses, destino_credito, cuota_estimada, estado, pendiente_sync
  )
  values (
    v_cliente_id, v_asesor_id, v_agencia_id, 'cliente', p_monto,
    p_plazo, p_destino, p_cuota, 'enviado', true
  )
  returning * into v_solicitud;

  insert into public.cartera_diaria (
    asesor_id, cliente_id, agencia_id, fecha_asignacion, tipo_gestion,
    prioridad, score_prioridad, monto_credito, estado_visita
  )
  values (
    v_asesor_id, v_cliente_id, v_agencia_id, current_date, 'NUEVA_SOLICITUD',
    'alta', 80, p_monto, 'pendiente'
  )
  on conflict (asesor_id, cliente_id, fecha_asignacion) do update set
    tipo_gestion = 'NUEVA_SOLICITUD',
    prioridad = 'alta',
    score_prioridad = greatest(public.cartera_diaria.score_prioridad, 80),
    monto_credito = excluded.monto_credito,
    estado_visita = 'pendiente',
    updated_at = now();

  insert into public.notificaciones (
    destinatario_tipo, asesor_id, cliente_id, titulo, cuerpo, tipo, data_json
  )
  values (
    'asesor', v_asesor_id, v_cliente_id,
    'Nueva solicitud desde App Clientes',
    'Un cliente envio una solicitud de credito para revision.',
    'solicitud_cliente',
    jsonb_build_object('solicitud_id', v_solicitud.id, 'monto', p_monto, 'plazo', p_plazo)
  );

  return v_solicitud;
end;
$$;

grant execute on function public.enviar_solicitud_cliente(numeric, integer, text, numeric) to authenticated;
