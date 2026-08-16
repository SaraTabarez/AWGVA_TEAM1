package mx.edu.utez.awgva.Utils;

import jakarta.servlet.http.HttpServletRequest;
import mx.edu.utez.awgva.Model.Documento;
import mx.edu.utez.awgva.Model.Usuario;

import java.util.List;

public final class TokenViewUtil {
    private TokenViewUtil() {
    }

    public static void decorateDocuments(HttpServletRequest request, Usuario usuario, List<Documento> documentos) {
        if (documentos == null) return;
        for (Documento documento : documentos) decorateDocument(request, usuario, documento);
    }

    public static void decorateDocument(HttpServletRequest request, Usuario usuario, Documento documento) {
        if (documento == null) return;
        documento.setReferenceToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                "documento-revision", documento.getIdDocumento()));
        documento.setFileToken(RecordTokenUtil.issue(request.getSession(), usuario.getIdUsuario(),
                "documento-archivo", documento.getIdDocumento()));
    }
}