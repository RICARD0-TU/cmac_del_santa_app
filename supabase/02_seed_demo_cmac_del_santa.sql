-- ============================================================================
-- Seed demo CMAC Del Santa
-- Ejecutar despues de 01_schema_cmac_del_santa.sql.
-- Luego crea usuarios en Supabase Auth y vincula clientes/asesores con los UPDATE
-- del final de este archivo.
-- ============================================================================

with agencia as (
  select id from public.agencias where cod_agencia = 'AGS-CHIMBOTE' limit 1
),
cliente_1 as (
  insert into public.clientes (
    cod_cliente, tipo_documento, numero_documento, nombres, apellidos,
    fecha_nacimiento, estado_civil, telefono, email, direccion, distrito,
    provincia, tipo_negocio, nombre_negocio, direccion_negocio,
    antiguedad_negocio_meses, ingresos_estimados, lat_negocio, lng_negocio,
    calificacion_sbs, es_prospecto
  )
  values (
    'CLI-000001', 'DNI', '72000001', 'Mariela', 'Salazar Rios',
    '1988-04-12', 'Casada', '943210111', 'mariela.salazar@example.com',
    'Jr. Manuel Ruiz 420', 'Chimbote', 'Santa', 'Bodega',
    'Bodega Santa Rosa', 'Av. Jose Pardo 1220 - Chimbote',
    72, 6200.00, -9.0738000, -78.5919000, 'Normal', false
  )
  on conflict (numero_documento) do update set
    nombres = excluded.nombres,
    apellidos = excluded.apellidos
  returning id
),
cliente_2 as (
  insert into public.clientes (
    cod_cliente, tipo_documento, numero_documento, nombres, apellidos,
    fecha_nacimiento, estado_civil, telefono, email, direccion, distrito,
    provincia, tipo_negocio, nombre_negocio, direccion_negocio,
    antiguedad_negocio_meses, ingresos_estimados, lat_negocio, lng_negocio,
    calificacion_sbs, es_prospecto
  )
  values (
    'CLI-000002', 'DNI', '72000002', 'Carlos', 'Mendoza Vega',
    '1991-09-24', 'Soltero', '943210222', 'carlos.mendoza@example.com',
    'Urb. Buenos Aires Mz. H Lt. 8', 'Nuevo Chimbote', 'Santa',
    'Restaurante', 'Cevicheria El Puerto', 'Av. Pacifico 500 - Nuevo Chimbote',
    38, 8900.00, -9.1199000, -78.5204000, 'CPP', false
  )
  on conflict (numero_documento) do update set
    nombres = excluded.nombres,
    apellidos = excluded.apellidos
  returning id
),
asesor_1 as (
  insert into public.asesores (
    agencia_id, cod_asesor, codigo_empleado, nombres, apellidos, perfil, zona
  )
  select id, 'ASE-0001', '1001', 'Luis', 'Herrera Campos', 'operador', 'Chimbote Centro'
  from agencia
  on conflict (codigo_empleado) do update set
    nombres = excluded.nombres,
    apellidos = excluded.apellidos
  returning id, agencia_id
),
ahorro_producto as (
  select id from public.productos_financieros where codigo = 'AHO-CORRIENTE' limit 1
),
credito_producto as (
  select id from public.productos_financieros where codigo = 'CRE-NEGOCIO' limit 1
),
cuenta_1 as (
  insert into public.cr_cuentas_ahorro (
    cod_cuenta_ahorro, cliente_id, producto_id, alias, tipo_cuenta,
    saldo_disponible, saldo_contable, saldo_interes, cci, tea, estado
  )
  select 'AHO-001-000001', cliente_1.id, ahorro_producto.id, 'Mi ahorro principal',
    'Ahorro Corriente', 3580.75, 3580.75, 12.35, '803001720000010000000011', 0.80, 'activa'
  from cliente_1, ahorro_producto
  on conflict (cod_cuenta_ahorro) do update set
    saldo_disponible = excluded.saldo_disponible,
    saldo_contable = excluded.saldo_contable
  returning id, cliente_id
),
credito_1 as (
  insert into public.cr_creditos (
    cod_cuenta_credito, cliente_id, producto_id, producto, monto_desembolsado,
    saldo_capital, saldo_total, cuota_mensual, dias_mora, calificacion_interna,
    estado, fecha_desembolso, fecha_proximo_pago, tea, cuotas_total, cuotas_pagadas
  )
  select 'CRE-001-000001', cliente_1.id, credito_producto.id, 'Credi Negocio',
    8000.00, 5300.00, 5750.00, 545.90, 0, 'A', 'vigente',
    current_date - 180, current_date + 12, 32.50, 18, 7
  from cliente_1, credito_producto
  on conflict (cod_cuenta_credito) do update set
    saldo_capital = excluded.saldo_capital,
    saldo_total = excluded.saldo_total,
    cuotas_pagadas = excluded.cuotas_pagadas
  returning id, cliente_id
),
preaprobado_1 as (
  insert into public.creditos_preaprobados (
    cliente_id, asesor_id, segmento, score_transaccional, monto_hipotesis,
    plazo_sugerido_meses, tea_referencial, ingreso_promedio_cuenta, estado
  )
  select cliente_1.id, asesor_1.id, 'PREMIER', 710, 5000.00, 12, 31.50, 5200.00, 'preaprobado'
  from cliente_1, asesor_1
  on conflict do nothing
  returning id, cliente_id, asesor_id
)
insert into public.cartera_diaria (
  asesor_id, cliente_id, agencia_id, preaprobado_id, fecha_asignacion,
  tipo_gestion, prioridad, score_prioridad, monto_credito
)
select asesor_1.id, cliente_1.id, asesor_1.agencia_id, preaprobado_1.id, current_date,
  'RENOVACION', 'alta', 92, 5000.00
