
CREATE TABLE 0Auth_Token
(
  ID_Token      INT           NOT NULL,
  ID_Cuenta     INT           NOT NULL,
  Access_Token  NVARCHAR(512) NOT NULL,
  Refresh_Token NVARCHAR(512) NULL    ,
  Expiracion    DATETIME      NULL    ,
  PRIMARY KEY (ID_Token)
);

CREATE TABLE Accion_Correctiva
(
  ID_Accion       INT           NOT NULL,
  ID_Incidente    INT           NOT NULL,
  Descripcion     NVARCHAR(150) NOT NULL,
  Fecha_Ejecucion DATETIME      NOT NULL,
  PRIMARY KEY (ID_Accion)
);

CREATE TABLE Agencia
(
  ID_Agencia   INT           NOT NULL,
  Nombre       NVARCHAR(150) NOT NULL,
  Ruc          NVARCHAR(20)  NULL    ,
  ID_Industria INT           NOT NULL,
  PRIMARY KEY (ID_Agencia)
);

CREATE TABLE Asignacion_Atribucion
(
  ID_Asignacion               INT   NOT NULL,
  ID_Touchpoint               INT   NOT NULL,
  ID_Evento                   INT   NOT NULL,
  ID_Modelo                   INT   NOT NULL,
  Porcentaje_Credito_Override FLOAT NULL    ,
  PRIMARY KEY (ID_Asignacion)
);

CREATE TABLE Audiencia_Agregada_Tiempo
(
  ID_Audiencia    INT      NOT NULL,
  ID_Transimision INT      NOT NULL,
  Timestamp       DATETIME NOT NULL,
  Concurrencia    INT      NULL    ,
  Tiempo_Promedio INT      NULL    ,
  PRIMARY KEY (ID_Audiencia)
);

CREATE TABLE Bloque_Silencio
(
  ID_Bloque_Silencio INT          NOT NULL,
  Dia_Semana         NVARCHAR(9)  NULL    ,
  Silencio_Inicio    NVARCHAR(50) NULL    ,
  Silencio_Fin       NVARCHAR(50) NULL    ,
  PRIMARY KEY (ID_Bloque_Silencio)
);

CREATE TABLE Campaña
(
  ID_Campaña   INT           NOT NULL,
  ID_Cliente   INT           NOT NULL,
  Nombre       NVARCHAR(100) NOT NULL,
  Fecha_Inicio DATE          NOT NULL,
  Fecha_Fin    DATE          NULL    ,
  Presupuesto  DECIMAL(12,2) NULL    ,
  PRIMARY KEY (ID_Campaña)
);

CREATE TABLE Catalogo_Canal_Notificacion
(
  ID_Canal_Notificacion    INT          NOT NULL,
  Nombre                   NVARCHAR(20) NOT NULL,
  Medio_Entrega            ENUM         NOT NULL,
  Soporta_Horario_Silencio BOOL         NOT NULL,
  PRIMARY KEY (ID_Canal_Notificacion)
);

CREATE TABLE Catalogo_Fallo_Tecnico
(
  ID_Fallo    INT           NOT NULL,
  Descripcion NVARCHAR(100) NOT NULL,
  PRIMARY KEY (ID_Fallo)
);

CREATE TABLE Catalogo_Industria
(
  ID_Industria  INT         NOT NULL,
  Nombre_Sector VARCHAR(50) NULL    ,
  PRIMARY KEY (ID_Industria)
);

CREATE TABLE Catalogo_KPI
(
  ID_Kpi        INT           NOT NULL,
  Codigo        NVARCHAR(30)  NOT NULL,
  Nombre        NVARCHAR(100) NOT NULL,
  Unidad_Medida NVARCHAR(20)  NULL    ,
  Unidad        NVARCHAR(20)  NULL    ,
  PRIMARY KEY (ID_Kpi)
);

CREATE TABLE Catalogo_Pais
(
  ID_Pais INT          NOT NULL,
  Nombre  NVARCHAR(58) NOT NULL,
  PRIMARY KEY (ID_Pais)
);

