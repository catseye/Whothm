package tc.catseye.whothm;

import javax.swing.JApplet;
import javax.swing.BorderFactory;
import java.awt.Color;

public class Applet extends JApplet {
    private ContentPane cp;

    public Applet() {
        cp = new ContentPane();
    }
    
    public void init() {
        try {
            javax.swing.SwingUtilities.invokeAndWait(new Runnable() {
                public void run() {
                    createGUI();
                }
            });
        } catch (Exception e) {
            System.err.println("createGUI didn't successfully complete");
        }
    }

    private void createGUI() {
        cp.setBorder(BorderFactory.createMatteBorder(1,1,1,1,Color.black));
        this.setContentPane(cp);
    }
}
