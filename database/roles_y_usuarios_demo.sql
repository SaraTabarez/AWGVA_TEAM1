-- ============================================================
-- AWGVA - Roles y usuarios de demostración para Oracle
-- Adaptado a la estructura real de tu base de datos:
--
-- ROL(ID_ROL, ROL, DESCRIPCION, FECHA_CREACION)
-- DIVISION(ID_DIVISION, DIVISION, DESCRIPCION, FECHA_CREACION)
-- USUARIO(ID_USUARIO, CORREO, PASSWORD_HASH, NOMBRES,
--         APELLIDO_PATERNO, APELLIDO_MATERNO, ID_ROL_FK,
--         ID_DIVISION_FK, ESTADO, CREADO_EN, ACTUALIZADO_EN,
--         RESET_TOKEN, RESET_TOKEN_EXPIRATION)
-- ============================================================


-- PBKDF2 necesita aproximadamente 112 caracteres.
-- Se asegura suficiente espacio para almacenar los hashes.
ALTER TABLE USUARIO
    MODIFY (PASSWORD_HASH VARCHAR2(255));


-- ============================================================
-- 1. VERIFICAR/CREAR ROLES
-- ============================================================
-- En tu base de datos estos roles ya existen:
-- DOCENTE  = 21
-- ADMIN    = 22
-- ESTADIAS = 41
-- DIRECTOR = 42
--
-- MERGE evita insertarlos nuevamente si ya existen.
-- ============================================================

MERGE INTO ROL destino
    USING (
        SELECT 'DOCENTE' AS NOMBRE_ROL FROM DUAL

        UNION ALL

        SELECT 'DIRECTOR' AS NOMBRE_ROL FROM DUAL

        UNION ALL

        SELECT 'ESTADIAS' AS NOMBRE_ROL FROM DUAL

        UNION ALL

        SELECT 'ADMIN' AS NOMBRE_ROL FROM DUAL
    ) origen
    ON (
        UPPER(TRIM(destino.ROL)) = origen.NOMBRE_ROL
        )
    WHEN NOT MATCHED THEN
        INSERT (ROL)
            VALUES (origen.NOMBRE_ROL);


-- ============================================================
-- 2. CREAR O ACTUALIZAR USUARIOS DE DEMOSTRACIÓN
-- ============================================================
-- DOCENTE y DIRECTOR pertenecen a DATID.
-- ESTADIAS no necesita división. ADMIN usa DATID para poder ejecutar también los flujos de Docente y Director.
--
-- Si los correos ya existen, se actualizan.
-- Si no existen, se insertan.
-- ============================================================