CREATE TABLE Catalogo_Scope
(
  ID_Scope     INT          NOT NULL,
  Nombre       NVARCHAR(20) NOT NULL,
  Descripcion  LINESTRING   NULL    ,
  Nivel_Acceso ENUM         NOT NULL,
  PRIMARY KEY (ID_Scope)
);

CREATE TABLE Catalogo_Tipo_Identificador
(
  ID_Tipo_Identificador INT NOT NULL,
  Descripcion               NULL    ,
  Politica_Retencion        NULL    ,
  PRIMARY KEY (ID_Tipo_Identificador)
);

CREATE TABLE Catalogo_Tipo_Propiedad
(
  ID_Tipo_Propiedad INT          NOT NULL,
  Nombre            NVARCHAR(30) NULL    ,
  Canal_Comercial   ENUM         NULL    ,
  PRIMARY KEY (ID_Tipo_Propiedad)
);

CREATE TABLE Catalogo_Tipo_Touchpoint
(
  ID_Tipo_Touchpoint INT          NOT NULL,
  Nombre             NVARCHAR(30) NOT NULL,
  Canal              ENUM         NOT NULL,
  Requiere_Tracking  BOOL         NOT NULL,
  PRIMARY KEY (ID_Tipo_Touchpoint)
);

CREATE TABLE Categoria
(
  ID_Categoria INT          NOT NULL,
  Nombre       NVARCHAR(80) NOT NULL,
  PRIMARY KEY (ID_Categoria)
);

CREATE TABLE Catlogo_Tipo_Interaccion
(
  ID_Tipo_Intraccion INT          NOT NULL,
  Nombre             NVARCHAR(30) NOT NULL,
  Retencion_Dias     INT          NOT NULL,
  Requiere_Contenido BOOLEAN      NOT NULL,
  PRIMARY KEY (ID_Tipo_Intraccion)
);

CREATE TABLE Cliente
(
  ID_Cliente   INT           NOT NULL,
  Nombre       NVARCHAR(150) NOT NULL,
  ID_Industria INT           NOT NULL,
  PRIMARY KEY (ID_Cliente)
);

CREATE TABLE Contenido
(
  ID_Contenido INT                            NOT NULL,
  ID_Cuenta    INT                            NOT NULL,
  Tipo         ENUM('clip', 'short', 'short') NOT NULL,
  Url          NVARCHAR(200)                  NULL    ,
  PRIMARY KEY (ID_Contenido)
);

CREATE TABLE Contenido_Etiqueta
(
  ID_Etiqueta  INT NOT NULL,
  ID_Categoria INT NOT NULL,
  PRIMARY KEY (ID_Etiqueta, ID_Categoria)
);

CREATE TABLE Creatividad
(
  ID_Creatividad INT                      NOT NULL,
  ID_Campaña     INT                      NOT NULL,
  Tipo           ENUM('video', 'banner')  NOT NULL,
  Url            NVARCHAR(200)            NULL    ,
  PRIMARY KEY (ID_Creatividad)
);

CREATE TABLE Cuenta_Plataforma
(
  ID_Cuenta     INT           NOT NULL,
  ID_Streamer   INT           NOT NULL,
  ID_Plataforma INT           NOT NULL,
  Handle        NVARCHAR(100) NOT NULL,
  Estado_Ouath  BOOLEAN       NULL    ,
  PRIMARY KEY (ID_Cuenta)
);

CREATE TABLE Dashboard_Slot_KPI
(
  ID_Kpi              INT  NOT NULL,
  ID_Slot             INT  NOT NULL,
  Fecha_Configuracion DATE NOT NULL,
  PRIMARY KEY (ID_Kpi, ID_Slot)
);

CREATE TABLE Dashbord_Slot
(
  ID_Slot    INT     NOT NULL,
  ID_Usuario INT     NOT NULL,
  Orden      INT     NOT NULL COMMENT 'UNIQUE',
  Visible    BOOLEAN NOT NULL,
  PRIMARY KEY (ID_Slot)
);

