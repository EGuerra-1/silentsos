-- Crear la base de datos
CREATE DATABASE VeterinariaDB;

-- Usar la base de datos
\c VeterinariaDB;

-- Tabla de Usuarios
CREATE TABLE Usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    rol VARCHAR(20) CHECK (rol IN ('admin', 'user')) NOT NULL,  -- Roles: 'admin' o 'user'
    clave VARCHAR(255) NOT NULL  -- Clave o contraseña del usuario
);

-- Tabla de Propietarios (Dueños)
CREATE TABLE Propietarios (
    id SERIAL PRIMARY KEY,
    id_usuario INT,  -- Relación con la tabla Usuarios (ID del usuario que gestionó al propietario)
    email VARCHAR(100),  -- Solo almacenamos el email en este caso
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id)
);

-- Tabla de Tipo de Mascotas
CREATE TABLE TipoMascota (
    id SERIAL PRIMARY KEY,
    tipo_nombre VARCHAR(50) NOT NULL  -- Ejemplo: Perro, Gato, Conejo, etc.
);

-- Tabla de Razas
CREATE TABLE Razas (
    id SERIAL PRIMARY KEY,
    raza_nombre VARCHAR(100) NOT NULL,  -- Ejemplo: Labrador, Persa, Bulldog, etc.
    id_tipo_mascota INT,  -- Relación con la tabla TipoMascota
    FOREIGN KEY (id_tipo_mascota) REFERENCES TipoMascota(id)
);

-- Tabla de Mascotas
CREATE TABLE Mascotas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_tipo INT,  -- Relación con la tabla TipoMascota
    id_raza INT,  -- Relación con la tabla Razas
    edad INT,  -- Edad de la mascota en años
    sexo VARCHAR(6) CHECK (sexo IN ('Macho', 'Hembra')) NOT NULL,  -- Sexo de la mascota: 'Macho' o 'Hembra'
    id_propietario INT,  -- Relación con la tabla Propietarios
    FOREIGN KEY (id_tipo) REFERENCES TipoMascota(id),
    FOREIGN KEY (id_raza) REFERENCES Razas(id),
    FOREIGN KEY (id_propietario) REFERENCES Propietarios(id)
);

-- Tabla de Medicamentos
CREATE TABLE Medicamentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,  -- Nombre del medicamento
    descripcion TEXT  -- Descripción del medicamento
);

-- Tabla de Tratamientos
CREATE TABLE Tratamientos (
    id SERIAL PRIMARY KEY,
    id_mascota INT,  -- Relación con la tabla Mascotas
    quien_asigno INT,  -- Relación con la tabla Usuarios (ID del usuario que asignó el tratamiento)
    fecha_inicio DATE,
    fecha_fin DATE,
    detalles TEXT,  -- Detalles del tratamiento
    FOREIGN KEY (id_mascota) REFERENCES Mascotas(id),
    FOREIGN KEY (quien_asigno) REFERENCES Usuarios(id)
);

-- Tabla de Medicamentos Asignados a Tratamientos (actualización)
CREATE TABLE MedicamentosTratamiento (
    id SERIAL PRIMARY KEY,
    id_tratamiento INT,  -- Relación con la tabla Tratamientos
    id_medicamento INT,  -- Relación con la tabla Medicamentos
    recomendacion TEXT,  -- Texto con la recomendación completa
    dosis VARCHAR(100),  -- Ejemplo: 1 tableta cada 8 horas
    cantidad INT,  -- Cantidad disponible del medicamento para ese tratamiento
    es_de_por_vida BOOLEAN DEFAULT FALSE,  -- Indica si el medicamento es de por vida
    fecha_fin DATE,  -- Fecha hasta cuando debe tomarse el medicamento, si no es de por vida
    FOREIGN KEY (id_tratamiento) REFERENCES Tratamientos(id),
    FOREIGN KEY (id_medicamento) REFERENCES Medicamentos(id)
);

-- Tabla de Historial Médico de las Mascotas
CREATE TABLE HistorialMedico (
    id SERIAL PRIMARY KEY,
    id_mascota INT,  -- Relación con la tabla Mascotas
    fecha_visita DATE,
    motivo TEXT,
    diagnostico TEXT,
    tratamiento TEXT,
    FOREIGN KEY (id_mascota) REFERENCES Mascotas(id)
);

-- Tabla de Citas Veterinarias (actualizada con estado y sin delete cascade)
CREATE TABLE Citas (
    id SERIAL PRIMARY KEY,
    id_mascota INT,  -- Relación con la tabla Mascotas
    fecha_cita DATE,
    hora TIME,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Confirmada', 'Cancelada', 'Realizada')),  -- Estado de la cita
    FOREIGN KEY (id_mascota) REFERENCES Mascotas(id)
);
