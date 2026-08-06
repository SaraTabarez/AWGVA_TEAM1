<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="mx.edu.utez.awgva.Model.SolicitudVisita" %>
<%@ page import="java.util.List" %>
<%
    // Recuperar la solicitud de la sesión usando el index
    List<SolicitudVisita> lista = (List<SolicitudVisita>) session.getAttribute("listaSolicitudes");
    SolicitudVisita sol = null;

    String indexParam = request.getParameter("index");
    if (lista != null && !lista.isEmpty() && indexParam != null) {
        try {
            int indexNum = Integer.parseInt(indexParam);
            if (indexNum >= 0 && indexNum < lista.size()) {
                sol = lista.get(indexNum);
            }
        } catch (NumberFormatException e) {
            sol = new SolicitudVisita(); // Evitar nulos si falla
        }
    } else {
        sol = new SolicitudVisita(); // Objeto vacío por seguridad
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oficio de Visita Institucional - UTEZ</title>
    <style>
        :root {
            --primary-green: #556B2F;
            --secondary-gold: #A0522D;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: Arial, Helvetica, sans-serif; font-size: 10pt; line-height: 1.5; background-color: #f0f0f0; padding: 20px;
        }
        .documento { width: 21cm; min-height: 29.7cm; margin: 0 auto; background: white; box-shadow: 0 0 10px rgba(0,0,0,0.1); position: relative; display: flex; flex-direction: column; }
        .contenido-oficio { padding: 2.5cm 2.5cm; flex: 1; }
        .top-section { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; width: 100%; }
        .logos-container { display: flex; align-items: center; gap: 12px; margin-left: 0; padding-left: 0; }
        .header-section { display: flex; align-items: center; gap: 8px; }
        .logo-graphic { background-size: contain; background-repeat: no-repeat; background-position: left center; }
        /* Si no tienes estas imágenes, los div se verán invisibles pero no romperán el layout */
        .edu-logo .logo-graphic { background-image: url('education_graphic.png'); width: 45px; height: 45px; }
        .utez-logo .logo-graphic { background-image: url('utez_graphic.png'); width: 35px; height: 35px; }
        .logo-text { display: flex; flex-direction: column; text-align: left; }
        .logo-text h1 { margin: 0; font-size: 16px; font-weight: bold; color: var(--primary-green); letter-spacing: 0.5px; line-height: 1.1; }
        .logo-text p { margin: 0; font-size: 7px; color: var(--secondary-gold); letter-spacing: 0; white-space: nowrap; }
        .utez-text h1 { font-style: italic; font-size: 15px; }
        .divider { width: 1px; height: 35px; background-color: var(--secondary-gold); }
        .doc-info { font-size: 8.5pt; flex: 0 0 auto; margin-left: 10px; }
        .doc-info-row { display: grid; grid-template-columns: 110px 1fr; margin-bottom: 2px; }
        .lema { text-align: right; font-weight: bold; font-size: 9pt; margin-top: 25px; margin-bottom: 20px; }
        .fecha-lugar { text-align: right; margin-bottom: 40px; font-size: 10pt; }
        .destinatario { margin-bottom: 30px; font-size: 10pt; font-weight: bold; text-transform: uppercase; text-align: left; }
        .cuerpo { text-align: justify; margin-bottom: 25px; font-size: 10pt; }
        .datos-visita { display: grid; grid-template-columns: 180px 1fr; gap: 15px 10px; margin-bottom: 40px; font-size: 10pt; }
        .despedida { font-weight: bold; margin-bottom: 60px; font-size: 10pt; text-align: left; }
        .firma { font-weight: bold; text-transform: uppercase; font-size: 10pt; text-align: left; }
        .copias { margin-top: 40px; font-size: 7pt; color: #555; line-height: 1.2; text-align: left; }
        footer { width: 100%; background-color: #fff; padding-bottom: 20px; }
        .footer-contact { text-align: center; color: var(--secondary-gold); margin-bottom: 5px; }
        .footer-contact p { margin: 2px 0; font-size: 9pt; }
        .footer-pattern { height: 30px; background-image: url('footer_pattern.png'); background-repeat: repeat-x; background-position: bottom; background-size: contain; }
        @media print { body { background: white; padding: 0; } .documento { box-shadow: none; } .btn-print-container { display: none; } }
    </style>
</head>
<body>
<div class="documento">
    <div class="contenido-oficio">
        <div class="top-section">
            <div class="logos-container">
                <div class="header-section edu-logo"><div class="logo-graphic"></div><div class="logo-text"><h1>EDUCACIÓN</h1><p>SECRETARÍA DE EDUCACIÓN</p></div></div>
                <div class="divider"></div>
                <div class="header-section utez-logo"><div class="logo-graphic"></div><div class="logo-text utez-text"><h1>UTEZ</h1><p>UNIVERSIDAD TECNOLÓGICA</p><p>EMILIANO ZAPATA DEL ESTADO DE MORELOS</p></div></div>
            </div>
            <div class="doc-info">
                <div class="doc-info-row"><div>Dependencia:</div><div>UTEZ</div></div>
                <div class="doc-info-row"><div>Departamento:</div><div>Estadías</div></div>
                <div class="doc-info-row"><div>Número de Oficio:</div><div>UTEZ/EST/INT/034/2026</div></div>
            </div>
        </div>

        <div class="lema">"2026, año de Margarita Maza Parada"</div>
        <div class="fecha-lugar">Emiliano Zapata, Morelos.</div>

        <div class="destinatario">
            <p>MTRO. EDUARDO PORCAYO PALAFOX</p>
            <p>DIRECTOR DE LA DIVISIÓN ACADÉMICA DE MECÁNICA INDUSTRIAL</p>
            <p>PRESENTE</p>
        </div>

        <div class="cuerpo">
            <p>Por medio del presente, comunico a usted que la visita institucional que se realizará a <strong><%= sol.getEmpresaNombre() != null ? sol.getEmpresaNombre() : "_____________" %></strong> por parte del programa educativo (Asignaturas: <strong><%= sol.getAsignaturas() != null ? sol.getAsignaturas() : "_____________" %></strong>), ha quedado confirmada.</p>
        </div>

        <div class="datos-visita">
            <div>Fecha de la salida:</div>
            <div><strong><%= sol.getFechaInicio() != null ? sol.getFechaInicio() : "_____________" %></strong></div>

            <div>Hora:</div>
            <div><strong><%= sol.getHoraInicio() != null ? sol.getHoraInicio() : "_____________" %></strong></div>

            <div>Número de estudiantes<br>asistentes:</div>
            <div><strong><%= sol.getTotalEstudiantes() != null ? sol.getTotalEstudiantes() : "_____________" %></strong></div>

            <div>Docente Responsable:</div>
            <div><strong><%= sol.getSolicitanteNombre() != null ? sol.getSolicitanteNombre() : "_____________" %></strong></div>

            <div>Reglas de seguridad:</div>
            <div>Los estudiantes deberán de contar con el seguro facultativo vigente, portar la credencial institucional, así como acatar las reglas de seguridad del lugar a visitar.</div>

            <div>Objetivo de la visita:</div>
            <div><strong><%= sol.getObjetivo() != null ? sol.getObjetivo() : "_____________" %></strong></div>
        </div>

        <div class="despedida">ATENTAMENTE</div>
        <div class="firma">
            <p>M.A VIVIANISSEL ARIZA BATALLA</p>
            <p>JEFA DEL DEPARTAMENTO DE ESTADÍAS</p>
        </div>
        <div class="copias">
            <p>C.c.p. DIRECTOR DE LA DIVISIÓN ACADÉMICA DE MECÁNICA INDUSTRIAL - Responsable de la visita. - Para su conocimiento.</p>
            <p>Archivo</p>
        </div>
    </div>
    <footer>
        <div class="footer-contact"><p>Av. Universidad Tecnológica No. 1, Col. Palo Escrito, Emiliano Zapata, Morelos. C.P. 62765</p><p>Teléfono: (777) 368 1165 / www.utez.edu.mx</p></div>
        <div class="footer-pattern"></div>
    </footer>
</div>

<div class="btn-print-container" style="position: fixed; top: 20px; right: 20px; display: flex; gap: 10px;">
    <button onclick="window.history.back()" style="padding: 10px 15px; background: #6c757d; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold;">⬅ Volver</button>
    <button onclick="window.print()" style="padding: 10px 15px; background: #1f3a5e; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold;">🖨️ Imprimir Oficio</button>
</div>
</body>
</html>