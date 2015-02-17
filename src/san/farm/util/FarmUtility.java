package san.farm.util;

import java.io.File;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;

import com.oreilly.servlet.MultipartRequest;

public class FarmUtility {
private static HashMap<String, String> fileNames=new HashMap<String, String>();
	
	public synchronized static void put(String key,String val){
		fileNames.put(key, val);
	}
	public synchronized static boolean containsKey (String key){
		return fileNames.containsKey(key);
	}
	public synchronized static String get(String key){
		return fileNames.get(key);
	}
	public synchronized static void delete(String key){
		fileNames.remove(key);
	}
	
	public static String convertfrom_ddmmyyToyymmdd(String qtDate) {
		if (null != qtDate) {
			if (!qtDate.equals("")) {
				String dateComp[] = qtDate.split("/");
				qtDate = dateComp[2] + "-" + dateComp[1] + "-" + dateComp[0];
			}
		}

		return qtDate;
	}

	public static String convertfrom_yymmddToddmmyy(String qtDate) {
		if (null != qtDate) {
			if (!qtDate.equals("")) {
				String dateComp[] = qtDate.split("-");
				qtDate = dateComp[2] + "/" + dateComp[1] + "/" + dateComp[0];
			}
		}

		return qtDate;
	}

	public static String uploadedFilesCSV(MultipartRequest mr) {
		String qtProof = Symbols.EMPTY.getSymbol();
		if (mr.getFileNames() != null) {
			Enumeration<String> listOfFileTagNames = mr.getFileNames();
			
			while (listOfFileTagNames.hasMoreElements()) {
				String tagName = listOfFileTagNames.nextElement();
				if (mr.getFile(tagName) != null) {
					String newName= Symbols.EMPTY.getSymbol();
					System.out.println("org Name="+mr.getFile(tagName).toString()+"------");
					
					if(FarmUtility.containsKey(mr.getFile(tagName).toString()))
					{
						newName= FarmUtility.get(mr.getFile(tagName).toString());
						FarmUtility.delete(mr.getFile(tagName).toString());
					}
					
					System.out.println("----"+FarmUtility.fileNames.get(mr.getFile(tagName).toString())+"----");
					//System.out.println("----"+FarmUtility.fileNames.toString()+"------");
					
					qtProof = qtProof + newName;
					if (listOfFileTagNames.hasMoreElements()) {
						qtProof = qtProof
								+ Symbols.SEPERATORBTNFILES.getSymbol();
					}
				}

			}
			
			 if (qtProof.length() > 0 && qtProof.charAt(qtProof.length() - 1) == Symbols.SEPERATORBTNFILES.getSymbol().charAt(Symbols.SEPERATORBTNFILES.getSymbol().length() - 1)) 
			 {  
				 qtProof = qtProof.substring(0, qtProof.length() - 1);
			 }
			
			System.out.println("qtProof:="+qtProof);
			if (qtProof.equals(Symbols.EMPTY.getSymbol())) {
				return null;
			}else{
				qtProof=qtProof.replace("\\", "/");
			}
			return qtProof;
		} else {
			return null;
		}
	}

	public static String deleteProof(String alreadyAddedProof, String deletePath) {

		if (alreadyAddedProof != null && deletePath != null) {

			Vector<String> splitedProofs = new Vector<String>(
					Arrays.asList(alreadyAddedProof
							.split(Symbols.SEPERATORBTNFILES.getSymbol())));

			Iterator<String> iterator = splitedProofs.iterator();

			String newPath = Symbols.EMPTY.getSymbol();

			while (iterator.hasNext()) {
				String singleProof = iterator.next();
				if (!singleProof.trim().equals(deletePath.trim())) {
					newPath = newPath + singleProof;
					if (iterator.hasNext()) {
						newPath = newPath
								+ Symbols.SEPERATORBTNFILES.getSymbol();

					}
				}
			}

			if (newPath.length() > 0
					&& newPath.charAt(newPath.length() - 1) == Symbols.SEPERATORBTNFILES
							.getSymbol().charAt(
									Symbols.SEPERATORBTNFILES.getSymbol()
											.length() - 1)) {
				newPath = newPath.substring(0, newPath.length() - 1);
			}

			File file = new File(deletePath);
			boolean res = false;
			if (file.exists()) {
				res = file.delete();
			}

			alreadyAddedProof = newPath;

		}
		return alreadyAddedProof;
	}
}