CREATE TABLE Etiqueta
(
  ID_Etiqueta INT          NOT NULL,
  Nombre      NVARCHAR(80) NOT NULL,
  PRIMARY KEY (ID_Etiqueta)
);

CREATE TABLE Evento_Conversion
(
  ID_Evento   INT            NOT NULL,
  ID_Objetivo INT            NOT NULL,
  Timestamp   DATETIME       NOT NULL,
  Valor       DECIMAL(10, 2) NULL    ,
  PRIMARY KEY (ID_Evento)
);

CREATE TABLE Experimento_Incrementalidad
(
  ID_Experimento INT                          NOT NULL,
  ID_Campaña     INT                          NOT NULL,
  Tipo           ENUM('holdout', 'geo-test')  NULL    ,
  Fecha_Inicio   DATE                         NULL    ,
  Fecha_Fin      DATE                         NULL    ,
  Lift_Estimado  FLOAT                        NULL    ,
  PRIMARY KEY (ID_Experimento)
);

CREATE TABLE Historial_Alertas
(
  ID_Alerta       INT           NOT NULL,
  ID_Transimision INT           NOT NULL,
  ID_Umbral       INT           NOT NULL,
  Timestamp       DATETIME      NOT NULL,
  Descripcion     NVARCHAR(200) NULL    ,
  PRIMARY KEY (ID_Alerta)
);

CREATE TABLE Identidad_Publico
(
  ID_Publico INT           NOT NULL,
  Device_ID  NVARCHAR(128) NULL    ,
  Cookie_ID  NVARCHAR(128) NULL    ,
  PRIMARY KEY (ID_Publico)
);

CREATE TABLE Incidente_Tecnico
(
  ID_Incidente          INT             NOT NULL,
  ID_Fallo              INT             NOT NULL,
  ID_Transimision       INT             NOT NULL,
  Inicio                DATETIME        NOT NULL,
  Fin                   DATETIME        NULL    ,
  Descripcion_Incidente MULTILINESTRING NOT NULL,
  Severidad             ENUM            NOT NULL,
  PRIMARY KEY (ID_Incidente)
);

CREATE TABLE Insight
(
  ID_Insight      INT                                           NOT NULL,
  ID_Transimision INT                                           NOT NULL,
  Descripcion     TEXT                                          NOT NULL,
  Tipo            ENUM('alerta', 'tendencia', 'recomendación')  NULL    ,
  PRIMARY KEY (ID_Insight)
);

CREATE TABLE Integracion_Api
(
  ID_Integracion INT                        NOT NULL,
  Proveedor      NVARCHAR(50)               NOT NULL,
  Estado         ENUM('activo', 'inactivo') NOT NULL,
  Fecha_Refresh  DATETIME                   NOT NULL,
  PRIMARY KEY (ID_Integracion)
);

CREATE TABLE Interaccion
(
  ID_Interaccion     INT      NOT NULL,
  ID_Transimision    INT      NOT NULL,
  Timestamp          DATETIME NOT NULL,
  ID_Tipo_Intraccion INT      NOT NULL,
  PRIMARY KEY (ID_Interaccion)
);

CREATE TABLE Interaccion_Detalle
(
  ID_Interaccion_Detalle INT             NOT NULL,
  ID_Interaccion         INT             NOT NULL,
  Tipo_Detalle           ENUM            NOT NULL COMMENT '(texto, adjunto, metadata',
  Contenido_Detalle      MULTILINESTRING NOT NULL,
  Orden                  INT             NULL    ,
  PRIMARY KEY (ID_Interaccion_Detalle)
);

CREATE TABLE Modelo_Atribucion
(
  ID_Modelo INT          NOT NULL,
  Nombre    NVARCHAR(50) NOT NULL,
  PRIMARY KEY (ID_Modelo)
);

CREATE TABLE Modelo_Distribucion
(
  ID_Modelo          INT   NOT NULL,
  Porcentaje_Default FLOAT NOT NULL,
  ID_Tipo_Touchpoint INT   NOT NULL,
  PRIMARY KEY (ID_Modelo, Porcentaje_Default, ID_Tipo_Touchpoint)
);

