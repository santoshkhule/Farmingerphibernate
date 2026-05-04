package san.farm.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Vector;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class DownloadFileServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void processRequest(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		String fileName = request.getParameter("fileName");		
		
		if (fileName == null || fileName.equals("")) {
			throw new ServletException("File Name can't be null or empty");
		}
		
		File file=null;
		
		 file = new File(FarmConstants.getInstance().getFarmProperty("path.name") + File.separator + fileName);
		
		if (!file.exists()) {
		
				System.out.println("File doesn't exists on server"+file+"  "+fileName  );
				String exceptionMsg="File Not Found";
				response.sendRedirect("view/errorAccount.jsp?exceptionMsg="+exceptionMsg);
		}
		else		
		{
		System.out.println("File location on server::" + file.getAbsolutePath());
		ServletContext ctx = getServletContext();
		InputStream fis = new FileInputStream(file);
		String mimeType = ctx.getMimeType(file.getAbsolutePath());
		response.setContentType(mimeType != null ? mimeType
				: "application/octet-stream");
		Vector<String> orgFileName = new Vector<String>(Arrays.asList(fileName
				.split(Symbols.SPLIT_PATTERN_FILENAME.getSymbol())));
		response.setContentLength((int) file.length());
		response.setHeader("Content-Disposition", "attachment; filename="
				+ Symbols.DOUBLEQUOTE.getSymbol() + orgFileName.get(0)
				+ Symbols.DOUBLEQUOTE.getSymbol());

		ServletOutputStream os = response.getOutputStream();
		byte[] bufferData = new byte[1024];
		int read = 0;
		while ((read = fis.read(bufferData)) != -1) {
			os.write(bufferData, 0, read);
		}
		
		os.flush();
		os.close();
		fis.close();
		System.out.println("File downloaded at client successfully");
		}
	}

	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		processRequest(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		processRequest(request, response);
	}

}
