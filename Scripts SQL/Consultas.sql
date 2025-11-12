--  **** CONSULTAS INTERMEDIAS ****  --

--  **** PROCEDIMIENTOS ALMACENADOS ****  --

CREATE PROCEDURE SP_RESUMEN_TRANSMISIONES
/*
Objetivo: Obtener indicadores claves por plataforma.
Usuario: Jahat Trinidad
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Plataforma = P.Nombre,
		TotalTransmisiones = COUNT(DISTINCT T.ID_Transimision),
		DuracionPromedioMin = AVG(DATEDIFF(MINUTE, T.Fecha_Inicio, T.Fecha_Fin)),
		ConcurrenciaTotal = SUM(ISNULL(A.Concurrencia, 0)),
		TiempoAudienciaPromedio = AVG(ISNULL(A.Tiempo_Promedio, 0))
	FROM Plataforma P
	INNER JOIN Cuenta_Plataforma CP ON CP.ID_Plataforma = P.ID_Plataforma
	INNER JOIN Transimision T ON T.ID_Cuenta = CP.ID_Cuenta
	LEFT JOIN Audiencia_Agregada_Tiempo A ON A.ID_Transimision = T.ID_Transimision
	GROUP BY P.Nombre
	ORDER BY TotalTransmisiones DESC, Plataforma;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_RESUMEN_TRANSMISIONES;
--------------------------------------------------------------

CREATE PROCEDURE SP_INCIDENTES_POR_STREAMER
/*
Objetivo: Resumir incidencias tecnicas por severidad y estado.
Usuario: Jahat Trinidad
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
		Severidad = I.Severidad,
		TotalIncidentes = COUNT(I.ID_Incidente),
		IncidentesEnCurso = SUM(CASE WHEN I.Fin IS NULL THEN 1 ELSE 0 END),
		PrimerRegistro = MIN(I.Inicio),
		UltimoRegistro = MAX(ISNULL(I.Fin, I.Inicio))
	FROM Incidente_Tecnico I
	INNER JOIN Transimision T ON T.ID_Transimision = I.ID_Transimision
	INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = T.ID_Cuenta
	INNER JOIN Streamer S ON S.ID_Streamer = CP.ID_Streamer
	GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno, I.Severidad
	ORDER BY TotalIncidentes DESC, Streamer, Severidad;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_INCIDENTES_POR_STREAMER;
--------------------------------------------------------------

CREATE PROCEDURE SP_RENDIMIENTO_CAMPANAS
/*
Objetivo: Evaluar conversiones y objetivos alcanzados por campaña.
Usuario: Jahat Trinidad
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Campania = C.Nombre,
		Cliente = CL.Nombre,
		DiasActiva = DATEDIFF(DAY, C.Fecha_Inicio, ISNULL(C.Fecha_Fin, SYSDATETIME())),
		TotalTouchpoints = COUNT(DISTINCT TP.ID_Touchpoint),
		Objetivos = COUNT(DISTINCT OC.ID_Objetivo),
		EventosConversion = COUNT(DISTINCT EV.ID_Evento),
		ValorConversionTotal = SUM(ISNULL(EV.Valor, 0.0)),
		ValorUltimos30Dias = SUM(CASE WHEN EV.Timestamp >= DATEADD(DAY, -30, SYSDATETIME()) THEN ISNULL(EV.Valor, 0.0) ELSE 0.0 END),
		ParticipacionCliente = CASE
			WHEN SUM(SUM(ISNULL(EV.Valor, 0.0))) OVER (PARTITION BY CL.ID_Cliente) = 0 THEN 0
			ELSE SUM(ISNULL(EV.Valor, 0.0)) / NULLIF(SUM(SUM(ISNULL(EV.Valor, 0.0))) OVER (PARTITION BY CL.ID_Cliente), 0)
		END,
		ObjetivosCumplidos = SUM(COALESCE(CA.Cumplido, 0))
	FROM Campaña C
	INNER JOIN Cliente CL ON CL.ID_Cliente = C.ID_Cliente
	LEFT JOIN Touchpoint TP ON TP.ID_Campaña = C.ID_Campaña
	LEFT JOIN Objetivo_Conversion OC ON OC.ID_Campaña = C.ID_Campaña
	LEFT JOIN Evento_Conversion EV ON EV.ID_Objetivo = OC.ID_Objetivo
	OUTER APPLY (
		SELECT TOP 1
			Cumplido = CASE WHEN COUNT(DISTINCT EV2.ID_Evento) >= 1 THEN 1 ELSE 0 END
		FROM Objetivo_Conversion OC2
		LEFT JOIN Evento_Conversion EV2 ON EV2.ID_Objetivo = OC2.ID_Objetivo
		WHERE OC2.ID_Campaña = C.ID_Campaña
		GROUP BY OC2.ID_Objetivo
		ORDER BY COUNT(DISTINCT EV2.ID_Evento) DESC
	) CA
	GROUP BY C.Nombre, CL.Nombre, CL.ID_Cliente, C.Fecha_Inicio, C.Fecha_Fin
	ORDER BY ValorConversionTotal DESC, Campania;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_RENDIMIENTO_CAMPANAS;
--------------------------------------------------------------

CREATE PROCEDURE SP_PREFERENCIAS_SILENCIO
/*
Objetivo: Validar preferencia de notificaciones y bloques de silencio por streamer.
Usuario: Adrian Estrada
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
		Canal = CN.Nombre,
		TieneSilencio = MAX(CASE WHEN PBS.Activo = 1 THEN 1 ELSE 0 END),
		BloquesActivos = SUM(CASE WHEN PBS.Activo = 1 THEN 1 ELSE 0 END)
	FROM Streamer S
	LEFT JOIN Preferencia_Notificacion PN ON PN.ID_Streamer = S.ID_Streamer
	LEFT JOIN Catalogo_Canal_Notificacion CN ON CN.ID_Canal_Notificacion = PN.ID_Canal_Notificacion
	LEFT JOIN Prefrencia_Bloque_Silencio PBS ON PBS.ID_Preferencia = PN.ID_Preferencia
	GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno, CN.Nombre
	HAVING CN.Nombre IS NOT NULL
	ORDER BY Streamer, Canal;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_PREFERENCIAS_SILENCIO;
--------------------------------------------------------------

CREATE PROCEDURE SP_SALUD_INTEGRACIONES
/*
Objetivo: Detectar integraciones que requieren sincronizacion o estan inactivas.
Usuario: Adrian Estrada
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Proveedor,
		Estado,
		Fecha_Refresh,
		DiasSinSincronizar = DATEDIFF(DAY, Fecha_Refresh, SYSDATETIME()),
		RequiereAtencion = CASE WHEN Estado <> 'activo' OR DATEDIFF(DAY, Fecha_Refresh, SYSDATETIME()) > 1 THEN 1 ELSE 0 END
	FROM Integracion_Api
	ORDER BY RequiereAtencion DESC, Proveedor;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_SALUD_INTEGRACIONES;
--------------------------------------------------------------

CREATE PROCEDURE SP_OCUPACION_DASHBOARD
/*
Objetivo: Analizar uso de slots y KPIs configurados por usuario.
Usuario: Adrian Estrada
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		DS.ID_Slot,
		Usuario = U.Nombre,
		Visible = DS.Visible,
		KPIsAsignados = COUNT(DISTINCT DSK.ID_Kpi),
		FechaConfiguracionReciente = MAX(DSK.Fecha_Configuracion)
	FROM Dashbord_Slot DS
	INNER JOIN Usuario U ON U.ID_Usuario = DS.ID_Usuario
	LEFT JOIN Dashboard_Slot_KPI DSK ON DSK.ID_Slot = DS.ID_Slot
	GROUP BY DS.ID_Slot, U.Nombre, DS.Visible
	ORDER BY Visible DESC, KPIsAsignados DESC, DS.ID_Slot;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_OCUPACION_DASHBOARD;
--------------------------------------------------------------

CREATE PROCEDURE SP_TOKENS_SCOPES
/*
Objetivo: Auditar scopes asociados a cada token y su proximidad de expiracion.
Usuario: Mateo Urviola
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Cuenta = CP.Handle,
		Expiracion = T.Expiracion,
		ScopesAsignados = COUNT(DISTINCT OS.ID_Scope),
		ScopesDisponibles = (SELECT COUNT(*) FROM Catalogo_Scope),
		ScopesFaltantes = (SELECT COUNT(*) FROM Catalogo_Scope) - COUNT(DISTINCT OS.ID_Scope),
		DiasParaExpirar = DATEDIFF(DAY, SYSDATETIME(), T.Expiracion)
	FROM [0Auth_Token] T
	INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = T.ID_Cuenta
	LEFT JOIN OAuth_Scope OS ON OS.ID_Token = T.ID_Token
	GROUP BY CP.Handle, T.Expiracion
	ORDER BY Expiracion, Cuenta;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_TOKENS_SCOPES;
--------------------------------------------------------------

CREATE PROCEDURE SP_BALANCE_MODELOS
/*
Objetivo: Validar distribucion de creditos en los modelos de atribucion.
Usuario: Mateo Urviola
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Modelo = MA.Nombre,
		TotalPorcentaje = SUM(ISNULL(MD.Porcentaje_Default, 0)),
		TiposTouchpoint = COUNT(DISTINCT MD.ID_Tipo_Touchpoint),
		EstadoBalance = CASE WHEN ABS(SUM(ISNULL(MD.Porcentaje_Default, 0)) - 1.0) < 0.001 THEN 'Balanceado' ELSE 'Revisar' END
	FROM Modelo_Distribucion MD
	INNER JOIN Modelo_Atribucion MA ON MA.ID_Modelo = MD.ID_Modelo
	GROUP BY MA.Nombre
	ORDER BY TotalPorcentaje DESC, Modelo;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_BALANCE_MODELOS;
--------------------------------------------------------------

CREATE PROCEDURE SP_CONTENIDO_STREAMER
/*
Objetivo: Medir la mezcla de formatos publicados por streamer.
Usuario: Mateo Urviola
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
		TipoContenido = C.Tipo,
		Total = COUNT(C.ID_Contenido),
		ConUrl = SUM(CASE WHEN C.Url IS NOT NULL THEN 1 ELSE 0 END)
	FROM Contenido C
	INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = C.ID_Cuenta
	INNER JOIN Streamer S ON S.ID_Streamer = CP.ID_Streamer
	GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno, C.Tipo
	ORDER BY Streamer, TipoContenido;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_CONTENIDO_STREAMER;
--------------------------------------------------------------

CREATE PROCEDURE SP_TELEMETRIA_CLASIFICACION
/*
Objetivo: Clasificar transmisiones segun estabilidad tecnica registrada.
Usuario: Jahat Trinidad
Fecha: 11/11/2025
*/
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN;

	SELECT
		T.ID_Transimision,
		MaxBitrate = MAX(ISNULL(TC.Bitrate, 0)),
		MinBitrate = MIN(ISNULL(TC.Bitrate, 0)),
		PromedioBitrate = AVG(ISNULL(TC.Bitrate, 0)),
		FramesPerdidos = SUM(ISNULL(TC.Dropped_Frames, 0)),
		LatenciaPromedio = AVG(ISNULL(TC.Latencia, 0)),
		Calidad = CASE
			WHEN AVG(ISNULL(TC.Bitrate, 0)) >= 6000 AND AVG(ISNULL(TC.Latencia, 0)) <= 120 THEN 'OPTIMO'
			WHEN AVG(ISNULL(TC.Bitrate, 0)) >= 3500 AND AVG(ISNULL(TC.Latencia, 0)) <= 200 THEN 'ACEPTABLE'
			ELSE 'CRITICO'
		END
	FROM Telemetria_Calidad TC
	INNER JOIN Transimision T ON T.ID_Transimision = TC.ID_Transimision
	GROUP BY T.ID_Transimision
	ORDER BY Calidad, T.ID_Transimision;

	COMMIT TRAN;
