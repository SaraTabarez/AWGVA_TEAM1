package mx.edu.utez.awgva.Utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public final class EmailSender {
    private EmailSender() { }

    public static boolean isConfigured() {
        MailCredentials credentials = loadCredentials(false);
        return credentials != null;
    }

    public static void sendMail(String to, String subject, String body) {
        MailCredentials credentials = loadCredentials(true);

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

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(credentials.user(), credentials.password());
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(credentials.user()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(body, "text/html; charset=utf-8");
            Transport.send(message);
            System.out.println("Correo enviado exitosamente a: " + to);
        } catch (MessagingException exception) {
            System.err.println("Error al enviar correo SMTP: " + exception.getMessage());
            throw new RuntimeException("No se pudo enviar el correo mediante SMTP.", exception);
        }
    }

    private static MailCredentials loadCredentials(boolean failIfMissing) {
        String user = clean(System.getenv("SMTP_USER"));
        String pass = clean(System.getenv("SMTP_PASS"));

        if (!valid(user, pass)) {
            Properties creds = new Properties();
            try (InputStream input = EmailSender.class.getClassLoader()
                    .getResourceAsStream("credentials.properties")) {
                if (input != null) {
                    try (InputStreamReader reader = new InputStreamReader(input, StandardCharsets.ISO_8859_1)) {
                        creds.load(reader);
                    }
                    user = clean(creds.getProperty("smtp.user"));
                    pass = clean(creds.getProperty("smtp.pass"));
                }
            } catch (Exception exception) {
                if (failIfMissing) {
                    throw new IllegalStateException("No fue posible leer la configuración SMTP.", exception);
                }
                return null;
            }
        }

        if (!valid(user, pass)) {
            if (failIfMissing) {
                throw new IllegalStateException(
                        "El correo emisor no está configurado. Define SMTP_USER/SMTP_PASS o credentials.properties.");
            }
            return null;
        }
        return new MailCredentials(user, pass);
    }

    private static boolean valid(String user, String pass) {
        if (user == null || pass == null || user.isBlank() || pass.isBlank()) return false;
        String normalizedUser = user.trim().toLowerCase();
        String normalizedPass = pass.trim().toLowerCase();
        return !normalizedUser.equals("tu_correo@gmail.com")
                && !normalizedUser.equals("correo@gmail.com")
                && !normalizedUser.contains("tu_correo")
                && !normalizedPass.equals("tu_contraseña_de_aplicacion")
                && !normalizedPass.equals("tu_contrasena_de_aplicacion")
                && !normalizedPass.contains("contraseña_de_aplicacion")
                && !normalizedPass.contains("contrasena_de_aplicacion");
    }

    private static String clean(String value) {
        return value == null ? null : value.trim();
    }

    private record MailCredentials(String user, String password) { }
}
