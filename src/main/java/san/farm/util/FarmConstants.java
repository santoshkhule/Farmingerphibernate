package san.farm.util;

import java.io.IOException;
import java.util.Properties;

/**
 * This class loads properties from given properties file and read properties
 * from it
 * 
 *
 * 
 */
public class FarmConstants {

	static FarmConstants farmCostants = null;
	Properties properties = null;

	/* Private Constructor */
	private FarmConstants() {
		loadProperties();
	}

	/**
	 * This method returns instance of this class
	 * 
	 * @return FarmConstants instance
	 */
	public static FarmConstants getInstance() {

		if (farmCostants == null) {
			farmCostants = new FarmConstants();

		}
		return farmCostants;
	}

	/**
	 * This method loads given properties file
	 */
	public void loadProperties() {
		try {
			properties = new Properties();
			properties.load(FarmConstants.class.getClassLoader()
					.getResourceAsStream("farm.properties"));
		} catch (IOException e) {
			System.out.println("Exception while loading farm.properties file");
			e.printStackTrace();
		}
	}

	/**
	 * This method returns the value for the given property
	 * 
	 * @param key
	 * @return value of the property
	 */
	public String getFarmProperty(String key) {

		String value = Symbols.EMPTY.getSymbol();
	//	String value=null;
		if (properties != null) {
			value = properties.getProperty(key);
		}

		return value;
	}

	/**
	 * This is test method. We can remove after testing this class
	 * 
	 * @param args
	 */
	public static void main(String args[]) {

		FarmConstants farmConstants = null;
		farmConstants = FarmConstants.getInstance();
		System.out.println("Property Value :"
				+ farmConstants.getFarmProperty("path.name"));
	}
}
