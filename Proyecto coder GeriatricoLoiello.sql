-- Crear base de datos
CREATE DATABASE IF NOT EXISTS geriatrico_sol;
USE geriatrico_sol;

-- Tabla: Cargo
CREATE TABLE Cargo (
    id_cargo INT PRIMARY KEY,
    descripcion VARCHAR(100)
);

-- Tabla: Empleado
CREATE TABLE Empleado (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    id_cargo INT,
    FOREIGN KEY (id_cargo) REFERENCES Cargo(id_cargo)
);

-- Tabla: Residente
CREATE TABLE Residente (
    id_residente INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    estado_salud VARCHAR(100)
);

-- Tabla: Familiar
CREATE TABLE Familiar (
    id_familiar INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    telefono VARCHAR(20),
    id_residente INT,
    FOREIGN KEY (id_residente) REFERENCES Residente(id_residente)
);

-- Tabla: Pago
CREATE TABLE Pago (
    id_pago INT PRIMARY KEY,
    fecha_pago DATE,
    monto DECIMAL(10,2),
    id_residente INT,
    FOREIGN KEY (id_residente) REFERENCES Residente(id_residente)
);

-- Tabla: Turno_Medico
CREATE TABLE Turno_Medico (
    id_turno INT PRIMARY KEY,
    fecha_turno DATE,
    id_empleado INT,
    id_residente INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_residente) REFERENCES Residente(id_residente)
);

-- Insertar datos en Cargo
INSERT INTO Cargo VALUES (1, 'Médica clínica');
INSERT INTO Cargo VALUES (2, 'Enfermero');

-- Insertar datos en Empleado
INSERT INTO Empleado VALUES (1, 'Carla', 'Rivas', 1);
INSERT INTO Empleado VALUES (2, 'Daniel', 'Pereyra', 2);

-- Insertar datos en Residente
INSERT INTO Residente VALUES (1, 'Ernesto', 'Gómez', '1945-06-12', 'Hipertensión');
INSERT INTO Residente VALUES (2, 'Marta', 'Sánchez', '1938-11-23', 'Diabética');
INSERT INTO Residente VALUES (3, 'Ramón', 'López', '1940-02-15', 'Dependencia leve');

-- Insertar datos en Familiar
INSERT INTO Familiar VALUES (1, 'Laura', 'Gómez', '1155994488', 1);
INSERT INTO Familiar VALUES (2, 'Julián', 'Sánchez', '1144223366', 2);
INSERT INTO Familiar VALUES (3, 'Andrea', 'López', '1177332211', 3);

-- Insertar datos en Pago
INSERT INTO Pago VALUES (1, '2025-04-01', 120000, 1);
INSERT INTO Pago VALUES (2, '2025-04-01', 125000, 2);
INSERT INTO Pago VALUES (3, '2025-04-01', 110000, 3);

-- Insertar datos en Turno_Medico
INSERT INTO Turno_Medico VALUES (1, '2025-04-05', 1, 1);
INSERT INTO Turno_Medico VALUES (2, '2025-04-06', 2, 2);
INSERT INTO Turno_Medico VALUES (3, '2025-04-07', 1, 3);