CREATE TABLE OAuth_Scope
(
  ID_Token INT NOT NULL,
  ID_Scope INT NOT NULL,
  PRIMARY KEY (ID_Token, ID_Scope)
);

CREATE TABLE Objetivo_Conversion
(
  ID_Objetivo INT                                       NOT NULL,
  ID_Campaña  INT                                       NOT NULL,
  Descripcion NVARCHAR(100)                             NOT NULL,
  Tipo        ENUM('suscripción', 'descarga', 'venta')  NULL    ,
  PRIMARY KEY (ID_Objetivo)
);

CREATE TABLE Plataforma
(
  ID_Plataforma INT           NOT NULL,
  Nombre        NVARCHAR(50)  NOT NULL,
  Url_Api       NVARCHAR(200) NULL    ,
  PRIMARY KEY (ID_Plataforma)
);

CREATE TABLE Preferencia_Notificacion
(
  ID_Preferencia        INT NOT NULL,
  ID_Streamer           INT NOT NULL,
  ID_Canal_Notificacion INT NOT NULL,
  PRIMARY KEY (ID_Preferencia)
);

CREATE TABLE Prefrencia_Bloque_Silencio
(
  ID_Preferencia     INT     NOT NULL,
  ID_Bloque_Silencio INT     NOT NULL,
  Activo             BOOLEAN NOT NULL,
  PRIMARY KEY (ID_Preferencia, ID_Bloque_Silencio)
);

CREATE TABLE Propiedad_Digital
(
  ID_Propiedad      INT           NOT NULL,
  Dominio           NVARCHAR(120) NOT NULL,
  Nombre            NVARCHAR(100) NOT NULL,
  ID_Tipo_Propiedad INT           NOT NULL,
  PRIMARY KEY (ID_Propiedad)
);

CREATE TABLE Publico_Identificador
(
  ID_Publico_Identificador INT  NOT NULL,
  ID_Publico               INT  NOT NULL,
  ID_Tipo_Identificador    INT  NOT NULL,
  Valor_Identificador      INT  NOT NULL,
  Fecha_Captura            DATE NOT NULL,
  PRIMARY KEY (ID_Publico_Identificador)
);

CREATE TABLE Region
(
  ID_Region  INT          NOT NULL,
  Nombre     NVARCHAR(80) NOT NULL,
  Codigo_Geo NVARCHAR(20) NULL    ,
  ID_Pais    INT          NOT NULL,
  PRIMARY KEY (ID_Region)
);

CREATE TABLE Resumen_Incidente
(
  ID_Resumen       INT        NOT NULL,
  ID_Resumen       INT        NOT NULL,
  Impacto_Resummen LINESTRING NULL    ,
  PRIMARY KEY (ID_Resumen, ID_Resumen)
);

CREATE TABLE Resumen_Poststream
(
  ID_Resumen      INT NOT NULL,
  Vistas_Totales  INT NULL    ,
  Tiempo_Promedio INT NULL    ,
  Pico_Audiencia  INT NULL    ,
  Incidencias     INT NULL    ,
  PRIMARY KEY (ID_Resumen)
);

CREATE TABLE Sesion
(
  ID_Sesion        INT      NOT NULL,
  ID_Publico       INT      NOT NULL,
  Timestamp_Inicio DATETIME NOT NULL,
  Timestamp_Fin    DATETIME NULL    ,
  PRIMARY KEY (ID_Sesion)
);

CREATE TABLE Software_Emision
(
  ID_Software INT          NOT NULL,
  Nombre      NVARCHAR(50) NOT NULL,
  Version     NVARCHAR(10) NOT NULL,
  PRIMARY KEY (ID_Software)
);

CREATE TABLE Streamer
(
  ID_Streamer      INT           NOT NULL,
  Nombres          NVARCHAR(100) NOT NULL,
  Apellido_Paterno NVARCHAR(60)  NOT NULL,
  Apellido_Materno NVARCHAR(60)  NULL    ,
  Fecha_Nacimiento DATE          NOT NULL,
  ID_Pais          INT           NOT NULL,
  PRIMARY KEY (ID_Streamer)
);

