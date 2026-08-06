-- ============================================================================
-- AWGVA - Actualización idempotente para Docente, Director y Estadías
-- Oracle / SQL Developer. Se puede ejecutar más de una vez sin duplicar datos.
-- Ejecutar con F5 (Run Script), no con Ctrl+Enter, porque contiene bloques "/".
-- ============================================================================

SET DEFINE OFF;

-- 1. Amplía catálogos existentes para los nuevos estados y tipos.
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE VISITA MODIFY (ESTADO VARCHAR2(40))';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-1440, -1451) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE DOCUMENTO MODIFY (TIPO_DOCUMENTO VARCHAR2(40))';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-1440, -1451) THEN RAISE; END IF;
END;
/

-- 2. Agrega sólo las columnas que todavía no existen.
DECLARE
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'VISITA' AND COLUMN_NAME = 'MOTIVO_RECHAZO';
    IF v_total = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE VISITA ADD (MOTIVO_RECHAZO VARCHAR2(500))';
    END IF;

    SELECT COUNT(*) INTO v_total FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'DOCUMENTO' AND COLUMN_NAME = 'ESTADO';
    IF v_total = 0 THEN
        EXECUTE IMMEDIATE q'[ALTER TABLE DOCUMENTO ADD (ESTADO VARCHAR2(20) DEFAULT 'PENDIENTE' NOT NULL)]';
    END IF;

    SELECT COUNT(*) INTO v_total FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'DOCUMENTO' AND COLUMN_NAME = 'OBSERVACIONES';
    IF v_total = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE DOCUMENTO ADD (OBSERVACIONES VARCHAR2(500))';
    END IF;

    SELECT COUNT(*) INTO v_total FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'DOCUMENTO' AND COLUMN_NAME = 'ID_REVISOR_FK';
    IF v_total = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE DOCUMENTO ADD (ID_REVISOR_FK NUMBER)';
    END IF;

    SELECT COUNT(*) INTO v_total FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'DOCUMENTO' AND COLUMN_NAME = 'REVISADO_EN';
    IF v_total = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE DOCUMENTO ADD (REVISADO_EN TIMESTAMP)';
    END IF;
END;
/

-- 3. Normaliza datos anteriores. Se usa DECODE dentro de PL/SQL para evitar
--    el ORA-00933 que algunas configuraciones de SQL Developer mostraron al
--    ejecutar el UPDATE con CASE como sentencia aislada.
BEGIN
    EXECUTE IMMEDIATE q'[
        UPDATE VISITA
           SET ESTADO = DECODE(
               UPPER(TRIM(ESTADO)),
               'PENDIENTE', 'PENDIENTE_DIRECTOR',
               'ACEPTADA', 'ACEPTADA_DIRECTOR',
               'RECHAZADA', 'RECHAZADA_DIRECTOR',
               UPPER(TRIM(ESTADO))
           )
    ]';
END;
/

BEGIN
    EXECUTE IMMEDIATE q'[
        UPDATE DOCUMENTO
           SET TIPO_DOCUMENTO = DECODE(
               UPPER(REPLACE(TRIM(TIPO_DOCUMENTO), ' ', '_')),
               'SOLICITUD', 'SOLICITUD_VISITA',
               'SOLICITUD_DE_VISITA', 'SOLICITUD_VISITA',
               'CARTA', 'CARTA_RESPONSIVA',
               'REPORTE_DE_VISITA', 'REPORTE',
               UPPER(REPLACE(TRIM(TIPO_DOCUMENTO), ' ', '_'))
           ),
               ESTADO = NVL(UPPER(TRIM(ESTADO)), 'PENDIENTE')
    ]';
END;
/

-- 4. Divisiones requeridas.
MERGE INTO DIVISION d
USING (
    SELECT 'DATID' DIVISION FROM DUAL UNION ALL
    SELECT 'DAMI' FROM DUAL UNION ALL
    SELECT 'DATEFI' FROM DUAL UNION ALL
    SELECT 'DACEA' FROM DUAL
) x
ON (UPPER(TRIM(d.DIVISION)) = x.DIVISION)
WHEN NOT MATCHED THEN INSERT (DIVISION) VALUES (x.DIVISION);

-- 5. Roles requeridos.
MERGE INTO ROL r
USING (
    SELECT 'DOCENTE' ROL FROM DUAL UNION ALL
    SELECT 'DIRECTOR' FROM DUAL UNION ALL
    SELECT 'ESTADIAS' FROM DUAL UNION ALL
    SELECT 'ADMIN' FROM DUAL
) x
ON (UPPER(TRIM(r.ROL)) = x.ROL)
WHEN NOT MATCHED THEN INSERT (ROL) VALUES (x.ROL);

