package tc.catseye.whothm;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import java.util.concurrent.SynchronousQueue;

import javax.swing.*;

public class ContentPane extends JPanel  {
    private BitMap bitmap;

    private JMenuBar menuBar;
    private Canvas canvas;
    private JLabel statusBar;
    private JTextArea progBox;

    public ContentPane() {
        super(new BorderLayout());

        bitmap = new BitMap();

        // Construct stuff in inner -> outer order
        canvas = new Canvas(bitmap);
        canvas.setBackground(Color.yellow);
        canvas.setMinimumSize(new Dimension(100, 50));

        progBox = new JTextArea();
        progBox.setText(
          "r := (0, 0, 1, 2);\n" +
          "s := (0, 0, 1, 2);\n" +
          "XOR := TF/FT;\n\n" +
          "begin\n" +
          "r.x += r.w;\n" +
          "r.x += -1;\n" +
          "r.w += 1;\n" +
          "r.h += 1;\n" +
          "draw r, XOR;\n" +
          "s.x += s.w;\n" +
          "s.x += -1;\n" +
          "s.w += 1;\n" +
          "s.h += 2;\n" +
          "draw s, XOR;\n" +
          "end"
        );
        progBox.addKeyListener(new KeyListener() {
            public void keyTyped(KeyEvent event) {
            }
            public void keyPressed(KeyEvent event) {
                if (event.getKeyCode() == KeyEvent.VK_PAGE_UP) {
                    bitmap.alterPixelSize(-1);
                    canvas.repaint();
                    event.consume();
                } else if (event.getKeyCode() == KeyEvent.VK_PAGE_DOWN) {
                    bitmap.alterPixelSize(+1);
                    canvas.repaint();
                    event.consume();
                }
            }
            public void keyReleased(KeyEvent event) { }
        });

        JButton buttonRun = new JButton("Run");
        buttonRun.setMnemonic(KeyEvent.VK_R);
        buttonRun.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String program = progBox.getText();
                statusBar.setText("Parsing...");
                canvas.repaint();
                Parser p = new Parser(program);
                try {
                    Machine m = p.parse();
                    statusBar.setText("Drawing...");
                    canvas.repaint();
                    bitmap.clear();
                    m.run(bitmap);
                    statusBar.setText("Ready.");
                    progBox.grabFocus();
                } catch (ParseException pe) {
                    System.out.println("Parse exception!");
                    pe.printStackTrace();
                    statusBar.setText(pe.asString());
                }
                canvas.repaint();
            } 
        });
        buttonRun.setToolTipText("Run the program entered above " +
                                 "and display the drawing on the canvas " +
                                 "to the right.");

        JPanel progPanel = new JPanel(new BorderLayout());
        progPanel.setMinimumSize(new Dimension(100, 50));
        progPanel.add(progBox, BorderLayout.CENTER);
        progPanel.add(buttonRun, BorderLayout.PAGE_END);

        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,
            progPanel, canvas);
        splitPane.setOneTouchExpandable(true);
        splitPane.setDividerLocation(150);

        statusBar = new JLabel("Ready.");

        this.setPreferredSize(new Dimension(640, 400));
        this.add(splitPane, BorderLayout.CENTER);
        this.add(statusBar, BorderLayout.PAGE_END);
        this.setOpaque(true);
    }
}
