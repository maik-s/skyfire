# Skyfire

## Docker image

This repository dockerized the original skyfire code.
In order to use the docker image first build the image with the following command:

	git clone https://github.com/maik-s/skyfire.git
	docker build . --tag=skyfire

Now you can learn the PCSG from a given set of input files by using docker-compose

Attention: This docker image is only configured to learn/generate XML files. In case you want to learn the PCSG of VBS or JS you need first to compile the respective classes by modifying the `Dockerfile` and then adapt the `entrypoint.sh`.

### Learning the PCSG

In order to learn the PCSG of XML files place the seeds into `seeds/xml` and assure the `docker-compose.yml` contains the line `command: /skyfire/entrypoint.sh learn`

### Generating sample files

Generating files is easy as well. Just change the parameter `learn` (from `entrypoint.sh` ) to `generate` in the `docker-compose.yml`.
If not done already, shut down the previously started container (`docker-compose down`) and bring it back up with `docker-compose up`.

In the following you'll find the original readme. See section "Run Generator class to generate samples" for further options for configuration. Keep in mind to rebuild the docker image that your changes take effect.


## Generate Lexer, Parser, Visitor automatically

add `antlr-4.7-complete.jar` to classpath

### XML

	java org.antlr.v4.Tool -o E:\xml\ -visitor -no-listener -Dlanguage=Java E:\xml\XMLLexer.g4
	java org.antlr.v4.Tool -o E:\xml\ -visitor -no-listener -Dlanguage=Java E:\xml\XMLParser.g4

### JavaScript

	java org.antlr.v4.Tool -o E:\jsgrammar\ -visitor -no-listener -Dlanguage=Java E:\jsgrammar\JavaScriptLexer.g4
	java org.antlr.v4.Tool -o E:\jsgrammar\ -visitor -no-listener -Dlanguage=Java E:\jsgrammar\JavaScriptParser.g4

## Install MySQL

download MySQL community version: `mysql-installer-community-5.7.21.0.msi`  
double click and install  
create new database pcsg  
create new table pcsg  

### XML

```sql
create table xmlpcsg (
	id int auto_increment,
	parent varchar(100) not null,
	context varchar(500) not null,
	rule varchar(4000) not null,
	prob float not null,
	primary key(id)
);
```

### JavaScript

```sql
create table jspcsg (
	id int auto_increment,
	parent varchar(100) not null,
	context varchar(500) not null,
	rule varchar(4000) not null,
	prob float not null,
	primary key(id)
);
```

download `mysql-connector-java-5.1.46.tar.gz` from `http://dev.mysql.com/downloads/connector/j/` and unzip it  
add `mysql-connector-java-5.1.46-bin.jar` to build path

## Change Visitor

change the original visitor function to extract context and rule information  

```java
public T visitDocument(XMLParser.DocumentContext ctx) {
	return visitChildren(ctx);
}
```

### XML 

```java
public T visitDocument(XMLParser.DocumentContext ctx) {
	String parent = "null", grandparent = "null", greatparent = "null", sibling = "null";
	if (ctx.getParent() != null) {
		parent = ctx.getParent().getClass().getSimpleName();
		if (ctx.getParent().getParent() != null) {
			grandparent = ctx.getParent().getParent().getClass().getSimpleName();
			if (ctx.getParent().getParent().getParent() != null) {
				greatparent = ctx.getParent().getParent().getParent().getClass().getSimpleName();
			}
		}
		if (ctx.getParent().getChild(0) != null) {
			// sibling = ctx.getParent().getChild(0).getClass().getSimpleName();
		}
	}
	String rule = "<" + greatparent + "," + grandparent + "," + parent + "," + sibling + ">";
	rule += ctx.getClass().getSimpleName() + "->";
	if (ctx.getChildCount() > 0 && ctx.getChildCount() < PCSGLearner.maxChildCount) {
		for (int i = 0; i < ctx.children.size(); i++) {
			if (ctx.getChild(i).getClass().getSimpleName().equals("TerminalNodeImpl")) {
				rule += ctx.getChild(i).getText().length() > PCSGLearner.maxChildLength
						? ctx.getChild(i).getText().substring(0, PCSGLearner.maxChildLength).trim()
						: ctx.getChild(i).getText().trim();
			} else {
				rule += "@@@@@" + ctx.getChild(i).getClass().getSimpleName() + "#####";
			}
		}
	} else {
		return visitChildren(ctx);
	}
	// System.out.println(rule);
	PCSGLearner.updateParentCount(ctx.getClass().getSimpleName());
	PCSGLearner.updateRuleCount(rule);
	return visitChildren(ctx);
}
```

### JavaScript

pay special attention to ErrorNodeImpl.

```java
public T visitDocument(XMLParser.DocumentContext ctx) {
	String parent = "null", grandparent = "null", greatparent = "null", sibling = "null";
	if (ctx.getParent() != null) {
		parent = ctx.getParent().getClass().getSimpleName();
		if (ctx.getParent().getParent() != null) {
			grandparent = ctx.getParent().getParent().getClass().getSimpleName();
			if (ctx.getParent().getParent().getParent() != null) {
				greatparent = ctx.getParent().getParent().getParent().getClass().getSimpleName();
			}
		}
		if (ctx.getParent().getChild(0) != null) {
			// sibling = ctx.getParent().getChild(0).getClass().getSimpleName();
		}
	}
	String rule = "<" + greatparent + "," + grandparent + "," + parent + "," + sibling + ">";
	rule += ctx.getClass().getSimpleName() + "->";
	if (ctx.getChildCount() > 0 && ctx.getChildCount() < JSPCSGLearner.maxChildCount) {
		for (int i = 0; i < ctx.children.size(); i++) {
			if (ctx.getChild(i).getClass().getSimpleName().equals("TerminalNodeImpl")) {
				rule += ctx.getChild(i).getText().length() > JSPCSGLearner.maxChildLength
						? ctx.getChild(i).getText().substring(0, JSPCSGLearner.maxChildLength).trim()
						: ctx.getChild(i).getText().trim();
			} else if (!ctx.getChild(i).getClass().getSimpleName().equals("ErrorNodeImpl")){
				rule += "@@@@@" + ctx.getChild(i).getClass().getSimpleName() + "#####";
			}
		}
	} else {
		return visitChildren(ctx);
	}
	// System.out.println(rule);
	JSPCSGLearner.updateParentCount(ctx.getClass().getSimpleName());
	JSPCSGLearner.updateRuleCount(rule);
	return visitChildren(ctx);
}	
```

##  First run `PCSGLearner` class to learn from samples

some optimizations for XML:  
ChardataContext and MiscContext nodes normally contain a string whose value is useless to grammar. Therefore, we omit those nodes to get a much smaller PCSG.
The non-terminal child of ContentContext contains comment and we omit them to reduce size of PCSG.

##  Run Generator class to generate samples

Several parameters affect the seed and complexity of generation and users can change them as their needs.

```java
static int maxDerivation = 50;			// the max number of derivation
static int maxDerivationDepth = 8;		// the max iteration depth of derivation
int numOfSamplesToGenerate = 10; 		// the number of seeds to generate
String outputPath = "E:\\xml_gen\\";	//the path to save generated seeds
```

# Custom XML files

	find . -type f -name "*xml*" -exec bash -c 'mv "$0" "$(echo "$0" | cut -d " " -f1).xml" ' {}  \;