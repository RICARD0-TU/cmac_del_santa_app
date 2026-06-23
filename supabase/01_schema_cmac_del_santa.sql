-- ============================================================================
-- CMAC Del Santa - bd_core_mobile para Supabase
-- App Clientes + App Fuerza de Ventas + Core Web
-- Ejecutar en Supabase SQL Editor sobre un proyecto nuevo.
-- ============================================================================

create extension if not exists pgcrypto;
-- ============================================================================
-- Helpers
-- ============================================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ============================================================================
-- Identidad, roles y catalogos
-- ============================================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('cliente','asesor','supervisor','administrador')),
  nombres text not null,
  apellidos text not null,
  documento text unique,
  telefono text,
  email text,
  avatar_url text,
  activo boolean not null default true,
  intentos_fallidos integer not null default 0,
  bloqueado_hasta timestamptz,
  ultimo_acceso timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.is_role(required_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = any(required_roles)
      and p.activo = true
  );
$$;

create table if not exists public.agencias (
  id uuid primary key default gen_random_uuid(),
  cod_agencia text unique not null,
  nombre text not null,
  region text,
  direccion text,
  telefono text,
  lat numeric(10,7),
  lng numeric(10,7),
  activa boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.asesores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete set null,
  agencia_id uuid references public.agencias(id),
  cod_asesor text unique,
  codigo_empleado text unique not null,
  nombres text not null,
  apellidos text not null,
  perfil text not null default 'operador'
    check (perfil in ('operador','super_operador','supervisor','administrador')),
  zona text,
  token_fcm text,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clientes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete set null,
  cod_cliente text unique,
  tipo_documento text not null default 'DNI' check (tipo_documento in ('DNI','RUC','CE')),
  numero_documento text unique not null,
  nombres text not null,
  apellidos text not null,
  fecha_nacimiento date,
  estado_civil text,
  telefono text,
  email text,
  direccion text,
  distrito text,
  provincia text,
  departamento text default 'Ancash',
  tipo_negocio text,
  nombre_negocio text,
  direccion_negocio text,
  antiguedad_negocio_meses integer,
  ingresos_estimados numeric(12,2),
  lat_negocio numeric(10,7),
  lng_negocio numeric(10,7),
  calificacion_sbs text default 'Normal'
    check (calificacion_sbs in ('Normal','CPP','Deficiente','Dudoso','Perdida')),
  es_prospecto boolean not null default false,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.productos_financieros (
  id uuid primary key default gen_random_uuid(),
  codigo text unique not null,
  categoria text not null check (categoria in ('ahorro','credito','servicio','seguro','tarjeta')),
  segmento text,
  nombre text not null,
  descripcion text,
  moneda text not null default 'PEN',
  tea_min numeric(7,2),
  tea_max numeric(7,2),
  monto_min numeric(12,2),
  monto_max numeric(12,2),
  plazo_min_meses integer,
  plazo_max_meses integer,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

-- ============================================================================
-- Espejo del core financiero para App Clientes
-- ============================================================================

create table if not exists public.cr_cuentas_ahorro (
  id uuid primary key default gen_random_uuid(),
  cod_cuenta_ahorro text unique not null,
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  producto_id uuid references public.productos_financieros(id),
  alias text,
  tipo_cuenta text not null,
  moneda text not null default 'PEN',
  saldo_disponible numeric(12,2) not null default 0,
  saldo_contable numeric(12,2) not null default 0,
  saldo_interes numeric(12,2) not null default 0,
  cci text,
  tea numeric(7,2),
  estado text not null default 'activa' check (estado in ('activa','bloqueada','cerrada')),
  fecha_apertura date not null default current_date,
  sync_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cr_creditos (
  id uuid primary key default gen_random_uuid(),
  cod_cuenta_credito text unique not null,
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  producto_id uuid references public.productos_financieros(id),
  producto text not null,
  moneda text not null default 'PEN',
  monto_desembolsado numeric(12,2) not null,
  saldo_capital numeric(12,2) not null default 0,
  saldo_total numeric(12,2) not null default 0,
  cuota_mensual numeric(12,2),
  dias_mora integer not null default 0,
  calificacion_interna text,
  estado text not null default 'vigente'
    check (estado in ('vigente','pagado','vencido','castigado','desembolsado')),
  fecha_desembolso date,
  fecha_proximo_pago date,
  tea numeric(7,2),
  cuotas_total integer,
  cuotas_pagadas integer not null default 0,
  sync_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cr_cronograma_pagos (
  id uuid primary key default gen_random_uuid(),
  credito_id uuid not null references public.cr_creditos(id) on delete cascade,
  nro_cuota integer not null,
  fecha_vencimiento date not null,
  monto_cuota numeric(12,2) not null,
  monto_capital numeric(12,2) not null default 0,
  monto_interes numeric(12,2) not null default 0,
  monto_mora numeric(12,2) not null default 0,
  saldo numeric(12,2) not null default 0,
  estado_cuota text not null default 'pendiente'
    check (estado_cuota in ('pendiente','pagada','vencida')),
  fecha_pago date,
  sync_at timestamptz not null default now(),
  unique (credito_id, nro_cuota)
);

create table if not exists public.cr_movimientos (
  id uuid primary key default gen_random_uuid(),
  cod_operacion text unique not null,
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  cuenta_ahorro_id uuid references public.cr_cuentas_ahorro(id) on delete cascade,
  credito_id uuid references public.cr_creditos(id) on delete cascade,
  tipo text not null check (tipo in ('DEB','CRE','TRF','PAG','COM')),
  concepto text not null,
  canal text not null default 'APP' check (canal in ('APP','WEB','CAJA','ATM','CORE')),
  monto numeric(12,2) not null,
  moneda text not null default 'PEN',
  saldo_posterior numeric(12,2),
  fecha_operacion timestamptz not null default now(),
  sync_at timestamptz not null default now()
);

create table if not exists public.tarjetas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  numero_enmascarado text not null,
  marca text not null default 'Visa',
  tipo text not null default 'debito' check (tipo in ('debito','credito')),
  moneda text not null default 'PEN',
  linea_credito numeric(12,2),
  saldo_utilizado numeric(12,2) not null default 0,
  fecha_corte date,
  fecha_pago date,
  estado text not null default 'activa' check (estado in ('activa','bloqueada','vencida')),
  created_at timestamptz not null default now()
);

-- ============================================================================
-- App Clientes: operaciones y autoservicio
-- ============================================================================

create table if not exists public.operaciones_cliente (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  cuenta_origen_id uuid references public.cr_cuentas_ahorro(id),
  cuenta_destino_texto text,
  credito_id uuid references public.cr_creditos(id),
  tipo text not null check (tipo in ('transferencia','pago_cuota','pago_servicio')),
  beneficiario text,
  concepto text,
  monto numeric(12,2) not null check (monto > 0),
  moneda text not null default 'PEN',
  estado text not null default 'pendiente'
    check (estado in ('pendiente','enviada','confirmada','rechazada')),
  cod_operacion_core text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notificaciones (
  id uuid primary key default gen_random_uuid(),
  destinatario_tipo text not null check (destinatario_tipo in ('cliente','asesor')),
  cliente_id uuid references public.clientes(id) on delete cascade,
  asesor_id uuid references public.asesores(id) on delete cascade,
  titulo text not null,
  cuerpo text not null,
  tipo text not null,
  data_json jsonb not null default '{}'::jsonb,
  leida boolean not null default false,
  created_at timestamptz not null default now()
);

-- ============================================================================
-- Fuerza de Ventas: cartera, scoring, ficha, documentos, buro y solicitudes
-- ============================================================================

create table if not exists public.creditos_preaprobados (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  asesor_id uuid references public.asesores(id) on delete set null,
  segmento text not null check (segmento in ('PREMIER','ESTANDAR','BASICO','NO_APLICA')),
  score_transaccional integer not null check (score_transaccional between 0 and 800),
  monto_hipotesis numeric(12,2) not null,
  plazo_sugerido_meses integer,
  tea_referencial numeric(7,2),
  ingreso_promedio_cuenta numeric(12,2),
  estado text not null default 'preaprobado'
    check (estado in ('preaprobado','visitado','en_comite','aprobado','rechazado','desembolsado','vencido')),
  fecha_preaprobacion date not null default current_date,
  fecha_vencimiento date not null default (current_date + 30),
  created_at timestamptz not null default now()
);

create table if not exists public.cartera_diaria (
  id uuid primary key default gen_random_uuid(),
  asesor_id uuid not null references public.asesores(id) on delete cascade,
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  agencia_id uuid references public.agencias(id),
  preaprobado_id uuid references public.creditos_preaprobados(id) on delete set null,
  fecha_asignacion date not null default current_date,
  tipo_gestion text not null
    check (tipo_gestion in ('RENOVACION','AMPLIACION','NUEVA_SOLICITUD','SEGUIMIENTO','RECUPERACION_MORA','DESERTOR')),
  prioridad text not null default 'normal' check (prioridad in ('alta','media','normal')),
  score_prioridad integer not null default 0 check (score_prioridad between 0 and 100),
  monto_credito numeric(12,2),
  estado_visita text not null default 'pendiente'
    check (estado_visita in ('pendiente','visitado','no_encontrado','reagendado','negocio_cerrado')),
  resultado_visita text,
  observacion_visita text check (char_length(coalesce(observacion_visita,'')) <= 200),
  timestamp_visita timestamptz,
  lat_visita numeric(10,7),
  lng_visita numeric(10,7),
  orden_manual integer,
  pendiente_sync boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (asesor_id, cliente_id, fecha_asignacion)
);

create table if not exists public.fichas_campo (
  id uuid primary key default gen_random_uuid(),
  cartera_id uuid references public.cartera_diaria(id) on delete set null,
  preaprobado_id uuid references public.creditos_preaprobados(id) on delete set null,
  asesor_id uuid not null references public.asesores(id),
  cliente_id uuid not null references public.clientes(id),
  negocio_verificado boolean not null default true,
  antiguedad_negocio text check (antiguedad_negocio in ('menos_1_anio','1_a_3_anios','mas_3_anios')),
  tenencia_local text check (tenencia_local in ('alquilado_sin_contrato','alquilado_con_contrato','propio')),
  ventas_diarias_rango text check (ventas_diarias_rango in ('menos_50','50_a_150','151_a_300','mas_300')),
  ratio_gastos text check (ratio_gastos in ('mas_80pct','50_a_80pct','menos_50pct')),
  consistencia_cuenta boolean,
  tiene_deuda_informal text check (tiene_deuda_informal in ('si_significativa','si_menor','no')),
  participa_pandero text check (participa_pandero in ('si_mayor_cuota','si_menor_cuota','no')),
  stock_visible text check (stock_visible in ('escaso','moderado','abundante')),
  activos_hogar text check (activos_hogar in ('ninguno','al_menos_uno')),
  caracter_resultado text not null default 'sin_penalidad'
    check (caracter_resultado in ('sin_penalidad','alerta','veto')),
  pts_f1 integer not null default 0,
  pts_f2 integer not null default 0,
  pts_f3 integer not null default 0,
  pts_f4 integer not null default 0,
  score_campo integer not null default 0,
  score_final integer not null default 0,
  segmento_resultante text,
  monto_maximo numeric(12,2),
  monto_propuesto numeric(12,2),
  plazo_meses integer,
  cuota_estimada numeric(12,2),
  recomendacion text check (recomendacion in ('aprobar','aprobar_monto_reducido','elevar_comite','rechazar')),
  descalificado boolean not null default false,
  motivo_descalificacion text,
  firma_cliente_url text,
  lat_captura numeric(10,7),
  lng_captura numeric(10,7),
  pendiente_sync boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.solicitudes_credito (
  id uuid primary key default gen_random_uuid(),
  numero_expediente text unique,
  cod_solicitud_core text unique,
  cliente_id uuid not null references public.clientes(id),
  asesor_id uuid references public.asesores(id),
  agencia_id uuid references public.agencias(id),
  ficha_campo_id uuid references public.fichas_campo(id),
  canal text not null default 'cliente' check (canal in ('cliente','asesor','core_web')),
  producto_id uuid references public.productos_financieros(id),
  tipo_negocio text,
  nombre_negocio text,
  actividad_economica text,
  ingresos_estimados numeric(12,2),
  gastos_mensuales numeric(12,2),
  patrimonio_estimado numeric(12,2),
  tiene_conyuge boolean not null default false,
  conyuge_json jsonb,
  tiene_garante boolean not null default false,
  garante_json jsonb,
  monto_solicitado numeric(12,2) not null check (monto_solicitado > 0),
  plazo_meses integer not null check (plazo_meses > 0),
  moneda text not null default 'PEN',
  tipo_cuota text not null default 'mensual',
  garantia text,
  destino_credito text,
  cuota_estimada numeric(12,2),
  tea_referencial numeric(7,2),
  estado text not null default 'borrador'
    check (estado in ('borrador','enviado','recibido_comite','en_evaluacion','aprobado','condicionado','rechazado','desembolsado')),
  monto_aprobado numeric(12,2),
  motivo_rechazo text,
  condicion_adicional text,
  analista_asignado text,
  pendiente_sync boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.solicitudes_documentos (
  id uuid primary key default gen_random_uuid(),
  solicitud_id uuid not null references public.solicitudes_credito(id) on delete cascade,
  cliente_id uuid references public.clientes(id),
  asesor_id uuid references public.asesores(id),
  tipo_documento text not null
    check (tipo_documento in ('dni_anverso','dni_reverso','ruc','recibo_servicios','foto_negocio','foto_visita','contrato_arrendamiento','firma_cliente','otro')),
  storage_bucket text not null default 'documentos-solicitudes',
  storage_path text not null,
  tamanio_kb integer,
  nitidez_score numeric(7,2),
  validado boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.consultas_buro (
  id uuid primary key default gen_random_uuid(),
  asesor_id uuid references public.asesores(id),
  cliente_id uuid not null references public.clientes(id),
  solicitud_id uuid references public.solicitudes_credito(id),
  dni_consultado text not null,
  calificacion_sbs text,
  entidades_con_deuda integer not null default 0,
  deuda_total_pen numeric(12,2) not null default 0,
  mayor_deuda numeric(12,2) not null default 0,
  dias_mayor_mora integer not null default 0,
  en_lista_negra boolean not null default false,
  motivo_bloqueo text,
  resultado_json jsonb not null default '{}'::jsonb,
  firma_consentimiento_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.lista_negra_crediticia (
  id uuid primary key default gen_random_uuid(),
  numero_documento text unique not null,
  motivo text not null,
  fuente text not null default 'interno',
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

-- ============================================================================
-- Puente de sincronizacion mobile <-> core
-- ============================================================================

create table if not exists public.sync_outbox (
  id uuid primary key default gen_random_uuid(),
  entidad text not null,
  entidad_id uuid not null,
  operacion text not null check (operacion in ('create','update','delete')),
  payload jsonb not null,
  estado text not null default 'pendiente'
    check (estado in ('pendiente','procesando','aplicado','error')),
  intentos integer not null default 0,
  core_ref text,
  ultimo_error text,
  created_at timestamptz not null default now(),
  procesado_at timestamptz
);

create table if not exists public.sync_log (
  id uuid primary key default gen_random_uuid(),
  direccion text not null check (direccion in ('mobile_a_core','core_a_mobile')),
  entidad text not null,
  referencia text,
  resultado text not null check (resultado in ('ok','error')),
  detalle text,
  created_at timestamptz not null default now()
);

-- ============================================================================
-- Triggers
-- ============================================================================

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_asesores_updated_at on public.asesores;
create trigger trg_asesores_updated_at before update on public.asesores
for each row execute function public.set_updated_at();

drop trigger if exists trg_clientes_updated_at on public.clientes;
create trigger trg_clientes_updated_at before update on public.clientes
for each row execute function public.set_updated_at();

drop trigger if exists trg_cuentas_updated_at on public.cr_cuentas_ahorro;
create trigger trg_cuentas_updated_at before update on public.cr_cuentas_ahorro
for each row execute function public.set_updated_at();

drop trigger if exists trg_creditos_updated_at on public.cr_creditos;
create trigger trg_creditos_updated_at before update on public.cr_creditos
for each row execute function public.set_updated_at();

drop trigger if exists trg_operaciones_cliente_updated_at on public.operaciones_cliente;
create trigger trg_operaciones_cliente_updated_at before update on public.operaciones_cliente
for each row execute function public.set_updated_at();

drop trigger if exists trg_cartera_updated_at on public.cartera_diaria;
create trigger trg_cartera_updated_at before update on public.cartera_diaria
for each row execute function public.set_updated_at();

drop trigger if exists trg_fichas_campo_updated_at on public.fichas_campo;
create trigger trg_fichas_campo_updated_at before update on public.fichas_campo
for each row execute function public.set_updated_at();

drop trigger if exists trg_solicitudes_updated_at on public.solicitudes_credito;
create trigger trg_solicitudes_updated_at before update on public.solicitudes_credito
for each row execute function public.set_updated_at();

-- ============================================================================
-- Indices
-- ============================================================================

create index if not exists idx_clientes_documento on public.clientes(numero_documento);
create index if not exists idx_clientes_user_id on public.clientes(user_id);
create index if not exists idx_asesores_user_id on public.asesores(user_id);
create index if not exists idx_cuentas_cliente on public.cr_cuentas_ahorro(cliente_id);
create index if not exists idx_creditos_cliente on public.cr_creditos(cliente_id);
create index if not exists idx_cronograma_credito on public.cr_cronograma_pagos(credito_id, nro_cuota);
create index if not exists idx_movimientos_cliente_fecha on public.cr_movimientos(cliente_id, fecha_operacion desc);
create index if not exists idx_operaciones_cliente_estado on public.operaciones_cliente(cliente_id, estado);
create index if not exists idx_notificaciones_cliente on public.notificaciones(cliente_id, leida, created_at desc);
create index if not exists idx_preaprobados_asesor_estado on public.creditos_preaprobados(asesor_id, estado, score_transaccional desc);
create index if not exists idx_cartera_asesor_fecha on public.cartera_diaria(asesor_id, fecha_asignacion, score_prioridad desc);
create index if not exists idx_solicitudes_estado on public.solicitudes_credito(estado, created_at desc);
create index if not exists idx_solicitudes_cliente on public.solicitudes_credito(cliente_id, created_at desc);
create index if not exists idx_outbox_pendiente on public.sync_outbox(estado, created_at) where estado = 'pendiente';

-- ============================================================================
-- Storage para documentos de solicitudes
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'documentos-solicitudes',
  'documentos-solicitudes',
  false,
  10485760,
  array['image/jpeg','image/png','application/pdf']
)
on conflict (id) do nothing;

-- ============================================================================
-- Row Level Security
-- ============================================================================

alter table public.profiles enable row level security;
alter table public.agencias enable row level security;
alter table public.asesores enable row level security;
alter table public.clientes enable row level security;
alter table public.productos_financieros enable row level security;
alter table public.cr_cuentas_ahorro enable row level security;
alter table public.cr_creditos enable row level security;
alter table public.cr_cronograma_pagos enable row level security;
alter table public.cr_movimientos enable row level security;
alter table public.tarjetas enable row level security;
alter table public.operaciones_cliente enable row level security;
alter table public.notificaciones enable row level security;
alter table public.creditos_preaprobados enable row level security;
alter table public.cartera_diaria enable row level security;
alter table public.fichas_campo enable row level security;
alter table public.solicitudes_credito enable row level security;
alter table public.solicitudes_documentos enable row level security;
alter table public.consultas_buro enable row level security;
alter table public.lista_negra_crediticia enable row level security;
alter table public.sync_outbox enable row level security;
alter table public.sync_log enable row level security;

drop policy if exists profiles_select_own_or_staff on public.profiles;
create policy profiles_select_own_or_staff on public.profiles
for select using (id = auth.uid() or public.is_role(array['asesor','supervisor','administrador']));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists catalogos_read_auth on public.agencias;
create policy catalogos_read_auth on public.agencias for select to authenticated using (true);

drop policy if exists productos_read_auth on public.productos_financieros;
create policy productos_read_auth on public.productos_financieros for select to authenticated using (activo = true);

drop policy if exists clientes_select_owner_or_staff on public.clientes;
create policy clientes_select_owner_or_staff on public.clientes
for select using (
  user_id = auth.uid()
  or public.is_role(array['asesor','supervisor','administrador'])
);

drop policy if exists clientes_update_owner_or_staff on public.clientes;
create policy clientes_update_owner_or_staff on public.clientes
for update using (
  user_id = auth.uid()
  or public.is_role(array['asesor','supervisor','administrador'])
);

drop policy if exists asesores_select_self_or_staff on public.asesores;
create policy asesores_select_self_or_staff on public.asesores
for select using (
  user_id = auth.uid()
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists cuentas_cliente_read on public.cr_cuentas_ahorro;
create policy cuentas_cliente_read on public.cr_cuentas_ahorro
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or public.is_role(array['asesor','supervisor','administrador'])
);

drop policy if exists creditos_cliente_read on public.cr_creditos;
create policy creditos_cliente_read on public.cr_creditos
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or public.is_role(array['asesor','supervisor','administrador'])
);

drop policy if exists cronograma_cliente_read on public.cr_cronograma_pagos;
create policy cronograma_cliente_read on public.cr_cronograma_pagos
for select using (
  exists (
    select 1 from public.cr_creditos cr
    join public.clientes c on c.id = cr.cliente_id
    where cr.id = credito_id
      and (c.user_id = auth.uid() or public.is_role(array['asesor','supervisor','administrador']))
  )
);

drop policy if exists movimientos_cliente_read on public.cr_movimientos;
create policy movimientos_cliente_read on public.cr_movimientos
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or public.is_role(array['asesor','supervisor','administrador'])
);

drop policy if exists tarjetas_cliente_read on public.tarjetas;
create policy tarjetas_cliente_read on public.tarjetas
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists operaciones_cliente_read on public.operaciones_cliente;
create policy operaciones_cliente_read on public.operaciones_cliente
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists operaciones_cliente_insert_own on public.operaciones_cliente;
create policy operaciones_cliente_insert_own on public.operaciones_cliente
for insert with check (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
);

drop policy if exists notificaciones_read_owner on public.notificaciones;
create policy notificaciones_read_owner on public.notificaciones
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or exists (select 1 from public.asesores a where a.id = asesor_id and a.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists cartera_read_assigned on public.cartera_diaria;
create policy cartera_read_assigned on public.cartera_diaria
for select using (
  exists (select 1 from public.asesores a where a.id = asesor_id and a.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists cartera_update_assigned on public.cartera_diaria;
create policy cartera_update_assigned on public.cartera_diaria
for update using (
  exists (select 1 from public.asesores a where a.id = asesor_id and a.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists preaprobados_read_assigned on public.creditos_preaprobados;
create policy preaprobados_read_assigned on public.creditos_preaprobados
for select using (
  exists (select 1 from public.asesores a where a.id = asesor_id and a.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists solicitudes_read_related on public.solicitudes_credito;
create policy solicitudes_read_related on public.solicitudes_credito
for select using (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or exists (select 1 from public.asesores a where a.id = asesor_id and a.user_id = auth.uid())
  or public.is_role(array['supervisor','administrador'])
);

drop policy if exists solicitudes_insert_cliente_or_staff on public.solicitudes_credito;
create policy solicitudes_insert_cliente_or_staff on public.solicitudes_credito
for insert with check (
  exists (select 1 from public.clientes c where c.id = cliente_id and c.user_id = auth.uid())
  or public.is_role(array['asesor','supervisor','administrador'])
);

drop policy if exists solicitudes_update_staff on public.solicitudes_credito;
create policy solicitudes_update_staff on public.solicitudes_credito
for update using (public.is_role(array['asesor','supervisor','administrador']));

drop policy if exists fichas_campo_staff on public.fichas_campo;
create policy fichas_campo_staff on public.fichas_campo
for all using (public.is_role(array['asesor','supervisor','administrador']))
with check (public.is_role(array['asesor','supervisor','administrador']));

drop policy if exists docs_read_related on public.solicitudes_documentos;
create policy docs_read_related on public.solicitudes_documentos
for select using (
  exists (
    select 1 from public.solicitudes_credito s
    left join public.clientes c on c.id = s.cliente_id
    left join public.asesores a on a.id = s.asesor_id
    where s.id = solicitud_id
      and (c.user_id = auth.uid() or a.user_id = auth.uid() or public.is_role(array['supervisor','administrador']))
  )
);

drop policy if exists docs_insert_related on public.solicitudes_documentos;
create policy docs_insert_related on public.solicitudes_documentos
for insert with check (
  exists (
    select 1 from public.solicitudes_credito s
    left join public.clientes c on c.id = s.cliente_id
    left join public.asesores a on a.id = s.asesor_id
    where s.id = solicitud_id
      and (c.user_id = auth.uid() or a.user_id = auth.uid() or public.is_role(array['supervisor','administrador']))
  )
);

drop policy if exists buro_staff_only on public.consultas_buro;
create policy buro_staff_only on public.consultas_buro
for all using (public.is_role(array['asesor','supervisor','administrador']))
with check (public.is_role(array['asesor','supervisor','administrador']));

drop policy if exists lista_negra_staff_only on public.lista_negra_crediticia;
create policy lista_negra_staff_only on public.lista_negra_crediticia
for select using (public.is_role(array['asesor','supervisor','administrador']));

drop policy if exists sync_admin_only on public.sync_outbox;
create policy sync_admin_only on public.sync_outbox
for all using (public.is_role(array['administrador'])) with check (public.is_role(array['administrador']));

drop policy if exists sync_log_admin_only on public.sync_log;
create policy sync_log_admin_only on public.sync_log
for all using (public.is_role(array['administrador'])) with check (public.is_role(array['administrador']));

drop policy if exists storage_docs_read_auth on storage.objects;
create policy storage_docs_read_auth on storage.objects
for select to authenticated
using (bucket_id = 'documentos-solicitudes');

drop policy if exists storage_docs_insert_auth on storage.objects;
create policy storage_docs_insert_auth on storage.objects
for insert to authenticated
with check (bucket_id = 'documentos-solicitudes');

-- ============================================================================
-- Vistas utiles para la App Clientes
-- ============================================================================

create or replace view public.vw_cliente_dashboard
with (security_invoker = true) as
select
  c.id as cliente_id,
  c.user_id,
  c.nombres,
  c.apellidos,
  c.numero_documento,
  coalesce(sum(a.saldo_disponible), 0) as saldo_total_ahorros,
  coalesce(sum(cr.saldo_total), 0) as deuda_total_creditos,
  count(distinct a.id) as cuentas_ahorro,
  count(distinct cr.id) as creditos_activos
from public.clientes c
left join public.cr_cuentas_ahorro a on a.cliente_id = c.id and a.estado = 'activa'
left join public.cr_creditos cr on cr.cliente_id = c.id and cr.estado in ('vigente','vencido','desembolsado')
group by c.id;

create or replace view public.vw_cartera_asesor_dia
with (security_invoker = true) as
select
  cd.*,
  c.numero_documento,
  c.nombres,
  c.apellidos,
  c.telefono,
  c.distrito,
  c.tipo_negocio,
  c.nombre_negocio,
  c.direccion_negocio,
  c.lat_negocio,
  c.lng_negocio,
  c.calificacion_sbs,
  cp.segmento,
  cp.score_transaccional,
  cp.monto_hipotesis
from public.cartera_diaria cd
join public.clientes c on c.id = cd.cliente_id
left join public.creditos_preaprobados cp on cp.id = cd.preaprobado_id;

-- ============================================================================
-- Semilla de catalogos CMAC Del Santa
-- ============================================================================

insert into public.agencias (cod_agencia, nombre, region, direccion, telefono, lat, lng)
values
  ('AGS-CHIMBOTE', 'Oficina Principal Chimbote', 'Ancash', 'Av. Jose Galvez 602 - Chimbote', '(043) 483 140', -9.0745000, -78.5936000),
  ('AGS-NUEVOCHIMBOTE', 'Agencia Nuevo Chimbote', 'Ancash', 'Nuevo Chimbote', '(043) 483 140', -9.1220000, -78.5200000)
on conflict (cod_agencia) do nothing;

insert into public.productos_financieros
  (codigo, categoria, segmento, nombre, descripcion, tea_min, tea_max, monto_min, monto_max, plazo_min_meses, plazo_max_meses)
values
  ('AHO-CORRIENTE', 'ahorro', 'Cuentas', 'Ahorro Corriente', 'Cuenta de ahorro para operaciones frecuentes.', 0.10, 1.50, 0, null, null, null),
  ('AHO-REMUN', 'ahorro', 'Cuentas', 'Cuenta Remuneraciones', 'Cuenta para abono de haberes.', 0.10, 1.50, 0, null, null, null),
  ('AHO-KIDS', 'ahorro', 'Cuentas', 'Cuenta Ahorro KIDS', 'Ahorro para menores de edad.', 0.10, 2.00, 0, null, null, null),
  ('DPF', 'ahorro', 'Plazo Fijo', 'Deposito Plazo Fijo', 'Deposito con tasa pactada por plazo.', 2.00, 7.50, 500, null, 1, 36),
  ('CRE-PAGA-DIARIO', 'credito', 'Empresarial', 'Credi Paga Diario', 'Credito para negocios con pago diario.', 25.00, 80.00, 500, 10000, 3, 18),
  ('CRE-EMPRESARIAL', 'credito', 'Empresarial', 'Credito Empresarial', 'Financiamiento para capital de trabajo y activo fijo.', 18.00, 55.00, 1000, 80000, 6, 48),
  ('CRE-CRECER', 'credito', 'Empresarial', 'Credi Crecer', 'Credito para crecimiento de microempresa.', 20.00, 60.00, 500, 30000, 6, 36),
  ('CRE-AGRO', 'credito', 'Empresarial', 'Credi Agro', 'Credito para actividades agropecuarias.', 18.00, 55.00, 1000, 50000, 6, 36),
  ('CRE-NEGOCIO', 'credito', 'Empresarial', 'Credi Negocio', 'Credito para emprendedores y negocios.', 22.00, 65.00, 500, 25000, 3, 36),
  ('CRE-PESCA', 'credito', 'Empresarial', 'Credi Pesca', 'Credito para actividades de pesca.', 18.00, 55.00, 1000, 50000, 6, 36),
  ('CRE-MULTIUSO', 'credito', 'Consumo', 'Credi Multiuso', 'Credito de libre disponibilidad.', 25.00, 70.00, 500, 20000, 6, 36),
  ('CRE-CONVENIO', 'credito', 'Consumo', 'Credi Convenio', 'Credito para trabajadores con convenio.', 18.00, 45.00, 1000, 40000, 6, 48),
  ('CRE-CASA-SANTA', 'credito', 'Consumo', 'Casa Santa', 'Credito para vivienda.', 12.00, 35.00, 5000, 150000, 12, 120),
  ('SERV-HIDRANDINA', 'servicio', 'Recaudacion', 'Pago Hidrandina', 'Pago de recibos de energia.', null, null, null, null, null, null),
  ('SERV-WU', 'servicio', 'Transacciones', 'Western Union', 'Pagos y remesas Western Union.', null, null, null, null, null, null)
on conflict (codigo) do nothing;

-- ============================================================================
-- FIN
-- ============================================================================
