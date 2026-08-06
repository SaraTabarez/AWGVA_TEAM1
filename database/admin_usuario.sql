-- ============================================================
-- AWGVA - Cuenta ADMIN única y funcional
-- Ejecutar con F5 en Oracle SQL Developer.
-- Es idempotente: si la cuenta ya existe, actualiza sus datos.
-- ============================================================

ALTER TABLE USUARIO MODIFY (PASSWORD_HASH VARCHAR2(255));

MERGE INTO DIVISION d
USING (SELECT 'DATID' AS DIVISION FROM DUAL) x
ON (UPPER(TRIM(d.DIVISION)) = x.DIVISION)
WHEN NOT MATCHED THEN
    INSERT (DIVISION) VALUES (x.DIVISION);

MERGE INTO ROL r
USING (SELECT 'ADMIN' AS ROL FROM DUAL) x
ON (UPPER(TRIM(r.ROL)) = x.ROL)
WHEN NOT MATCHED THEN
    INSERT (ROL) VALUES (x.ROL);

MERGE INTO USUARIO destino
USING (
    SELECT
        'admin.awgva@utez.edu.mx' AS CORREO,
        'pbkdf2$210000$de0e933682dc42ddd8d6fd223f226508$393f34759e4d0b41544066fe61865778954c9a748c5a50f97f66db0ea3e825f5' AS PASSWORD_HASH,
        'Administrador' AS NOMBRES,
        'General' AS APELLIDO_PATERNO,
        'AWGVA' AS APELLIDO_MATERNO,
        r.ID_ROL AS ID_ROL_FK,
        d.ID_DIVISION AS ID_DIVISION_FK
    FROM ROL r
    JOIN DIVISION d ON UPPER(TRIM(d.DIVISION)) = 'DATID'
    WHERE UPPER(TRIM(r.ROL)) = 'ADMIN'
) origen
ON (LOWER(destino.CORREO) = LOWER(origen.CORREO))
WHEN MATCHED THEN UPDATE SET
    destino.PASSWORD_HASH = origen.PASSWORD_HASH,
    destino.NOMBRES = origen.NOMBRES,
    destino.APELLIDO_PATERNO = origen.APELLIDO_PATERNO,
    destino.APELLIDO_MATERNO = origen.APELLIDO_MATERNO,
    destino.ID_ROL_FK = origen.ID_ROL_FK,
    destino.ID_DIVISION_FK = origen.ID_DIVISION_FK,
    destino.ESTADO = 1,
    destino.ACTUALIZADO_EN = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN INSERT (
    CORREO, PASSWORD_HASH, NOMBRES, APELLIDO_PATERNO, APELLIDO_MATERNO,
    ID_ROL_FK, ID_DIVISION_FK, ESTADO, CREADO_EN
) VALUES (
    origen.CORREO, origen.PASSWORD_HASH, origen.NOMBRES,
    origen.APELLIDO_PATERNO, origen.APELLIDO_MATERNO,
    origen.ID_ROL_FK, origen.ID_DIVISION_FK, 1, CURRENT_TIMESTAMP
);

COMMIT;

SELECT u.ID_USUARIO, u.CORREO, r.ROL, d.DIVISION, u.ESTADO
FROM USUARIO u
JOIN ROL r ON r.ID_ROL = u.ID_ROL_FK
LEFT JOIN DIVISION d ON d.ID_DIVISION = u.ID_DIVISION_FK
WHERE LOWER(u.CORREO) = 'admin.awgva@utez.edu.mx';

-- Acceso inicial:
-- Correo: admin.awgva@utez.edu.mx
-- Contraseña: Admin#2026!
-- Cambia la contraseña al entrar por primera vez.
