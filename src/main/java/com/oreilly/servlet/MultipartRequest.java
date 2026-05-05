package com.oreilly.servlet;

import com.oreilly.servlet.multipart.FileRenamePolicy;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.util.*;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * Drop-in replacement for COS MultipartRequest, implemented using Apache Commons FileUpload.
 * Maintains the same API so no changes are needed in calling code.
 */
public class MultipartRequest {

    private final Map<String, List<String>> parameters = new HashMap<>();
    private final Map<String, File> fileMap = new LinkedHashMap<>();

    public MultipartRequest(ServletRequest request, String saveDirectory) throws IOException {
        this(request, saveDirectory, 1024 * 1024, (FileRenamePolicy) null);
    }

    public MultipartRequest(ServletRequest request, String saveDirectory, int maxPostSize) throws IOException {
        this(request, saveDirectory, maxPostSize, (FileRenamePolicy) null);
    }

    public MultipartRequest(ServletRequest request, String saveDirectory, int maxPostSize, FileRenamePolicy renamePolicy) throws IOException {
        parseRequest((HttpServletRequest) request, saveDirectory, maxPostSize, renamePolicy);
    }

    public MultipartRequest(ServletRequest request, String saveDirectory, int maxPostSize, String encoding) throws IOException {
        parseRequest((HttpServletRequest) request, saveDirectory, maxPostSize, (FileRenamePolicy) null);
    }

    private void parseRequest(HttpServletRequest request, String saveDirectory, int maxPostSize, FileRenamePolicy renamePolicy) throws IOException {
        try {
            File saveDir = resolveUploadDir(saveDirectory);

            DiskFileItemFactory factory = new DiskFileItemFactory();
            factory.setRepository(saveDir);

            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(maxPostSize);

            List<FileItem> items = upload.parseRequest(request);

            for (FileItem item : items) {
                if (item.isFormField()) {
                    parameters
                        .computeIfAbsent(item.getFieldName(), k -> new ArrayList<>())
                        .add(item.getString());
                } else {
                    String originalName = item.getName();
                    if (originalName != null && !originalName.trim().isEmpty()) {
                        File dest = new File(saveDir, new File(originalName).getName());
                        if (renamePolicy != null) {
                            dest = renamePolicy.rename(dest);
                        }
                        item.write(dest);
                        fileMap.put(item.getFieldName(), dest);
                    }
                }
            }
        } catch (IOException e) {
            throw e;
        } catch (Exception e) {
            throw new IOException("Failed to parse multipart request: " + e.getMessage(), e);
        }
    }

    private File resolveUploadDir(String saveDirectory) throws IOException {
        File dir;
        if (saveDirectory == null || saveDirectory.trim().isEmpty()) {
            String webappRoot = System.getProperty("webapp.root");
            dir = new File(webappRoot != null ? webappRoot + "/uploads" : System.getProperty("java.io.tmpdir"));
        } else {
            dir = new File(saveDirectory);
        }
        if (!dir.exists()) {
            dir.mkdirs();
        }
        if (!dir.isDirectory()) {
            throw new IOException("Upload directory is not a directory: " + dir.getAbsolutePath());
        }
        return dir;
    }

    public String getParameter(String name) {
        List<String> values = parameters.get(name);
        return (values != null && !values.isEmpty()) ? values.get(0) : null;
    }

    public Enumeration<String> getParameterNames() {
        return Collections.enumeration(parameters.keySet());
    }

    public String[] getParameterValues(String name) {
        List<String> values = parameters.get(name);
        return values != null ? values.toArray(new String[0]) : null;
    }

    public File getFile(String name) {
        return fileMap.get(name);
    }

    public Enumeration<String> getFileNames() {
        return Collections.enumeration(fileMap.keySet());
    }
}