END
--------------------------------------------------------------
EXEC SP_TELEMETRIA_CLASIFICACION;
--------------------------------------------------------------

--  **** FUNCIONES ****  --

CREATE FUNCTION FN_DIAS_SIN_REFRESH(@Fecha DATETIME)
/*
Objetivo: Calcular dias sin sincronizacion para una integracion.
Usuario: Jahat Trinidad
Fecha: 11/11/2025
*/
RETURNS INT
AS
BEGIN
	RETURN DATEDIFF(DAY, @Fecha, SYSDATETIME());
END
--------------------------------------------------------------

CREATE FUNCTION FN_STREAMERS_CON_ALERTAS()
/*
Objetivo: Listar streamers con alertas recientes y su severidad maxima.
Usuario: Equipo Qawana
Fecha: 11/11/2025
*/
RETURNS TABLE
AS
RETURN(
	SELECT
		Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
		UltimaTransmision = MAX(T.Fecha_Inicio),
		Alertas = COUNT(H.ID_Alerta),
		SeveridadMaxima = MAX(UA.Severidad)
	FROM Historial_Alertas H
	INNER JOIN Transimision T ON T.ID_Transimision = H.ID_Transimision
	INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = T.ID_Cuenta
	INNER JOIN Streamer S ON S.ID_Streamer = CP.ID_Streamer
	INNER JOIN Umbral_Alerta UA ON UA.ID_Umbral = H.ID_Umbral
	GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno
);
--------------------------------------------------------------

