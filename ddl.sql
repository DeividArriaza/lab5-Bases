-- ============================================================
-- CC3008 - Bases de Datos 1 | Lab 5 - Vistas y Transacciones
-- DDL - Biblioteca Universitaria (PostgreSQL)
-- ============================================================

-- ------------------------------------------------------------
-- Autores
-- ------------------------------------------------------------
CREATE TABLE autor (
    id_autor      SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    apellido      VARCHAR(100) NOT NULL,
    nacionalidad  VARCHAR(100) NOT NULL
);

-- ------------------------------------------------------------
-- Libros
-- ------------------------------------------------------------
CREATE TABLE libro (
    id_libro            SERIAL PRIMARY KEY,
    titulo              VARCHAR(255) NOT NULL,
    isbn                VARCHAR(20)  NOT NULL UNIQUE,
    id_autor            INT          NOT NULL REFERENCES autor(id_autor),
    anio                INT          NOT NULL CHECK (anio > 0),
    genero              VARCHAR(100) NOT NULL,
    copias_disponibles  INT          NOT NULL DEFAULT 0 CHECK (copias_disponibles >= 0),
    copias_totales      INT          NOT NULL CHECK (copias_totales > 0),
    CHECK (copias_disponibles <= copias_totales)
);

-- ------------------------------------------------------------
-- Categorías
-- ------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria  SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- Relación libro - categoría (N:M)
-- ------------------------------------------------------------
CREATE TABLE libro_categoria (
    id_libro      INT NOT NULL REFERENCES libro(id_libro),
    id_categoria  INT NOT NULL REFERENCES categoria(id_categoria),
    PRIMARY KEY (id_libro, id_categoria)
);

-- ------------------------------------------------------------
-- Lectores
-- ------------------------------------------------------------
CREATE TABLE lector (
    id_lector  SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    apellido   VARCHAR(100) NOT NULL,
    carnet     VARCHAR(20)  NOT NULL UNIQUE,
    carrera    VARCHAR(150) NOT NULL
);

-- ------------------------------------------------------------
-- Préstamos
-- ------------------------------------------------------------
CREATE TABLE prestamo (
    id_prestamo                 SERIAL PRIMARY KEY,
    id_libro                    INT  NOT NULL REFERENCES libro(id_libro),
    id_lector                   INT  NOT NULL REFERENCES lector(id_lector),
    fecha_prestamo              DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion_esperada   DATE NOT NULL,
    fecha_devolucion_real       DATE,
    estado                      VARCHAR(20) NOT NULL DEFAULT 'activo'
                                    CHECK (estado IN ('activo', 'devuelto', 'vencido')),
    CHECK (fecha_devolucion_esperada > fecha_prestamo)
);

-- ------------------------------------------------------------
-- Multas
-- ------------------------------------------------------------
CREATE TABLE multa (
    id_multa    SERIAL PRIMARY KEY,
    id_prestamo INT            NOT NULL REFERENCES prestamo(id_prestamo),
    monto       NUMERIC(10, 2) NOT NULL CHECK (monto > 0),
    pagado      BOOLEAN        NOT NULL DEFAULT FALSE
);
