package net.torguet;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class RemoveTapHeader {
    public static void main(String[] args) throws IOException {
        String name = "map";
        try (FileInputStream fileInputStream = new FileInputStream("/Users/torguet/.wine/drive_c/Tyrann4/BUILD/"+name+".tap")) {
            try (FileOutputStream fileOutputStream = new FileOutputStream("/Users/torguet/.wine/drive_c/Tyrann4/Compressed/"+name+".raw")) {
                byte[] buffer = new byte[1024];
                int size = fileInputStream.read(buffer);
                if (size>0) {
                    int skip = 13 + name.length() + 1;
                    String fileName = new String(buffer, 13, name.length());
                    System.out.println("<"+fileName+">");
                    if (fileName.equals(name)) {
                        fileOutputStream.write(buffer, skip, size-skip);
                        while(size>0) {
                            size = fileInputStream.read(buffer);
                            if (size>0) {
                                fileOutputStream.write(buffer, 0, size);
                            }
                        }
                    }
                }
            }
        }

    }
}
