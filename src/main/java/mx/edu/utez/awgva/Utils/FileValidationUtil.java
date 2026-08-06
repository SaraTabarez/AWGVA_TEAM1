package mx.edu.utez.awgva.Utils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

/** Validación mínima de firma binaria; no confía sólo en nombre o MIME del navegador. */
public final class FileValidationUtil {

    private FileValidationUtil() {
    }

    public static boolean hasExpectedSignature(Path file, String extension) throws IOException {
        byte[] header;
        try (InputStream input = Files.newInputStream(file)) {
            header = input.readNBytes(12);
        }

        return switch (extension) {
            case ".pdf" -> startsWith(header, "%PDF-".getBytes(StandardCharsets.US_ASCII));
            case ".png" -> startsWith(header, new byte[]{(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A});
            case ".jpg", ".jpeg" -> header.length >= 3
                    && header[0] == (byte) 0xFF && header[1] == (byte) 0xD8 && header[2] == (byte) 0xFF;
            case ".webp" -> header.length >= 12
                    && asciiEquals(header, 0, "RIFF") && asciiEquals(header, 8, "WEBP");
            default -> false;
        };
    }

    private static boolean startsWith(byte[] data, byte[] expected) {
        if (data.length < expected.length) {
            return false;
        }
        for (int index = 0; index < expected.length; index++) {
            if (data[index] != expected[index]) {
                return false;
            }
        }
        return true;
    }

    private static boolean asciiEquals(byte[] data, int offset, String expected) {
        byte[] bytes = expected.getBytes(StandardCharsets.US_ASCII);
        if (data.length < offset + bytes.length) {
            return false;
        }
        for (int index = 0; index < bytes.length; index++) {
            if (data[offset + index] != bytes[index]) {
                return false;
            }
        }
        return true;
    }
}