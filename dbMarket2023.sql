USE master;
--Poner en uso la Base Datos dbMarket2023
USE dbMarket2023; 

 drop DATABASE dbMarket2023;

--CREAR la Base Datos dbMarket2023
CREATE DATABASE dbMarket2023
ON
(
    NAME = Market2023,
    FILENAME = 'C:\VENTAS\Market2023.mdf',
    SIZE = 15MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
);


ALTER DATABASE dbMarket2023
ADD FILE
(
    NAME = Market2023_Data,
    FILENAME = 'C:\VENTAS\Market2023.ndf',
    SIZE = 30MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 25%
);

ALTER DATABASE dbMarket2023
ADD LOG
(
    NAME = Market2023_Log,
    FILENAME = 'C:\VENTAS\Market2023.ldf',
    SIZE = 60MB,
    MAXSIZE = 150MB,
    FILEGROWTH = 20%
);

--Formato de fecha
SET DATEFORMAT dmy
GO

--Crear los esquemas
--PERSONA
CREATE SCHEMA PERSONA AUTHORIZATION dbo;
GO
--Descripción
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Esquema persona', 
@level0type=N'SCHEMA',@level0name=N'PERSONA';

--PRODUCTO
CREATE SCHEMA PRODUCTO AUTHORIZATION dbo;
GO
--Descripción
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Esquema producto', 
@level0type=N'SCHEMA',@level0name=N'Producto';

--VENTAS
CREATE SCHEMA VENTAS AUTHORIZATION dbo;
GO
--Descripción
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Esquema ventas', 
@level0type=N'SCHEMA', @level0name=N'VENTAS';



--Crear la tabla PERSONA
CREATE TABLE PERSONA (
    IDPER INT IDENTITY(200, 1) PRIMARY KEY, --El identificador de la tabla es auto incrementable
    DNIPER CHAR(8),
    NOMPER VARCHAR(50),
    APEPER VARCHAR(50),
    EMAPER VARCHAR(100),
    CELPER CHAR(9),
    TIPPER CHAR(1), -- El tipo de persona se refiere "V" a Vendedor y "C" a Cliente.
    ESTPER CHAR(1) DEFAULT 'A', --El estado de la persona por default es A de activo
    FECNACPER DATE --El campo FECNACPER es Fecha de Nacimiento de tipo DATE
);

-- Insertamos los registros en la tabla "PERSONA"
INSERT INTO PERSONA (DNIPER, NOMPER, APEPER, EMAPER, CELPER, TIPPER, FECNACPER)
VALUES
('77889955', 'Alberto', 'Solano Pariona', 'alberto.pariona@empresa.com', '998456321', 'V', '1970-02-10'),
('45781233', 'Alicia', 'García Campos', 'alicia.garcia@gmail.com', '929185236', 'C', '1980-03-20'),
('15487922', 'Juana', 'Ávila Chumpitaz', 'juana.avila@gmail.com', '923568741', 'C', '1986-06-06'),
('22116633', 'Ana', 'Enriquez Flores', 'ana.enriquez@empresa.com', '978848551', 'V', '1970-02-10'),
('88741589', 'Claudia', 'Perales Ortíz', 'claudia.perales@yahoo.com', '997845263', 'C', '1981-07-25'),
('45122587', 'Mario', 'Barrios Martinez', 'mario.barrios@outlook.com', '986525874', 'C', '1987-10-10'),
('15285864', 'Brunela', 'Tarazona Guerra', 'brunela.tarazona@gmail.com', '986525877', 'C', '1990-06-06');

SELECT * FROM PERSONA;



-- Crear la tabla CATEGORIA
CREATE TABLE CATEGORIA (
    IDCAT INT IDENTITY(10, 10) PRIMARY KEY, --El identificador de la tabla es auto incrementable
    NOMCAT VARCHAR(50)
);

-- Insertamos los registros en la tabla "CATEGORIA"
INSERT INTO CATEGORIA (NOMCAT)
VALUES
('ABARROTES'),
('CARNES Y POLLO'),
('HIGIENE y LIMPIEZA');

SELECT * FROM CATEGORIA;



-- Creamos la tabla "PRODUCTO"
CREATE TABLE PRODUCTO (
    CODPRO VARCHAR(10),
    NOMPRO VARCHAR(50),
    PREPRO DECIMAL(10, 2), --El PREPRO se refiere a precio y debe ser tipo decimal.
    STOCKPRO INT,
    IDCATPRO INT,
    ESTPRO CHAR(1) DEFAULT 'A' --El estado del producto por default es A de activo.
);

-- Insertamos los registros en la tabla "PRODUCTO"
INSERT INTO PRODUCTO (CODPRO, NOMPRO, PREPRO, STOCKPRO, IDCATPRO)
VALUES
('P01', 'Arroz', 4.65, 50, 10),
('P02', 'Azúcar', 2.45, 60, 10),
('P03', 'Pollo fresco', 3.45, 20, 20),
('P04', 'Lomo fino', 18.50, 40, 20),
('P05', 'Detergente Opal', 8.75, 60, 30),
('P06', 'Suavizante Ariel', 7.85, 30, 30);

SELECT * FROM PRODUCTO;

--Relación
-- Creamos la clave foránea para la relación entre PRODUCTO e IDCATPRO de CATEGORIA
ALTER TABLE PRODUCTO
ADD CONSTRAINT FK_Producto_Categoria
FOREIGN KEY (IDCATPRO)
REFERENCES CATEGORIA (IDCAT);



