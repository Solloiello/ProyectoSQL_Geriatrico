DROP DATABASE IF EXISTS geriatrico_sol;
CREATE DATABASE geriatrico_sol;
USE geriatrico_sol;
CREATE TABLE Cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(100)
);

CREATE TABLE Empleado (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    id_cargo INT,
    turno VARCHAR(20),
    FOREIGN KEY (id_cargo) REFERENCES Cargo(id_cargo)
);

CREATE TABLE Paciente (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni VARCHAR(20) UNIQUE,
    fecha_ingreso DATE,
    estado_salud TEXT
);

CREATE TABLE Familiar (
    id_familiar INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    telefono VARCHAR(20),
    relacion VARCHAR(50),
    id_paciente INT,
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente)
);

CREATE TABLE Habitacion (
    id_habitacion INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(10),
    tipo VARCHAR(20),
    capacidad INT,
    disponible BOOLEAN
);

CREATE TABLE AsignacionHabitacion (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    id_habitacion INT,
    fecha_asignacion DATE,
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente),
    FOREIGN KEY (id_habitacion) REFERENCES Habitacion(id_habitacion)
);

CREATE TABLE Pago (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    fecha_pago DATE,
    monto DECIMAL(10,2),
    medio_pago VARCHAR(50),
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente)
);

CREATE TABLE Visita (
    id_visita INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    nombre_familiar VARCHAR(100),
    fecha_visita DATE,
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente)
);

CREATE TABLE Servicio (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(100),
    costo DECIMAL(10,2)
);

CREATE TABLE Medicamento (
    id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    dosis VARCHAR(50),
    id_paciente INT,
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente)
);
-- Cargos
INSERT INTO Cargo (descripcion) VALUES ('Médico'), ('Enfermero'), ('Cocinero');

-- Empleados
INSERT INTO Empleado (nombre, apellido, id_cargo, turno)
VALUES ('Carlos', 'Pérez', 1, 'Mañana'),
       ('María', 'Gómez', 2, 'Tarde');

-- Pacientes
INSERT INTO Paciente (nombre, apellido, dni, fecha_ingreso, estado_salud)
VALUES ('Ernesto', 'López', '12345678', '2024-05-01', 'Hipertensión'),
       ('Marta', 'Fernández', '87654321', '2024-04-15', 'Diabetes');

-- Habitaciones
INSERT INTO Habitacion (numero, tipo, capacidad, disponible)
VALUES ('101A', 'Individual', 1, TRUE),
       ('102B', 'Compartida', 2, TRUE);

-- Pagos
INSERT INTO Pago (id_paciente, fecha_pago, monto, medio_pago)
VALUES (1, '2024-06-01', 120000, 'Transferencia'),
       (2, '2024-06-05', 115000, 'Efectivo');
       
-- VISTAS
-- ==============================

CREATE VIEW pagos_paciente AS
SELECT p.nombre, p.apellido, SUM(pa.monto) AS total_pagado
FROM Paciente p
JOIN Pago pa ON p.id_paciente = pa.id_paciente
GROUP BY p.id_paciente;

CREATE VIEW empleados_con_cargo AS
SELECT e.nombre, e.apellido, c.descripcion AS cargo, e.turno
FROM Empleado e
JOIN Cargo c ON e.id_cargo = c.id_cargo;

CREATE VIEW visitas_recientes AS
SELECT p.nombre, p.apellido, v.nombre_familiar, v.fecha_visita
FROM Paciente p
JOIN Visita v ON p.id_paciente = v.id_paciente
WHERE v.fecha_visita >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

CREATE VIEW medicamentos_por_paciente AS
SELECT p.nombre, p.apellido, m.nombre AS medicamento, m.dosis
FROM Paciente p
JOIN Medicamento m ON p.id_paciente = m.id_paciente;

CREATE VIEW habitaciones_ocupadas AS
SELECT h.numero, h.tipo, h.capacidad, a.fecha_asignacion
FROM Habitacion h
JOIN AsignacionHabitacion a ON h.id_habitacion = a.id_habitacion;

-- ==============================
-- FUNCIONES
-- ==============================

DELIMITER $$
CREATE FUNCTION calcular_edad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION total_pagos_paciente(id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10,2);
  SELECT SUM(monto) INTO total FROM Pago WHERE id_paciente = id;
  RETURN total;
END$$
DELIMITER ;

-- ==============================
-- PROCEDIMIENTOS
-- ==============================

