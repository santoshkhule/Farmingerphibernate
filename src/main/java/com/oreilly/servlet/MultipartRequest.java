package com.oreilly.servlet;

import com.oreilly.servlet.multipart.FileRenamePolicy;
import javax.servlet.ServletRequest;
import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * Stub class for COS (O'Reilly) MultipartRequest.
 * Note: This is a minimal stub to allow compilation.
 * Please install the actual COS library (cos-05Nov2002.jar) for production use.
 *
 * For file upload handling in production, consider using Apache Commons FileUpload instead.
 */
public class MultipartRequest {
    private Map<String, String> parameters = new HashMap<>();
    private Map<String, String> files = new HashMap<>();

    public MultipartRequest(ServletRequest request, String saveDirectory) throws IOException {
        // Stub implementation
    }

    public MultipartRequest(ServletRequest request, String saveDirectory, int maxPostSize) throws IOException {
        // Stub implementation
    }

    public MultipartRequest(ServletRequest request, String saveDirectory, int maxPostSize, FileRenamePolicy renamePolicy) throws IOException {
        // Stub implementation
    }

    public MultipartRequest(ServletRequest request, String saveDirectory, int maxPostSize, String encoding) throws IOException {
        // Stub implementation
    }

    public String getParameter(String name) {
        return parameters.get(name);
    }

    public Enumeration<String> getParameterNames() {
        return Collections.enumeration(parameters.keySet());
    }

    public String[] getParameterValues(String name) {
        String value = parameters.get(name);
        return value != null ? new String[]{value} : null;
    }

    public File getFile(String name) {
        String filePath = files.get(name);
        return filePath != null ? new File(filePath) : null;
    }

    public Enumeration<String> getFileNames() {
        return Collections.enumeration(files.keySet());
    }
}


