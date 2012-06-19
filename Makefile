JAVAC?="/cygdrive/c/Program Files (x86)/Java/jdk1.6.0_20/bin/javac"
JAVA?="/cygdrive/c/Program Files (x86)/Java/jre6/bin/java"
JAR?=jar

JFLAGS="-Xlint:deprecation"

CDIR=bin/tc/catseye/whothm

CLASSES=$(CDIR)/Parser.class \
        $(CDIR)/Rectangle.class \
        $(CDIR)/TruthTable.class \
        $(CDIR)/Canvas.class \
        $(CDIR)/Bitmap.class \
        $(CDIR)/Machine.class \
        $(CDIR)/ContentPane.class \
        $(CDIR)/Applet.class \
        $(CDIR)/GUI.class

all: $(CLASSES)

$(CDIR)/Rectangle.class: src/Rectangle.java $(CDIR)/TruthTable.class $(CDIR)/BitMap.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/Rectangle.java

$(CDIR)/TruthTable.class: src/TruthTable.java
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/TruthTable.java

$(CDIR)/Machine.class: src/Machine.java $(CDIR)/Rectangle.class $(CDIR)/TruthTable.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/Machine.java

$(CDIR)/Parser.class: src/Parser.java $(CDIR)/Machine.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/Parser.java

$(CDIR)/BitMap.class: src/BitMap.java $(CDIR)/TruthTable.class 
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/BitMap.java

$(CDIR)/Canvas.class: src/Canvas.java $(CDIR)/BitMap.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/Canvas.java

$(CDIR)/ContentPane.class: src/ContentPane.java $(CDIR)/Canvas.class $(CDIR)/Parser.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/ContentPane.java

$(CDIR)/GUI.class: src/GUI.java $(CDIR)/ContentPane.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/GUI.java

$(CDIR)/Applet.class: src/Applet.java $(CDIR)/ContentPane.class
	$(JAVAC) $(JFLAGS) -cp bin -d bin src/Applet.java

doc/whothm.jar:
	jar cvf doc/whothm.jar -C bin tc/catseye/whothm/*.class

clean:
	rm -rf $(CDIR)/*.class

test: $(CDIR)/GUI.class
	$(JAVA) -cp bin tc.catseye.whothm.GUI
