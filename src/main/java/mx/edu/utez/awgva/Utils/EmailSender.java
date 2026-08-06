package mx.edu.utez.awgva.Utils;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.InputStream;
import java.util.Properties;

public class EmailSender {
    public static void sendMail(String to, String subject, String body) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        String userTemp = System.getenv("SMTP_USER");
        String passTemp = System.getenv("SMTP_PASS");

        if (userTemp == null || userTemp.isBlank() || passTemp == null || passTemp.isBlank()) {
            Properties creds = new Properties();
            try (InputStream is = EmailSender.class.getClassLoader().getResourceAsStream("credentials.properties")) {
                if (is == null) {
                    throw new RuntimeException("No se encontró credentials.properties ni variables de entorno.");
                }

                try (java.io.InputStreamReader reader = new java.io.InputStreamReader(is, java.nio.charset.StandardCharsets.ISO_8859_1)) {
                    creds.load(reader);
                }
                userTemp = creds.getProperty("smtp.user");
                passTemp = creds.getProperty("smtp.pass");
            } catch (Exception e) {
                throw new RuntimeException("Error al cargar credenciales: " + e.getMessage());
            }
        }
        if (userTemp == null || userTemp.isBlank() || passTemp == null || passTemp.isBlank()) {
            throw new IllegalStateException("Configura SMTP_USER y SMTP_PASS para enviar correos.");
        }

        final String usuario = userTemp;
        final String contrasena = passTemp;

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(usuario, contrasena);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(usuario));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(body, "text/html; charset=utf-8");
            Transport.send(message);
            System.out.println("Correo enviado exitosamente a: " + to);

        } catch (MessagingException e) {
            System.err.println("Error al enviar correo: " + e.getMessage());
            throw new RuntimeException("No se pudo enviar el correo.", e);
        }
    }
}