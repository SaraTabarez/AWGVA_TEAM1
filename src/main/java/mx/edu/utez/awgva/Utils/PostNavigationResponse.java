package mx.edu.utez.awgva.Utils;

import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

public final class PostNavigationResponse {
    private PostNavigationResponse() {
    }

    public static void send(HttpServletResponse response, String action, String csrfToken,
                            Map<String, String> parameters) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        StringBuilder inputs = new StringBuilder(hidden("csrfToken", csrfToken));
        if (parameters != null) {
            parameters.forEach((name, value) -> inputs.append(hidden(name, value)));
        }
        response.getWriter().write("<!doctype html><html lang=\"es\"><head><meta charset=\"UTF-8\">"
                + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>Cargando</title>"
                + "</head><body><form id=\"post-navigation\" method=\"post\" action=\"" + html(action) + "\">"
                + inputs + "</form><script>document.getElementById('post-navigation').submit();</script>"
                + "</body></html>");
    }

    private static String hidden(String name, String value) {
        return "<input type=\"hidden\" name=\"" + html(name) + "\" value=\"" + html(value) + "\">";
    }

    private static String html(String value) {
        return value == null ? "" : value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
}