-- 6. Un Docente y un Director por división. Los MERGE también corrigen la
--    división/rol si las cuentas ya fueron creadas en una ejecución anterior.
MERGE INTO USUARIO u
USING (
    SELECT datos.CORREO, datos.PASSWORD_HASH, datos.NOMBRES,
           datos.APELLIDO_PATERNO, datos.APELLIDO_MATERNO,
           r.ID_ROL AS ID_ROL_FK, d.ID_DIVISION AS ID_DIVISION_FK
    FROM (
        SELECT 'docente.datid@utez.edu.mx' CORREO,
               'pbkdf2$210000$717daeba2fc06ae6289db977ec35fffe$f31335bbc5c609a93b410e81d1a5e80ef886fbb6aa2f3143af8c1090dcb93e2c' PASSWORD_HASH,
               'Docente' NOMBRES, 'Prueba' APELLIDO_PATERNO, 'DATID' APELLIDO_MATERNO, 'DOCENTE' ROL, 'DATID' DIVISION FROM DUAL
        UNION ALL SELECT 'docente.dami@utez.edu.mx',
               'pbkdf2$210000$717daeba2fc06ae6289db977ec35fffe$f31335bbc5c609a93b410e81d1a5e80ef886fbb6aa2f3143af8c1090dcb93e2c',
               'Docente', 'Prueba', 'DAMI', 'DOCENTE', 'DAMI' FROM DUAL
        UNION ALL SELECT 'docente.datefi@utez.edu.mx',
               'pbkdf2$210000$717daeba2fc06ae6289db977ec35fffe$f31335bbc5c609a93b410e81d1a5e80ef886fbb6aa2f3143af8c1090dcb93e2c',
               'Docente', 'Prueba', 'DATEFI', 'DOCENTE', 'DATEFI' FROM DUAL
        UNION ALL SELECT 'docente.dacea@utez.edu.mx',
               'pbkdf2$210000$717daeba2fc06ae6289db977ec35fffe$f31335bbc5c609a93b410e81d1a5e80ef886fbb6aa2f3143af8c1090dcb93e2c',
               'Docente', 'Prueba', 'DACEA', 'DOCENTE', 'DACEA' FROM DUAL
        UNION ALL SELECT 'director.datid@utez.edu.mx',
               'pbkdf2$210000$7d0e9bb7b6b217c64534c91e5694162b$29aefb0e1af73936f9c37004f8733809ca786d581e4fb3e8f38a3acd648a6d83',
               'Director', 'Prueba', 'DATID', 'DIRECTOR', 'DATID' FROM DUAL
        UNION ALL SELECT 'director.dami@utez.edu.mx',
               'pbkdf2$210000$7d0e9bb7b6b217c64534c91e5694162b$29aefb0e1af73936f9c37004f8733809ca786d581e4fb3e8f38a3acd648a6d83',
               'Director', 'Prueba', 'DAMI', 'DIRECTOR', 'DAMI' FROM DUAL
        UNION ALL SELECT 'director.datefi@utez.edu.mx',
               'pbkdf2$210000$7d0e9bb7b6b217c64534c91e5694162b$29aefb0e1af73936f9c37004f8733809ca786d581e4fb3e8f38a3acd648a6d83',
               'Director', 'Prueba', 'DATEFI', 'DIRECTOR', 'DATEFI' FROM DUAL
        UNION ALL SELECT 'director.dacea@utez.edu.mx',
               'pbkdf2$210000$7d0e9bb7b6b217c64534c91e5694162b$29aefb0e1af73936f9c37004f8733809ca786d581e4fb3e8f38a3acd648a6d83',
               'Director', 'Prueba', 'DACEA', 'DIRECTOR', 'DACEA' FROM DUAL
    ) datos
    JOIN ROL r ON UPPER(TRIM(r.ROL)) = datos.ROL
    JOIN DIVISION d ON UPPER(TRIM(d.DIVISION)) = datos.DIVISION
) x
ON (LOWER(u.CORREO) = LOWER(x.CORREO))
WHEN MATCHED THEN UPDATE SET
    u.PASSWORD_HASH = x.PASSWORD_HASH,
    u.NOMBRES = x.NOMBRES,
    u.APELLIDO_PATERNO = x.APELLIDO_PATERNO,
    u.APELLIDO_MATERNO = x.APELLIDO_MATERNO,
    u.ID_ROL_FK = x.ID_ROL_FK,
    u.ID_DIVISION_FK = x.ID_DIVISION_FK,
    u.ESTADO = 1,
    u.ACTUALIZADO_EN = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN INSERT (
    CORREO, PASSWORD_HASH, NOMBRES, APELLIDO_PATERNO, APELLIDO_MATERNO,
    ID_ROL_FK, ID_DIVISION_FK, ESTADO, CREADO_EN
) VALUES (
    x.CORREO, x.PASSWORD_HASH, x.NOMBRES, x.APELLIDO_PATERNO,
    x.APELLIDO_MATERNO, x.ID_ROL_FK, x.ID_DIVISION_FK, 1, CURRENT_TIMESTAMP
);

-- Conserva las cuentas AWGVA del proyecto base y las asigna a DATID.
UPDATE USUARIO
SET ID_DIVISION_FK = (SELECT ID_DIVISION FROM DIVISION WHERE UPPER(TRIM(DIVISION)) = 'DATID' FETCH FIRST 1 ROWS ONLY),
    ACTUALIZADO_EN = CURRENT_TIMESTAMP
WHERE LOWER(CORREO) IN ('docente.awgva@utez.edu.mx', 'director.awgva@utez.edu.mx');

COMMIT;

-- 7. Comprobación final.
SELECT u.CORREO, r.ROL, NVL(d.DIVISION, 'TODAS') AS DIVISION, u.ESTADO
FROM USUARIO u
JOIN ROL r ON r.ID_ROL = u.ID_ROL_FK
LEFT JOIN DIVISION d ON d.ID_DIVISION = u.ID_DIVISION_FK
WHERE LOWER(u.CORREO) IN (
    'docente.datid@utez.edu.mx', 'docente.dami@utez.edu.mx',
    'docente.datefi@utez.edu.mx', 'docente.dacea@utez.edu.mx',
    'director.datid@utez.edu.mx', 'director.dami@utez.edu.mx',
    'director.datefi@utez.edu.mx', 'director.dacea@utez.edu.mx',
    'estadias.awgva@utez.edu.mx'
)
ORDER BY r.ROL, d.DIVISION;

-- Contraseñas de prueba:
--   Docentes:   Docente#2026!
--   Directores: Director#2026!
--   Estadías:   Estadias#2026!  (cuenta del archivo roles_y_usuarios_demo.sql)
