modelo-logico.sql
-- Archivo: modelo-logico.sql
-- Descripción: Definición del modelo lógico de la base de datos para el Sistema Core Bancario.

-- ====================================================================================
-- Tabla: Clientes
-- Almacena la información personal de los clientes del banco.
-- ====================================================================================
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1), -- ID único del cliente, autoincremental
    TipoIdentificacion VARCHAR(10) NOT NULL, -- Ej: 'CEDULA', 'PASAPORTE', 'RUC'
    NumeroIdentificacion VARCHAR(20) NOT NULL UNIQUE, -- Número de cédula, pasaporte o RUC
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    FechaNacimiento DATE,
    Direccion VARCHAR(255),
    Telefono VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Estado VARCHAR(15) DEFAULT 'ACTIVO' -- Ej: 'ACTIVO', 'INACTIVO', 'BLOQUEADO'
);
GO

-- ====================================================================================
-- Tabla: TiposCuenta
-- Define los diferentes tipos de cuentas bancarias (ej: Ahorros, Corriente, Pagaré).
-- ====================================================================================
CREATE TABLE TiposCuenta (
    TipoCuentaID INT PRIMARY KEY IDENTITY(1,1), -- ID único del tipo de cuenta
    NombreTipo VARCHAR(50) NOT NULL UNIQUE, -- Ej: 'Cuenta de Ahorros', 'Cuenta Corriente'
    Descripcion VARCHAR(255),
    TasaInteres DECIMAL(5,4) DEFAULT 0.00 -- Tasa de interés anual (ej: 0.0150 para 1.50%)
);
GO

-- ====================================================================================
-- Tabla: Cuentas
-- Almacena las cuentas bancarias de los clientes.
-- ====================================================================================
CREATE TABLE Cuentas (
    CuentaID INT PRIMARY KEY IDENTITY(1,1), -- ID único de la cuenta
    NumeroCuenta VARCHAR(20) NOT NULL UNIQUE, -- Número de cuenta único generado por el sistema
    ClienteID INT NOT NULL, -- FK a la tabla Clientes
    TipoCuentaID INT NOT NULL, -- FK a la tabla TiposCuenta
    Saldo DECIMAL(18,2) DEFAULT 0.00, -- Saldo actual de la cuenta
    FechaApertura DATETIME DEFAULT GETDATE(),
    EstadoCuenta VARCHAR(15) DEFAULT 'ACTIVA', -- Ej: 'ACTIVA', 'CERRADA', 'BLOQUEADA'
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
    FOREIGN KEY (TipoCuentaID) REFERENCES TiposCuenta(TipoCuentaID)
);
GO

-- ====================================================================================
-- Tabla: Transacciones
-- Registra todos los movimientos monetarios de las cuentas.
-- ====================================================================================
CREATE TABLE Transacciones (
    TransaccionID BIGINT PRIMARY KEY IDENTITY(1,1), -- ID único de la transacción
    CuentaOrigenID INT, -- FK a la tabla Cuentas (si aplica, ej: transferencias, retiros)
    CuentaDestinoID INT, -- FK a la tabla Cuentas (si aplica, ej: transferencias, depósitos)
    TipoTransaccion VARCHAR(50) NOT NULL, -- Ej: 'DEPOSITO', 'RETIRO', 'TRANSFERENCIA', 'PAGO_SERVICIO'
    Monto DECIMAL(18,2) NOT NULL,
    FechaTransaccion DATETIME DEFAULT GETDATE(),
    Descripcion VARCHAR(255),
    EstadoTransaccion VARCHAR(15) DEFAULT 'COMPLETADA', -- Ej: 'COMPLETADA', 'PENDIENTE', 'FALLIDA'
    ReferenciaExterna VARCHAR(100), -- Para integrar con pagos externos
    FOREIGN KEY (CuentaOrigenID) REFERENCES Cuentas(CuentaID),
    FOREIGN KEY (CuentaDestinoID) REFERENCES Cuentas(CuentaID)
);
GO

-- ====================================================================================
-- Tabla: UsuariosSistema
-- Almacena los usuarios que accederán al sistema bancario (ej: empleados del banco).
-- Esto es distinto a los Clientes.
-- ====================================================================================
CREATE TABLE UsuariosSistema (
    UsuarioID INT PRIMARY KEY IDENTITY(1,1),
    NombreUsuario VARCHAR(50) NOT NULL UNIQUE,
    ContrasenaHash VARCHAR(255) NOT NULL, -- Aquí se almacenaría el hash de la contraseña
    Salt VARCHAR(255), -- Para sal de la contraseña (buena práctica de seguridad)
    Email VARCHAR(100) UNIQUE,
    Rol VARCHAR(50) NOT NULL, -- Ej: 'ADMIN', 'GERENTE', 'CAJERO', 'SOPORTE'
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Estado VARCHAR(15) DEFAULT 'ACTIVO'
);
GO

-- ====================================================================================
-- Tabla: LogsAuditoria
-- Registra eventos importantes del sistema para auditoría y seguridad.
-- ====================================================================================
CREATE TABLE LogsAuditoria (
    LogID BIGINT PRIMARY KEY IDENTITY(1,1),
    UsuarioID INT, -- FK a UsuariosSistema si un usuario del sistema realiza la acción
    ClienteID INT, -- FK a Clientes si la acción es sobre un cliente
    TipoEvento VARCHAR(50) NOT NULL, -- Ej: 'LOGIN_EXITOSO', 'FALLO_LOGIN', 'CREAR_CUENTA', 'MODIFICAR_SALDO'
    DetalleEvento VARCHAR(MAX),
    FechaEvento DATETIME DEFAULT GETDATE(),
    DireccionIP VARCHAR(45),
    FOREIGN KEY (UsuarioID) REFERENCES UsuariosSistema(UsuarioID),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);
GO