-- Creamos la tabla "VENTA"
CREATE TABLE VENTA (
    IDVEN INT IDENTITY(1, 1) PRIMARY KEY, --El identificador de la tabla es auto incrementable.
    FECVENT DATETIME DEFAULT GETDATE(), --La fecha de venta es obtenida del sistema de manera predetermina.
    IDVEND INT NOT NULL,
    IDCLI INT NOT NULL,
    TIPPAGVEN CHAR(1) CHECK (TIPPAGVEN IN ('E', 'T')), --El TIPPAGVEN se refiere a tipo de pago 'E' (efectivo) y 'T' (transferencia). 
    ESTVEN CHAR(1) DEFAULT 'A' --El estado de la VENTA por defauul es A de activo.
);

-- Insertamos los registros en la tabla "VENTA"
INSERT INTO VENTA (IDVEND, IDCLI, TIPPAGVEN)
VALUES
(200, 202, 'E'),
(200, 204, 'T'),
(203, 205, 'T'),
(203, 206, 'E');

SELECT * FROM VENTA;


--Creación de relaciones con las tablas
--VENTA con VENDEDORES
ALTER TABLE VENTA
ADD CONSTRAINT FK_Venta_Vendedor
FOREIGN KEY (IDVEND)
REFERENCES PERSONA (IDPER);

--VENTA con CLIENTES
ALTER TABLE VENTA
ADD CONSTRAINT FK_Venta_Cliente
FOREIGN KEY (IDCLI)
REFERENCES PERSONA (IDPER);



-- Creamos la tabla "VENTA_DETALLE"
CREATE TABLE VENTA_DETALLE (
    IDVENDET INT IDENTITY(300, 1) PRIMARY KEY, --El identificador de la tabla es auto incrementable.
    IDVEN INT,
    CODPRO VARCHAR(10),
    CANVENDET NUMERIC(10, 2)--El campo CANVENDET
);

-- Insertamos los registros en la tabla "VENTA_DETALLE"
INSERT INTO VENTA_DETALLE (IDVEN, CODPRO, CANVENDET)
VALUES
(1,'P01', 2),
(1,'P04', 4);

SELECT * FROM VENTA_DETALLE;


DROP TABLE PERSONA;

--Creacioón de relaciones con las tablas
-- Relacionar VENTA_DETALLE con VENTA
ALTER TABLE VENTA_DETALLE
ADD CONSTRAINT FK_VENTA_DETALLE_VENTA
FOREIGN KEY (IDVEN) REFERENCES VENTA(IDVEN);

-- Cambiar la definición de la columna CODPRO en la tabla PRODUCTO
ALTER TABLE PRODUCTO
ALTER COLUMN CODPRO VARCHAR(10) NOT NULL;

-- Definir la columna CODPRO como clave primaria en la tabla PRODUCTO
ALTER TABLE PRODUCTO
ADD CONSTRAINT PK_PRODUCTO_CODPRO PRIMARY KEY (CODPRO);

-- Relacionar VENTA_DETALLE con PRODUCTO
ALTER TABLE VENTA_DETALLE
ADD CONSTRAINT FK_VENTA_DETALLE_PRODUCTO
FOREIGN KEY (CODPRO) REFERENCES PRODUCTO(CODPRO);


--Organización de las tablas esquemas
-- Creamos el esquema "PERSONA"
CREATE SCHEMA PERSONA; 

-- Movemos la tabla "PERSONA" al esquema "PERSONA"
ALTER SCHEMA PERSONA TRANSFER dbo.PERSONA;

-- Creamos el esquema "PRODUCTO"
CREATE SCHEMA PRODUCTO; 

-- Movemos las tablas "PRODUCTO" y "CATEGORIA" al esquema "PRODUCTO"
ALTER SCHEMA PRODUCTO TRANSFER dbo.PRODUCTO;
ALTER SCHEMA PRODUCTO TRANSFER dbo.CATEGORIA;

-- Creamos el esquema "VENTA"
CREATE SCHEMA VENTA;

-- Movemos las tablas "VENTA" y "VENTA_DETALLE" al esquema "VENTA"
ALTER SCHEMA VENTA TRANSFER dbo.VENTA;
ALTER SCHEMA VENTA TRANSFER dbo.VENTA_DETALLE;

--Detener la BD 
USE master;
ALTER DATABASE dbMarket2023 SET OFFLINE;

--Mover archivos
USE master;
ALTER DATABASE dbMarket2023 
MODIFY FILE (NAME = dbMarket2023, FILENAME = 'C:\BDSYSTEMS\dbMarket2023.mdf');

ALTER DATABASE dbMarket2023 
MODIFY FILE (NAME = [NombreLógicoNDF], FILENAME = 'C:\BDSYSTEMS\[NombreArchivoNDF].ndf');
ALTER DATABASE dbMarket2023 
MODIFY FILE (NAME = [NombreLógicoNDF2], FILENAME = 'C:\BDSYSTEMS\[NombreArchivoNDF2].ndf');
-- Modifica el archivo de registro de transacciones
ALTER DATABASE dbMarket2023 
MODIFY FILE (NAME = dbMarket2023_Log, FILENAME = 'C:\BDSYSTEMS\dbMarket2023.ldf');

--Poner en linea la BD
ALTER DATABASE dbMarket2023 SET ONLINE;