CREATE FUNCTION FN_RESUMEN_CONVERSION(@Dias INT)
/*
Objetivo: Resumir conversiones por campaña considerando una ventana movible.
Usuario: Jahat Trinidad
Fecha: 11/11/2025
*/
RETURNS @Resumen TABLE (
	Campania NVARCHAR(100),
	Objetivos INT,
	Eventos INT,
	ValorTotal DECIMAL(18,2)
)
AS
BEGIN
	INSERT INTO @Resumen
	SELECT
		Campania = C.Nombre,
		Objetivos = COUNT(DISTINCT OC.ID_Objetivo),
		Eventos = COUNT(EV.ID_Evento),
		ValorTotal = SUM(ISNULL(EV.Valor, 0.0))
	FROM Campaña C
	LEFT JOIN Objetivo_Conversion OC ON OC.ID_Campaña = C.ID_Campaña
	LEFT JOIN Evento_Conversion EV ON EV.ID_Objetivo = OC.ID_Objetivo
	WHERE EV.Timestamp >= DATEADD(DAY, -@Dias, SYSDATETIME())
	GROUP BY C.Nombre;

	RETURN;
END
--------------------------------------------------------------

-- Consultas de apoyo para funciones

BEGIN TRAN;
SELECT Integracion = Proveedor, DiasSinRefresh = dbo.FN_DIAS_SIN_REFRESH(Fecha_Refresh)
FROM Integracion_Api;
COMMIT TRAN;
--------------------------------------------------------------