MERGE INTO USUARIO destino
    USING (
        SELECT
            datos.CORREO,
            datos.PASSWORD_HASH,
            datos.NOMBRES,
            datos.APELLIDO_PATERNO,
            datos.APELLIDO_MATERNO,
            rol.ID_ROL AS ID_ROL_FK,
            division.ID_DIVISION AS ID_DIVISION_FK
        FROM (
                 -- Usuario DOCENTE
                 SELECT
                     'docente.awgva@utez.edu.mx' AS CORREO,
                     'pbkdf2$210000$717daeba2fc06ae6289db977ec35fffe$f31335bbc5c609a93b410e81d1a5e80ef886fbb6aa2f3143af8c1090dcb93e2c'
                                                 AS PASSWORD_HASH,
                     'Docente' AS NOMBRES,
                     'Prueba' AS APELLIDO_PATERNO,
                     'AWGVA' AS APELLIDO_MATERNO,
                     'DOCENTE' AS NOMBRE_ROL,
                     'DATID' AS NOMBRE_DIVISION
                 FROM DUAL

                 UNION ALL

                 -- Usuario DIRECTOR
                 SELECT
                     'director.awgva@utez.edu.mx',
                     'pbkdf2$210000$7d0e9bb7b6b217c64534c91e5694162b$29aefb0e1af73936f9c37004f8733809ca786d581e4fb3e8f38a3acd648a6d83',
                     'Director',
                     'Prueba',
                     'AWGVA',
                     'DIRECTOR',
                     'DATID'
                 FROM DUAL

                 UNION ALL

                 -- Usuario ESTADIAS
                 SELECT
                     'estadias.awgva@utez.edu.mx',
                     'pbkdf2$210000$22ee89bc3d12ba5d1f2e2df6db5f9fa0$298bc8880d05fbf4afb4f1ae2157d26899cbcd947a99a18b2b87139e30e08851',
                     'Responsable',
                     'Estadias',
                     'AWGVA',
                     'ESTADIAS',
                     NULL
                 FROM DUAL

                 UNION ALL

                 -- Usuario ADMIN
                 SELECT
                     'admin.awgva@utez.edu.mx',
                     'pbkdf2$210000$de0e933682dc42ddd8d6fd223f226508$393f34759e4d0b41544066fe61865778954c9a748c5a50f97f66db0ea3e825f5',
                     'Administrador',
                     'General',
                     'AWGVA',
                     'ADMIN',
                     'DATID'
                 FROM DUAL
             ) datos

                 -- La columna real de la tabla ROL se llama ROL.
                 JOIN ROL rol
                      ON UPPER(TRIM(rol.ROL)) = datos.NOMBRE_ROL

            -- La columna real de la tabla DIVISION se llama DIVISION.
                 LEFT JOIN DIVISION division
                           ON UPPER(TRIM(division.DIVISION)) = datos.NOMBRE_DIVISION
    ) origen

    ON (
        LOWER(destino.CORREO) = LOWER(origen.CORREO)
        )

    WHEN MATCHED THEN
        UPDATE SET
            destino.PASSWORD_HASH = origen.PASSWORD_HASH,
            destino.NOMBRES = origen.NOMBRES,
            destino.APELLIDO_PATERNO = origen.APELLIDO_PATERNO,
            destino.APELLIDO_MATERNO = origen.APELLIDO_MATERNO,
            destino.ID_ROL_FK = origen.ID_ROL_FK,
            destino.ID_DIVISION_FK = origen.ID_DIVISION_FK,
            destino.ESTADO = 1,
            destino.ACTUALIZADO_EN = CURRENT_TIMESTAMP

    WHEN NOT MATCHED THEN
        INSERT (
                CORREO,
                PASSWORD_HASH,
                NOMBRES,
                APELLIDO_PATERNO,
                APELLIDO_MATERNO,
                ID_ROL_FK,
                ID_DIVISION_FK,
                ESTADO,
                CREADO_EN
            )
            VALUES (
                       origen.CORREO,
                       origen.PASSWORD_HASH,
                       origen.NOMBRES,
                       origen.APELLIDO_PATERNO,
                       origen.APELLIDO_MATERNO,
                       origen.ID_ROL_FK,
                       origen.ID_DIVISION_FK,
                       1,
                       CURRENT_TIMESTAMP
                   );


COMMIT;


-- ============================================================
-- 3. COMPROBACIÓN FINAL
-- ============================================================

SELECT
    u.ID_USUARIO,
    u.CORREO,
    u.NOMBRES,
    u.APELLIDO_PATERNO,
    r.ROL,
    NVL(d.DIVISION, 'SIN DIVISION') AS DIVISION,
    u.ESTADO
FROM USUARIO u
         JOIN ROL r
              ON r.ID_ROL = u.ID_ROL_FK
         LEFT JOIN DIVISION d
                   ON d.ID_DIVISION = u.ID_DIVISION_FK
WHERE u.CORREO IN (
                   'docente.awgva@utez.edu.mx',
                   'director.awgva@utez.edu.mx',
                   'estadias.awgva@utez.edu.mx',
                   'admin.awgva@utez.edu.mx'
    )
ORDER BY r.ROL;


-- ============================================================
-- USUARIOS Y CONTRASEÑAS INICIALES
-- ============================================================
-- DOCENTE:
-- docente.awgva@utez.edu.mx
-- Docente#2026!
--
-- DIRECTOR:
-- director.awgva@utez.edu.mx
-- Director#2026!
--
-- ESTADIAS:
-- estadias.awgva@utez.edu.mx
-- Estadias#2026!
--
-- ADMIN:
-- admin.awgva@utez.edu.mx
-- Admin#2026!
-- ============================================================