CREATE TABLE Streamer_Contacto
(
  ID_Contacto   INT           NOT NULL,
  ID_Streamer   INT           NOT NULL,
  Tipo_Contacto ENUM          NOT NULL,
  Valor         NVARCHAR(100) NOT NULL,
  Es_Principal  BOOLEAN       NOT NULL,
  PRIMARY KEY (ID_Contacto)
);

CREATE TABLE Telemetria_Calidad
(
  ID_Telemetria   INT      NOT NULL,
  Timestamp       DATETIME NOT NULL,
  Bitrate         INT      NULL    ,
  Dropped_Frames  INT      NULL    ,
  Latencia        INT      NULL    ,
  ID_Transimision INT      NOT NULL,
  PRIMARY KEY (ID_Telemetria)
);

CREATE TABLE Touchpoint
(
  ID_Touchpoint      INT      NOT NULL,
  ID_Campaña         INT      NOT NULL,
  Timestamp          DATETIME NOT NULL,
  ID_Tipo_Touchpoint INT      NOT NULL,
  PRIMARY KEY (ID_Touchpoint)
);

CREATE TABLE Transimision
(
  ID_Transimision INT           NOT NULL,
  ID_Software     INT           NOT NULL,
  ID_Cuenta       INT           NOT NULL,
  Titulo          NVARCHAR(150) NOT NULL,
  Fecha_Inicio    DATETIME      NOT NULL,
  Fecha_Fin       DATETIME      NOT NULL,
  Ancho_Px        INT           NOT NULL,
  Alto_Px         INT           NOT NULL,
  Fps             INT           NOT NULL,
  PRIMARY KEY (ID_Transimision)
);

CREATE TABLE Umbral_Alerta
(
  ID_Umbral   INT                         NOT NULL,
  ID_Streamer INT                         NOT NULL,
  ID_Kpi      INT                         NOT NULL,
  Operador    ENUM('<','>','<=','>=')     NOT NULL,
  Valor       FLOAT                       NOT NULL,
  Severidad   ENUM('alta','media','baja') NOT NULL,
  PRIMARY KEY (ID_Umbral)
);

CREATE TABLE Usuario
(
  ID_Usuario   INT                            NOT NULL,
  Nombre       NVARCHAR(100)                  NOT NULL,
  email        NVARCHAR(100)                  NOT NULL,
  Tipo_Usuario ENUM('Streamer', 'Publicista') NOT NULL,
  Auth_2fa     BOOLEAN                        NULL    ,
  PRIMARY KEY (ID_Usuario)
);

ALTER TABLE Cuenta_Plataforma
  ADD CONSTRAINT FK_Plataforma_TO_Cuenta_Plataforma
    FOREIGN KEY (ID_Plataforma)
    REFERENCES Plataforma (ID_Plataforma);

ALTER TABLE Transimision
  ADD CONSTRAINT FK_Software_Emision_TO_Transimision
    FOREIGN KEY (ID_Software)
    REFERENCES Software_Emision (ID_Software);

ALTER TABLE Incidente_Tecnico
  ADD CONSTRAINT FK_Catalogo_Fallo_Tecnico_TO_Incidente_Tecnico
    FOREIGN KEY (ID_Fallo)
    REFERENCES Catalogo_Fallo_Tecnico (ID_Fallo);

ALTER TABLE Campaña
  ADD CONSTRAINT FK_Cliente_TO_Campaña
    FOREIGN KEY (ID_Cliente)
    REFERENCES Cliente (ID_Cliente);

ALTER TABLE Objetivo_Conversion
  ADD CONSTRAINT FK_Campaña_TO_Objetivo_Conversion
    FOREIGN KEY (ID_Campaña)
    REFERENCES Campaña (ID_Campaña);

ALTER TABLE Creatividad
  ADD CONSTRAINT FK_Campaña_TO_Creatividad
    FOREIGN KEY (ID_Campaña)
    REFERENCES Campaña (ID_Campaña);

