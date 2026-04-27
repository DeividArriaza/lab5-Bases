-- Ejercicio 1.1--
CREATE VIEW titulo_libro AS
SELECT l.titulo, a.nombre, a.apellido
FROM libro l
JOIN autor a ON l.id_autor = a.id_autor

--Ejercicio 1.2--
CREATE VIEW lectores AS
SELECT l.carnet, l.carrera
FROM lector l

--Ejercicio 1.3--
CREATE VIEW prestamos_activos AS
SELECT p.estado, l.titulo
FROM prestamo p
JOIN libro l ON p.id_libro = l.id_libro
WHERE p.estado = 'activo'

--Ejercicio 1.4--
CREATE VIEW copia_disponible AS
SELECT l.titulo, l.copias_disponibles
FROM libro l
WHERE l.copias_disponibles >= 1

--Ejercicio 1.5--
CREATE VIEW autores_nacionalidad AS
SELECT a.nombre, a.apellido, a.nacionalidad
FROM autor a

--Ejercicio 1.6--
CREATE VIEW multas_lector AS
SELECT m.id_multa, l.nombre, l.apellido
FROM multa m
JOIN prestamo p ON m.id_prestamo = p.id_prestamo
JOIN lector l ON p.id_lector = l.id_lector

--Ejercicio 2.1--
CREATE VIEW prestamos_lector AS
SELECT l.id_lector, l.nombre, l.apellido, COUNT(*) AS total_prestamos
FROM prestamo p
JOIN lector l ON p.id_lector = l.id_lector
GROUP BY l.id_lector, l.nombre, l.apellido

--Ejercicio 2.2--
CREATE VIEW libros_categorias AS
SELECT l.id_libro, l.titulo, c.nombre AS categoria
FROM libro l
JOIN libro_categoria lc ON l.id_libro = lc.id_libro
JOIN categoria c ON lc.id_categoria = c.id_categoria

--Ejercicio 2.4--
CREATE VIEW libros_por_autor AS
SELECT a.id_autor, a.nombre, a.apellido, COUNT(*) AS total_libros
FROM libro l
JOIN autor a ON l.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre, a.apellido

--Ejercicio 2.5--
CREATE VIEW libros_mas_prestados AS
SELECT l.id_libro, l.titulo, COUNT(*) AS total_prestamos
FROM prestamo p
JOIN libro l ON p.id_libro = l.id_libro
GROUP BY l.id_libro, l.titulo
ORDER BY total_prestamos DESC

--Ejercicio 3.1--
CREATE VIEW prestamos_vencidos AS
SELECT l.id_libro, l.titulo, p.id_prestamo, p.fecha_devolucion_esperada
FROM prestamo p
JOIN libro l ON p.id_libro = l.id_libro
WHERE p.fecha_devolucion_esperada < CURRENT_DATE
  AND p.estado = 'activo'

--Ejercicio 3.3--
CREATE VIEW prestamo_completo AS
SELECT
p.id_prestamo,
  p.fecha_prestamo,
  p.fecha_devolucion_esperada,
  p.estado,
  l.titulo,
  a.nombre AS autor_nombre,
  a.apellido AS autor_apellido,
  le.nombre AS lector_nombre,
  le.apellido AS lector_apellido,
  le.carnet
FROM prestamo p
JOIN libro l ON p.id_libro = l.id_libro
JOIN autor a ON l.id_autor = a.id_autor
JOIN lector le ON p.id_lector = le.id_lector

--Ejercicio 4.2--
CREATE VIEW libros_con_prestamos AS
SELECT l.id_libro, l.titulo, a.nacionalidad, COUNT(*) AS total_prestamos
FROM prestamo p
JOIN libro l ON p.id_libro = l.id_libro
JOIN autor a ON l.id_autor = a.id_autor
GROUP BY l.id_libro, l.titulo, a.nacionalidad

CREATE VIEW libros_latinos_populares AS
SELECT *
FROM libros_con_prestamos
WHERE total_prestamos > 5
  AND nacionalidad IN ('argentina','boliviana','brasileña','chilena','colombiana',
                       'costarricense','cubana','dominicana','ecuatoriana','guatemalteca',
                       'hondureña','mexicana','nicaragüense','panameña','paraguaya',
                       'peruana','salvadoreña','uruguaya','venezolana')

--Ejercicio 3.2--
-- Transacción: registra un nuevo préstamo y descuenta una copia del libro.
-- Si el libro no tiene copias disponibles, la restricción CHECK
-- (copias_disponibles >= 0) hace que el UPDATE falle y debemos hacer ROLLBACK
-- para que ni el descuento ni el préstamo queden guardados.

-- Paso 1: abrimos la transacción. A partir de aquí los cambios son temporales
-- hasta que se ejecute COMMIT o ROLLBACK.
BEGIN;

-- Paso 2: descontamos una copia disponible del libro elegido (id_libro = 1).
-- Si copias_disponibles ya era 0, este UPDATE viola el CHECK y la transacción
-- queda abortada (los pasos siguientes ya no se ejecutan).
UPDATE libro
SET copias_disponibles = copias_disponibles - 1
WHERE id_libro = 1;

-- Paso 3: insertamos el registro del préstamo: libro 1, lector 1,
-- con fecha de devolución esperada 14 días después de hoy.
INSERT INTO prestamo (id_libro, id_lector, fecha_devolucion_esperada)
VALUES (1, 1, CURRENT_DATE + 14);

-- Paso 4: si los dos pasos anteriores fueron exitosos confirmamos los
-- cambios y la transacción queda guardada en la base.
COMMIT;

-- Paso 4 alterno (en caso de error por falta de copias o cualquier otro fallo):
-- en lugar del COMMIT anterior se ejecutaría este ROLLBACK para deshacer todo.
-- ROLLBACK;

