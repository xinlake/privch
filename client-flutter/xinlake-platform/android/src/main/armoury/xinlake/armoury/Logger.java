package xinlake.armoury;

import androidx.annotation.NonNull;

import java.io.FileOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * @author Xinlake Liu
 * @version 2022.03
 */
public class Logger {
    private final String logFile;

    private final DateTimeFormatter dateTimeFormatter =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    // Utility class
    public Logger(String logFile) {
        this.logFile = logFile;
    }

    public void write(@NonNull String head, String message) {
        try (FileOutputStream fileOutputStream =
                 new FileOutputStream(logFile, true)) {
            writeHead(fileOutputStream, head);

            if (message != null) {
                byte[] messageLine = (message + "\r\n").getBytes();
                fileOutputStream.write(messageLine);
            }

            fileOutputStream.flush();
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    public void write(@NonNull String head, Throwable throwable) {
        try (FileOutputStream fileOutputStream =
                 new FileOutputStream(logFile, true)) {
            writeHead(fileOutputStream, head);

            if (throwable != null) {
                String message = throwable.getLocalizedMessage();
                if (message != null) {
                    fileOutputStream.write((message + "\r\n").getBytes());
                }
            }

            fileOutputStream.flush();
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    private void writeHead(FileOutputStream fileOutputStream, String head) throws IOException {
        final String time = LocalDateTime.now().format(dateTimeFormatter);
        final byte[] headLine = (time + ". " + head + "\r\n").getBytes();
        fileOutputStream.write(headLine);
    }
}