ALTER TABLE Evento_Conversion
  ADD CONSTRAINT FK_Objetivo_Conversion_TO_Evento_Conversion
    FOREIGN KEY (ID_Objetivo)
    REFERENCES Objetivo_Conversion (ID_Objetivo);

ALTER TABLE Touchpoint
  ADD CONSTRAINT FK_Campaña_TO_Touchpoint
    FOREIGN KEY (ID_Campaña)
    REFERENCES Campaña (ID_Campaña);

ALTER TABLE Asignacion_Atribucion
  ADD CONSTRAINT FK_Touchpoint_TO_Asignacion_Atribucion
    FOREIGN KEY (ID_Touchpoint)
    REFERENCES Touchpoint (ID_Touchpoint);

ALTER TABLE Asignacion_Atribucion
  ADD CONSTRAINT FK_Evento_Conversion_TO_Asignacion_Atribucion
    FOREIGN KEY (ID_Evento)
    REFERENCES Evento_Conversion (ID_Evento);

ALTER TABLE Asignacion_Atribucion
  ADD CONSTRAINT FK_Modelo_Atribucion_TO_Asignacion_Atribucion
    FOREIGN KEY (ID_Modelo)
    REFERENCES Modelo_Atribucion (ID_Modelo);

ALTER TABLE Experimento_Incrementalidad
  ADD CONSTRAINT FK_Campaña_TO_Experimento_Incrementalidad
    FOREIGN KEY (ID_Campaña)
    REFERENCES Campaña (ID_Campaña);

ALTER TABLE Cuenta_Plataforma
  ADD CONSTRAINT FK_Streamer_TO_Cuenta_Plataforma
    FOREIGN KEY (ID_Streamer)
    REFERENCES Streamer (ID_Streamer);

ALTER TABLE Contenido
  ADD CONSTRAINT FK_Cuenta_Plataforma_TO_Contenido
    FOREIGN KEY (ID_Cuenta)
    REFERENCES Cuenta_Plataforma (ID_Cuenta);

ALTER TABLE Preferencia_Notificacion
  ADD CONSTRAINT FK_Streamer_TO_Preferencia_Notificacion
    FOREIGN KEY (ID_Streamer)
    REFERENCES Streamer (ID_Streamer);

ALTER TABLE Umbral_Alerta
  ADD CONSTRAINT FK_Streamer_TO_Umbral_Alerta
    FOREIGN KEY (ID_Streamer)
    REFERENCES Streamer (ID_Streamer);

ALTER TABLE Umbral_Alerta
  ADD CONSTRAINT FK_Catalogo_KPI_TO_Umbral_Alerta
    FOREIGN KEY (ID_Kpi)
    REFERENCES Catalogo_KPI (ID_Kpi);

ALTER TABLE Dashbord_Slot
  ADD CONSTRAINT FK_Usuario_TO_Dashbord_Slot
    FOREIGN KEY (ID_Usuario)
    REFERENCES Usuario (ID_Usuario);

ALTER TABLE Accion_Correctiva
  ADD CONSTRAINT FK_Incidente_Tecnico_TO_Accion_Correctiva
    FOREIGN KEY (ID_Incidente)
    REFERENCES Incidente_Tecnico (ID_Incidente);

ALTER TABLE Incidente_Tecnico
  ADD CONSTRAINT FK_Transimision_TO_Incidente_Tecnico
    FOREIGN KEY (ID_Transimision)
    REFERENCES Transimision (ID_Transimision);

ALTER TABLE Telemetria_Calidad
  ADD CONSTRAINT FK_Transimision_TO_Telemetria_Calidad
    FOREIGN KEY (ID_Transimision)
    REFERENCES Transimision (ID_Transimision);

ALTER TABLE Audiencia_Agregada_Tiempo
  ADD CONSTRAINT FK_Transimision_TO_Audiencia_Agregada_Tiempo
    FOREIGN KEY (ID_Transimision)
    REFERENCES Transimision (ID_Transimision);

