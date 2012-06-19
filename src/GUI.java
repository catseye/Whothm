package tc.catseye.whothm;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import java.util.concurrent.SynchronousQueue;

import javax.swing.*;

public class GUI {
    private ContentPane cp;
    private SynchronousQueue<Integer> mailbox;

    public GUI() {
        cp = new ContentPane();
        mailbox = new SynchronousQueue<Integer>();
    }
 
    private void init() {
        JFrame frame = new JFrame("JWhothm");
        frame.setContentPane(cp);
        final GUI gui = this;
        frame.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                gui.close(new Integer(5));
            }
        });
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    public void display() {
        init();
        try {
            mailbox.take();
        } catch (InterruptedException e) {
            System.out.println("Interrupted.");
        }
    }

    void close(Integer r) {
        try {
            mailbox.put(r);
        } catch (InterruptedException e) {
            System.out.println("Interrupted.");
        }
    }

    /********************** Static Methods *************************/

    public static void main(String[] args) {
        GUI gui = new GUI();
        gui.display();
        System.exit(0);
    }
}
