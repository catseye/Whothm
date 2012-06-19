package tc.catseye.whothm;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.Dimension;

import javax.swing.JPanel;

public class Canvas extends JPanel {
    private BitMap bm;

    public Canvas(BitMap bm) {
        super();
        this.bm = bm;
    }

    public void resize() {
        int width = bm.getPixelWidth() * bm.getWidth();
        int height = bm.getPixelHeight() * bm.getHeight();
        Dimension area = new Dimension(width, height);
        setPreferredSize(area);
        revalidate();
        repaint();
    }

    protected void paintComponent(Graphics g) {
        super.paintComponent(g);

        g.setColor(Color.yellow);  
        Rectangle r = g.getClipBounds();
        g.fillRect(r.x, r.y, r.width, r.height);
        bm.render(g);
    }
}