ALTER TABLE Transimision
  ADD CONSTRAINT FK_Cuenta_Plataforma_TO_Transimision
    FOREIGN KEY (ID_Cuenta)
    REFERENCES Cuenta_Plataforma (ID_Cuenta);

ALTER TABLE Historial_Alertas
  ADD CONSTRAINT FK_Transimision_TO_Historial_Alertas
    FOREIGN KEY (ID_Transimision)
    REFERENCES Transimision (ID_Transimision);

ALTER TABLE Historial_Alertas
  ADD CONSTRAINT FK_Umbral_Alerta_TO_Historial_Alertas
    FOREIGN KEY (ID_Umbral)
    REFERENCES Umbral_Alerta (ID_Umbral);

ALTER TABLE Insight
  ADD CONSTRAINT FK_Transimision_TO_Insight
    FOREIGN KEY (ID_Transimision)
    REFERENCES Transimision (ID_Transimision);

ALTER TABLE 0Auth_Token
  ADD CONSTRAINT FK_Cuenta_Plataforma_TO_0Auth_Token
    FOREIGN KEY (ID_Cuenta)
    REFERENCES Cuenta_Plataforma (ID_Cuenta);

ALTER TABLE Sesion
  ADD CONSTRAINT FK_Identidad_Publico_TO_Sesion
    FOREIGN KEY (ID_Publico)
    REFERENCES Identidad_Publico (ID_Publico);

ALTER TABLE Interaccion
  ADD CONSTRAINT FK_Transimision_TO_Interaccion
    FOREIGN KEY (ID_Transimision)
    REFERENCES Transimision (ID_Transimision);

ALTER TABLE Contenido_Etiqueta
  ADD CONSTRAINT FK_Etiqueta_TO_Contenido_Etiqueta
    FOREIGN KEY (ID_Etiqueta)
    REFERENCES Etiqueta (ID_Etiqueta);

ALTER TABLE Contenido_Etiqueta
  ADD CONSTRAINT FK_Categoria_TO_Contenido_Etiqueta
    FOREIGN KEY (ID_Categoria)
    REFERENCES Categoria (ID_Categoria);

ALTER TABLE Streamer_Contacto
  ADD CONSTRAINT FK_Streamer_TO_Streamer_Contacto
    FOREIGN KEY (ID_Streamer)
    REFERENCES Streamer (ID_Streamer);

ALTER TABLE Resumen_Incidente
  ADD CONSTRAINT FK_Resumen_Poststream_TO_Resumen_Incidente
    FOREIGN KEY (ID_Resumen)
    REFERENCES Resumen_Poststream (ID_Resumen);

ALTER TABLE OAuth_Scope
  ADD CONSTRAINT FK_0Auth_Token_TO_OAuth_Scope
    FOREIGN KEY (ID_Token)
    REFERENCES 0Auth_Token (ID_Token);

ALTER TABLE Publico_Identificador
  ADD CONSTRAINT FK_Identidad_Publico_TO_Publico_Identificador
    FOREIGN KEY (ID_Publico)
    REFERENCES Identidad_Publico (ID_Publico);

ALTER TABLE Interaccion_Detalle
  ADD CONSTRAINT FK_Interaccion_TO_Interaccion_Detalle
    FOREIGN KEY (ID_Interaccion)
    REFERENCES Interaccion (ID_Interaccion);

ALTER TABLE Dashboard_Slot_KPI
  ADD CONSTRAINT FK_Catalogo_KPI_TO_Dashboard_Slot_KPI
    FOREIGN KEY (ID_Kpi)
    REFERENCES Catalogo_KPI (ID_Kpi);

ALTER TABLE Dashboard_Slot_KPI
  ADD CONSTRAINT FK_Dashbord_Slot_TO_Dashboard_Slot_KPI
    FOREIGN KEY (ID_Slot)
    REFERENCES Dashbord_Slot (ID_Slot);

ALTER TABLE Prefrencia_Bloque_Silencio
  ADD CONSTRAINT FK_Preferencia_Notificacion_TO_Prefrencia_Bloque_Silencio
    FOREIGN KEY (ID_Preferencia)
    REFERENCES Preferencia_Notificacion (ID_Preferencia);