BEGIN TRAN;
SELECT *
FROM dbo.FN_STREAMERS_CON_ALERTAS();
COMMIT TRAN;
--------------------------------------------------------------

BEGIN TRAN;
SELECT *
FROM dbo.FN_RESUMEN_CONVERSION(30)
ORDER BY ValorTotal DESC;
COMMIT TRAN;
----------------------------------------------------------------  **** CONSULTAS INTERMEDIAS ****  --

/*
1.  Resumen de transmisiones por plataforma
    Objetivo: Revisar la actividad promedio por plataforma de streaming.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Plataforma = P.Nombre,
	TotalTransmisiones = COUNT(DISTINCT T.ID_Transimision),
	DuracionPromedioMin = AVG(DATEDIFF(MINUTE, T.Fecha_Inicio, T.Fecha_Fin)),
	ConcurrenciaTotal = SUM(ISNULL(A.Concurrencia, 0)),
	TiempoAudienciaPromedio = AVG(ISNULL(A.Tiempo_Promedio, 0))
FROM Plataforma P
INNER JOIN Cuenta_Plataforma CP ON CP.ID_Plataforma = P.ID_Plataforma
INNER JOIN Transimision T ON T.ID_Cuenta = CP.ID_Cuenta
LEFT JOIN Audiencia_Agregada_Tiempo A ON A.ID_Transimision = T.ID_Transimision
GROUP BY P.Nombre
ORDER BY TotalTransmisiones DESC, Plataforma;
COMMIT TRAN;
--------------------------------------------------------------

/*
2.  Incidentes tecnicos por streamer y severidad
    Objetivo: Identificar incidentes activos y resueltos por severidad.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
	Severidad = I.Severidad,
	TotalIncidentes = COUNT(I.ID_Incidente),
	IncidentesEnCurso = SUM(CASE WHEN I.Fin IS NULL THEN 1 ELSE 0 END),
	PrimerRegistro = MIN(I.Inicio),
	UltimoRegistro = MAX(ISNULL(I.Fin, I.Inicio))
FROM Incidente_Tecnico I
INNER JOIN Transimision T ON T.ID_Transimision = I.ID_Transimision
INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = T.ID_Cuenta
INNER JOIN Streamer S ON S.ID_Streamer = CP.ID_Streamer
GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno, I.Severidad
ORDER BY TotalIncidentes DESC, Streamer, Severidad;
COMMIT TRAN;
--------------------------------------------------------------

/*
3.  Rendimiento de campañas y conversiones
    Objetivo: Medir la productividad de campañas con sus eventos de conversion.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Campania = C.Nombre,
	TotalTouchpoints = COUNT(DISTINCT TP.ID_Touchpoint),
	Objetivos = COUNT(DISTINCT OC.ID_Objetivo),
	EventosConversion = COUNT(DISTINCT EV.ID_Evento),
	ValorConversionTotal = SUM(ISNULL(EV.Valor, 0.0)),
	ValorUltimos30Dias = SUM(CASE WHEN EV.Timestamp >= DATEADD(DAY, -30, SYSDATETIME()) THEN ISNULL(EV.Valor, 0.0) ELSE 0.0 END)
FROM Campaña C
LEFT JOIN Touchpoint TP ON TP.ID_Campaña = C.ID_Campaña
LEFT JOIN Objetivo_Conversion OC ON OC.ID_Campaña = C.ID_Campaña
LEFT JOIN Evento_Conversion EV ON EV.ID_Objetivo = OC.ID_Objetivo
GROUP BY C.Nombre
ORDER BY ValorConversionTotal DESC, Campania;
COMMIT TRAN;
--------------------------------------------------------------

/*
4.  Preferencias de notificacion y bloques de silencio
    Objetivo: Verificar configuraciones activas por streamer.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
	Canal = CN.Nombre,
	TieneSilencio = MAX(CASE WHEN PBS.Activo = 1 THEN 1 ELSE 0 END),
	BloquesActivos = SUM(CASE WHEN PBS.Activo = 1 THEN 1 ELSE 0 END)
FROM Streamer S
LEFT JOIN Preferencia_Notificacion PN ON PN.ID_Streamer = S.ID_Streamer
LEFT JOIN Catalogo_Canal_Notificacion CN ON CN.ID_Canal_Notificacion = PN.ID_Canal_Notificacion
LEFT JOIN Prefrencia_Bloque_Silencio PBS ON PBS.ID_Preferencia = PN.ID_Preferencia
GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno, CN.Nombre
HAVING CN.Nombre IS NOT NULL
ORDER BY Streamer, Canal;
COMMIT TRAN;
--------------------------------------------------------------

/*
5.  Salud de integraciones API
    Objetivo: Detectar integraciones que requieren sincronizacion.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Proveedor,
	Estado,
	Fecha_Refresh,
	DiasSinSincronizar = DATEDIFF(DAY, Fecha_Refresh, SYSDATETIME()),
	RequiereAtencion = CASE WHEN Estado <> 'activo' OR DATEDIFF(DAY, Fecha_Refresh, SYSDATETIME()) > 1 THEN 1 ELSE 0 END
FROM Integracion_Api
ORDER BY RequiereAtencion DESC, Proveedor;
COMMIT TRAN;
--------------------------------------------------------------

/*
6.  Ocupacion de dashboards y KPIs configurados
    Objetivo: Evaluar el uso de slots visibles y su configuracion reciente.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	DS.ID_Slot,
	Usuario = U.Nombre,
	Visible = DS.Visible,
	KPIsAsignados = COUNT(DISTINCT DSK.ID_Kpi),
	FechaConfiguracionReciente = MAX(DSK.Fecha_Configuracion)
FROM Dashbord_Slot DS
INNER JOIN Usuario U ON U.ID_Usuario = DS.ID_Usuario
LEFT JOIN Dashboard_Slot_KPI DSK ON DSK.ID_Slot = DS.ID_Slot
GROUP BY DS.ID_Slot, U.Nombre, DS.Visible
ORDER BY Visible DESC, KPIsAsignados DESC, DS.ID_Slot;
COMMIT TRAN;
--------------------------------------------------------------

/*
7.  Tokens OAuth y cobertura de scopes
    Objetivo: Auditar expiraciones y cantidad de scopes asignados.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Cuenta = CP.Handle,
	Expiracion = T.Expiracion,
	ScopesAsignados = COUNT(DISTINCT OS.ID_Scope),
	ScopesDisponibles = (SELECT COUNT(*) FROM Catalogo_Scope),
	ScopesFaltantes = (SELECT COUNT(*) FROM Catalogo_Scope) - COUNT(DISTINCT OS.ID_Scope),
	DiasParaExpirar = DATEDIFF(DAY, SYSDATETIME(), T.Expiracion)
FROM [0Auth_Token] T
INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = T.ID_Cuenta
LEFT JOIN OAuth_Scope OS ON OS.ID_Token = T.ID_Token
GROUP BY CP.Handle, T.Expiracion
ORDER BY Expiracion, Cuenta;
COMMIT TRAN;
--------------------------------------------------------------

/*
8.  Balance de modelos de atribucion
    Objetivo: Validar que los porcentajes sumen al 100 por ciento.
    Usuario: Equipo Qawana
    Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Modelo = MA.Nombre,
	TotalPorcentaje = SUM(ISNULL(MD.Porcentaje_Default, 0)),
	TiposTouchpoint = COUNT(DISTINCT MD.ID_Tipo_Touchpoint),
	EstadoBalance = CASE WHEN ABS(SUM(ISNULL(MD.Porcentaje_Default, 0)) - 1.0) < 0.001 THEN 'Balanceado' ELSE 'Revisar' END
FROM Modelo_Distribucion MD
INNER JOIN Modelo_Atribucion MA ON MA.ID_Modelo = MD.ID_Modelo
GROUP BY MA.Nombre
ORDER BY TotalPorcentaje DESC, Modelo;
COMMIT TRAN;
--------------------------------------------------------------

/*
Contenido publicado por streamer y tipo
Objetivo: Controlar la mezcla de formatos que publica cada streamer.
Usuario: Aadrian Estrada
Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	Streamer = LTRIM(RTRIM(CONCAT(S.Nombres, ' ', S.Apellido_Paterno, ' ', ISNULL(S.Apellido_Materno, '')))),
	TipoContenido = C.Tipo,
	Total = COUNT(C.ID_Contenido),
	ConUrl = SUM(CASE WHEN C.Url IS NOT NULL THEN 1 ELSE 0 END)
FROM Contenido C
INNER JOIN Cuenta_Plataforma CP ON CP.ID_Cuenta = C.ID_Cuenta
INNER JOIN Streamer S ON S.ID_Streamer = CP.ID_Streamer
GROUP BY S.Nombres, S.Apellido_Paterno, S.Apellido_Materno, C.Tipo
ORDER BY Streamer, TipoContenido;
COMMIT TRAN;
--------------------------------------------------------------

/*
10.  Telemetria de calidad y clasificacion de streams
     Objetivo: Clasificar transmisiones segun estabilidad tecnica registrada.
     Usuario: Equipo Qawana
     Fecha: 11/11/2025
*/
BEGIN TRAN;
SELECT
	T.ID_Transimision,
	MaxBitrate = MAX(ISNULL(TC.Bitrate, 0)),
	MinBitrate = MIN(ISNULL(TC.Bitrate, 0)),
	PromedioBitrate = AVG(ISNULL(TC.Bitrate, 0)),
	FramesPerdidos = SUM(ISNULL(TC.Dropped_Frames, 0)),
	LatenciaPromedio = AVG(ISNULL(TC.Latencia, 0)),
	Calidad = CASE
		WHEN AVG(ISNULL(TC.Bitrate, 0)) >= 6000 AND AVG(ISNULL(TC.Latencia, 0)) <= 120 THEN 'OPTIMO'
		WHEN AVG(ISNULL(TC.Bitrate, 0)) >= 3500 AND AVG(ISNULL(TC.Latencia, 0)) <= 200 THEN 'ACEPTABLE'
		ELSE 'CRITICO'
	END
FROM Telemetria_Calidad TC
INNER JOIN Transimision T ON T.ID_Transimision = TC.ID_Transimision
GROUP BY T.ID_Transimision
ORDER BY Calidad, T.ID_Transimision;
COMMIT TRAN;
--------------------------------------------------------------
