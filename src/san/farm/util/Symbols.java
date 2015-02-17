package san.farm.util;

/**
 * This class provides symbols through out the application
 * 
 */
public enum Symbols {

	EMPTY(""), BACKSLASH("\\"), SINGLEQUOTE("\'"), DOUBLEQUOTE("\""), FORWARDSLASH(
			"/"), HYPHON("-"), SEPERATORBTNFILES(";"), SPLITTER("[\\\\/]"), COMMA(
			","), SPACE(" "),DOT("."),STAR("*"),SPLIT_PATTERN_FILENAME("~~"),FILE_NAME_VALIDATION_PATTERN(";|~|:|\'"),SPLITTER_JAVASCRIPT("\\\\"),INITIALISE_DATA_TYPE(" ");
	private String symbol;

	/* private constructor */
	private Symbols(String s) {
		symbol = s;
	}

	/**
	 * This method return symbol for given String
	 * 
	 * @return symbol
	 */
	public String getSymbol() {

		return symbol;
	}
}
