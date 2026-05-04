package san.farm.util;

import java.io.File;

import com.oreilly.servlet.multipart.FileRenamePolicy;

/**
 * This is utility class which uses File rename policy with file uploads and
 * returns newly created file name which is uploaded by user
 * 
 * 
 */
public class MyFileRenamePolicy implements FileRenamePolicy {

	File returnFileName = null;
	/**
	 * Implement the rename(File f) method to satisfy the FileRenamePolicy
	 * interface contract
	 * 
	 * @param file  Input File Object
	 * @return File Object with rename file
	 */
	public File rename(File file) {
		// Get the parent directory path 
		String parentDir = file.getParent();

		// Get filename without its path location, such as 'index.txt'
		String fname = file.getName();
		String oldFname=parentDir + System.getProperty("file.separator")+fname;
		
		// Get the extension if the file has one
		String fileExt = Symbols.EMPTY.getSymbol();

		int i = -1;
		if ((i = fname.indexOf(Symbols.DOT.getSymbol())) != -1) {

			fileExt = fname.substring(i);
			fname = fname.substring(0, i);
		}

		// add the timestamp
		fname = fname
				+ (Symbols.EMPTY.getSymbol()+ Symbols.SPLIT_PATTERN_FILENAME.getSymbol() + System.nanoTime());

		// piece together the filename
		fname = parentDir + System.getProperty("file.separator") + fname
				+ fileExt;
		FarmUtility.put(oldFname, fname);
		returnFileName = new File(fname);

		return returnFileName;
	}

	/**
	 * This method returns file name which is renamed
	 * 
	 * @return file name
	 */
	public String getFileName() {
		return returnFileName.getName();
	}
	
}
