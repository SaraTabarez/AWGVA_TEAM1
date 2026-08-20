<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Carta Responsiva Visitas Académicas</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        *{box-sizing:border-box}
        body{margin:0;background:#a6b5c3;font-family:Arial,sans-serif;color:#111}
        .shell{margin-left:240px;padding:28px 20px;min-height:100vh}
        .toolbar{width:min(900px,100%);margin:0 auto 14px;display:flex;justify-content:space-between;gap:12px}
        .toolbar button{border:0;border-radius:7px;padding:11px 18px;font-weight:800;cursor:pointer}
        .back{background:#fff;color:#1e3a5f}.download{background:#f59120;color:#fff}
        .document-container{background:#fff;width:min(900px,100%);margin:0 auto;padding:48px 62px;box-shadow:0 4px 15px rgba(0,0,0,.12)}
        .doc-title{text-align:center;font-size:17px;font-weight:800;margin-bottom:26px}
        .doc-date{text-align:right;font-size:13px;margin-bottom:34px}
        .recipient{font-size:13px;font-weight:800;line-height:1.45;margin-bottom:28px}
        .body-text{font-size:13px;line-height:1.55;text-align:justify;margin:0 0 13px}
        .bullet-list{font-size:13px;line-height:1.5;margin:0 0 14px;padding-left:36px}
        .bullet-list li{margin-bottom:5px}
        .italic-text{font-size:13px;font-style:italic;line-height:1.55;text-align:justify;margin:0 0 24px}
        .filled{font-weight:700;text-decoration:underline;text-decoration-thickness:1px;text-underline-offset:2px}
        table{width:100%;border-collapse:collapse;margin-top:10px}
        th,td{border:1px solid #111;padding:9px;text-align:center;font-size:13px}
        th{font-weight:800}td{height:45px}
        td[contenteditable="true"]{background:#fffef2;outline:none}
        td[contenteditable="true"]:focus{box-shadow:inset 0 0 0 2px #f59120}
        .add-row-container{text-align:right;margin-top:14px}
        .add-btn{width:42px;height:42px;border:0;border-radius:50%;background:#4caf50;color:#fff;font-size:25px;font-weight:900;display:inline-flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 3px 7px rgba(0,0,0,.2)}
        .helper{font-size:12px;color:#5d6670;margin-top:8px;text-align:right}
        @media(max-width:800px){.shell{margin-left:0;padding:12px}.document-container{padding:30px 22px}.toolbar{flex-wrap:wrap}}
        @media print{body{background:#fff}.sidebar,.toolbar,.no-print{display:none!important}.shell{margin:0;padding:0}.document-container{width:100%;box-shadow:none;padding:8mm 10mm}td[contenteditable="true"]{background:#fff}@page{size:letter;margin:8mm}}
    </style>
</head>
<body>
<jsp:include page="Layout/sidebar.jsp"/>
<div class="shell">
    <div class="toolbar no-print">
        <button class="back" type="button" data-post-url="${ctx}/detalle-solicitud" data-post-ref="<c:out value='${expediente.referenceToken}'/>"><i class="bi bi-arrow-left"></i> Volver</button>
        <button class="download" id="btnDescargar" type="button"><i class="bi bi-download"></i> Descargar para continuar</button>
    </div>

    <article class="document-container" id="pdfContent">
        <div class="doc-title">CARTA RESPONSIVA VISITAS ACADÉMICAS</div>
        <div class="doc-date">Emiliano Zapata, Morelos a _______ de _______________________ del 20_______.</div>

        <div class="recipient">
            UNIVERSIDAD TECNOLÓGICA EMILIANO ZAPATA<br>
            DEL ESTADO DE MORELOS.<br>
            P R E S E N T E
        </div>

        <p class="body-text">
            Por este medio, los suscritos estudiantes del programa educativo de
            <span class="filled"><c:out value="${solicitud.programaEducativo}"/></span>
            y bajo protesta de decir verdad, confirmamos nuestra participación en la visita a
            "<span class="filled"><c:out value="${solicitud.empresaNombre}"/></span>",
            a celebrarse del <span class="filled"><c:out value="${solicitud.fechaInicio}"/></span>
            al <span class="filled"><c:out value="${solicitud.fechaTermino}"/></span>, en
            <span class="filled"><c:out value="${solicitud.empresaDireccion}"/></span>;
            bajo el programa anexo al presente documento.
        </p>

        <p class="body-text">
            Conocedores que la actividad se documentará como una visita de estudio de la Universidad Tecnológica Emiliano Zapata del Estado de Morelos (UTEZ) y debido al horario del encuentro
            (<span class="filled"><c:out value="${solicitud.horaInicio}"/></span> a ________ hrs.),
            declaramos que los traslados y gastos derivados a nuestra participación en el evento antes mencionado los realizaremos con nuestros propios medios y recursos, asimismo que conocemos el alcance del seguro de la empresa que se contrató para el traslado.
        </p>

        <p class="body-text">Derivado de lo anterior nos obligamos a:</p>
        <ul class="bullet-list">
            <li>Respetar las reglas impuestas tanto por la UTEZ, como por los organizadores de la salida.</li>
            <li>Buscar siempre estar informado de las actividades grupales programadas.</li>
            <li>Abstenerme de cualquier conducta ilegal o inapropiada que pueda denigrar la buena imagen de la UTEZ o que sea perjudicial para sus objetivos y;</li>
            <li>No poner en riesgo mi integridad física ni la de mis compañeros.</li>
        </ul>

        <p class="body-text">Estamos de acuerdo en asumir la responsabilidad como ciudadanos y como miembros de la comunidad universitaria, por lo que nos obligamos a realizar las siguientes acciones:</p>
        <p class="body-text">Adoptar las medidas de seguridad correspondientes de la actividad que desempeñemos en cualquier lugar, tales como uso adecuado de equipo de protección personal, higiene respiratoria, lavado de manos, etc. Así como, seguir los protocolos de prevención emitidos por la Universidad o institución donde esté realizando la actividad de visita de estudio, dentro o fuera del Estado de Morelos.</p>
        <p class="body-text">Asimismo, manifestamos que la actividad descrita la realizamos bajo nuestra responsabilidad, por lo que deslindamos a la UTEZ y a su personal docente y administrativo de toda responsabilidad en caso de que se presente alguna consecuencia que resulte de la falta de acción, omisión o incumplimiento en la que hayamos incurrido con respecto a los puntos descritos anteriormente, así como del pago de daños y perjuicios y cualquier acción legal, en el entendido que mediante las acciones anteriores la Universidad está protegiendo nuestra integridad y la de los demás miembros de la comunidad universitaria.</p>
        <p class="italic-text">He leído este documento, entiendo completamente sus términos y por medio del mismo eximo y libero de toda responsabilidad a la UTEZ y a terceros, y me hago único y absoluto responsable de mi persona, en los términos del presente, mismo que suscribo libre y voluntariamente.</p>

        <table id="alumnosTable">
            <thead><tr><th style="width:7%">No.</th><th style="width:43%">Nombre</th><th style="width:25%">Grado y Grupo</th><th style="width:25%">Firma</th></tr></thead>
            <tbody>
            <c:forEach begin="1" end="4" var="numero">
                <tr>
                    <td><c:out value="${numero}"/></td>
                    <td contenteditable="true"></td>
                    <td contenteditable="true"><c:out value="${solicitud.semestre}"/> <c:out value="${solicitud.grupo}"/></td>
                    <td></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

        <div class="add-row-container no-print">
            <button class="add-btn" id="btnAgregarFila" type="button" title="Agregar alumno" aria-label="Agregar alumno">+</button>
            <div class="helper">Puedes escribir los nombres y agregar tantas filas como necesites antes de descargar.</div>
        </div>
    </article>
</div>

<script>
    const ctx='${ctx}';
    const referenceToken='<c:out value="${expediente.referenceToken}"/>';
    const csrf='<c:out value="${sessionScope.csrfToken}"/>';

    document.addEventListener('DOMContentLoaded',()=>{
        const tbody=document.querySelector('#alumnosTable tbody');
        const add=document.getElementById('btnAgregarFila');
        const download=document.getElementById('btnDescargar');

        add.addEventListener('click',()=>{
            const numero=tbody.querySelectorAll('tr').length+1;
            const row=document.createElement('tr');
            row.innerHTML='<td>'+numero+'</td><td contenteditable="true"></td><td contenteditable="true"><c:out value="${solicitud.semestre}"/> <c:out value="${solicitud.grupo}"/></td><td></td>';
            tbody.appendChild(row);
        });

        download.addEventListener('click',async()=>{
            const hidden=document.querySelectorAll('.no-print');
            hidden.forEach(el=>el.style.display='none');
            download.disabled=true;
            try{
                await html2pdf().set({
                    margin:[8,8,8,8],
                    filename:'Carta_Responsiva_Visitas_Academicas.pdf',
                    image:{type:'jpeg',quality:.98},
                    html2canvas:{scale:2,useCORS:true},
                    jsPDF:{unit:'mm',format:'letter',orientation:'portrait'},
                    pagebreak:{mode:['css','legacy']}
                }).from(document.getElementById('pdfContent')).save();

                const body=new URLSearchParams({csrfToken:csrf,ref:referenceToken,tipo:'CARTA_RESPONSIVA'});
                const response=await fetch(ctx+'/docente/marcar-descarga',{
                    method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
                    credentials:'same-origin',body
                });
                if(!response.ok) throw new Error('No fue posible registrar la descarga.');
                window.awgvaPost(ctx+'/detalle-solicitud',{ref:referenceToken});
            }catch(error){
                alert(error.message || 'No fue posible generar la carta responsiva.');
            }finally{
                hidden.forEach(el=>el.style.display='');
                download.disabled=false;
            }
        });
    });
</script>
</body>
</html>
