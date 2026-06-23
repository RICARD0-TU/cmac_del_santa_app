-- ============================================================================
-- Operaciones simples para App Clientes CMAC Del Santa
-- Ejecutar despues de 01_schema y 02_seed.
-- ============================================================================

create or replace function public.cliente_actual_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select c.id
  from public.clientes c
  where c.user_id = auth.uid()
  limit 1;
$$;

create or replace function public.registrar_transferencia_cliente(
  p_cuenta_origen_id uuid,
  p_destino text,
  p_monto numeric,
  p_tipo text default 'transferencia'
)
returns public.operaciones_cliente
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cliente_id uuid;
  v_saldo numeric(12,2);
  v_operacion public.operaciones_cliente;
  v_cod text;
begin
  v_cliente_id := public.cliente_actual_id();
  if v_cliente_id is null then
    raise exception 'Cliente no encontrado para el usuario autenticado';
  end if;

  if p_monto <= 0 then
    raise exception 'El monto debe ser mayor a cero';
  end if;

  select saldo_disponible
  into v_saldo
  from public.cr_cuentas_ahorro
  where id = p_cuenta_origen_id and cliente_id = v_cliente_id and estado = 'activa'
  for update;

  if v_saldo is null then
    raise exception 'Cuenta origen no encontrada';
  end if;

  if v_saldo < p_monto then
    raise exception 'Saldo insuficiente';
  end if;

  update public.cr_cuentas_ahorro
  set saldo_disponible = saldo_disponible - p_monto,
      saldo_contable = saldo_contable - p_monto,
      updated_at = now()
  where id = p_cuenta_origen_id;

  v_cod := 'APP-' || replace(gen_random_uuid()::text, '-', '');

  insert into public.operaciones_cliente (
    cliente_id, cuenta_origen_id, cuenta_destino_texto, tipo,
    beneficiario, concepto, monto, estado, cod_operacion_core
  )
  values (
    v_cliente_id, p_cuenta_origen_id, p_destino,
    case when p_tipo = 'pago_servicio' then 'pago_servicio' else 'transferencia' end,
    p_destino,
    case when p_tipo = 'pago_servicio' then 'Pago de servicio' else 'Transferencia desde app cliente' end,
    p_monto, 'confirmada', v_cod
  )
  returning * into v_operacion;

  insert into public.cr_movimientos (
    cod_operacion, cliente_id, cuenta_ahorro_id, tipo, concepto, canal,
    monto, saldo_posterior, fecha_operacion
  )
  select v_cod, v_cliente_id, p_cuenta_origen_id, 'DEB',
    case when p_tipo = 'pago_servicio' then 'Pago de servicio: ' || p_destino else 'Transferencia: ' || p_destino end,
    'APP', p_monto, saldo_disponible, now()
  from public.cr_cuentas_ahorro
  where id = p_cuenta_origen_id;

  return v_operacion;
end;
$$;

create or replace function public.pagar_cuota_cliente(
  p_cuenta_origen_id uuid,
  p_credito_id uuid,
  p_cuota_id uuid
)
returns public.operaciones_cliente
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cliente_id uuid;
  v_saldo numeric(12,2);
  v_monto numeric(12,2);
  v_nro_cuota integer;
  v_operacion public.operaciones_cliente;
  v_cod text;
begin
  v_cliente_id := public.cliente_actual_id();
  if v_cliente_id is null then
    raise exception 'Cliente no encontrado para el usuario autenticado';
  end if;

  select saldo_disponible
  into v_saldo
  from public.cr_cuentas_ahorro
  where id = p_cuenta_origen_id and cliente_id = v_cliente_id and estado = 'activa'
  for update;

  if v_saldo is null then
    raise exception 'Cuenta origen no encontrada';
  end if;

  select monto_cuota, nro_cuota
  into v_monto, v_nro_cuota
  from public.cr_cronograma_pagos
  where id = p_cuota_id
    and credito_id = p_credito_id
    and estado_cuota in ('pendiente', 'vencida')
  for update;

  if v_monto is null then
    raise exception 'Cuota pendiente no encontrada';
  end if;

  if not exists (
    select 1 from public.cr_creditos
    where id = p_credito_id and cliente_id = v_cliente_id
  ) then
    raise exception 'Credito no pertenece al cliente';
  end if;

  if v_saldo < v_monto then
    raise exception 'Saldo insuficiente';
  end if;

  update public.cr_cuentas_ahorro
  set saldo_disponible = saldo_disponible - v_monto,
      saldo_contable = saldo_contable - v_monto,
      updated_at = now()
  where id = p_cuenta_origen_id;

  update public.cr_cronograma_pagos
  set estado_cuota = 'pagada',
      fecha_pago = current_date
  where id = p_cuota_id;

  update public.cr_creditos
  set saldo_total = greatest(saldo_total - v_monto, 0),
      cuotas_pagadas = cuotas_pagadas + 1,
      fecha_proximo_pago = (
        select min(fecha_vencimiento)
        from public.cr_cronograma_pagos
        where credito_id = p_credito_id and estado_cuota in ('pendiente', 'vencida')
      ),
      updated_at = now()
  where id = p_credito_id;

  v_cod := 'APP-' || replace(gen_random_uuid()::text, '-', '');

  insert into public.operaciones_cliente (
    cliente_id, cuenta_origen_id, credito_id, tipo, beneficiario,
    concepto, monto, estado, cod_operacion_core
  )
  values (
    v_cliente_id, p_cuenta_origen_id, p_credito_id, 'pago_cuota',
    'Credito cuota ' || v_nro_cuota,
    'Pago de cuota ' || v_nro_cuota,
    v_monto, 'confirmada', v_cod
  )
  returning * into v_operacion;

  insert into public.cr_movimientos (
    cod_operacion, cliente_id, cuenta_ahorro_id, credito_id, tipo, concepto,
    canal, monto, saldo_posterior, fecha_operacion
  )
  select v_cod, v_cliente_id, p_cuenta_origen_id, p_credito_id, 'DEB',
    'Pago cuota ' || v_nro_cuota, 'APP', v_monto, saldo_disponible, now()
  from public.cr_cuentas_ahorro
  where id = p_cuenta_origen_id;

  return v_operacion;
end;
$$;

grant execute on function public.cliente_actual_id() to authenticated;
grant execute on function public.registrar_transferencia_cliente(uuid, text, numeric, text) to authenticated;
grant execute on function public.pagar_cuota_cliente(uuid, uuid, uuid) to authenticated;