ALTER TABLE Prefrencia_Bloque_Silencio
  ADD CONSTRAINT FK_Bloque_Silencio_TO_Prefrencia_Bloque_Silencio
    FOREIGN KEY (ID_Bloque_Silencio)
    REFERENCES Bloque_Silencio (ID_Bloque_Silencio);

ALTER TABLE OAuth_Scope
  ADD CONSTRAINT FK_Catalogo_Scope_TO_OAuth_Scope
    FOREIGN KEY (ID_Scope)
    REFERENCES Catalogo_Scope (ID_Scope);

ALTER TABLE Publico_Identificador
  ADD CONSTRAINT FK_Catalogo_Tipo_Identificador_TO_Publico_Identificador
    FOREIGN KEY (ID_Tipo_Identificador)
    REFERENCES Catalogo_Tipo_Identificador (ID_Tipo_Identificador);

ALTER TABLE Modelo_Distribucion
  ADD CONSTRAINT FK_Modelo_Atribucion_TO_Modelo_Distribucion
    FOREIGN KEY (ID_Modelo)
    REFERENCES Modelo_Atribucion (ID_Modelo);

ALTER TABLE Resumen_Incidente
  ADD CONSTRAINT FK_Resumen_Poststream_TO_Resumen_Incidente1
    FOREIGN KEY (ID_Resumen)
    REFERENCES Resumen_Poststream (ID_Resumen);

ALTER TABLE Streamer
  ADD CONSTRAINT FK_Catalogo_Pais_TO_Streamer
    FOREIGN KEY (ID_Pais)
    REFERENCES Catalogo_Pais (ID_Pais);

ALTER TABLE Cliente
  ADD CONSTRAINT FK_Catalogo_Industria_TO_Cliente
    FOREIGN KEY (ID_Industria)
    REFERENCES Catalogo_Industria (ID_Industria);

ALTER TABLE Preferencia_Notificacion
  ADD CONSTRAINT FK_Catalogo_Canal_Notificacion_TO_Preferencia_Notificacion
    FOREIGN KEY (ID_Canal_Notificacion)
    REFERENCES Catalogo_Canal_Notificacion (ID_Canal_Notificacion);

ALTER TABLE Touchpoint
  ADD CONSTRAINT FK_Catalogo_Tipo_Touchpoint_TO_Touchpoint
    FOREIGN KEY (ID_Tipo_Touchpoint)
    REFERENCES Catalogo_Tipo_Touchpoint (ID_Tipo_Touchpoint);

ALTER TABLE Modelo_Distribucion
  ADD CONSTRAINT FK_Catalogo_Tipo_Touchpoint_TO_Modelo_Distribucion
    FOREIGN KEY (ID_Tipo_Touchpoint)
    REFERENCES Catalogo_Tipo_Touchpoint (ID_Tipo_Touchpoint);

ALTER TABLE Propiedad_Digital
  ADD CONSTRAINT FK_Catalogo_Tipo_Propiedad_TO_Propiedad_Digital
    FOREIGN KEY (ID_Tipo_Propiedad)
    REFERENCES Catalogo_Tipo_Propiedad (ID_Tipo_Propiedad);

ALTER TABLE Region
  ADD CONSTRAINT FK_Catalogo_Pais_TO_Region
    FOREIGN KEY (ID_Pais)
    REFERENCES Catalogo_Pais (ID_Pais);

ALTER TABLE Agencia
  ADD CONSTRAINT FK_Catalogo_Industria_TO_Agencia
    FOREIGN KEY (ID_Industria)
    REFERENCES Catalogo_Industria (ID_Industria);

ALTER TABLE Interaccion
  ADD CONSTRAINT FK_Catlogo_Tipo_Interaccion_TO_Interaccion
    FOREIGN KEY (ID_Tipo_Intraccion)
    REFERENCES Catlogo_Tipo_Interaccion (ID_Tipo_Intraccion);