DELIMITER $$
CREATE PROCEDURE registrar_visita(
  IN p_id_paciente INT,
  IN p_nombre_familiar VARCHAR(100),
  IN p_fecha DATE
)
BEGIN
  INSERT INTO Visita (id_paciente, nombre_familiar, fecha_visita)
  VALUES (p_id_paciente, p_nombre_familiar, p_fecha);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE asignar_habitacion(
  IN p_id_paciente INT,
  IN p_id_habitacion INT,
  IN p_fecha DATE
)
BEGIN
  INSERT INTO AsignacionHabitacion (id_paciente, id_habitacion, fecha_asignacion)
  VALUES (p_id_paciente, p_id_habitacion, p_fecha);

  UPDATE Habitacion
  SET disponible = FALSE
  WHERE id_habitacion = p_id_habitacion;
END$$
DELIMITER ;

-- ==============================
-- TRIGGERS
-- ==============================

-- Trigger para registrar logs de pago
CREATE TABLE IF NOT EXISTS LogPagos (
  id_log INT PRIMARY KEY AUTO_INCREMENT,
  id_paciente INT,
  monto DECIMAL(10,2),
  fecha_registro DATETIME
);

DELIMITER $$
CREATE TRIGGER log_pago_insert
AFTER INSERT ON Pago
FOR EACH ROW
BEGIN
  INSERT INTO LogPagos (id_paciente, monto, fecha_registro)
  VALUES (NEW.id_paciente, NEW.monto, NOW());
END$$
DELIMITER ;

-- Trigger para liberar habitación cuando se elimina asignación
DELIMITER $$
CREATE TRIGGER Trigger_LiberarHabitacion_AfterDelete
AFTER DELETE ON AsignacionHabitacion
FOR EACH ROW
BEGIN
  UPDATE Habitacion
  SET disponible = TRUE
  WHERE id_habitacion = OLD.id_habitacion;
END$$
DELIMITER ;




INSERT INTO Cargo (descripcion) VALUES ('Médico'), ('Enfermero'), ('Cocinero');

-- Empleados
INSERT INTO Empleado (nombre, apellido, id_cargo, turno)
VALUES ('Carlos', 'Pérez', 1, 'Mañana'),
       ('María', 'Gómez', 2, 'Tarde');

-- Pacientes
INSERT INTO Paciente (nombre, apellido, dni, fecha_ingreso, estado_salud)
VALUES ('Roberto', 'López', '12345679', '2024-06-01', 'Hipertensión'),
       ('Marta', 'Concha', '87654322', '2024-04-16', 'Diabetes');

-- Habitaciones
INSERT INTO Habitacion (numero, tipo, capacidad, disponible)
VALUES ('101A', 'Individual', 1, TRUE),
       ('102B', 'Compartida', 2, TRUE);

-- Pagos
INSERT INTO Pago (id_paciente, fecha_pago, monto, medio_pago)
VALUES (1, '2024-06-01', 120000, 'Transferencia'),
       (2, '2024-06-05', 115000, 'Efectivo');

USE geriatrico_sol;
SELECT 
DATE_FORMAT(fecha_pago, '%Y-%m') AS mes,
SUM(monto) AS total_recaudado
FROM Pago
GROUP BY mes;
SELECT 
    p.nombre,
    p.apellido,
    COUNT(v.id_visita) AS cantidad_visitas
FROM Paciente p
JOIN Visita v ON p.id_paciente = v.id_paciente
GROUP BY p.id_paciente
ORDER BY cantidad_visitas DESC;
SELECT 
    p.nombre,
    p.apellido,
    COUNT(m.id_medicamento) AS cantidad_medicamentos
FROM Paciente p
JOIN Medicamento m ON p.id_paciente = m.id_paciente
GROUP BY p.id_paciente
ORDER BY cantidad_medicamentos DESC;
SELECT 
    turno,
    COUNT(id_empleado) AS cantidad_empleados
FROM Empleado
GROUP BY turno;
INSERT INTO Visita (id_paciente, nombre_familiar, fecha_visita)
VALUES 
(1, 'Lucía López', '2024-06-10'),
(1, 'Lucía López', '2024-06-25'),
(2, 'Carlos Concha', '2024-06-20'),
(2, 'Carlos Concha', '2024-06-22');
INSERT INTO Medicamento (nombre, dosis, id_paciente)
VALUES 
('Enalapril', '10mg', 1),
('Metformina', '500mg', 2),
('Losartán', '50mg', 1),
('Insulina', '5U', 2),
('Paracetamol', '500mg', 1);