from asesor_1, cliente_1, preaprobado_1
on conflict (asesor_id, cliente_id, fecha_asignacion) do nothing;

insert into public.cr_cronograma_pagos (
  credito_id, nro_cuota, fecha_vencimiento, monto_cuota,
  monto_capital, monto_interes, monto_mora, saldo, estado_cuota, fecha_pago
)
select cr.id, v.nro_cuota, v.fecha_vencimiento, v.monto_cuota,
  v.monto_capital, v.monto_interes, v.monto_mora, v.saldo, v.estado_cuota, v.fecha_pago
from public.cr_creditos cr
cross join (
  values
    (1, current_date - 150, 545.90, 390.00, 155.90, 0.00, 7610.00, 'pagada', current_date - 149),
    (2, current_date - 120, 545.90, 402.00, 143.90, 0.00, 7208.00, 'pagada', current_date - 119),
    (3, current_date - 90, 545.90, 415.00, 130.90, 0.00, 6793.00, 'pagada', current_date - 88),
    (4, current_date - 60, 545.90, 428.00, 117.90, 0.00, 6365.00, 'pagada', current_date - 60),
    (5, current_date - 30, 545.90, 442.00, 103.90, 0.00, 5923.00, 'pagada', current_date - 29),
    (6, current_date, 545.90, 456.00, 89.90, 0.00, 5467.00, 'pendiente', null),
    (7, current_date + 30, 545.90, 471.00, 74.90, 0.00, 4996.00, 'pendiente', null),
    (8, current_date + 60, 545.90, 486.00, 59.90, 0.00, 4510.00, 'pendiente', null)
) as v(nro_cuota, fecha_vencimiento, monto_cuota, monto_capital, monto_interes, monto_mora, saldo, estado_cuota, fecha_pago)
where cr.cod_cuenta_credito = 'CRE-001-000001'
on conflict (credito_id, nro_cuota) do nothing;

insert into public.cr_movimientos (
  cod_operacion, cliente_id, cuenta_ahorro_id, tipo, concepto, canal,
  monto, saldo_posterior, fecha_operacion
)
select *
from (
  select 'MOV-000001' as cod_operacion, c.id as cliente_id, a.id as cuenta_ahorro_id,
    'CRE' as tipo, 'Deposito en agencia' as concepto, 'CAJA' as canal,
    1200.00 as monto, 3580.75 as saldo_posterior, now() - interval '2 days' as fecha_operacion
  from public.clientes c join public.cr_cuentas_ahorro a on a.cliente_id = c.id
  where c.numero_documento = '72000001' and a.cod_cuenta_ahorro = 'AHO-001-000001'
  union all
  select 'MOV-000002', c.id, a.id, 'DEB', 'Pago cuota Credi Negocio', 'APP',
    545.90, 2380.75, now() - interval '8 days'
  from public.clientes c join public.cr_cuentas_ahorro a on a.cliente_id = c.id
  where c.numero_documento = '72000001' and a.cod_cuenta_ahorro = 'AHO-001-000001'
  union all
  select 'MOV-000003', c.id, a.id, 'TRF', 'Transferencia a tercero', 'APP',
    250.00, 2926.65, now() - interval '13 days'
  from public.clientes c join public.cr_cuentas_ahorro a on a.cliente_id = c.id
  where c.numero_documento = '72000001' and a.cod_cuenta_ahorro = 'AHO-001-000001'
) m
on conflict (cod_operacion) do nothing;

insert into public.tarjetas (
  cliente_id, numero_enmascarado, marca, tipo, moneda, saldo_utilizado, estado
)
select id, '**** **** **** 2048', 'Visa', 'debito', 'PEN', 0, 'activa'
from public.clientes
where numero_documento = '72000001'
on conflict do nothing;

insert into public.notificaciones (
  destinatario_tipo, cliente_id, titulo, cuerpo, tipo, data_json
)
select 'cliente', id, 'Tu cronograma esta actualizado',
  'Ya puedes revisar las proximas cuotas de tu Credi Negocio.',
  'cronograma', '{"modulo":"creditos"}'::jsonb
from public.clientes
where numero_documento = '72000001'
on conflict do nothing;

-- ============================================================================
-- Vinculacion con Supabase Auth
-- ============================================================================
-- 1. En Supabase Dashboard > Authentication > Users, crea:
--    cliente.demo@cmacdelsanta.test  / password de prueba
--    asesor.demo@cmacdelsanta.test   / password de prueba
-- 2. Copia cada UUID de auth.users y ejecuta estos UPDATE reemplazando los IDs.
--
-- insert into public.profiles (id, role, nombres, apellidos, documento, telefono, email)
-- values ('UUID_AUTH_CLIENTE', 'cliente', 'Mariela', 'Salazar Rios', '72000001', '943210111', 'cliente.demo@cmacdelsanta.test')
-- on conflict (id) do update set role = excluded.role, documento = excluded.documento;
--
-- update public.clientes
-- set user_id = 'UUID_AUTH_CLIENTE'
-- where numero_documento = '72000001';
--
-- insert into public.profiles (id, role, nombres, apellidos, documento, telefono, email)
-- values ('UUID_AUTH_ASESOR', 'asesor', 'Luis', 'Herrera Campos', '1001', '943210999', 'asesor.demo@cmacdelsanta.test')
-- on conflict (id) do update set role = excluded.role, documento = excluded.documento;
--
-- update public.asesores
-- set user_id = 'UUID_AUTH_ASESOR'
-- where codigo_empleado = '1001';
